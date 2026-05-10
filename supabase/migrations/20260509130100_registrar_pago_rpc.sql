-- =====================================================================
-- RPC: registrar_pago_completo
--
-- Registra un pago, sus aplicaciones a facturas y reconecta el servicio
-- automaticamente si el cliente venia suspendido por mora y ya no le
-- quedan facturas pendientes. TODO en una sola transaccion atomica.
--
-- Reemplaza la logica multi-paso del cliente Dart en pago_repository.dart
-- (insert pago + insert pago_factura + update facturas), que era
-- vulnerable a estados parciales si fallaba a mitad.
--
-- Aplicar en SQL Editor de Supabase con rol service_role.
-- =====================================================================

create or replace function public.registrar_pago_completo(
  p_cliente_id    uuid,
  p_fecha         date,
  p_valor         integer,
  p_metodo        text,
  p_referencia    text,
  p_notas         text,
  p_aplicaciones  jsonb       -- [{"factura_id": "<uuid>", "monto": <int>}, ...]
)
returns uuid                  -- id del pago insertado
language plpgsql
security definer
set search_path = public
as $$
declare
  v_tenant_id            uuid;
  v_cliente_estado       text;
  v_pago_id              uuid;
  v_app                  jsonb;
  v_factura_id           uuid;
  v_monto                integer;
  v_total_factura        integer;
  v_aplicado_total       integer;
  v_pendientes_restantes integer;
  v_suma_aplicaciones    integer;
begin
  -- ---------------------------------------------------------------
  -- 1) Tenant del usuario autenticado
  -- ---------------------------------------------------------------
  v_tenant_id := public.auth_tenant_id();
  if v_tenant_id is null then
    raise exception 'usuario sin tenant asociado';
  end if;

  -- ---------------------------------------------------------------
  -- 2) Validar argumentos basicos
  -- ---------------------------------------------------------------
  if p_valor is null or p_valor <= 0 then
    raise exception 'valor del pago debe ser mayor que cero';
  end if;
  if p_metodo is null or p_metodo not in ('bancolombia', 'nequi', 'efectivo', 'otro') then
    raise exception 'metodo de pago invalido: %', p_metodo;
  end if;

  v_suma_aplicaciones := coalesce((
    select sum((a->>'monto')::integer)
      from jsonb_array_elements(coalesce(p_aplicaciones, '[]'::jsonb)) as a
  ), 0);
  if v_suma_aplicaciones > p_valor then
    raise exception 'aplicaciones suman %s mayor que valor del pago %s',
      v_suma_aplicaciones, p_valor;
  end if;

  -- ---------------------------------------------------------------
  -- 3) Validar que el cliente pertenece al tenant
  -- ---------------------------------------------------------------
  select estado into v_cliente_estado
    from public.clientes
    where id = p_cliente_id
      and tenant_id = v_tenant_id;
  if not found then
    raise exception 'cliente no encontrado o de otro tenant';
  end if;

  -- ---------------------------------------------------------------
  -- 4) Insert del pago
  -- ---------------------------------------------------------------
  insert into public.pagos
    (tenant_id, cliente_id, fecha, valor, metodo, referencia, notas)
    values
    (v_tenant_id, p_cliente_id, p_fecha, p_valor, p_metodo, p_referencia, p_notas)
    returning id into v_pago_id;

  -- ---------------------------------------------------------------
  -- 5) Aplicaciones a facturas (cada una validada y bloqueada)
  -- ---------------------------------------------------------------
  for v_app in
    select * from jsonb_array_elements(coalesce(p_aplicaciones, '[]'::jsonb))
  loop
    v_factura_id := (v_app->>'factura_id')::uuid;
    v_monto      := (v_app->>'monto')::integer;

    if v_monto is null or v_monto <= 0 then
      continue;
    end if;

    -- Lock de la factura para evitar race con otro pago concurrente
    -- sobre la misma factura.
    select total into v_total_factura
      from public.facturas
      where id = v_factura_id
        and tenant_id = v_tenant_id
        and cliente_id = p_cliente_id
        and estado <> 'anulada'
      for update;
    if not found then
      raise exception 'factura % invalida para este cliente o ya anulada', v_factura_id;
    end if;

    insert into public.pago_factura
      (tenant_id, pago_id, factura_id, monto_aplicado)
      values
      (v_tenant_id, v_pago_id, v_factura_id, v_monto);

    -- Suma total ya aplicada a esta factura (incluye la insercion previa)
    select coalesce(sum(monto_aplicado), 0) into v_aplicado_total
      from public.pago_factura
      where factura_id = v_factura_id;

    if v_aplicado_total >= v_total_factura then
      update public.facturas
        set estado = 'pagada'
        where id = v_factura_id;
    end if;
  end loop;

  -- ---------------------------------------------------------------
  -- 6) Reconexion automatica
  --    Si el cliente venia suspendido por mora y ya no quedan
  --    facturas pendientes, reactivar y registrar el evento.
  -- ---------------------------------------------------------------
  if v_cliente_estado = 'suspendido_mora' then
    select count(*) into v_pendientes_restantes
      from public.facturas
      where cliente_id = p_cliente_id
        and tenant_id = v_tenant_id
        and estado = 'pendiente';

    if v_pendientes_restantes = 0 then
      update public.clientes
        set estado = 'activo'
        where id = p_cliente_id;

      insert into public.eventos_servicio
        (tenant_id, cliente_id, tipo, estado_resultante, motivo)
      values
        (v_tenant_id, p_cliente_id, 'reconexion', 'activo',
         'Reconexion automatica tras pago completo de la deuda');
    end if;
  end if;

  return v_pago_id;
end;
$$;

grant execute on function public.registrar_pago_completo(
  uuid, date, integer, text, text, text, jsonb
) to authenticated;

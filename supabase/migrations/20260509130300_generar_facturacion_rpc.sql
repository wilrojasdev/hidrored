-- =====================================================================
-- RPC: generar_facturacion_masiva
--
-- Inserta de forma atomica un lote de facturas (calculadas previamente
-- en el cliente Dart) junto con sus lineas, asignando numero consecutivo
-- por tenant/anio.
--
-- Reemplaza el loop multi-paso de billing_service.ejecutarFacturacion,
-- que hacia 1 RPC + 1 INSERT factura + 1 INSERT lineas por cliente sin
-- envoltura transaccional. Riesgos eliminados:
--   - Race condition en `siguiente_numero_recibo` con multiples admins.
--   - Estados parciales (factura sin lineas) si fallaba a mitad.
--   - Doble emision si el admin presionaba "generar" dos veces (el
--     check anti-duplicado por (cliente_id, periodo) ahora ocurre dentro
--     de la misma transaccion).
--
-- El cliente sigue calculando el preview localmente (mora, total,
-- mensualidad) — esa logica esta testeada en `mora_calculator_test`.
-- El RPC solo persiste lo que recibe.
--
-- Aplicar en SQL Editor de Supabase con rol service_role.
-- =====================================================================

create or replace function public.generar_facturacion_masiva(
  p_periodo            text,
  p_fecha_emision      date,
  p_fecha_vencimiento  date,
  p_facturas           jsonb
)
returns integer       -- cantidad de facturas creadas (excluye duplicadas omitidas)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_tenant_id      uuid;
  v_anio           integer;
  v_prefijo        text;
  v_factura        jsonb;
  v_cliente_id     uuid;
  v_factura_id     uuid;
  v_ultimo_numero  integer;
  v_numero         text;
  v_creadas        integer := 0;
  v_existing       integer;
  v_linea          jsonb;
begin
  -- ---------------------------------------------------------------
  -- 1) Tenant + validaciones
  -- ---------------------------------------------------------------
  v_tenant_id := public.auth_tenant_id();
  if v_tenant_id is null then
    raise exception 'usuario sin tenant asociado';
  end if;

  if p_periodo is null or p_periodo !~ '^\d{4}-\d{2}$' then
    raise exception 'periodo invalido (esperado YYYY-MM): %', p_periodo;
  end if;
  if p_fecha_emision is null or p_fecha_vencimiento is null then
    raise exception 'fechas de emision y vencimiento son requeridas';
  end if;
  if p_fecha_vencimiento < p_fecha_emision then
    raise exception 'fecha_vencimiento (%) anterior a fecha_emision (%)',
      p_fecha_vencimiento, p_fecha_emision;
  end if;

  v_anio := extract(year from p_fecha_emision)::int;

  select prefijo_recibos into v_prefijo
    from public.tenants
    where id = v_tenant_id;
  if v_prefijo is null then
    raise exception 'tenant sin prefijo_recibos configurado';
  end if;

  -- ---------------------------------------------------------------
  -- 2) Loop de facturas
  -- ---------------------------------------------------------------
  for v_factura in
    select * from jsonb_array_elements(coalesce(p_facturas, '[]'::jsonb))
  loop
    v_cliente_id := (v_factura->>'cliente_id')::uuid;

    -- Validar que el cliente exista en este tenant
    if not exists (
      select 1 from public.clientes
        where id = v_cliente_id and tenant_id = v_tenant_id
    ) then
      raise exception 'cliente % no encontrado o de otro tenant', v_cliente_id;
    end if;

    -- Anti-duplicado: si ya hay factura no-anulada del mismo periodo,
    -- omitir silenciosamente (idempotencia: 2 clics no duplican).
    select count(*) into v_existing
      from public.facturas
      where tenant_id  = v_tenant_id
        and cliente_id = v_cliente_id
        and periodo    = p_periodo
        and estado    <> 'anulada';
    if v_existing > 0 then
      continue;
    end if;

    -- Numeracion atomica via UPSERT en recibo_secuencias.
    -- ON CONFLICT lockea la fila (tenant, anio) para evitar race.
    insert into public.recibo_secuencias (tenant_id, anio, ultimo_numero)
      values (v_tenant_id, v_anio, 1)
      on conflict (tenant_id, anio)
      do update set ultimo_numero = public.recibo_secuencias.ultimo_numero + 1
      returning ultimo_numero into v_ultimo_numero;
    v_numero := v_prefijo || '-' || v_anio || '-' ||
                lpad(v_ultimo_numero::text, 5, '0');

    -- Insert de la factura
    insert into public.facturas (
      tenant_id, cliente_id, numero, periodo, tipo,
      fecha_emision, fecha_vencimiento,
      valor_mensualidad, valor_mora, total, estado
    ) values (
      v_tenant_id,
      v_cliente_id,
      v_numero,
      p_periodo,
      coalesce(v_factura->>'tipo', 'mensual'),
      p_fecha_emision,
      p_fecha_vencimiento,
      coalesce((v_factura->>'valor_mensualidad')::int, 0),
      coalesce((v_factura->>'valor_mora')::int, 0),
      (v_factura->>'total')::int,
      'pendiente'
    )
    returning id into v_factura_id;

    -- Insert de lineas (mensualidad, mora, reconexion, conceptos extra)
    for v_linea in
      select * from jsonb_array_elements(coalesce(v_factura->'lineas', '[]'::jsonb))
    loop
      insert into public.factura_lineas (
        tenant_id, factura_id, concepto_id, descripcion,
        cantidad, valor_unitario, subtotal
      ) values (
        v_tenant_id,
        v_factura_id,
        nullif(v_linea->>'concepto_id', '')::uuid,
        v_linea->>'descripcion',
        coalesce((v_linea->>'cantidad')::int, 1),
        (v_linea->>'valor_unitario')::int,
        (v_linea->>'subtotal')::int
      );
    end loop;

    v_creadas := v_creadas + 1;
  end loop;

  return v_creadas;
end;
$$;

grant execute on function public.generar_facturacion_masiva(
  text, date, date, jsonb
) to authenticated;

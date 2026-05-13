-- =====================================================================
-- hidrored — Modelo "factura única viva por cliente" con refacturación
--
-- Cambio de modelo:
--   - Cada cliente tiene a lo sumo UNA factura `pendiente` a la vez
--     (la del último periodo emitido).
--   - Al emitir un periodo nuevo, las facturas `pendiente` anteriores
--     pasan a estado `refacturada` y su saldo no pagado (total - sum
--     pagos aplicados) se incorpora como una línea de la nueva factura,
--     con trazabilidad al `factura_origen_id`.
--   - La mora se sigue contando desde la fecha de vencimiento ORIGINAL
--     de la factura absorbida (la mora se acumula contra el cliente,
--     no contra la factura nueva).
--   - Si se anula la factura "absorbedora", las hijas vuelven a
--     `pendiente` y la nueva queda anulada.
--   - Pagos contra una factura `refacturada` quedan bloqueados (hay que
--     registrarlos contra la `pendiente` actual).
--
-- Decisiones (acordadas previamente con el usuario):
--   A) Estado nuevo: `refacturada`.
--   B) Pagos parciales: se mantienen en la factura origen (histórico).
--      Solo se traslada el SALDO no pagado.
--   C) Mora: días desde vencimiento ORIGINAL.
--   D) Líneas: una línea por cada factura absorbida.
--   F) Sin migración de datos (prod arranca limpio).
--
-- Aplicar en SQL Editor de Supabase con rol service_role.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1) Esquema: nuevo estado, FK refacturada_en_id y factura_origen_id
-- ---------------------------------------------------------------------
alter table public.facturas drop constraint if exists facturas_estado_check;
alter table public.facturas add constraint facturas_estado_check
  check (estado in ('pendiente', 'pagada', 'anulada', 'refacturada'));

alter table public.facturas
  add column if not exists refacturada_en_id uuid
    references public.facturas(id) on delete set null;

create index if not exists idx_facturas_refacturada_en
  on public.facturas(refacturada_en_id)
  where refacturada_en_id is not null;

alter table public.factura_lineas
  add column if not exists factura_origen_id uuid
    references public.facturas(id) on delete restrict;

create index if not exists idx_factura_lineas_origen
  on public.factura_lineas(factura_origen_id)
  where factura_origen_id is not null;

-- ---------------------------------------------------------------------
-- 2) RPC interno: _emitir_facturas_internal (reescrito)
--    Antes de insertar la nueva factura de un cliente, absorbe sus
--    facturas pendientes anteriores: las marca como `refacturada` y
--    agrega líneas a la nueva con el saldo neto.
-- ---------------------------------------------------------------------
create or replace function public._emitir_facturas_internal(
  p_tenant_id          uuid,
  p_periodo            text,
  p_fecha_emision      date,
  p_fecha_vencimiento  date,
  p_facturas           jsonb,
  p_omitir_duplicados  boolean
)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_anio              integer;
  v_prefijo           text;
  v_factura           jsonb;
  v_cliente_id        uuid;
  v_factura_id        uuid;
  v_ultimo_numero     integer;
  v_numero            text;
  v_creadas           integer := 0;
  v_existing          integer;
  v_linea             jsonb;
  v_cargo_id          uuid;
  v_cargo_aplicado_en uuid;
  v_subtotal_extra    integer;
  v_total_calc        integer;
  v_anterior          record;
  v_saldo             integer;
begin
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
    where id = p_tenant_id;
  if v_prefijo is null then
    raise exception 'tenant sin prefijo_recibos configurado';
  end if;

  for v_factura in
    select * from jsonb_array_elements(coalesce(p_facturas, '[]'::jsonb))
  loop
    v_cliente_id := (v_factura->>'cliente_id')::uuid;

    -- Cliente debe existir, ser del tenant y NO estar retirado.
    -- (Antes solo validaba existencia; ahora también estado.)
    perform 1
      from public.clientes
      where id = v_cliente_id
        and tenant_id = p_tenant_id
        and estado <> 'retirado';
    if not found then
      raise exception 'cliente % no encontrado, de otro tenant o retirado',
        v_cliente_id;
    end if;

    -- Anti-duplicado por (cliente, periodo) en estados vivos.
    -- "Vivo" = no anulada ni refacturada.
    select count(*) into v_existing
      from public.facturas
      where tenant_id  = p_tenant_id
        and cliente_id = v_cliente_id
        and periodo    = p_periodo
        and estado not in ('anulada', 'refacturada');
    if v_existing > 0 then
      if p_omitir_duplicados then
        continue;
      else
        raise exception 'ya existe una factura no-anulada del cliente % '
                        'para el periodo %. Anúlala antes de re-emitir.',
                        v_cliente_id, p_periodo;
      end if;
    end if;

    -- Número de la nueva factura (atómico).
    insert into public.recibo_secuencias (tenant_id, anio, ultimo_numero)
      values (p_tenant_id, v_anio, 1)
      on conflict (tenant_id, anio)
      do update set ultimo_numero = public.recibo_secuencias.ultimo_numero + 1
      returning ultimo_numero into v_ultimo_numero;
    v_numero := v_prefijo || '-' || v_anio || '-' ||
                lpad(v_ultimo_numero::text, 5, '0');

    -- Total preliminar = lo que viene del cliente. Se recalculará al
    -- final sumando las líneas refacturadas para que `total` quede
    -- consistente con la suma real de líneas.
    v_total_calc := coalesce((v_factura->>'total')::int, 0);

    insert into public.facturas (
      tenant_id, cliente_id, numero, periodo, tipo,
      fecha_emision, fecha_vencimiento,
      valor_mensualidad, valor_mora, total, estado
    ) values (
      p_tenant_id,
      v_cliente_id,
      v_numero,
      p_periodo,
      coalesce(v_factura->>'tipo', 'mensual'),
      p_fecha_emision,
      p_fecha_vencimiento,
      coalesce((v_factura->>'valor_mensualidad')::int, 0),
      coalesce((v_factura->>'valor_mora')::int, 0),
      v_total_calc,
      'pendiente'
    )
    returning id into v_factura_id;

    -- ------ Líneas "nativas" del periodo (mensualidad, mora, extras)
    for v_linea in
      select * from jsonb_array_elements(coalesce(v_factura->'lineas', '[]'::jsonb))
    loop
      insert into public.factura_lineas (
        tenant_id, factura_id, concepto_id, descripcion,
        cantidad, valor_unitario, subtotal,
        factura_origen_id
      ) values (
        p_tenant_id,
        v_factura_id,
        nullif(v_linea->>'concepto_id', '')::uuid,
        v_linea->>'descripcion',
        coalesce((v_linea->>'cantidad')::int, 1),
        (v_linea->>'valor_unitario')::int,
        (v_linea->>'subtotal')::int,
        null  -- nativa
      );

      -- Si la línea proviene de un cargo pendiente: bloquear y validar
      -- atómicamente. Si ya estaba aplicado, abortar la transacción
      -- (evita doble cobro si dos equipos emiten en paralelo).
      v_cargo_id := nullif(v_linea->>'cargo_pendiente_id', '')::uuid;
      if v_cargo_id is not null then
        select aplicado_factura_id into v_cargo_aplicado_en
          from public.cargos_pendientes
          where id = v_cargo_id and tenant_id = p_tenant_id
          for update;
        if not found then
          raise exception 'cargo pendiente % no existe en este tenant',
            v_cargo_id;
        end if;
        if v_cargo_aplicado_en is not null then
          raise exception 'el cargo % ya fue aplicado a la factura %; '
                          'recarga el preview antes de emitir.',
                          v_cargo_id, v_cargo_aplicado_en;
        end if;
        update public.cargos_pendientes
          set aplicado_factura_id = v_factura_id,
              aplicado_at = now()
          where id = v_cargo_id;
      end if;
    end loop;

    -- ------ Refacturación: absorber facturas pendientes anteriores
    -- Tomamos todas las pendientes ANTERIORES (periodo lex < p_periodo)
    -- de este cliente. Las bloqueamos para evitar carrera con un pago
    -- concurrente.
    for v_anterior in
      select id, numero, periodo, total, fecha_vencimiento
        from public.facturas
        where tenant_id  = p_tenant_id
          and cliente_id = v_cliente_id
          and estado     = 'pendiente'
          and periodo    < p_periodo
          and id        <> v_factura_id
        order by fecha_emision
        for update
    loop
      -- Saldo neto = total - suma de pagos aplicados
      select coalesce(sum(monto_aplicado), 0)
        into v_saldo
        from public.pago_factura
        where factura_id = v_anterior.id;
      v_saldo := v_anterior.total - v_saldo;

      if v_saldo <= 0 then
        -- Estaba completamente pagada pero sin marcar (caso raro).
        -- La marcamos pagada y no le agregamos línea a la nueva.
        update public.facturas
          set estado = 'pagada'
          where id = v_anterior.id;
        continue;
      end if;

      -- Marcar la vieja como refacturada apuntando a la nueva.
      update public.facturas
        set estado = 'refacturada',
            refacturada_en_id = v_factura_id
        where id = v_anterior.id;

      -- Agregar línea a la nueva con el saldo no pagado.
      insert into public.factura_lineas (
        tenant_id, factura_id, descripcion,
        cantidad, valor_unitario, subtotal,
        factura_origen_id
      ) values (
        p_tenant_id,
        v_factura_id,
        'Saldo pendiente ' || v_anterior.numero ||
          ' (' || v_anterior.periodo || ')',
        1,
        v_saldo,
        v_saldo,
        v_anterior.id
      );
    end loop;

    -- Recalcular el total de la nueva factura como la suma real de sus
    -- líneas (nativas + refacturadas). Esto evita inconsistencias si el
    -- cliente Dart no incluyó saldos refacturados en su `total`.
    select coalesce(sum(subtotal), 0) into v_subtotal_extra
      from public.factura_lineas
      where factura_id = v_factura_id;

    update public.facturas
      set total = v_subtotal_extra
      where id = v_factura_id;

    v_creadas := v_creadas + 1;
  end loop;

  return v_creadas;
end;
$$;

-- ---------------------------------------------------------------------
-- 3) RPC público: anular_factura (reescrito)
--    Si la factura anulada había absorbido a otras (refacturadas a esta),
--    revivir esas hijas: vuelven a `pendiente` con refacturada_en_id =
--    null. La factura padre queda `anulada`. También revierte cargos
--    pendientes aplicados a ella (comportamiento previo).
-- ---------------------------------------------------------------------
create or replace function public.anular_factura(
  p_factura_id  uuid,
  p_motivo      text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_tenant_id uuid;
  v_estado    text;
begin
  v_tenant_id := public.auth_tenant_id();
  if v_tenant_id is null then
    raise exception 'usuario sin tenant asociado';
  end if;
  if p_motivo is null or btrim(p_motivo) = '' then
    raise exception 'motivo de anulación requerido';
  end if;

  select estado into v_estado
    from public.facturas
    where id = p_factura_id and tenant_id = v_tenant_id
    for update;
  if v_estado is null then
    raise exception 'factura % no encontrada en este tenant', p_factura_id;
  end if;
  if v_estado = 'pagada' then
    raise exception 'no se puede anular una factura ya pagada';
  end if;
  if v_estado = 'anulada' then
    raise exception 'la factura ya está anulada';
  end if;
  if v_estado = 'refacturada' then
    raise exception 'esta factura ya fue refacturada en otra. Anula la '
                    'factura que la absorbió y se revertirá el proceso.';
  end if;

  -- Anular la factura padre.
  update public.facturas
    set estado = 'anulada',
        motivo_anulacion = p_motivo
    where id = p_factura_id and tenant_id = v_tenant_id;

  -- Resucitar facturas hijas (que esta factura había refacturado).
  update public.facturas
    set estado = 'pendiente',
        refacturada_en_id = null
    where refacturada_en_id = p_factura_id
      and tenant_id = v_tenant_id;

  -- Revertir cargos pendientes que se habían aplicado a esta factura.
  update public.cargos_pendientes
    set aplicado_factura_id = null,
        aplicado_at = null
    where aplicado_factura_id = p_factura_id
      and tenant_id = v_tenant_id;
end;
$$;

grant execute on function public.anular_factura(uuid, text) to authenticated;

-- ---------------------------------------------------------------------
-- 4) RPC público: registrar_pago_completo (ajuste)
--    Bloquea pagos contra facturas con estado `refacturada`. El bloqueo
--    sucede al hacer el `select ... for update`: si la factura no está
--    pendiente (esto incluye anulada Y refacturada), el match falla.
--    Mejoramos el mensaje de error para distinguir el caso refacturada.
-- ---------------------------------------------------------------------
create or replace function public.registrar_pago_completo(
  p_cliente_id    uuid,
  p_fecha         date,
  p_valor         integer,
  p_metodo        text,
  p_referencia    text,
  p_notas         text,
  p_aplicaciones  jsonb
)
returns uuid
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
  v_estado_factura       text;
  v_refacturada_en       uuid;
  v_aplicado_total       integer;
  v_pendientes_restantes integer;
  v_suma_aplicaciones    integer;
begin
  v_tenant_id := public.auth_tenant_id();
  if v_tenant_id is null then
    raise exception 'usuario sin tenant asociado';
  end if;

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

  if v_suma_aplicaciones <= 0 then
    raise exception 'no se puede registrar un pago sin aplicarlo a una factura. '
                    'genera primero la factura del cliente.';
  end if;

  if v_suma_aplicaciones > p_valor then
    raise exception 'aplicaciones suman %s mayor que valor del pago %s',
      v_suma_aplicaciones, p_valor;
  end if;

  select estado into v_cliente_estado
    from public.clientes
    where id = p_cliente_id
      and tenant_id = v_tenant_id;
  if not found then
    raise exception 'cliente no encontrado o de otro tenant';
  end if;

  insert into public.pagos
    (tenant_id, cliente_id, fecha, valor, metodo, referencia, notas)
    values
    (v_tenant_id, p_cliente_id, p_fecha, p_valor, p_metodo, p_referencia, p_notas)
    returning id into v_pago_id;

  for v_app in
    select * from jsonb_array_elements(coalesce(p_aplicaciones, '[]'::jsonb))
  loop
    v_factura_id := (v_app->>'factura_id')::uuid;
    v_monto      := (v_app->>'monto')::integer;

    if v_monto is null or v_monto <= 0 then
      continue;
    end if;

    -- Carga + lock para detectar el estado real (incluye refacturada).
    select total, estado, refacturada_en_id
      into v_total_factura, v_estado_factura, v_refacturada_en
      from public.facturas
      where id = v_factura_id
        and tenant_id = v_tenant_id
        and cliente_id = p_cliente_id
      for update;
    if not found then
      raise exception 'factura % invalida para este cliente', v_factura_id;
    end if;
    if v_estado_factura = 'anulada' then
      raise exception 'factura % está anulada', v_factura_id;
    end if;
    if v_estado_factura = 'refacturada' then
      raise exception 'factura % fue refacturada en %; '
                      'registra el pago contra la factura nueva.',
                      v_factura_id, v_refacturada_en;
    end if;
    if v_estado_factura = 'pagada' then
      raise exception 'factura % ya está pagada', v_factura_id;
    end if;

    insert into public.pago_factura
      (tenant_id, pago_id, factura_id, monto_aplicado)
      values
      (v_tenant_id, v_pago_id, v_factura_id, v_monto);

    select coalesce(sum(monto_aplicado), 0) into v_aplicado_total
      from public.pago_factura
      where factura_id = v_factura_id;

    if v_aplicado_total >= v_total_factura then
      update public.facturas
        set estado = 'pagada'
        where id = v_factura_id;
    end if;
  end loop;

  -- Reconexión automática (igual que antes).
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

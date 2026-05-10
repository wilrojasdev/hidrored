-- =====================================================================
-- hidrored — Cargos pendientes + facturación individual
--
-- Habilita 2 huecos del MVP:
--   1) Cargos extra (conceptos del catálogo) que el admin asigna a un
--      cliente y se incluyen automáticamente como líneas en su próximo
--      recibo emitido.
--   2) Generación de factura para UN solo cliente (alta posterior a la
--      facturación masiva, re-emisión tras anulación, ajustes puntuales).
--
-- Reglas:
--   - Un cargo pendiente queda "en cola" hasta que se emite la siguiente
--     factura mensual / individual del cliente; ahí se aplica y queda
--     vinculado a esa factura. No se puede asignar a un mes específico.
--   - Si se anula la factura, los cargos vuelven a estar pendientes para
--     que aparezcan en la re-emisión.
--   - Los cargos aplicados no se pueden borrar (preserva historial).
-- =====================================================================

-- ---------------------------------------------------------------------
-- Tabla cargos_pendientes
-- ---------------------------------------------------------------------
create table public.cargos_pendientes (
  id                    uuid primary key default gen_random_uuid(),
  tenant_id             uuid not null references public.tenants(id) on delete cascade,
  cliente_id            uuid not null references public.clientes(id) on delete cascade,
  concepto_id           uuid references public.conceptos(id) on delete set null,
  descripcion           text not null,
  cantidad              integer not null default 1 check (cantidad > 0),
  valor_unitario        integer not null check (valor_unitario >= 0),
  notas                 text,
  -- Cuando aplicado_factura_id IS NOT NULL, este cargo ya entró en una
  -- factura emitida. Al anularse esa factura el campo se vuelve NULL.
  aplicado_factura_id   uuid references public.facturas(id) on delete set null,
  aplicado_at           timestamptz,
  created_at            timestamptz not null default now(),
  created_by            uuid references auth.users(id) on delete set null,
  updated_at            timestamptz not null default now()
);

create index idx_cargos_pendientes_cliente_pendientes
  on public.cargos_pendientes(cliente_id)
  where aplicado_factura_id is null;
create index idx_cargos_pendientes_factura
  on public.cargos_pendientes(aplicado_factura_id);
create index idx_cargos_pendientes_tenant
  on public.cargos_pendientes(tenant_id);

create trigger trg_cargos_pendientes_updated_at
  before update on public.cargos_pendientes
  for each row execute function public.set_updated_at();

-- RLS
alter table public.cargos_pendientes enable row level security;

create policy cargos_pendientes_select on public.cargos_pendientes
  for select using (tenant_id = public.auth_tenant_id());
create policy cargos_pendientes_insert on public.cargos_pendientes
  for insert with check (tenant_id = public.auth_tenant_id());
create policy cargos_pendientes_update on public.cargos_pendientes
  for update using (tenant_id = public.auth_tenant_id())
              with check (tenant_id = public.auth_tenant_id());
create policy cargos_pendientes_delete on public.cargos_pendientes
  for delete using (
    tenant_id = public.auth_tenant_id()
    and aplicado_factura_id is null  -- solo borrables si NO se han aplicado
  );

-- ---------------------------------------------------------------------
-- RPC: emitir_facturas (loop interno reutilizable)
--
-- Reemplaza al antiguo `generar_facturacion_masiva`. Recibe un payload
-- de facturas y las inserta atómicamente. La diferencia con la versión
-- anterior es que también marca como aplicados los cargos pendientes
-- referenciados en cada línea (campo cargo_pendiente_id) y deja al
-- llamador decidir si los duplicados se omiten silenciosamente (modo
-- masivo) o si fallan (modo individual: el usuario debe ver el error).
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
  v_cargo_id       uuid;
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

    if not exists (
      select 1 from public.clientes
        where id = v_cliente_id and tenant_id = p_tenant_id
    ) then
      raise exception 'cliente % no encontrado o de otro tenant', v_cliente_id;
    end if;

    select count(*) into v_existing
      from public.facturas
      where tenant_id  = p_tenant_id
        and cliente_id = v_cliente_id
        and periodo    = p_periodo
        and estado    <> 'anulada';
    if v_existing > 0 then
      if p_omitir_duplicados then
        continue;
      else
        raise exception 'ya existe una factura no-anulada del cliente % '
                        'para el periodo %. Anúlala antes de re-emitir.',
                        v_cliente_id, p_periodo;
      end if;
    end if;

    insert into public.recibo_secuencias (tenant_id, anio, ultimo_numero)
      values (p_tenant_id, v_anio, 1)
      on conflict (tenant_id, anio)
      do update set ultimo_numero = public.recibo_secuencias.ultimo_numero + 1
      returning ultimo_numero into v_ultimo_numero;
    v_numero := v_prefijo || '-' || v_anio || '-' ||
                lpad(v_ultimo_numero::text, 5, '0');

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
      (v_factura->>'total')::int,
      'pendiente'
    )
    returning id into v_factura_id;

    for v_linea in
      select * from jsonb_array_elements(coalesce(v_factura->'lineas', '[]'::jsonb))
    loop
      insert into public.factura_lineas (
        tenant_id, factura_id, concepto_id, descripcion,
        cantidad, valor_unitario, subtotal
      ) values (
        p_tenant_id,
        v_factura_id,
        nullif(v_linea->>'concepto_id', '')::uuid,
        v_linea->>'descripcion',
        coalesce((v_linea->>'cantidad')::int, 1),
        (v_linea->>'valor_unitario')::int,
        (v_linea->>'subtotal')::int
      );

      -- Si la línea proviene de un cargo pendiente, marcarlo aplicado.
      v_cargo_id := nullif(v_linea->>'cargo_pendiente_id', '')::uuid;
      if v_cargo_id is not null then
        update public.cargos_pendientes
          set aplicado_factura_id = v_factura_id,
              aplicado_at = now()
          where id = v_cargo_id
            and tenant_id = p_tenant_id
            and aplicado_factura_id is null;
      end if;
    end loop;

    v_creadas := v_creadas + 1;
  end loop;

  return v_creadas;
end;
$$;

-- ---------------------------------------------------------------------
-- RPC público: generar_facturacion_masiva (mantiene firma anterior)
-- Reemplaza la implementación pero conserva la API pública.
-- ---------------------------------------------------------------------
create or replace function public.generar_facturacion_masiva(
  p_periodo            text,
  p_fecha_emision      date,
  p_fecha_vencimiento  date,
  p_facturas           jsonb
)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_tenant_id uuid;
begin
  v_tenant_id := public.auth_tenant_id();
  if v_tenant_id is null then
    raise exception 'usuario sin tenant asociado';
  end if;
  return public._emitir_facturas_internal(
    v_tenant_id, p_periodo, p_fecha_emision, p_fecha_vencimiento,
    p_facturas, true  -- modo masivo: omitir duplicados silenciosamente
  );
end;
$$;

grant execute on function public.generar_facturacion_masiva(
  text, date, date, jsonb
) to authenticated;

-- ---------------------------------------------------------------------
-- RPC público: generar_factura_individual
-- Emite UNA factura para un cliente específico. Falla si ya existe
-- factura no-anulada del mismo periodo (a diferencia del masivo, aquí
-- el admin verá el error explícito).
-- ---------------------------------------------------------------------
create or replace function public.generar_factura_individual(
  p_periodo            text,
  p_fecha_emision      date,
  p_fecha_vencimiento  date,
  p_factura            jsonb
)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_tenant_id uuid;
begin
  v_tenant_id := public.auth_tenant_id();
  if v_tenant_id is null then
    raise exception 'usuario sin tenant asociado';
  end if;
  if p_factura is null then
    raise exception 'p_factura no puede ser null';
  end if;
  return public._emitir_facturas_internal(
    v_tenant_id, p_periodo, p_fecha_emision, p_fecha_vencimiento,
    jsonb_build_array(p_factura), false  -- individual: no omitir, fallar
  );
end;
$$;

grant execute on function public.generar_factura_individual(
  text, date, date, jsonb
) to authenticated;

-- ---------------------------------------------------------------------
-- RPC público: anular_factura
-- Anula la factura y revierte los cargos pendientes que aplicó (los
-- vuelve a marcar como no-aplicados para que reaparezcan en la
-- re-emisión).
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
  v_tenant_id  uuid;
  v_estado     text;
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

  update public.facturas
    set estado = 'anulada',
        motivo_anulacion = p_motivo
    where id = p_factura_id and tenant_id = v_tenant_id;

  -- Revertir cargos pendientes que se habían aplicado a esta factura.
  update public.cargos_pendientes
    set aplicado_factura_id = null,
        aplicado_at = null
    where aplicado_factura_id = p_factura_id
      and tenant_id = v_tenant_id;
end;
$$;

grant execute on function public.anular_factura(uuid, text) to authenticated;

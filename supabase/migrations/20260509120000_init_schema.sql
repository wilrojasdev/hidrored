-- =====================================================================
-- hidrored — Schema inicial
-- Multi-tenant con aislamiento por RLS. IDs UUID para soportar offline-first.
-- Valores monetarios en INTEGER (pesos colombianos sin decimales).
-- =====================================================================

-- ---------------------------------------------------------------------
-- TENANTS  (cada acueducto veredal cliente del SaaS)
-- ---------------------------------------------------------------------
create table public.tenants (
  id                    uuid primary key default gen_random_uuid(),
  nombre                text not null,
  nit                   text,
  representante_legal   text,
  prefijo_recibos       text not null default 'AC',
  cuenta_bancolombia    text,
  cuenta_nequi          text,
  tarifa_mora_diaria    integer not null default 300   check (tarifa_mora_diaria >= 0),
  costo_reconexion      integer not null default 0     check (costo_reconexion   >= 0),
  tarifa_basica         integer not null default 18000 check (tarifa_basica      >= 0),
  tarifa_extendida      integer not null default 36000 check (tarifa_extendida   >= 0),
  dias_habiles_pago     integer not null default 5     check (dias_habiles_pago  >  0),
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- PROFILES  (admins; 1 por tenant en MVP, vinculado a auth.users)
-- ---------------------------------------------------------------------
create table public.profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  tenant_id   uuid not null references public.tenants(id) on delete restrict,
  nombre      text not null,
  email       text not null,
  rol         text not null default 'admin' check (rol in ('admin', 'super_admin')),
  created_at  timestamptz not null default now()
);

create index idx_profiles_tenant on public.profiles(tenant_id);

-- ---------------------------------------------------------------------
-- CLIENTES  (los ~300 usuarios del acueducto)
-- ---------------------------------------------------------------------
create table public.clientes (
  id                uuid primary key default gen_random_uuid(),
  tenant_id         uuid not null references public.tenants(id) on delete cascade,
  codigo            integer not null,
  cedula            text not null,
  nombre            text not null,
  direccion         text,
  telefono          text,
  sector            text,
  zona              text,
  barrio            text,
  tarifa_mensual    integer not null check (tarifa_mensual >= 0),
  estado            text not null default 'activo' check (estado in (
                      'activo', 'suspendido_mora', 'suspendido_voluntario',
                      'dano_reportado', 'en_reparacion', 'retirado'
                    )),
  fecha_ingreso     date not null default current_date,
  fecha_retiro      date,
  deuda_inicial     integer not null default 0 check (deuda_inicial >= 0),
  notas             text,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  unique (tenant_id, codigo)
);

create index idx_clientes_tenant       on public.clientes(tenant_id);
create index idx_clientes_estado       on public.clientes(tenant_id, estado);
create index idx_clientes_cedula       on public.clientes(tenant_id, cedula);

-- ---------------------------------------------------------------------
-- CONCEPTOS  (catalogo de cargos extra: reconexion, mejoras, etc.)
-- ---------------------------------------------------------------------
create table public.conceptos (
  id              uuid primary key default gen_random_uuid(),
  tenant_id       uuid not null references public.tenants(id) on delete cascade,
  nombre          text not null,
  valor_default   integer not null default 0 check (valor_default >= 0),
  descripcion     text,
  activo          boolean not null default true,
  created_at      timestamptz not null default now()
);

create index idx_conceptos_tenant on public.conceptos(tenant_id);

-- ---------------------------------------------------------------------
-- FACTURAS
-- ---------------------------------------------------------------------
create table public.facturas (
  id                  uuid primary key default gen_random_uuid(),
  tenant_id           uuid not null references public.tenants(id) on delete cascade,
  cliente_id       uuid not null references public.clientes(id) on delete restrict,
  numero              text not null,
  periodo             text not null,
  tipo                text not null default 'mensual' check (tipo in (
                        'mensual', 'recordatorio_suspension'
                      )),
  fecha_emision       date not null,
  fecha_vencimiento   date not null,
  valor_mensualidad   integer not null default 0 check (valor_mensualidad >= 0),
  valor_mora          integer not null default 0 check (valor_mora        >= 0),
  total               integer not null           check (total             >= 0),
  estado              text not null default 'pendiente' check (estado in (
                        'pendiente', 'pagada', 'anulada'
                      )),
  motivo_anulacion    text,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now(),
  unique (tenant_id, numero)
);

create index idx_facturas_tenant_estado on public.facturas(tenant_id, estado);
create index idx_facturas_cliente    on public.facturas(cliente_id, estado);
create index idx_facturas_periodo       on public.facturas(tenant_id, periodo);

-- ---------------------------------------------------------------------
-- FACTURA_LINEAS  (conceptos extra dentro de una factura)
-- ---------------------------------------------------------------------
create table public.factura_lineas (
  id              uuid primary key default gen_random_uuid(),
  tenant_id       uuid not null references public.tenants(id) on delete cascade,
  factura_id      uuid not null references public.facturas(id) on delete cascade,
  concepto_id     uuid references public.conceptos(id) on delete restrict,
  descripcion     text not null,
  cantidad        integer not null default 1 check (cantidad       >  0),
  valor_unitario  integer not null           check (valor_unitario >= 0),
  subtotal        integer not null           check (subtotal       >= 0),
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

create index idx_factura_lineas_factura on public.factura_lineas(factura_id);
create index idx_factura_lineas_tenant  on public.factura_lineas(tenant_id);

-- ---------------------------------------------------------------------
-- PAGOS
-- ---------------------------------------------------------------------
create table public.pagos (
  id              uuid primary key default gen_random_uuid(),
  tenant_id       uuid not null references public.tenants(id) on delete cascade,
  cliente_id   uuid not null references public.clientes(id) on delete restrict,
  fecha           date not null default current_date,
  valor           integer not null check (valor > 0),
  metodo          text not null check (metodo in (
                    'bancolombia', 'nequi', 'efectivo', 'otro'
                  )),
  referencia      text,
  notas           text,
  created_at      timestamptz not null default now()
);

create index idx_pagos_tenant       on public.pagos(tenant_id);
create index idx_pagos_cliente   on public.pagos(cliente_id);
create index idx_pagos_fecha        on public.pagos(tenant_id, fecha desc);

-- ---------------------------------------------------------------------
-- PAGO_FACTURA  (n:n; un pago salda 1+ facturas)
-- ---------------------------------------------------------------------
create table public.pago_factura (
  id              uuid primary key default gen_random_uuid(),
  tenant_id       uuid not null references public.tenants(id) on delete cascade,
  pago_id         uuid not null references public.pagos(id) on delete cascade,
  factura_id      uuid not null references public.facturas(id) on delete restrict,
  monto_aplicado  integer not null check (monto_aplicado > 0),
  created_at      timestamptz not null default now(),
  unique (pago_id, factura_id)
);

create index idx_pago_factura_pago     on public.pago_factura(pago_id);
create index idx_pago_factura_factura  on public.pago_factura(factura_id);

-- ---------------------------------------------------------------------
-- EVENTOS_SERVICIO  (bitacora de cambios de estado)
-- ---------------------------------------------------------------------
create table public.eventos_servicio (
  id                  uuid primary key default gen_random_uuid(),
  tenant_id           uuid not null references public.tenants(id) on delete cascade,
  cliente_id       uuid not null references public.clientes(id) on delete restrict,
  fecha               timestamptz not null default now(),
  tipo                text not null check (tipo in (
                        'activacion', 'suspension', 'reconexion',
                        'reporte_dano', 'inicio_reparacion', 'fin_reparacion',
                        'retiro', 'cambio_estado'
                      )),
  estado_resultante   text,
  motivo              text,
  costo               integer,
  created_at          timestamptz not null default now()
);

create index idx_eventos_cliente    on public.eventos_servicio(cliente_id);
create index idx_eventos_tenant_fecha  on public.eventos_servicio(tenant_id, fecha desc);

-- ---------------------------------------------------------------------
-- DANOS  (registro detallado de averias por cliente)
-- ---------------------------------------------------------------------
create table public.danos (
  id              uuid primary key default gen_random_uuid(),
  tenant_id       uuid not null references public.tenants(id) on delete cascade,
  cliente_id   uuid not null references public.clientes(id) on delete restrict,
  fecha_reporte   date not null default current_date,
  fecha_solucion  date,
  descripcion     text not null,
  costo           integer not null default 0 check (costo >= 0),
  reportado_por   text,
  estado          text not null default 'reportado' check (estado in (
                    'reportado', 'en_reparacion', 'solucionado'
                  )),
  notas           text,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

create index idx_danos_cliente      on public.danos(cliente_id);
create index idx_danos_tenant_estado   on public.danos(tenant_id, estado);

-- ---------------------------------------------------------------------
-- RECIBO_SECUENCIAS  (numeracion atomica server-side por tenant/anio)
-- NO sincronizar a clientes — es server-authoritative.
-- ---------------------------------------------------------------------
create table public.recibo_secuencias (
  tenant_id       uuid not null references public.tenants(id) on delete cascade,
  anio            integer not null,
  ultimo_numero   integer not null default 0,
  primary key (tenant_id, anio)
);

-- =====================================================================
-- FUNCIONES
-- =====================================================================

-- tenant_id del usuario autenticado actualmente.
create or replace function public.auth_tenant_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select tenant_id from public.profiles where id = auth.uid();
$$;

-- Genera el siguiente numero de recibo de forma atomica.
-- Llamar via Supabase rpc('siguiente_numero_recibo', ...)
create or replace function public.siguiente_numero_recibo(
  p_tenant_id uuid,
  p_anio      integer
)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  v_prefijo text;
  v_ultimo  integer;
begin
  -- Validar acceso al tenant
  if p_tenant_id <> public.auth_tenant_id() then
    raise exception 'no autorizado para este tenant';
  end if;

  select prefijo_recibos into v_prefijo
    from public.tenants
    where id = p_tenant_id;

  insert into public.recibo_secuencias (tenant_id, anio, ultimo_numero)
    values (p_tenant_id, p_anio, 1)
    on conflict (tenant_id, anio)
    do update set ultimo_numero = public.recibo_secuencias.ultimo_numero + 1
    returning ultimo_numero into v_ultimo;

  return v_prefijo || '-' || p_anio || '-' || lpad(v_ultimo::text, 5, '0');
end;
$$;

-- Trigger generico para mantener updated_at
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

create trigger trg_tenants_updated_at
  before update on public.tenants
  for each row execute function public.set_updated_at();

create trigger trg_clientes_updated_at
  before update on public.clientes
  for each row execute function public.set_updated_at();

create trigger trg_facturas_updated_at
  before update on public.facturas
  for each row execute function public.set_updated_at();

create trigger trg_factura_lineas_updated_at
  before update on public.factura_lineas
  for each row execute function public.set_updated_at();

create trigger trg_danos_updated_at
  before update on public.danos
  for each row execute function public.set_updated_at();

-- =====================================================================
-- ROW LEVEL SECURITY  (aislamiento estricto por tenant)
-- =====================================================================

alter table public.tenants            enable row level security;
alter table public.profiles           enable row level security;
alter table public.clientes       enable row level security;
alter table public.conceptos          enable row level security;
alter table public.facturas           enable row level security;
alter table public.factura_lineas     enable row level security;
alter table public.pagos              enable row level security;
alter table public.pago_factura       enable row level security;
alter table public.eventos_servicio   enable row level security;
alter table public.danos              enable row level security;
alter table public.recibo_secuencias  enable row level security;

-- Policies separadas por verbo (select/insert/update/delete) para evitar
-- que un cliente inserte/actualice filas con tenant_id ajeno escribiendo
-- el campo a mano. WITH CHECK valida el tenant_id resultante.

-- tenants: el admin solo lee y actualiza SU tenant. INSERT/DELETE
-- requieren service_role (no expuesto al cliente).
create policy tenants_select on public.tenants
  for select using (id = public.auth_tenant_id());
create policy tenants_update on public.tenants
  for update using (id = public.auth_tenant_id())
              with check (id = public.auth_tenant_id());

-- profiles: solo lectura del propio tenant. Crear/editar perfiles
-- requiere service_role (onboarding manual hasta tener super-admin).
create policy profiles_select on public.profiles
  for select using (tenant_id = public.auth_tenant_id());

-- recibo_secuencias: server-authoritative. Sin policies = sin acceso
-- desde el cliente. Las RPCs `siguiente_numero_recibo` y
-- `registrar_pago_completo` son security definer y bypassean RLS.

-- clientes
create policy clientes_select on public.clientes
  for select using (tenant_id = public.auth_tenant_id());
create policy clientes_insert on public.clientes
  for insert with check (tenant_id = public.auth_tenant_id());
create policy clientes_update on public.clientes
  for update using (tenant_id = public.auth_tenant_id())
              with check (tenant_id = public.auth_tenant_id());
create policy clientes_delete on public.clientes
  for delete using (tenant_id = public.auth_tenant_id());

-- conceptos
create policy conceptos_select on public.conceptos
  for select using (tenant_id = public.auth_tenant_id());
create policy conceptos_insert on public.conceptos
  for insert with check (tenant_id = public.auth_tenant_id());
create policy conceptos_update on public.conceptos
  for update using (tenant_id = public.auth_tenant_id())
              with check (tenant_id = public.auth_tenant_id());
create policy conceptos_delete on public.conceptos
  for delete using (tenant_id = public.auth_tenant_id());

-- facturas
create policy facturas_select on public.facturas
  for select using (tenant_id = public.auth_tenant_id());
create policy facturas_insert on public.facturas
  for insert with check (tenant_id = public.auth_tenant_id());
create policy facturas_update on public.facturas
  for update using (tenant_id = public.auth_tenant_id())
              with check (tenant_id = public.auth_tenant_id());
create policy facturas_delete on public.facturas
  for delete using (tenant_id = public.auth_tenant_id());

-- factura_lineas
create policy factura_lineas_select on public.factura_lineas
  for select using (tenant_id = public.auth_tenant_id());
create policy factura_lineas_insert on public.factura_lineas
  for insert with check (tenant_id = public.auth_tenant_id());
create policy factura_lineas_update on public.factura_lineas
  for update using (tenant_id = public.auth_tenant_id())
              with check (tenant_id = public.auth_tenant_id());
create policy factura_lineas_delete on public.factura_lineas
  for delete using (tenant_id = public.auth_tenant_id());

-- pagos
create policy pagos_select on public.pagos
  for select using (tenant_id = public.auth_tenant_id());
create policy pagos_insert on public.pagos
  for insert with check (tenant_id = public.auth_tenant_id());
create policy pagos_update on public.pagos
  for update using (tenant_id = public.auth_tenant_id())
              with check (tenant_id = public.auth_tenant_id());
create policy pagos_delete on public.pagos
  for delete using (tenant_id = public.auth_tenant_id());

-- pago_factura
create policy pago_factura_select on public.pago_factura
  for select using (tenant_id = public.auth_tenant_id());
create policy pago_factura_insert on public.pago_factura
  for insert with check (tenant_id = public.auth_tenant_id());
create policy pago_factura_update on public.pago_factura
  for update using (tenant_id = public.auth_tenant_id())
              with check (tenant_id = public.auth_tenant_id());
create policy pago_factura_delete on public.pago_factura
  for delete using (tenant_id = public.auth_tenant_id());

-- eventos_servicio
create policy eventos_servicio_select on public.eventos_servicio
  for select using (tenant_id = public.auth_tenant_id());
create policy eventos_servicio_insert on public.eventos_servicio
  for insert with check (tenant_id = public.auth_tenant_id());
create policy eventos_servicio_update on public.eventos_servicio
  for update using (tenant_id = public.auth_tenant_id())
              with check (tenant_id = public.auth_tenant_id());
create policy eventos_servicio_delete on public.eventos_servicio
  for delete using (tenant_id = public.auth_tenant_id());

-- danos
create policy danos_select on public.danos
  for select using (tenant_id = public.auth_tenant_id());
create policy danos_insert on public.danos
  for insert with check (tenant_id = public.auth_tenant_id());
create policy danos_update on public.danos
  for update using (tenant_id = public.auth_tenant_id())
              with check (tenant_id = public.auth_tenant_id());
create policy danos_delete on public.danos
  for delete using (tenant_id = public.auth_tenant_id());

-- =====================================================================
-- ONBOARDING DE TENANTS  (manual, hasta tener super-admin)
-- =====================================================================
-- Para crear un nuevo cliente del SaaS:
--
--   1) Crear el usuario admin via Supabase Auth dashboard (email + password).
--   2) Ejecutar (como service_role):
--        insert into public.tenants (nombre, nit, representante_legal)
--          values ('Acueducto Dosquebradas', '900238278-8', 'Alexander ...')
--          returning id;
--      -- copiar el id devuelto.
--
--   3) Vincular el admin al tenant:
--        insert into public.profiles (id, tenant_id, nombre, email)
--          values ('<auth.users.id>', '<tenant_id>', 'Nombre admin', 'mail');
--
-- En el futuro: una funcion `crear_tenant_y_admin()` ejecutada por super-admin.

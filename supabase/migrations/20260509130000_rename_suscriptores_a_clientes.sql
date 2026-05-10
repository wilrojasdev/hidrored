-- =====================================================================
-- Rename suscriptores -> clientes (alinear con nomenclatura del front).
--
-- No destructivo: solo renames de tabla, columnas FK, indices y trigger.
-- Cero perdida de datos. La policy `tenant_iso` y las constraints
-- implicitas (pkey, fkey, check, unique) siguen funcionando bajo sus
-- nombres antiguos; renombrarlas es solo cosmetico y se omite aqui.
--
-- Aplicar en SQL Editor de Supabase con rol service_role.
-- =====================================================================

-- 1) Tabla principal
alter table public.suscriptores rename to clientes;

-- 2) Columnas FK en tablas dependientes
alter table public.facturas         rename column suscriptor_id to cliente_id;
alter table public.pagos            rename column suscriptor_id to cliente_id;
alter table public.eventos_servicio rename column suscriptor_id to cliente_id;
alter table public.danos            rename column suscriptor_id to cliente_id;

-- 3) Indices (los nombres son referenciables; conviene alinearlos)
alter index idx_suscriptores_tenant rename to idx_clientes_tenant;
alter index idx_suscriptores_estado rename to idx_clientes_estado;
alter index idx_suscriptores_cedula rename to idx_clientes_cedula;
alter index idx_facturas_suscriptor rename to idx_facturas_cliente;
alter index idx_pagos_suscriptor    rename to idx_pagos_cliente;
alter index idx_eventos_suscriptor  rename to idx_eventos_cliente;
alter index idx_danos_suscriptor    rename to idx_danos_cliente;

-- 4) Trigger de updated_at
alter trigger trg_suscriptores_updated_at on public.clientes
  rename to trg_clientes_updated_at;

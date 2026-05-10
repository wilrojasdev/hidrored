-- =====================================================================
-- Polish: CHECK constraints en columnas monetarias, indice tenant_id en
-- factura_lineas, y columna updated_at + trigger faltante en
-- factura_lineas (consistencia con el resto de las tablas).
--
-- Cambios no destructivos: solo agrega constraints y columnas. Asume que
-- los datos actuales cumplen las reglas (>= 0). Si alguna fila viola
-- una constraint, el ALTER fallara y habra que corregirla manualmente.
--
-- Aplicar en SQL Editor de Supabase con rol service_role.
-- =====================================================================

-- 1) CHECK >= 0 en columnas monetarias del tenant
alter table public.tenants
  add constraint tenants_tarifa_mora_diaria_chk    check (tarifa_mora_diaria  >= 0),
  add constraint tenants_costo_reconexion_chk      check (costo_reconexion    >= 0),
  add constraint tenants_tarifa_basica_chk         check (tarifa_basica       >= 0),
  add constraint tenants_tarifa_extendida_chk      check (tarifa_extendida    >= 0),
  add constraint tenants_dias_habiles_pago_chk     check (dias_habiles_pago   >  0);

-- 2) CHECK >= 0 en monetarios de clientes
alter table public.clientes
  add constraint clientes_tarifa_mensual_chk       check (tarifa_mensual >= 0),
  add constraint clientes_deuda_inicial_chk        check (deuda_inicial  >= 0);

-- 3) CHECK >= 0 en monetarios de facturas
alter table public.facturas
  add constraint facturas_valor_mensualidad_chk    check (valor_mensualidad >= 0),
  add constraint facturas_valor_mora_chk           check (valor_mora        >= 0),
  add constraint facturas_total_chk                check (total             >= 0);

-- 4) CHECK >= 0 en monetarios de factura_lineas
alter table public.factura_lineas
  add constraint factura_lineas_cantidad_chk       check (cantidad       >  0),
  add constraint factura_lineas_valor_unitario_chk check (valor_unitario >= 0),
  add constraint factura_lineas_subtotal_chk       check (subtotal       >= 0);

-- 5) CHECK >= 0 en otros monetarios
alter table public.conceptos
  add constraint conceptos_valor_default_chk       check (valor_default >= 0);

alter table public.danos
  add constraint danos_costo_chk                   check (costo >= 0);

-- (`pagos.valor`  ya tiene CHECK > 0)
-- (`pago_factura.monto_aplicado` ya tiene CHECK > 0)

-- 6) factura_lineas: indice por tenant_id (faltaba; el RLS filtra por tenant)
create index if not exists idx_factura_lineas_tenant
  on public.factura_lineas(tenant_id);

-- 7) factura_lineas: columna updated_at + trigger (el resto de tablas
--    de dominio ya la tienen; era una inconsistencia menor)
alter table public.factura_lineas
  add column if not exists updated_at timestamptz not null default now();

drop trigger if exists trg_factura_lineas_updated_at on public.factura_lineas;
create trigger trg_factura_lineas_updated_at
  before update on public.factura_lineas
  for each row execute function public.set_updated_at();

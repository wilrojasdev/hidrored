-- =====================================================================
-- Endurecer RLS: separar policies `for all` por verbo (select/insert/
-- update/delete) y agregar WITH CHECK para evitar que un cliente
-- inserte o actualice filas con tenant_id ajeno escribiendo el campo
-- a mano.
--
-- Tambien restringe tenants/profiles a SELECT (+ UPDATE en tenants para
-- la pantalla de configuracion). recibo_secuencias queda sin policies:
-- solo accesible via RPCs `security definer`.
--
-- Aplicar en SQL Editor de Supabase con rol service_role.
-- =====================================================================

-- 1) DROP policies viejas
drop policy if exists tenant_iso on public.tenants;
drop policy if exists tenant_iso on public.profiles;
drop policy if exists tenant_iso on public.clientes;
drop policy if exists tenant_iso on public.conceptos;
drop policy if exists tenant_iso on public.facturas;
drop policy if exists tenant_iso on public.factura_lineas;
drop policy if exists tenant_iso on public.pagos;
drop policy if exists tenant_iso on public.pago_factura;
drop policy if exists tenant_iso on public.eventos_servicio;
drop policy if exists tenant_iso on public.danos;
drop policy if exists tenant_iso on public.recibo_secuencias;

-- 2) tenants: SELECT + UPDATE propio (sin INSERT/DELETE)
create policy tenants_select on public.tenants
  for select using (id = public.auth_tenant_id());
create policy tenants_update on public.tenants
  for update using (id = public.auth_tenant_id())
              with check (id = public.auth_tenant_id());

-- 3) profiles: solo SELECT del propio tenant
create policy profiles_select on public.profiles
  for select using (tenant_id = public.auth_tenant_id());

-- 4) clientes
create policy clientes_select on public.clientes
  for select using (tenant_id = public.auth_tenant_id());
create policy clientes_insert on public.clientes
  for insert with check (tenant_id = public.auth_tenant_id());
create policy clientes_update on public.clientes
  for update using (tenant_id = public.auth_tenant_id())
              with check (tenant_id = public.auth_tenant_id());
create policy clientes_delete on public.clientes
  for delete using (tenant_id = public.auth_tenant_id());

-- 5) conceptos
create policy conceptos_select on public.conceptos
  for select using (tenant_id = public.auth_tenant_id());
create policy conceptos_insert on public.conceptos
  for insert with check (tenant_id = public.auth_tenant_id());
create policy conceptos_update on public.conceptos
  for update using (tenant_id = public.auth_tenant_id())
              with check (tenant_id = public.auth_tenant_id());
create policy conceptos_delete on public.conceptos
  for delete using (tenant_id = public.auth_tenant_id());

-- 6) facturas
create policy facturas_select on public.facturas
  for select using (tenant_id = public.auth_tenant_id());
create policy facturas_insert on public.facturas
  for insert with check (tenant_id = public.auth_tenant_id());
create policy facturas_update on public.facturas
  for update using (tenant_id = public.auth_tenant_id())
              with check (tenant_id = public.auth_tenant_id());
create policy facturas_delete on public.facturas
  for delete using (tenant_id = public.auth_tenant_id());

-- 7) factura_lineas
create policy factura_lineas_select on public.factura_lineas
  for select using (tenant_id = public.auth_tenant_id());
create policy factura_lineas_insert on public.factura_lineas
  for insert with check (tenant_id = public.auth_tenant_id());
create policy factura_lineas_update on public.factura_lineas
  for update using (tenant_id = public.auth_tenant_id())
              with check (tenant_id = public.auth_tenant_id());
create policy factura_lineas_delete on public.factura_lineas
  for delete using (tenant_id = public.auth_tenant_id());

-- 8) pagos
create policy pagos_select on public.pagos
  for select using (tenant_id = public.auth_tenant_id());
create policy pagos_insert on public.pagos
  for insert with check (tenant_id = public.auth_tenant_id());
create policy pagos_update on public.pagos
  for update using (tenant_id = public.auth_tenant_id())
              with check (tenant_id = public.auth_tenant_id());
create policy pagos_delete on public.pagos
  for delete using (tenant_id = public.auth_tenant_id());

-- 9) pago_factura
create policy pago_factura_select on public.pago_factura
  for select using (tenant_id = public.auth_tenant_id());
create policy pago_factura_insert on public.pago_factura
  for insert with check (tenant_id = public.auth_tenant_id());
create policy pago_factura_update on public.pago_factura
  for update using (tenant_id = public.auth_tenant_id())
              with check (tenant_id = public.auth_tenant_id());
create policy pago_factura_delete on public.pago_factura
  for delete using (tenant_id = public.auth_tenant_id());

-- 10) eventos_servicio
create policy eventos_servicio_select on public.eventos_servicio
  for select using (tenant_id = public.auth_tenant_id());
create policy eventos_servicio_insert on public.eventos_servicio
  for insert with check (tenant_id = public.auth_tenant_id());
create policy eventos_servicio_update on public.eventos_servicio
  for update using (tenant_id = public.auth_tenant_id())
              with check (tenant_id = public.auth_tenant_id());
create policy eventos_servicio_delete on public.eventos_servicio
  for delete using (tenant_id = public.auth_tenant_id());

-- 11) danos
create policy danos_select on public.danos
  for select using (tenant_id = public.auth_tenant_id());
create policy danos_insert on public.danos
  for insert with check (tenant_id = public.auth_tenant_id());
create policy danos_update on public.danos
  for update using (tenant_id = public.auth_tenant_id())
              with check (tenant_id = public.auth_tenant_id());
create policy danos_delete on public.danos
  for delete using (tenant_id = public.auth_tenant_id());

-- 12) recibo_secuencias: ningun policy = sin acceso desde el cliente.
-- RLS sigue activado; solo las RPCs `security definer` pueden tocarla.

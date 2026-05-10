-- =====================================================================
-- Plantilla de seed para un nuevo tenant.
--
-- USO:
--   1. Copiar este archivo a `<nombre_tenant>.sql` (NO commitear: queda
--      automáticamente ignorado por .gitignore).
--   2. Reemplazar los placeholders <...> con los datos reales del tenant.
--   3. Ejecutar UNA SOLA VEZ desde el SQL Editor de Supabase con rol
--      service_role.
--   4. Crear primero el usuario admin desde Supabase Auth y copiar su id
--      como <AUTH_USER_ID>.
--
-- IMPORTANTE: este archivo es solo plantilla y NO contiene datos reales.
-- Cualquier seed con PII / cuentas bancarias / cédulas debe vivir en un
-- archivo separado, que el .gitignore excluye por defecto.
-- =====================================================================

-- Paso 1: crear el tenant
insert into public.tenants (
  id,
  nombre,
  nit,
  representante_legal,
  prefijo_recibos,
  cuenta_bancolombia,
  cuenta_nequi,
  tarifa_mora_diaria,
  costo_reconexion,
  tarifa_basica,
  tarifa_extendida
) values (
  gen_random_uuid(),
  '<NOMBRE_DEL_ACUEDUCTO>',
  '<NIT>',
  '<REPRESENTANTE_LEGAL>',
  '<PREFIJO>',                -- ej. 'DSQ'
  '<CUENTA_BANCOLOMBIA>',
  '<CUENTA_NEQUI>',
  300,                         -- tarifa de mora diaria (configurable)
  0,                           -- costo de reconexion (ajustar segun acueducto)
  18000,                       -- tarifa basica
  36000                        -- tarifa extendida
)
returning id;
-- ^ copiar el id devuelto y usarlo abajo como <TENANT_ID>

-- Paso 2: crear el perfil del admin (tras crearlo en Supabase Auth)
-- insert into public.profiles (id, tenant_id, nombre, email)
--   values ('<AUTH_USER_ID>', '<TENANT_ID>', '<NOMBRE_ADMIN>', '<EMAIL_ADMIN>');

-- Paso 3 (opcional): conceptos extra iniciales
-- insert into public.conceptos (tenant_id, nombre, valor_default, descripcion) values
--   ('<TENANT_ID>', 'Reconexion del servicio', 0, 'Tarifa por reconectar tras suspension'),
--   ('<TENANT_ID>', 'Mejora de tuberia por la propiedad', 0, 'Cargo por mejora de la red'),
--   ('<TENANT_ID>', 'Multa', 0, 'Sancion por incumplimiento');

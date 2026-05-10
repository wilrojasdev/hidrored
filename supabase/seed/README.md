# Seeds de Supabase

Esta carpeta contiene plantillas y seeds reales por tenant.

## Convención

- **Plantillas y documentación**: `_template.sql`, `README.md`, `.gitkeep` → SÍ se commitean.
- **Cualquier otro archivo**: NO se commitea. El `.gitignore` raíz está configurado como blacklist por defecto: todo en `supabase/seed/` queda ignorado salvo lo whitelisted explícitamente.

Esto protege contra commitear por accidente PII de clientes (cédulas, teléfonos, direcciones) o números de cuenta bancarios.

## Cómo añadir un seed para un tenant nuevo

1. Copia `_template.sql` a `<nombre_tenant>.sql` (ej. `dosquebradas.sql`).
2. Reemplaza los placeholders `<...>` con los datos reales.
3. Ejecuta el archivo desde el **SQL Editor** de Supabase con rol `service_role`.
4. El archivo queda local: el `.gitignore` lo excluye automáticamente.

## Si necesitas versionar un seed

Si por alguna razón quieres versionar un seed específico (ej. datos de prueba sin PII):

1. Asegúrate de que NO contenga datos personales reales ni credenciales.
2. Añade una excepción específica al `.gitignore` raíz:
   ```
   !supabase/seed/<archivo>.sql
   ```
3. Justifica el por qué en el commit.

## Verificar que un archivo está correctamente ignorado

```bash
git check-ignore -v supabase/seed/<archivo>.sql
```

Si devuelve la regla `supabase/seed/*` el archivo está protegido.

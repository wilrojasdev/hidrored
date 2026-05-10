# hidrored

MVP/SaaS multi-tenant para gestionar acueductos veredales en Colombia. Cliente piloto: Acueducto Dosquebradas (~300 usuarios).

App **Flutter** (Windows desktop + Android mobile) que opera contra Supabase. **MVP online-first**: la app requiere internet para leer/escribir datos; muestra un banner cuando no hay red. La capa offline (drift + PowerSync) está postergada a fase 2 — se implementará si el piloto demuestra problemas reales de conectividad.

---

## Estructura del repo

```
hidrored/
├── app/                    Flutter app (Windows + Android)
├── supabase/               Backend (Postgres + Auth + Storage)
│   ├── migrations/         Schemas SQL versionados
│   ├── functions/          Edge Functions (Deno) — futuras
│   └── seed/               Datos iniciales por tenant
├── docs/                   Documentacion del proyecto
├── .github/workflows/      CI/CD (build APK + Windows zip)
├── .fvmrc                  Version Flutter pinneada
└── README.md
```

---

## Stack

| Capa | Tecnologia |
|---|---|
| App | Flutter (Windows + Android) |
| Estado | Riverpod |
| Ruteo | go_router |
| Backend | Supabase (Postgres + Auth + Storage) |
| Conectividad | connectivity_plus |
| Logger | logger (`core/logging/app_logger.dart`) |
| PDF | pdf + printing |
| Compartir | url_launcher (wa.me) + share_plus |
| Reportes | fl_chart |
| Forms | flutter_form_builder |
| ~~DB local~~ | ~~drift (SQLite)~~ — pospuesto a fase 2 |
| ~~Sync~~ | ~~PowerSync~~ — pospuesto a fase 2 |

Decisiones de arquitectura: ver el `MEMORY.md` y `project_*.md` en el directorio de memoria del agente.

---

## Setup local (macOS / Linux / Windows)

### 1. Instalar fvm y Flutter
```bash
brew install fvm   # macOS
# o ver: https://fvm.app/docs/getting_started/installation

cd hidrored
fvm install        # lee .fvmrc
fvm use stable
```

### 2. Resolver dependencias del app
```bash
cd app
fvm flutter pub get
```

### 3. Configurar variables de entorno

El app lee tres variables vía `--dart-define`. Crea un script local para no escribirlas cada vez:

```bash
# scripts/run_macos.sh (no commitear)
fvm flutter run -d macos \
  --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJh... \
  --dart-define=POWERSYNC_URL=https://xxxx.powersync.journeyapps.com
```

Sin estas variables el app arranca, pero muestra "Backend NO configurado" y no podrás autenticar.

### 4. Targets disponibles

```bash
fvm flutter devices              # listar
fvm flutter run -d macos         # dev rapido en macOS
fvm flutter run -d windows       # solo desde Windows
fvm flutter run -d <android-id>  # Android conectado o emulador
```

---

## Setup del backend (Supabase + PowerSync)

### 1. Crear proyecto Supabase
1. Crear cuenta en [supabase.com](https://supabase.com).
2. Crear proyecto nuevo (region recomendada: `us-east-1` para latencia con Colombia).
3. Copiar `Project URL` y `anon public key` desde Settings > API.

### 2. Aplicar migraciones
Las migraciones estan en `supabase/migrations/` con timestamps. Hay dos formas:

**Opcion A — SQL Editor (manual, sirve para empezar)**
1. Abrir SQL Editor en el dashboard de Supabase.
2. Pegar y ejecutar `20260509120000_init_schema.sql`.
3. Pegar y ejecutar `20260509120100_festivos_colombia.sql`.

**Opcion B — Supabase CLI (recomendado para prod)**
```bash
brew install supabase/tap/supabase
supabase login
supabase link --project-ref <project-ref>
supabase db push
```

### 3. Crear el primer tenant
1. En Supabase Auth, crear el usuario admin con email + password.
2. Copiar el `id` del usuario creado.
3. Copiar `supabase/seed/_template.sql` a `supabase/seed/<nombre_tenant>.sql` y reemplazar los placeholders `<...>` con los datos reales.
4. Ejecutar el archivo desde el SQL Editor con rol `service_role`.

> **Importante**: los seeds reales (con cédulas, teléfonos, cuentas bancarias) están **excluidos del repo por defecto** vía `.gitignore`. Solo se versiona la plantilla (`_template.sql`). Ver `supabase/seed/README.md` para detalles.

### 4. Configurar PowerSync
1. Crear cuenta en [powersync.com](https://www.powersync.com/).
2. Conectar el proyecto Supabase.
3. Definir el sync rules YAML — basicamente sincronizar todas las tablas filtrando por `tenant_id = (jwt -> tenant_id)`.
4. Copiar la URL de PowerSync para usarla como `POWERSYNC_URL`.

> **Nota**: PowerSync se conecta en una fase posterior. La app funciona con Supabase puro mientras tanto.

---

## CI / Distribucion

`.github/workflows/build.yml` corre en cada push a `main` y en cada PR:

- **analyze**: `dart format`, `flutter analyze`, `flutter test`.
- **build-android**: APK release sin firmar (`hidrored-<sha>.apk`).
- **build-windows**: Carpeta build empaquetada en zip (`hidrored-windows-<sha>.zip`).

Los artefactos quedan disponibles 30 dias en la pestana Actions del repo.

### Secrets requeridos en GitHub
Settings > Secrets and variables > Actions:

| Nombre | Valor |
|---|---|
| `SUPABASE_URL` | URL del proyecto Supabase |
| `SUPABASE_ANON_KEY` | anon key publica |
| `POWERSYNC_URL` | URL de PowerSync (cuando se conecte) |

### Releases firmadas (post-MVP)
Cuando llegue el momento de firmar:
- **Android**: subir `key.properties` y keystore, configurar `signingConfig` en `android/app/build.gradle`. Luego subir a Play Store.
- **Windows**: comprar certificado de firma de codigo (DigiCert, Sectigo) o usar Azure Trusted Signing. Empaquetar como MSIX firmado.

---

## Roadmap

- [x] **Fase 0**: Cimientos — repo, scaffolding, schema base, CI.
- [ ] **Fase 1**: Nucleo MVP — usuarios, conceptos, facturacion masiva, pagos, recibos PDF.
- [ ] **Fase 2**: Operacion — estados del servicio, suspension/reconexion, danos, reportes, lista de corte.
- [ ] **Fase 3**: Pulido — importador Excel, configuracion del tenant, dashboard, backup, estado de cuenta.
- [ ] **Fase 4** (post-MVP): Mobile companion full + super-admin para gestion de tenants.

---

## Reglas de negocio (resumen)

Lo critico:

- **Tarifas**: 2 valores configurables por tenant ($18.000 / $36.000), asignables por cliente.
- **Facturacion**: ultimo dia del mes, masiva, con boton explicito.
- **Mora**: $300/dia calendario (configurable) tras 5 dias habiles desde emision.
- **Suspension**: sugerida tras vencer 5 dias habiles del 2° mes en mora; el admin confirma.
- **Suspendidos**: no acumulan nueva mensualidad — solo deuda + mora + reconexion.
- **Pagos**: completos del recibo (sin parciales), registro manual.
- **Recibos**: PDF individual + lote 4 por hoja, compartibles via wa.me.
- **Estados del servicio**: activo, suspendido por mora, suspendido voluntario, dano reportado, en reparacion, retirado.

---

## Licencia

Propietario. Todos los derechos reservados.

# Biomech AI v0.1

**Análisis Biomecánico Asistido por IA** — Aplicación profesional de podología.

## Descripción

Biomech AI es una aplicación para profesionales de la podología que permite:
- Registro y gestión de pacientes
- Captura fotográfica guiada (8 ángulos: corporal + pies)
- Verificación de calidad de imagen
- Preparación para análisis biomecánico por IA (V0.2+)

## Arquitectura

```
biomech-ai/
├── biomech_ai/          # Flutter app (Android + iOS)
│   ├── lib/
│   │   ├── main.dart
│   │   ├── core/        # Theme, constants, router
│   │   ├── models/      # Patient, Photo models
│   │   ├── services/    # API service (Dio)
│   │   └── modules/     # Screens: home, patients, capture
│   └── pubspec.yaml
├── backend/             # FastAPI backend
│   ├── main.py
│   ├── database.py
│   ├── models.py
│   ├── schemas.py
│   ├── routers/         # patients.py, photos.py
│   ├── services/        # ai_service.py (placeholder)
│   ├── storage/         # Photo storage
│   ├── Dockerfile
│   ├── railway.toml
│   └── requirements.txt
└── README.md
```

## Ejecución Local

### Backend (Python)

```bash
cd backend

# Crear entorno virtual
python -m venv venv
source venv/bin/activate  # Linux/Mac
# venv\Scripts\activate   # Windows

# Instalar dependencias
pip install -r requirements.txt

# Configurar variables de entorno
cp .env.example .env
# Editar .env según necesidad

# Ejecutar servidor
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

El API estará disponible en: http://localhost:8000
Documentación: http://localhost:8000/docs

### Flutter App

```bash
cd biomech_ai

# Instalar dependencias
flutter pub get

# Ejecutar en modo debug
flutter run

# Compilar APK
flutter build apk --release
```

**Nota:** Para conectar la app al backend, editar `lib/core/constants.dart` y cambiar `apiBaseUrl` o usar la variable de entorno `API_BASE_URL` al compilar:
```bash
flutter run --dart-define=API_BASE_URL=http://tu-servidor:8000
```

## Deploy en Railway (Backend)

1. Crear un nuevo proyecto en [Railway](https://railway.app)
2. Conectar el repositorio Git
3. Configurar el root directory como `/backend`
4. Configurar las variables de entorno:
   - `DATABASE_URL`: `sqlite+aiosqlite:///./biomech.db`
   - `EMERGENT_LLM_KEY`: (tu API key, cuando esté disponible)
   - `STORAGE_PATH`: `./storage`
   - `MAX_FILE_SIZE_MB`: `10`
   - `ALLOWED_ORIGINS`: `*` (restringir en producción)
5. Railway detectará automáticamente el Dockerfile

## Variables de Entorno

| Variable | Descripción | Default |
|----------|-------------|---------|
| `DATABASE_URL` | URL de conexión SQLite async | `sqlite+aiosqlite:///./biomech.db` |
| `EMERGENT_LLM_KEY` | API key para integración IA | - |
| `STORAGE_PATH` | Directorio para fotos | `./storage` |
| `MAX_FILE_SIZE_MB` | Tamaño máximo de foto en MB | `10` |
| `ALLOWED_ORIGINS` | Orígenes CORS permitidos | `*` |

## API Endpoints

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/health` | Health check |
| GET | `/api/v1/patients` | Listar pacientes |
| POST | `/api/v1/patients` | Crear paciente |
| GET | `/api/v1/patients/{id}` | Detalle paciente |
| PUT | `/api/v1/patients/{id}` | Actualizar paciente |
| DELETE | `/api/v1/patients/{id}` | Eliminar paciente |
| GET | `/api/v1/patients/{id}/photos` | Listar fotos |
| POST | `/api/v1/patients/{id}/photos` | Subir foto |
| DELETE | `/api/v1/photos/{id}` | Eliminar foto |

## Roadmap

- **V0.1** ✅ — MVP: CRUD pacientes, captura fotográfica guiada
- **V0.2** — Análisis de huella plantar con IA
- **V0.3** — Generación de reportes PDF
- **V0.5** — Recomendación de plantillas ortopédicas
- **V0.7** — Generación de imagen 3D de plantilla
- **V1.0** — App completa con todos los módulos

## Tecnologías

- **Frontend:** Flutter (Dart) — Android + iOS
- **Backend:** Python 3.11, FastAPI, SQLAlchemy (async), SQLite
- **Deploy:** Docker, Railway
- **IA (futuro):** Emergent LLM API

---

*Solo para uso profesional. V0.1 — Biomech AI © 2026*

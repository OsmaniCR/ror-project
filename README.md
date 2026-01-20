# Fudo API - Challenge Técnico

API REST desarrollada en Ruby con Rack para la gestión de productos con creación asíncrona.

## Características

- ✅ Autenticación con tokens Bearer (JWT)
- ✅ CRUD completo de productos
- ✅ Creación asíncrona de productos (disponible después de 5 segundos)
- ✅ Compresión Gzip automática
- ✅ Persistencia en PostgreSQL
- ✅ Especificación OpenAPI
- ✅ Dockerizado con Docker Compose (PostgreSQL, API, Dozzle)
- ✅ Hot reload para desarrollo
- ✅ Arquitectura con controladores separados
- ✅ Archivos estáticos (openapi.yaml, AUTHORS)
- ✅ Documentación en archivos .md (fudo.md, tcp.md, http.md)

## Requisitos

- Docker
- Docker Compose

## Quick Start (Setup Inicial)

### Paso 1: Clonar el repositorio
```bash
git clone git@github.com:OsmaniCR/ror-project.git
cd ror-project
```

### Paso 2: Configurar variables de entorno
```bash
cp .env.example .env
```

El archivo `.env` está en `.gitignore` y no se subirá al repositorio. Puedes editarlo para personalizar:
- Credenciales de la base de datos (DB_USER, DB_PASSWORD, DB_NAME)
- Usuario administrador inicial (ADMIN_USERNAME, ADMIN_PASSWORD)
- Secreto JWT para tokens (JWT_SECRET)

### Paso 3: Levantar el proyecto
```bash
make up-build
```

Esto construirá las imágenes Docker y levantará todos los servicios. La primera vez puede tardar unos minutos.

### Paso 4: Verificar que todo funciona
```bash
make status
```

Esto mostrará el estado de los servicios y las URLs disponibles.

## Levantar el proyecto

### Opción 1: Makefile (Recomendado)

**Comandos principales para setup inicial:**
```bash
make help          # Ver todos los comandos disponibles
make up-build      # Construir y levantar servicios (primera vez)
make up            # Levantar servicios (si ya están construidos)
make logs          # Ver logs de todos los servicios
make status        # Ver estado y URLs de servicios
```

Esto levantará:
- **PostgreSQL** en el puerto 5432
- **API** en el puerto 9292
- **Dozzle** (visualización de logs) en el puerto 8080

4. Acceder a los servicios:
   - API: http://localhost:9292
   - Dozzle: http://localhost:8080
   - OpenAPI Spec: http://localhost:9292/openapi.yaml
   - AUTHORS: http://localhost:9292/AUTHORS

### Opción 2: Docker Compose directo

1. Clonar el repositorio:
```bash
git clone git@github.com:OsmaniCR/ror-project.git
cd ror-project
```

2. Levantar todos los servicios:
```bash
docker-compose up --build
```

### Opción 3: Desarrollo local (sin Docker)

1. Instalar dependencias:
```bash
bundle install
```

2. Configurar PostgreSQL:
   - Crear base de datos `fudo_db`
   - Configurar variables de entorno o editar `lib/database.rb`

3. Levantar la aplicación:
```bash
bundle exec rackup
```

## Uso de la API

### 1. Autenticación

```bash
curl -X POST http://localhost:9292/auth \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

Respuesta:
```json
{
  "token": "abc123..."
}
```

### 2. Crear producto (asíncrono)

```bash
curl -X POST http://localhost:9292/products \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{"name":"Mi Producto"}'
```

Respuesta (202 Accepted):
```json
{
  "job_id": 1,
  "message": "Product creation queued"
}
```

El producto estará disponible después de 5 segundos.

### 3. Listar productos

```bash
curl -X GET http://localhost:9292/products \
  -H "Authorization: Bearer <token>"
```

### 4. Obtener producto por ID

```bash
curl -X GET http://localhost:9292/products/1 \
  -H "Authorization: Bearer <token>"
```

### 5. Actualizar producto

```bash
curl -X PUT http://localhost:9292/products/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{"name":"Producto Actualizado"}'
```

También puedes usar `PATCH` en lugar de `PUT`:

```bash
curl -X PATCH http://localhost:9292/products/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{"name":"Producto Actualizado"}'
```

Respuesta (200 OK):
```json
{
  "id": 1,
  "name": "Producto Actualizado",
  "created_at": "2024-01-20T10:00:00Z"
}
```

### 6. Eliminar producto

```bash
curl -X DELETE http://localhost:9292/products/1 \
  -H "Authorization: Bearer <token>"
```

Respuesta (200 OK):
```json
{
  "message": "Product deleted successfully"
}
```

## Estructura del proyecto

```
.
├── app.rb                 # Aplicación principal Rack
├── config.ru              # Configuración Rack
├── Gemfile                # Dependencias Ruby
├── Dockerfile             # Imagen Docker de la API
├── docker-compose.yml     # Configuración Docker Compose
├── openapi.yaml           # Especificación OpenAPI
├── AUTHORS                # Archivo de autores
├── fudo.md                # Información sobre Fudo
├── tcp.md                 # Explicación de TCP
├── http.md                # Explicación de HTTP
├── .env.example           # Ejemplo de variables de entorno
├── Makefile               # Comandos útiles para el proyecto
├── lib/
│   ├── database.rb       # Configuración de base de datos
│   ├── models/           # Modelos (User, Product)
│   ├── services/         # Servicios (Auth, Product, AsyncProcessor)
│   ├── middleware/       # Middlewares (Auth, Gzip)
│   └── controllers/      # Controladores (Auth, Products, Static, Base)
└── README.md             # Este archivo
```

## Credenciales

Las credenciales del usuario administrador se configuran en el archivo `.env`:
- `ADMIN_USERNAME`: Nombre de usuario (por defecto: `admin`)
- `ADMIN_PASSWORD`: Contraseña (por defecto: `admin123`)

**Nota:** Si cambias estas credenciales en `.env`, reinicia los servicios para que se apliquen los cambios.

## Notas

- Los productos se crean de forma asíncrona y estarán disponibles después de 5 segundos de la solicitud.
- La compresión Gzip se aplica automáticamente cuando el cliente la solicita mediante el header `Accept-Encoding: gzip`.
- El archivo `openapi.yaml` nunca se cachea (headers `Cache-Control: no-cache`).
- El archivo `AUTHORS` se cachea por 24 horas.

## Comandos útiles con Makefile

```bash
make help          # Ver todos los comandos disponibles
make up-build      # Construir y levantar servicios
make up            # Levantar servicios (si ya están construidos)
make down          # Detener servicios
make restart       # Reiniciar servicios
make logs          # Ver logs de todos los servicios
make logs-api      # Ver logs solo de la API
make logs-db       # Ver logs solo de la base de datos
make logs-dozzle   # Ver logs solo de Dozzle
make clean         # Detener y eliminar volúmenes (incluye BD)
make ps            # Ver estado de contenedores
make shell-api     # Abrir shell en contenedor de API
make shell-db      # Abrir shell en PostgreSQL
make db-reset      # Resetear la base de datos
make db-clean      # Eliminar volumen de BD (recrea desde cero)
make db-setup      # Configurar la base de datos
make status        # Ver estado y URLs de servicios
make stop          # Detener servicios sin eliminarlos
make start         # Iniciar servicios detenidos
make rebuild       # Reconstruir completamente
```

## Detener los servicios

Con Makefile:
```bash
make down          # Detener servicios
make clean         # Detener y eliminar volúmenes (incluyendo BD)
```

Con Docker Compose:
```bash
docker-compose down
docker-compose down -v  # Eliminar también volúmenes
```

.PHONY: help build up down restart logs clean shell-db shell-api test ps db-clean db-reset db-setup

# Variables
COMPOSE = docker compose
COMPOSE_FILE = docker-compose.yml

# Default target
help: ## Mostrar esta ayuda
	@echo "Comandos disponibles:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

build: ## Construir las imágenes Docker
	$(COMPOSE) build

up: ## Levantar todos los servicios
	$(COMPOSE) up

up-build: ## Construir y levantar los servicios
	$(COMPOSE) up --build

down: ## Detener todos los servicios
	$(COMPOSE) down

restart: ## Reiniciar todos los servicios
	$(COMPOSE) restart

logs: ## Ver logs de todos los servicios
	$(COMPOSE) logs -f

logs-api: ## Ver logs solo de la API
	$(COMPOSE) logs -f api

logs-db: ## Ver logs solo de la base de datos
	$(COMPOSE) logs -f db

logs-dozzle: ## Ver logs solo de Dozzle
	$(COMPOSE) logs -f dozzle

clean: ## Detener servicios y eliminar volúmenes
	$(COMPOSE) down -v

ps: ## Mostrar estado de los contenedores
	$(COMPOSE) ps

shell-api: ## Abrir shell en el contenedor de la API
	$(COMPOSE) exec api /bin/bash

shell-db: ## Abrir shell en el contenedor de PostgreSQL
	$(COMPOSE) exec db psql -U fudo_user -d fudo_db

test: ## Ejecutar tests (si existen)
	@echo "Ejecutando tests..."
	$(COMPOSE) exec api bundle exec rake test || echo "No hay tests configurados"

install: ## Instalar dependencias (dentro del contenedor)
	$(COMPOSE) exec api bundle install

db-setup: ## Configurar la base de datos
	$(COMPOSE) exec api bundle exec ruby -e "require_relative 'lib/database'; Database.setup"

db-reset: ## Resetear la base de datos (eliminar y recrear)
	$(COMPOSE) exec db psql -U fudo_user -d postgres -c "DROP DATABASE IF EXISTS fudo_db;"
	$(COMPOSE) exec db psql -U fudo_user -d postgres -c "CREATE DATABASE fudo_db;"
	$(MAKE) db-setup

db-clean: ## Eliminar volumen de base de datos (recrea desde cero)
	$(COMPOSE) down
	$(COMPOSE) volume rm postgres_data || true
	@echo "Volumen de base de datos eliminado. Ejecuta 'make up-build' para recrear."

status: ## Ver estado de los servicios y salud
	@echo "=== Estado de contenedores ==="
	$(COMPOSE) ps
	@echo ""
	@echo "=== Salud de servicios ==="
	@echo "API: http://localhost:9292"
	@echo "Dozzle: http://localhost:8080"
	@echo "PostgreSQL: localhost:5432"

stop: ## Detener servicios sin eliminarlos
	$(COMPOSE) stop

start: ## Iniciar servicios detenidos
	$(COMPOSE) start

rebuild: ## Reconstruir completamente (down, build, up)
	$(MAKE) down
	$(MAKE) build
	$(MAKE) up

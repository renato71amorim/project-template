#!/bin/bash

echo "🔄 Reiniciando containers (sem apagar volumes)..."

# ------------------------------------------------------------
# Carregar variáveis do .env
# ------------------------------------------------------------
if [ ! -f .env ]; then
  echo "❌ Arquivo .env não encontrado."
  exit 1
fi

echo "📂 Lendo variáveis do .env..."
export $(grep -v '^#' .env | xargs)

# Verificações essenciais
if [ -z "$PROJECT_NAME" ]; then
  echo "❌ PROJECT_NAME não definido no .env."
  exit 1
fi

DB_CONTAINER="${PROJECT_NAME}-db"

echo "📦 Container do banco detectado: $DB_CONTAINER"
echo ""

# ------------------------------------------------------------
# Parar containers (sem apagar volumes)
# ------------------------------------------------------------
echo "⏹️ Parando containers..."
docker compose down --remove-orphans

# ------------------------------------------------------------
# Subir novamente
# ------------------------------------------------------------
echo "🚀 Subindo containers com build forçado..."
docker compose up --build --force-recreate --detach

# ------------------------------------------------------------
# Aguardar banco ficar pronto
# ------------------------------------------------------------
echo "⏳ Aguardando inicialização do banco de dados..."
until docker exec "$DB_CONTAINER" mysqladmin ping -h "127.0.0.1" --silent; do
  sleep 2
done

echo "✅ Ambiente reiniciado com sucesso!"

if [ -n "$PROJECT_URL" ]; then
  echo "🌐 Acesse: $PROJECT_URL"
fi

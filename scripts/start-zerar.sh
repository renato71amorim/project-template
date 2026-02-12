#!/bin/bash

echo "⚠️ Atenção: este processo irá APAGAR volumes e recriar o ambiente do zero!"
read -p "Tem certeza? Escreva exatamente: sim eu quero → " confirmacao

if [ "$confirmacao" != "sim eu quero" ]; then
  echo "❌ Operação cancelada."
  exit 1
fi

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

if [ -z "$DB_ROOT_PASS" ]; then
  echo "❌ DB_ROOT_PASS não definido no .env."
  exit 1
fi

DB_CONTAINER="${PROJECT_NAME}-db"

echo "📦 Container do banco detectado: $DB_CONTAINER"
echo ""

# ------------------------------------------------------------
# Criar backup antes de apagar volumes
# ------------------------------------------------------------
timestamp=$(date +"%Y%m%d_%H%M%S")
backup_dir="backup_$timestamp"
mkdir -p "$backup_dir"

echo "📦 Gerando backup do banco de dados..."
docker exec "$DB_CONTAINER" sh -c "mysqldump -uroot -p$DB_ROOT_PASS --all-databases" > "$backup_dir/db_backup.sql"

if [ $? -ne 0 ] || [ ! -s "$backup_dir/db_backup.sql" ]; then
  echo "❌ Falha ao gerar backup. Operação abortada."
  exit 1
fi

echo "✅ Backup salvo em: $backup_dir/db_backup.sql"
echo ""

# ------------------------------------------------------------
# Derrubar containers + volumes
# ------------------------------------------------------------
echo "🔄 Limpando containers e volumes antigos..."
docker compose down --volumes --remove-orphans

# ------------------------------------------------------------
# Subir novamente do zero
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

echo "✅ Ambiente iniciado do zero com sucesso!"

if [ -n "$PROJECT_URL" ]; then
  echo "🌐 Acesse: $PROJECT_URL"
fi

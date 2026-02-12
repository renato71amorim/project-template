#!/bin/bash

echo "🔄 Iniciando processo de commit..."

# ------------------------------------------------------------
# Carregar variáveis do .env (se existir)
# ------------------------------------------------------------
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

# ------------------------------------------------------------
# Verificar se estamos em um repositório Git
# ------------------------------------------------------------
if [ ! -d ".git" ]; then
  echo "❌ Este diretório não é um repositório Git."
  echo "Execute: git init"
  echo "Este comando deve ser executo um diretório abaixo do scripts/ para funcionar corretamente."
  exit 1
fi

# ------------------------------------------------------------
# Mostrar status
# ------------------------------------------------------------
echo "🔍 Verificando alterações..."
git status
echo ""

# ------------------------------------------------------------
# Solicitar mensagem do commit
# ------------------------------------------------------------
read -p "📝 Digite a mensagem do commit: " COMMIT_MSG

if [ -z "$COMMIT_MSG" ]; then
  echo "❌ Mensagem de commit não pode ser vazia."
  exit 1
fi

# ------------------------------------------------------------
# Adicionar arquivos
# ------------------------------------------------------------
echo "📌 Adicionando arquivos ao Git..."
git add .

# ------------------------------------------------------------
# Criar commit
# ------------------------------------------------------------
echo "📝 Criando commit..."
git commit -m "$COMMIT_MSG"

# ------------------------------------------------------------
# Enviar para o GitHub
# ------------------------------------------------------------
echo "🚀 Enviando para o GitHub..."
git push origin main

# ------------------------------------------------------------
# Se falhar, oferecer push forçado
# ------------------------------------------------------------
if [ $? -ne 0 ]; then
  echo ""
  echo "⚠️  O push foi rejeitado (provavelmente o repositório remoto tem commits)."
  read -p "Deseja enviar com --force? (sim/nao) → " forcar

  if [ "$forcar" = "sim" ]; then
    echo "🚨 Enviando com --force..."
    git push origin main --force
    echo "✅ Push forçado concluído!"
  else
    echo "❌ Push cancelado."
    exit 1
  fi
else
  echo "✅ Commit enviado com sucesso!"
fi

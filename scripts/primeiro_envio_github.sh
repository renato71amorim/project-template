#!/bin/bash

echo "⚠️  Este script deve ser usado APENAS no primeiro envio do projeto ao GitHub."
echo "Este comando deve ser executo um diretório abaixo do scripts/ para funcionar corretamente."
read -p "Tem certeza? Digite exatamente: sim eu quero → " confirmacao

if [ "$confirmacao" != "sim eu quero" ]; then
  echo "❌ Operação cancelada."
  exit 1
fi

# ------------------------------------------------------------
# Carregar variáveis do .env
# ------------------------------------------------------------
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo "❌ Arquivo .env não encontrado."
  exit 1
fi

# ------------------------------------------------------------
# Configuração global do Git (se definida no .env)
# ------------------------------------------------------------
if [ -n "$GIT_USER_NAME" ] && [ -n "$GIT_USER_EMAIL" ]; then
  echo "🔧 Configurando Git global..."
  git config --global user.name "$GIT_USER_NAME"
  git config --global user.email "$GIT_USER_EMAIL"
else
  echo "⚠️ Variáveis GIT_USER_NAME e GIT_USER_EMAIL não definidas no .env."
  echo "   O Git não será configurado automaticamente."
fi

# ------------------------------------------------------------
# Solicitar caminho do projeto
# ------------------------------------------------------------
echo ""
echo "📁 Informe o caminho completo do projeto:"
read -p "→ " PROJETO

if [ ! -d "$PROJETO" ]; then
  echo "❌ Caminho inválido."
  exit 1
fi

# ------------------------------------------------------------
# Solicitar repositório remoto
# ------------------------------------------------------------
echo ""
echo "📦 Informe o repositório SSH do GitHub (ex: git@github.com:usuario/repositorio.git):"
read -p "→ " REPO_SSH

if [[ ! "$REPO_SSH" =~ ^git@github.com:.*\.git$ ]]; then
  echo "❌ Formato inválido de repositório SSH."
  exit 1
fi

# ------------------------------------------------------------
# Testar chave SSH
# ------------------------------------------------------------
echo ""
echo "🔑 Sua chave pública SSH:"
cat ~/.ssh/id_ed25519.pub 2>/dev/null || echo "Nenhuma chave encontrada. Gere com: ssh-keygen -t ed25519"

echo ""
echo "🔗 Testando conexão SSH com GitHub..."
ssh -T git@github.com

if [ $? -ne 1 ] && [ $? -ne 0 ]; then
  echo "❌ Falha na autenticação SSH com GitHub."
  exit 1
fi

# ------------------------------------------------------------
# Preparar repositório local
# ------------------------------------------------------------
echo ""
echo "🧹 Removendo .git antigo (se existir)..."
rm -rf "$PROJETO/.git"

echo "📂 Entrando no diretório do projeto..."
cd "$PROJETO" || exit 1

echo "🚀 Inicializando repositório Git..."
git init

echo "🔗 Adicionando repositório remoto..."
git remote add origin "$REPO_SSH"

echo "📌 Adicionando arquivos..."
git add .

echo "📝 Criando commit inicial..."
git commit -m "Primeiro commit: estrutura inicial do template"

echo "🌿 Renomeando branch principal para main..."
git branch -M main

# ------------------------------------------------------------
# Enviar para o GitHub
# ------------------------------------------------------------
echo "📤 Enviando arquivos para o GitHub..."
git push -u origin main

# Se falhar, oferecer push forçado
if [ $? -ne 0 ]; then
  echo ""
  echo "⚠️  O push foi rejeitado porque o repositório remoto já contém commits."
  read -p "Deseja sobrescrever o repositório remoto com --force? (sim/nao) → " forcar

  if [ "$forcar" = "sim" ]; then
    echo "🚨 Enviando com --force..."
    git push origin main --force
    echo "✅ Push forçado concluído!"
  else
    echo "❌ Push cancelado. Nenhuma alteração enviada."
    exit 1
  fi
else
  echo "✅ Projeto enviado com sucesso!"
fi

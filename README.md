# 📄 **README.md — Template de Projeto PHP com Docker**


# 🚀 Project Template — PHP + Docker + MariaDB

Este repositório fornece um **template completo e reutilizável** para iniciar rapidamente novos projetos PHP utilizando Docker, MariaDB e variáveis de ambiente.  
A proposta é permitir que você comece um novo projeto em minutos, mantendo uma estrutura padronizada, organizada e fácil de manter.

---

## 📦 Recursos incluídos

- Estrutura base para projetos PHP:
  - `app/public` para arquivos públicos (ex: index.php)
  - `app/src` para código-fonte
  - `app/config` para configurações
  - `app/storage` para logs, cache e arquivos gerados
- Ambiente Docker completo:
  - Container PHP configurado
  - Container MariaDB com inicialização automática
  - Suporte a `.env` para variáveis de ambiente
- Scripts utilitários:
  - Envio inicial para o GitHub
  - Commit rápido
  - Inicialização e reinicialização do ambiente Docker
- Arquivo `init.sql` para criação automática do banco
- `Dockerfile` otimizado
- `php.ini` customizável
- `.env.example` pronto para copiar e configurar

---

## 🧱 Estrutura do projeto

```
project-template/
├── app
│   ├── composer.json
│   ├── config/
│   ├── public/
│   │   └── index.php
│   ├── src/
│   └── storage/
├── docker-compose.yml
├── Dockerfile
├── php.ini
├── .env.example
├── README.md
├── LICENCA.md
├── scripts/
│   ├── novo-commit.sh
│   ├── primeiro_envio_github.sh
│   ├── start.sh
│   └── start-zerar.sh
└── sql/
    └── init.sql
```

---

## ⚙️ Como usar este template

### 1. Clone este repositório

```bash
git clone git@github.com:renato71amorim/project-template.git
```

### 2. Renomeie a pasta para o novo projeto

```bash
mv project-template meu-novo-projeto
cd meu-novo-projeto
```

### 3. Crie o arquivo `.env`

```bash
cp .env.example .env
```

Edite as variáveis conforme necessário.

---

## 🐳 Subindo o ambiente Docker

### Iniciar o ambiente

```bash
docker compose up -d
```

### Parar o ambiente

```bash
docker compose down
```

### Reiniciar sem apagar volumes

```bash
./scripts/start-zerar.sh
```

### Reiniciar apagando volumes e recriando tudo

```bash
./scripts/start.sh
```

---

## 🧰 Scripts úteis

### Envio inicial para o GitHub

```bash
./scripts/primeiro_envio_github.sh
```

### Criar commit rápido

```bash
./scripts/novo-commit.sh
```

---

## 📝 Licença

Este projeto utiliza a **MIT License**, permitindo uso livre, modificação e redistribuição.  
Consulte o arquivo `LICENCA.md` para mais detalhes.

---

## 🤝 Contribuindo

Sinta-se à vontade para sugerir melhorias, abrir issues ou enviar pull requests.  
Este template foi criado para evoluir continuamente e facilitar a criação de novos projetos PHP.

---

## 💬 Contato

Criado por **Renato Amorim**  
GitHub: https://github.com/renato71amorim

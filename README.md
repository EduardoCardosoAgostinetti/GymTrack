# GymTrack

Aplicativo Flutter para gerenciamento de usuários e fichas de treino de academia. O app permite que os usuários se registrem, façam login, recuperem senha e controlem suas rotinas de treino de forma organizada e intuitiva.

---

## 🚀 Funcionalidades

### 👤 Autenticação de Usuário
- Registro de novos usuários
- Login com email e senha
- Recuperação de senha por email com:
  - Envio de código de verificação
  - Verificação do código enviado por email
  - Redefinição de senha com novo acesso
- Validação e mensagens de erro elegantes
- Atualização de dados do usuário:
  - Alterar nome
  - Alterar email (com validação)
  - Alterar senha

### 📋 Gestão de Fichas de Treino
- Criar nova ficha de treino (exercícios com grupo muscular, nome e séries)
- Listar todas as fichas de treino de um usuário
- Editar ficha de treino por ID
- Excluir ficha de treino por ID
- Histórico de treinos anteriores

---

## 🛠️ Tecnologias Utilizadas

- [Flutter](https://flutter.dev/)
- [Dart](https://dart.dev/)
- Backend com:
  - [Node.js](https://nodejs.org/)
  - [Express](https://expressjs.com/)
  - [Sequelize ORM](https://sequelize.org/)
  - [PostgreSQL](https://www.postgresql.org/)

---

## 📱 Telas Principais

- Login
- Registro de Usuário
- Recuperar Senha
- Verificação de Código
- Redefinir Senha
- Gestão de Fichas
- Criação de Fichas
- Perfil do Usuário (edição de nome, email e senha)

---

## 📦 Como Executar o Projeto

### ⚙️ Pré-requisitos

Certifique-se de que você tenha os seguintes softwares instalados na sua máquina:

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Node.js](https://nodejs.org/)
- [PostgreSQL](https://www.postgresql.org/)
- Android Studio ou VS Code
- Emulador Android ou dispositivo físico

---

### 🚀 Passos para executar

1. **Clone o repositório:**

```bash
git clone https://github.com/seu-usuario/gymtrack.git
cd gymtrack
```

2. **Configure o banco de dados PostgreSQL:**

- Crie um banco de dados no PostgreSQL.
- Configure as credenciais e o nome do banco no arquivo `.env` (ou `config/config.json`) da API.

3. **Instale as dependências do backend:**

```bash
cd api
npm install
```

4. **(Opcional) Rode as migrações e seeds (se existirem):**

```bash
npx sequelize db:migrate
npx sequelize db:seed:all
```

5. **Inicie o servidor backend:**

```bash
npm start
```

> O backend deverá estar disponível em `http://localhost:3000`

6. **Instale as dependências do app Flutter:**

```bash
cd ../app
flutter pub get
flutter pub upgrade
```

7. **Conecte um emulador ou dispositivo Android e execute o app:**

```bash
flutter run
```

---

## 🧩 Estrutura das Rotas de Autenticação (Backend)

- `POST /api/auth/register` – Cria novo usuário
- `POST /api/auth/login` – Realiza login e retorna token
- `POST /api/auth/forgot` – Envia código para o email para recuperação de senha
- `POST /api/auth/verify-code` – Verifica o código enviado
- `POST /api/auth/reset` – Redefine a senha
- `GET /api/auth/user/:id` – Obter dados do usuário (sem senha)
- `PUT /api/auth/user/:id/name` – Atualiza nome do usuário
- `PUT /api/auth/user/:id/email` – Atualiza email do usuário (verifica duplicidade)
- `PUT /api/auth/user/:id/password` – Atualiza senha do usuário

---

## 🧩 Estrutura das Rotas de Fichas de Treino (Backend)

/workout

- `POST /workout/` – Criar nova ficha de treino
- `GET /workout/user/:userId` – Listar todas as fichas de treino de um usuário
- `PUT /workout/:id` – Atualizar ficha de treino por ID
- `DELETE /workout/:id` – Deletar ficha de treino por ID

---

## ✨ Estilo Visual

- Telas estilizadas com tons de **azul** e **verde**
- Interface intuitiva, com links para navegação fácil entre as telas de autenticação e gestão de treino

---


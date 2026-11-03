# FitLog - Diário de Treinos

Aplicativo Flutter para acompanhamento de treinos semanais, com perfis de **Aluno** e **Personal Trainer**. O personal cadastra treinos e os atribui aos dias da semana de cada aluno; o aluno apenas visualiza a própria agenda.

---

## Integrantes e Divisão de Atividades

- **Maria Beatriz**
- Responsável pela arquitetura geral (`models/`, `pages/`, `repositories/`), modelos de domínio, repositório reativo com `ChangeNotifier` + `AnimatedBuilder`, listagem e detalhe de treinos/exercícios. Implementou o fluxo completo de **autenticação vinculada à base de dados relacional e ao repositório de sessão**, além da otimização e unificação de chamadas de rotinas frequentes e reestruturação do fluxo de carregamento assíncrono para maximizar a eficiência da aplicação na Web e em dispositivos móveis.

- **João Gabriel**
- Responsável pela **arquitetura de banco de dados e persistência**. Implementou a estrutura do banco de dados local (`AppDatabase`), a definição das tabelas relacionais, o painel do Personal (cadastro de alunos, de treinos, formulários com validações, atribuição de treinos por dia da agenda) e a configuração do seeding inicial dos dados.

---

## Funcionalidades

- **Autenticação Real (Banco de Dados):** Login validado diretamente pelas credenciais armazenadas na tabela de usuários do SQLite com feedback visual.


- **Personal:** cadastro de treinos, exercícios e alunos, e atribuição treino → dia (sem atribuição = descanso).


- **Aluno:** visualiza apenas a própria semana e os detalhes dos exercícios; não edita dados.


- **Navegação** com **GoRouter** e redirecionamentos protegidos por sessão/papel.


- **Persistência Local (SQLite):** armazenamento local permanente para alunos, treinos, exercícios e agendas (com suporte nativo e para Web via IndexedDB).

---

## Banco de Dados e Como Utilizar

A aplicação utiliza o **SQLite** (via pacote `sqflite` e `path`) para garantir a persistência local dos dados do aplicativo.

### Estrutura do Banco de Dados

O banco de dados armazena as seguintes entidades principais:

- **Usuários/Alunos:** dados cadastrais, credenciais e papéis (`personal` ou `aluno`).
- **Treinos:** identificação, título e foco do treino.
- **Exercícios:** séries, repetições, carga, grupo muscular e vinculação ao treino correspondente.
- **Agenda Semanal:** relacionamento dos dias da semana de cada aluno com os seus treinos definidos.

### Como Utilizar a Persistência no App

1. **Inicialização do Banco:**
Ao iniciar o aplicativo, o helper de banco de dados (`AppDatabase`) executa a criação automática do arquivo `.db` local e cria as tabelas necessárias caso ainda não existam.
2. **Operações CRUD (Personal Trainer):**
- **Cadastrar Aluno/Treino/Exercício:** Acesse o menu de cadastro no painel do Personal Trainer. Ao preencher e salvar o formulário, os registros são diretamente salvos no banco SQLite.
- **Atribuir Treino à Agenda:** No painel do Personal, escolha o aluno e vincule um treino a um dia da semana. Essa alteração é gravada na tabela de agenda no banco.


3. **Leitura e Sincronização de Dados:**
- Sempre que o app é iniciado ou uma atualização é realizada, os repositórios realizam consultas (`SELECT`) no banco SQLite.
- **Alunos:** ao realizar o login, o app consulta os treinos persistidos do aluno para exibir a agenda atualizada.


4. **Persistência entre Sessões:**
Diferente da versão em memória, ao fechar e abrir novamente a aplicação, os dados inseridos permanecerão gravados.

---

## Contas de Demonstração

| Perfil | E-mail | Senha |
| --- | --- | --- |
| **Personal** | `personal@fitlog.com` | `123456` |
| **Aluno 1** | `aluno1@fitlog.com` | `123456` |
| **Aluno 2** | `aluno2@fitlog.com` | `123456` |

---

## Instalação e Execução

### Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.x ou superior)
- Um dispositivo/emulador (Android, iOS, macOS ou Chrome)

### Passos

1. **Clone o repositório:**
   ```bash
   git clone <url-do-repositorio>
   cd fitlog

2. **Instale as dependências:**
   ```bash
   flutter pub get

3. **Configure os binários do SQLite para o ambiente Web (se necessário):**
   ```bash
   dart run sqflite_common_ffi_web:setup

4. **Execute a aplicação:**
   ```bash
   flutter run

**Para escolher o dispositivo de execução específico:**
```bash
flutter devices
flutter run -d android
flutter run -d chrome

## Estrutura do Código
```text
lib/
  main.dart
  app_state.dart
  database/        # Configuração, tabelas e helpers do SQLite
  models/          # Entidades (Aluno, Treino, Exercicio)
  pages/           # Interface do Usuário (Personal e Aluno)
  repositories/    # Acesso a dados (SQLite e Sessão)
  routes/          # Roteamento centralizado com GoRouter
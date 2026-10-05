# FitLog - Diário de Treinos

Aplicativo Flutter para acompanhamento de treinos semanais, com perfis de **Aluno** e **Personal Trainer**. O personal cadastra treinos e os atribui aos dias da semana de cada aluno; o aluno apenas visualiza a própria agenda.

## Integrantes e Divisão de Atividades (Parte 1)

* **Maria Beatriz**
  * Arquitetura geral (`models/`, `pages/`, `repositories/`), modelos de domínio, repositório reativo com `ChangeNotifier` + `AnimatedBuilder`, listagem e detalhe de treinos/exercícios.
* **Lucas Gabriel**
  * Módulo de autenticação/sessão (`SessaoRepository`, `LoginPage`), controle de papéis (Aluno/Personal), restrição de rotas e visão somente leitura do aluno.
* **João Gabriel**
  * Painel do Personal: cadastro de alunos, cadastro de treinos, formulários com validações e atribuição de treino por dia da agenda.

## Funcionalidades (Parte 1)

* **Login simulado** com e-mail e senha (validação de formulário + feedback).
* **Personal:** cadastro de treinos, exercícios e alunos, e atribuição treino → dia (sem atribuição = descanso).
* **Aluno:** visualiza apenas a própria semana e os detalhes dos exercícios; não edita dados.
* **Navegação** com **GoRouter** e redirects por sessão/papel.
* **Dados em memória** prontos para substituição por banco na Parte 2.

## Contas de demonstração

| Perfil   | E-mail               | Senha  |
|----------|----------------------|--------|
| Personal | personal@fitlog.com  | 123456 |
| Aluno 1  | aluno1@fitlog.com    | 123456 |
| Aluno 2  | aluno2@fitlog.com    | 123456 |

## Instalação e execução

### Pré-requisitos

* [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.x)
* Um dispositivo/emulador (Android, iOS, macOS ou Chrome)

### Passos

```bash
git clone <url-do-repositorio>
cd fitlog
flutter pub get
flutter run
```

Para escolher o destino:

```bash
flutter devices
flutter run -d macos
flutter run -d chrome
```

### Particularidades / limitações

* Os dados **não persistem** após fechar o app (repositório em memória).
* Autenticação é simulada (comparação local de e-mail/senha), sem backend.
* Pacote `provider` permanece no `pubspec` como dependência opcional; o estado usa `ChangeNotifier` + `AnimatedBuilder`, conforme padrão do grupo.

## Estrutura do código

```
lib/
  main.dart
  app_state.dart
  models/
  pages/
  repositories/
  routes/
```

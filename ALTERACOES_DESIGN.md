# Alterações de design do FitLog

Este documento registra as alterações realizadas na primeira entrega visual do
FitLog. A lógica de autenticação, os dados mockados, as rotas e os repositórios
foram preservados.

As mudanças de design foram consolidadas nos commits:

- `82469fd` — melhorias da tela de login;
- `4d1c3fa` — layout e design das demais telas.

## Padrão visual utilizado

As telas passaram a seguir um padrão comum:

```dart
final colors = Theme.of(context).colorScheme;
```

As cores são obtidas do `ColorScheme` definido no tema global, em vez de
espalhar `Colors.deepOrange` pelos componentes.

O fundo das telas utiliza um degradê:

```dart
DecoratedBox(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        colors.primaryContainer,
        colors.surface,
        colors.secondaryContainer.withValues(alpha: 0.4),
      ],
    ),
  ),
  child: ...,
)
```

Os formulários e os blocos de conteúdo utilizam cards:

```dart
Card(
  elevation: 0,
  color: colors.surface.withValues(alpha: 0.94),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(24),
    side: BorderSide(color: colors.outlineVariant),
  ),
  child: ...,
)
```

Também foram utilizados:

- `ColorScheme` para cores adaptáveis ao tema;
- `Card` e `RoundedRectangleBorder` para agrupamento visual;
- `DecoratedBox` e `LinearGradient` para fundos;
- `InkWell` para feedback visual de toque;
- `ConstrainedBox` para responsividade;
- `Wrap` para impedir overflow em telas menores;
- `AlertDialog` para listas auxiliares;
- componentes privados reutilizáveis dentro das páginas;
- `Tooltip` em ações com ícones;
- `flutter analyze` e `git diff --check` para validação.

## 1. Tela de login

Arquivo: [lib/pages/login_page.dart](lib/pages/login_page.dart)

### Alterações

- fundo com degradê;
- card central com largura máxima de 460 pixels;
- cabeçalho com ícone de academia;
- título e subtítulo;
- campos com ícones e dicas de preenchimento;
- botão para mostrar e ocultar senha;
- envio do formulário pelo teclado;
- mensagem de erro em um container destacado;
- botão de login com ícone;
- contas de demonstração organizadas em linhas;
- layout responsivo;
- `TextEditingController` para os campos.

### Trechos principais

```dart
final _emailController = TextEditingController();
final _senhaController = TextEditingController();
bool _senhaVisivel = false;
```

```dart
TextFormField(
  controller: _senhaController,
  obscureText: !_senhaVisivel,
  decoration: InputDecoration(
    prefixIcon: const Icon(Icons.lock_outline),
    suffixIcon: IconButton(
      tooltip: _senhaVisivel ? 'Ocultar senha' : 'Mostrar senha',
      onPressed: () {
        setState(() => _senhaVisivel = !_senhaVisivel);
      },
      icon: Icon(
        _senhaVisivel
            ? Icons.visibility_off_outlined
            : Icons.visibility_outlined,
      ),
    ),
  ),
)
```

As contas mockadas continuam sendo:

```text
personal@fitlog.com / 123456
aluno1@fitlog.com / 123456
aluno2@fitlog.com / 123456
```

## 2. Tela inicial do Personal

Arquivo: [lib/pages/home_page.dart](lib/pages/home_page.dart)

A `HomePage` continua escolhendo o painel de acordo com o papel do usuário.
A estilização foi aplicada principalmente à classe `_PersonalHome`.

### Alterações

- AppBar com cores do tema;
- card de boas-vindas com avatar e nome do Personal;
- fundo com degradê;
- cards de estatísticas;
- seção “Acesso rápido”;
- cards para abrir Treinos e Alunos;
- logout preservado;
- modal ao tocar nos cards de estatísticas.

### Estatísticas exibidas

```dart
final alunos = AppState.instance.usuarios.alunos;
final alunosComTreinos = alunos
    .where((aluno) => aluno.agenda.any((dia) => dia.treinoId != null))
    .length;
final alunosSemTreinos = alunos.length - alunosComTreinos;
```

Os três cards representam:

- total de alunos;
- total de alunos com pelo menos um treino;
- total de alunos sem treino.

### Modal dos cards

Cada card recebe uma ação:

```dart
onTap: () => _mostrarAlunos(
  context,
  titulo: 'Alunos com treinos',
  alunos: alunosFiltrados,
)
```

O modal apresenta nome, inicial e e-mail dos alunos. Quando a lista está
vazia, o componente `_EmptyStudentsState` mostra:

```text
Nenhum aluno encontrado.
```

## 3. Lista de treinos

Arquivo: [lib/pages/treinos_list_page.dart](lib/pages/treinos_list_page.dart)

### Alterações

- AppBar padronizada;
- fundo com degradê;
- cabeçalho “Biblioteca de treinos”;
- resumo com quantidade de treinos cadastrados;
- treinos apresentados em cards;
- foco muscular e quantidade de exercícios destacados;
- ações de abrir e excluir;
- estado vazio com mensagem orientativa;
- botão flutuante com tooltip.

### Componentes criados

- `_WorkoutSummary`;
- `_WorkoutCard`;
- `_EmptyWorkoutsState`.

### Trecho representativo

```dart
_WorkoutCard(
  title: treino.titulo,
  focus: treino.focado,
  exerciseCount: treino.exercicios.length,
  colors: colors,
  onTap: () => context.go('/treinos/${treino.id}'),
  onDelete: () { ... },
)
```

A exclusão continua limpando as referências do treino nas agendas dos alunos
antes de remover o treino do repositório.

## 4. Detalhes do treino e exercícios

Arquivo: [lib/pages/treino_detalhe_page.dart](lib/pages/treino_detalhe_page.dart)

### Alterações

- cabeçalho do treino em card;
- título e foco muscular;
- seção “Exercícios do treino”;
- exercícios transformados em cards;
- informações organizadas em chips;
- botões de editar e excluir;
- estado vazio;
- AppBar e botão flutuante padronizados;
- suporte mantido ao modo somente leitura do aluno.

### Informações do exercício

```dart
_ExerciseInfoChip(
  icon: Icons.repeat,
  label: '$series séries',
  colors: colors,
)
```

Também são exibidos:

```text
repetições
carga em kg
grupo muscular
```

Quando `somenteLeitura` é verdadeiro, os botões de edição, exclusão e adição
de exercício não aparecem.

## 5. Formulário de treino

Arquivo: [lib/pages/treino_form_page.dart](lib/pages/treino_form_page.dart)

### Alterações

- formulário centralizado;
- card com bordas arredondadas;
- fundo com degradê;
- cabeçalho contextual para novo/edição;
- ícones nos campos;
- textos de exemplo;
- botão com ícone;
- largura máxima de 560 pixels.

### Componente criado

```dart
_FormHeader(
  icon: Icons.fitness_center,
  title: isEdicao ? 'Editar treino' : 'Novo treino',
  subtitle: ...,
  colors: colors,
)
```

Os campos, validações, salvamento e redirecionamentos não foram alterados.

## 6. Formulário de exercício

Arquivo: [lib/pages/exercicio_form_page.dart](lib/pages/exercicio_form_page.dart)

### Alterações

- mesmo padrão visual do formulário de treino;
- cabeçalho contextual;
- ícones nos campos;
- dicas de preenchimento;
- campos numéricos organizados;
- botão de salvar/adicionar com ícone;
- card responsivo;
- suporte preservado para criação e edição.

### Componente criado

```dart
_ExerciseFormHeader(
  isEdicao: isEdicao,
  colors: colors,
)
```

As validações de séries, repetições, carga e grupo muscular continuam iguais.

## 7. Lista de alunos

Arquivo: [lib/pages/alunos_list_page.dart](lib/pages/alunos_list_page.dart)

### Alterações

- AppBar padronizada;
- fundo com degradê;
- cabeçalho “Alunos acompanhados”;
- resumo com quantidade de alunos;
- avatar com inicial;
- e-mail;
- quantidade de dias com treino;
- status para alunos com ou sem treino;
- cards clicáveis;
- botão de exclusão;
- estado vazio;
- botão flutuante para cadastro.

### Componentes criados

- `_StudentsSummary`;
- `_StudentCard`;
- `_EmptyStudentsState`.

### Status exibidos

```text
5 dia(s) com treino
```

ou:

```text
Nenhum treino atribuído
```

## 8. Agenda semanal do aluno na visão do Personal

Arquivo: [lib/pages/aluno_detalhe_page.dart](lib/pages/aluno_detalhe_page.dart)

Esta é a tela aberta quando o Personal seleciona um aluno. Ela não deve ser
confundida com a agenda do próprio aluno em `meu_treino_page.dart`.

### Alterações

- card com dados do aluno;
- avatar com inicial;
- e-mail;
- resumo de dias com treino e descanso;
- cards para cada dia da semana;
- destaque para treino ou descanso;
- indicação de que o dia pode ser configurado;
- botão de edição do aluno preservado.

### Componentes criados

- `_AgendaSummary`;
- `_AgendaSummaryItem`;
- `_AgendaDayCard`.

O toque em qualquer dia continua levando para:

```dart
context.go('/alunos/$alunoId/dias/${dia.diaSemana}')
```

## 9. Agenda semanal na visão do próprio aluno

Arquivo: [lib/pages/meu_treino_page.dart](lib/pages/meu_treino_page.dart)

Também foi melhorada a agenda que o aluno visualiza.

### Alterações

- cabeçalho “Sua semana de treinos”;
- resumo de dias de treino e descanso;
- cards para cada dia;
- treino e foco muscular;
- distinção visual entre treino e descanso;
- navegação para detalhes somente leitura.

### Componentes criados

- `_WeekSummary`;
- `_SummaryItem`;
- `_DayWorkoutCard`.

Dias com treino continuam abrindo:

```dart
context.go('/meu-treino/${dia.diaSemana}')
```

Dias de descanso permanecem sem navegação.

## 10. Atribuição de treino por dia

Arquivo: [lib/pages/atribuir_treino_page.dart](lib/pages/atribuir_treino_page.dart)

### Alterações

- cabeçalho “Agenda do aluno”;
- dia selecionado em destaque;
- fundo com degradê;
- opções de descanso e treino em cards;
- opção selecionada com borda e cor diferenciadas;
- ícones de seleção;
- botão “Salvar atribuição” com ícone;
- layout centralizado e responsivo.

### Componentes criados

- `_AssignmentHeader`;
- `_AssignmentOption`.

A atribuição continua sendo controlada por:

```dart
String? _treinoSelecionado;
```

Quando o valor é `null`, o dia continua representando descanso.

## 11. Formulário de aluno

Arquivo: [lib/pages/aluno_form_page.dart](lib/pages/aluno_form_page.dart)

### Alterações

- card centralizado;
- fundo com degradê;
- cabeçalho para novo/edição;
- ícones nos campos;
- dicas de preenchimento;
- botão com ícone;
- largura máxima para telas maiores;
- senha mantida como campo oculto.

### Componente criado

```dart
_StudentFormHeader(
  isEdicao: isEdicao,
  colors: colors,
)
```

As validações e o bloqueio de e-mail duplicado continuam funcionando:

```dart
if (AppState.instance.usuarios.emailEmUso(
  email,
  ignorarId: widget.alunoId,
)) {
  ...
}
```

## 12. Configuração Android adicionada pelo Flutter

Arquivo: [android/gradle.properties](android/gradle.properties)

Foram adicionadas pelo migrador do Flutter as propriedades:

```properties
android.builtInKotlin=false
android.newDsl=false
```

Essas propriedades fazem parte da configuração Android gerada pelo Flutter e
não alteram a lógica visual ou os dados da aplicação.

## O que não foi alterado

As seguintes partes permaneceram funcionais e conceitualmente iguais:

- `UsuarioRepository`;
- `TreinoRepository`;
- `SessaoRepository`;
- modelos de usuário, treino e exercício;
- contas mockadas;
- dados mockados de agendas;
- rotas do `GoRouter`;
- regras de acesso por perfil;
- autenticação local;
- persistência em memória;
- mensagens e redirecionamentos principais.

## Validação final

As alterações foram verificadas com:

```powershell
flutter analyze
git diff --check
```

Resultado:

```text
No issues found!
```

Os dados continuam sendo mockados e são perdidos ao encerrar o aplicativo.

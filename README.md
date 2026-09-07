# FitLog - Diário de Treinos

Aplicativo desenvolvido em Flutter para acompanhamento de treinos semanais, detalhamento de exercícios e controle de cargas e repetições, contando com uma arquitetura voltada para múltiplos perfis (Usuário e Personal Trainer).

## 👥 Integrantes e Divisão de Atividades (Parte 1)

* **Maria Beatriz**
  * **Atividades Desenvolvidas:** Arquitetura geral do projeto (estruturação de pastas), criação dos modelos de dados (`Exercicio` e `TreinoDia`), desenvolvimento do repositório em memória com padrão reativo (`ChangeNotifier`), implementação da tela de listagem semanal de treinos (`HomePage`) e da tela de detalhes do treino (`TreinoDetalhePage`).
* **Lucas Gabriel**
  * **Atividades Desenvolvidas:** Implementação do módulo de **Autenticação de Perfis** e controle de sessão (Alternância de visualização entre o painel do Aluno/Usuário e o painel do Personal Trainer).
* **João Gabriel**
  * **Atividades Desenvolvidas:** Desenvolvimento do **Painel do Personal Trainer** (interface dedicada para cadastro, edição e remoção de treinos por dia da semana) e refinamento do formulário de exercícios com validações avançadas de cargas e repetições.

---

## 📱 Funcionalidades Implementadas (Parte 1)

* **Seleção de Perfil (Autenticação Simulada):** Tela inicial que permite alternar entre o modo **Usuário (Aluno)** (focado em visualizar os treinos do dia e acompanhar cargas) e o modo **Personal Trainer** (focado na prescrição e gerenciamento de treinos).
* **Listagem Semanal:** Navegação pelos dias da semana (Segunda a Domingo) com visualização rápida dos treinos agendados.
* **Detalhes do Treino:** Listagem de exercícios específicos de cada dia, exibindo grupos musculares, séries, repetições e cargas estruturadas com divisores.
* **Formulário de Exercício Personalizado (Visão do Personal):** Tela para cadastro e edição de exercícios com validação de campos e feedback visual dinâmico.
* **Gerenciamento em Memória:** Dados estáticos gerenciados via padrão reativo simples (`ChangeNotifier` + `AnimatedBuilder`).

---

## 🛠️ Instruções de Instalação e Execução

1. Certifique-se de ter o [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado e configurado em sua máquina.
2. Clone o repositório para o seu ambiente local:
   ```bash
   git clone [https://github.com/seu-usuario/fitlog.git](https://github.com/seu-usuario/fitlog.git)
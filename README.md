# Mamba Fast Tracker. - Wellson Almeida

O **Mamba Fast Tracker** é um aplicativo mobile desenvolvido em Flutter para controle de jejum intermitente e registro de calorias. O objetivo é fornecer uma ferramenta simples, bonita e eficiente para usuários acompanharem suas janelas de jejum e ingestão calórica.

## 🚀 Como rodar o projeto

Este projeto utiliza o **FVM (Flutter Version Management)** para garantir consistência na versão do Flutter.

### Pré-requisitos
- Flutter SDK 3.38.5
- Dart SDK
- Android Studio / Xcode (para emuladores e build nativo)

### Passos
1.  **Clone o repositório e acesse a pasta:**
    ```bash
    git clone https://github.com/wellson/-Desafio-Tecnico-Mobile-Apps-Division.git
    cd mamba_fast_tracker
    ```

2.  **Instale as dependências:**
    ```bash
     flutter pub get
    ```

3.  **Gere os arquivos de código (para injeção de dependência e mocks):**
    ```bash
     flutter pub run build_runner build --delete-conflicting-outputs
    ```

4.  **Execute o aplicativo:**
    ```bash
     flutter run
    ```

##  APK - INSTALAÇÃO

- https://drive.google.com/file/d/1yoflfIN2469coUyz-QcWGH7qa-WOynOJ/view?usp=sharing

---

## 🛠 Stack Escolhida

-   **Linguagem:** Dart
-   **Framework:** Flutter (Versão 3.38.5)
-   **Gerenciamento de Versão:** FVM

---

## 🏛 Arquitetura Utilizada

O projeto segue os princípios da **Clean Architecture** para garantir testabilidade, escalabilidade e separação de responsabilidades. A estrutura de pastas reflete essa divisão:

-   **Presentation:** Contém a UI (Pages, Widgets) e o gerenciamento de estado (Cubits).
-   **Domain:** Contém as Regras de Negócio (Entities, Usecases) e Interfaces de Repositórios. Camada totalmente agnóstica a frameworks externos.
-   **Data:** Contém a implementação dos Repositórios e Fontes de Dados (Datasources - API/Local).
-   **Core:** Contém utilitários compartilhados, configurações de dependência, temas e serviços globais.

**Padrão de Gerenciamento de Estado:** **Cubit (Bloc)** foi escolhido por sua simplicidade e previsibilidade, sendo ideal para gerenciar fluxos de estado claros (ex: `FastingIdle` -> `FastingActive` -> `FastingCompleted`).

---

## 💡 Decisões Técnicas

1.  **Navegação Declarativa (`go_router`):**
    -   Escolhida para facilitar o gerenciamento de rotas, deep links (futuro) e redirecionamentos baseados em estado.

2.  **Persistência Local (`sqflite`):**
    -   Utilizado para armazenar históricos de jejum e refeições. Decisão baseada na necessidade de dados relacionais e estruturados localmente sem dependência de internet.

3.  **Segurança (`flutter_secure_storage`):**
    -   Embora o app seja majoritariamente offline, preparamos o terreno para autenticação (tokens), armazenando dados sensíveis de forma segura.

4.  **Serviço em Segundo Plano (`flutter_background_service`):**
    -   Implementação crítica para garantir que o timer de jejum continue preciso e notificando o usuário mesmo se o app for fechado ou o sistema matar o processo da UI.

5.  **Gráficos (`graphic`):**
    -   Biblioteca baseada na "Grammar of Graphics" (similar ao G2 do AntV), permitindo visualizações de dados (gráfico de calorias) altamente customizáveis e declarativas.

---

## 📚 Bibliotecas Utilizadas

As principais bibliotecas externas incluem:

-   **`flutter_bloc` / `bloc`:** Gerenciamento de estado.
-   **`get_it`:** Injeção de dependência (Service Locator).
-   **`equatable`:** Simplificação de comparação de objetos (útil para estados do Bloc).
-   **`go_router`:** Roteamento.
-   **`sqflite` / `path`:** Banco de dados SQLite.
-   **`flutter_local_notifications`:** Notificações locais.
-   **`flutter_background_service`:** Execução de código em background.
-   **`graphic`:** Renderização de gráficos.
-   **`dio`:** Cliente HTTP (preparado para futuras integrações de API).
-   **`mocktail` / `bloc_test`:** Testes unitários.

---

## ⚖️ Trade-offs Considerados

-   **SQLite vs Hive/SharedPrefs:**
    -   Optamos por SQLite pela robustez nas queries de histórico e relatórios futuros, aceitando o *boilerplate* maior em comparação a soluções NoSQL mais simples como Hive.

-   **Background Service vs Apenas Cálculo de Data:**
    -   Poderíamos apenas salvar o `startTime` e calcular a diferença ao abrir o app. Porém, para garantir notificações precisas e atualizações de timer na bandeja de notificações do Android em tempo real, optamos por um `BackgroundService` real, ao custo de maior consumo de bateria e complexidade de implementação.

-   **UI Customizada vs Material Padrão:**
    -   Investimos tempo criando uma identidade visual própria (Cores, Gráficos, Fontes) em vez de usar apenas os componentes padrão do Material 3, para entregar uma experiência de "produto real".

---

## 🚀 O que melhoraria com mais tempo

1.  **Sincronização em Nuvem:** Implementar um backend real (Firebase ou Custom API) para backup dos dados do usuário.
2.  **Testes de Integração:** Adicionar testes de fluxo completo (patrol/integration_test) para garantir que a UI e o Banco de Dados conversem perfeitamente.
3.  **Gamificação:** Adicionar conquistas e badges para motivar o usuário.
4.  **Relatórios Avançados:** Gráficos mais detalhados de tendências de peso x jejum.
5.  **CI/CD:** Configurar rotinas de build e deploy automático (ex: GitHub Actions + Fastlane).
6.  **Acessibilidade:** Melhorar os rótulos semânticos para leitores de tela.

---

## ⏱ Tempo Gasto no Desafio

O desenvolvimento foi realizado ao longo de aproximadamente **18 horas**, divididas entre planejamento, configuração de arquitetura, implementação de features (Timer, Banco de Dados, UI), correções de bugs (Background Service, Android Manifest) e documentação.

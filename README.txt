# StudyMate
O projeto tem como objetivo principal, auxiliar estudantes do ensino médio/fundamental, que precisam
de uma forma melhor de estudar usando uma IA como auxiliadora, usando de métodos de estudo eficazes 
tais como: flashcards e quizzes estilo ENEM
------------------------------------------------------------------------
## Alunos integrantes da equipe
- Artur Fernandes Braga de Menezes
- Davi Godoi Grilo
- Enzo de Melo Bolognani
- Joao Paulo Vaz de Melo Gonçalves
------------------------------------------------------------------------
## Professores responsáveis
- Cristiano Neves Rodrigues
------------------------------------------------------------------------
## Descrição Geral do Projeto *
O StudyMate é um aplicativo móvel desenvolvido em Flutter, focado em auxiliar estudantes do ensino fundamental e médio a otimizarem suas rotinas de aprendizado. O diferencial do projeto reside na utilização de Inteligência Artificial para potencializar métodos de estudo ativo, como a repetição espaçada via Flashcards e a prática de testes através de Quizzes (estilo ENEM).

A aplicação oferece um ambiente seguro e organizado, permitindo que o aluno salve seu progresso tanto localmente quanto na nuvem. O objetivo central é transformar o estudo passivo em uma experiência interativa e eficiente, utilizando tecnologia moderna para suprir as dificuldades comuns na preparação para provas e vestibulares.

## IMPORTANTE:
Caso não seja usado o método de chave de API local você devera entrar no site da open router (openrouter.ai), 
logar no site, gerar uma API key, ir nas linhas de código abaixo e em todas elas substituir "String.fromEnvironment("OPENROUTER_KEY")" por sua API key.

studymate\lib\screens\ai_screen.dart ; linha 27:
const apiKey = String.fromEnvironment("OPENROUTER_KEY");

studymate\lib\screens\flashcard_detail_screen.dart ; linha 45:
const openRouterKey = String.fromEnvironment("OPENROUTER_KEY");

studymate\lib\screens\quiz_detail_screen.dart; linha 28:
const openRouterKey = String.fromEnvironment("OPENROUTER_KEY");
------------------------------------------------------------------------
## Funcionalidades Principais *
- Geração de Conteúdo via IA (Quizzes e Flashcards)
- Sistema Robusto de Autenticação
- Integração com Firebase Authentication para cadastro e login seguro.
- Sincronização de Dados Híbrida
- Interface Organizada e Intuitiva
------------------------------------------------------------------------
## Estrutura do Repositório 
├── .dart_tool
    ├── package_config.json
    ├── package_graph.json
    └── version
├── pubspec.lock
└── studymate
    ├── .gitignore
    ├── .metadata
    ├── README.md
    ├── analysis_options.yaml
    ├── android
        ├── .gitignore
        ├── app
        │   ├── build.gradle.kts
        │   ├── google-services.json
        │   └── src
        │   │   ├── debug
        │   │       └── AndroidManifest.xml
        │   │   ├── main
        │   │       ├── AndroidManifest.xml
        │   │       ├── kotlin
        │   │       │   └── com
        │   │       │   │   └── example
        │   │       │   │       └── studymate
        │   │       │   │           └── MainActivity.kt
        │   │       └── res
        │   │       │   ├── drawable-v21
        │   │       │       └── launch_background.xml
        │   │       │   ├── drawable
        │   │       │       └── launch_background.xml
        │   │       │   ├── mipmap-hdpi
        │   │       │       └── ic_launcher.png
        │   │       │   ├── mipmap-mdpi
        │   │       │       └── ic_launcher.png
        │   │       │   ├── mipmap-xhdpi
        │   │       │       └── ic_launcher.png
        │   │       │   ├── mipmap-xxhdpi
        │   │       │       └── ic_launcher.png
        │   │       │   ├── mipmap-xxxhdpi
        │   │       │       └── ic_launcher.png
        │   │       │   ├── values-night
        │   │       │       └── styles.xml
        │   │       │   └── values
        │   │       │       └── styles.xml
        │   │   └── profile
        │   │       └── AndroidManifest.xml
        ├── build.gradle.kts
        ├── build
        │   └── reports
        │   │   └── problems
        │   │       └── problems-report.html
        ├── gradle.properties
        ├── gradle
        │   └── wrapper
        │   │   └── gradle-wrapper.properties
        └── settings.gradle.kts
    ├── assets
        └── logo_brain.png
    ├── firebase.json
    ├── ios
        ├── .gitignore
        ├── Flutter
        │   ├── AppFrameworkInfo.plist
        │   ├── Debug.xcconfig
        │   └── Release.xcconfig
        ├── Runner.xcodeproj
        │   ├── project.pbxproj
        │   ├── project.xcworkspace
        │   │   ├── contents.xcworkspacedata
        │   │   └── xcshareddata
        │   │   │   ├── IDEWorkspaceChecks.plist
        │   │   │   └── WorkspaceSettings.xcsettings
        │   └── xcshareddata
        │   │   └── xcschemes
        │   │       └── Runner.xcscheme
        ├── Runner.xcworkspace
        │   ├── contents.xcworkspacedata
        │   └── xcshareddata
        │   │   ├── IDEWorkspaceChecks.plist
        │   │   └── WorkspaceSettings.xcsettings
        ├── Runner
        │   ├── AppDelegate.swift
        │   ├── Assets.xcassets
        │   │   ├── AppIcon.appiconset
        │   │   └── LaunchImage.imageset
        │   │   │   ├── Contents.json
        │   │   │   ├── LaunchImage.png
        │   │   │   ├── LaunchImage@2x.png
        │   │   │   ├── LaunchImage@3x.png
        │   │   │   └── README.md
        │   ├── Base.lproj
        │   │   ├── LaunchScreen.storyboard
        │   │   └── Main.storyboard
        │   ├── Info.plist
        │   └── Runner-Bridging-Header.h
        └── RunnerTests
        │   └── RunnerTests.swift
    ├── lib
        ├── main.dart
        ├── screens
        │   ├── Profile_screen.dart
        │   ├── ai_screen.dart
        │   ├── cadastro.dart
        │   ├── firebase_options.dart
        │   ├── flashcard_detail_screen.dart
        │   ├── flashcards_screen.dart
        │   ├── home_screen.dart
        │   ├── login.dart
        │   ├── quiz_detail_screen.dart
        │   └── quizzes_screen.dart
        ├── theme
        │   ├── app_colors.dart
	│   └── theme_controller.dart
        └── widgets
        │   ├── progress_bar.dart
        │   ├── stat_card.dart
        │   └── topic_card.dart
    ├── linux
        ├── .gitignore
        ├── CMakeLists.txt
        ├── flutter
        │   ├── CMakeLists.txt
        │   ├── generated_plugin_registrant.cc
        │   ├── generated_plugin_registrant.h
        │   └── generated_plugins.cmake
        └── runner
        │   ├── CMakeLists.txt
        │   ├── main.cc
        │   ├── my_application.cc
        │   └── my_application.h
    ├── macos
        ├── .gitignore
        ├── Flutter
        │   ├── Flutter-Debug.xcconfig
        │   ├── Flutter-Release.xcconfig
        │   └── GeneratedPluginRegistrant.swift
        ├── Runner.xcodeproj
        │   ├── project.pbxproj
        │   ├── project.xcworkspace
        │   │   └── xcshareddata
        │   │   │   └── IDEWorkspaceChecks.plist
        │   └── xcshareddata
        │   │   └── xcschemes
        │   │       └── Runner.xcscheme
        ├── Runner.xcworkspace
        │   ├── contents.xcworkspacedata
        │   └── xcshareddata
        │   │   └── IDEWorkspaceChecks.plist
        ├── Runner
        │   ├── AppDelegate.swift
        │   ├── Assets.xcassets
        │   ├── Base.lproj
        │   │   └── MainMenu.xib
        │   ├── Configs
        │   │   ├── AppInfo.xcconfig
        │   │   ├── Debug.xcconfig
        │   │   ├── Release.xcconfig
        │   │   └── Warnings.xcconfig
        │   ├── DebugProfile.entitlements
        │   ├── Info.plist
        │   ├── MainFlutterWindow.swift
        │   └── Release.entitlements
        └── RunnerTests
        │   └── RunnerTests.swift
    ├── pubspec.lock
    ├── pubspec.yaml
    ├── test
        └── widget_test.dart
    ├── web
        ├── favicon.png
        ├── icons
        │   ├── Icon-192.png
        │   ├── Icon-512.png
        │   ├── Icon-maskable-192.png
        │   └── Icon-maskable-512.png
        ├── index.html
        └── manifest.json
    └── windows
        ├── .gitignore
        ├── CMakeLists.txt
        ├── flutter
            ├── CMakeLists.txt
            ├── generated_plugin_registrant.cc
            ├── generated_plugin_registrant.h
            └── generated_plugins.cmake
        └── runner
├── READ.me
.dart_tool/
  - GERENCIAMENTO INTERNO: Pasta gerada pelo Dart/Flutter SDK 
para armazenar metadados, cache e configurações de compilação.

studymate/ (Pasta Raiz do Projeto)

android/
  - PLATAFORMA ANDROID: Contém o projeto nativo (Kotlin/Java e Gradle) 
necessário para compilar e configurar o aplicativo para dispositivos Android.

assets/
  - RECURSOS (ASSETS): Armazena arquivos estáticos como imagens (logo_brain.png), 
fontes, ícones e outros recursos que não são código.

ios/
  - PLATAFORMA IOS: Contém o projeto nativo (Swift/Objective-C e Xcode) 
necessário para compilar e configurar o aplicativo para dispositivos iOS.

lib/
  - CÓDIGO FONTE DART: Contém todo o código-fonte principal do seu aplicativo 
(lógica e UI). É o núcleo do desenvolvimento Flutter.
  
  lib/screens/
    - TELAS PRINCIPAIS: Arquivos Dart que representam as páginas/telas completas 
do aplicativo (ex: login, home, perfil).

  lib/theme/
    - ESTILOS GLOBAIS: Contém arquivos de definição de temas, cores (app_colors.dart) 
e estilos visuais globais.

  lib/widgets/
    - COMPONENTES REUTILIZÁVEIS: Contém pequenos componentes de interface de usuário 
(UI) que são reutilizados em diferentes telas do app (ex: botões, cartões, barras de progresso).

linux/
  - PLATAFORMA LINUX: Arquivos necessários para compilar e executar o aplicativo 
como um software desktop no Linux.

macos/
  - PLATAFORMA MACOS: Arquivos necessários para compilar e executar o aplicativo 
como um software desktop no macOS.

test/
  - TESTES AUTOMATIZADOS: Contém os arquivos de testes de unidade e de widget para 
verificar a funcionalidade do código.

web/
  - PLATAFORMA WEB: Arquivos específicos para o build web (HTML, CSS, manifesto), 
permitindo que o app seja executado em navegadores.

windows/
  - PLATAFORMA WINDOWS: Arquivos necessários para compilar e executar o aplicativo 
como um software desktop no Windows.
------------------------------------------------------------------------
## Tecnologias utilizadas 
-Flutter
-Dart
-http
-shared_preferences
-firebase_core
-firebase_auth
-flutter_test
-flutter_lints
------------------------------------------------------------------------
## Instruções de utilização
### Clonar o repositório
git clone <https://github.com/D4v1G0D01/StudyMate.git>
### Acessar a pasta do projeto
cd <StudyMate>
### Instalar dependências
flutter pub get
### Executar o aplicativo
flutter run
------------------------------------------------------------------------
## Contribuição de cada integrante
- Arthur Fernandes: Implementação da IA para quizzes e flashcards 
- Davi Godoi: Wireframes, front-end do projeto, organização do GitHub (arquivos e READ.me)
- Enzo de Melo: banco de dados local e em nuvem do app 
- João Paulo: Implementação do login e autenticação do app usando firebase para limitar o acesso do 
usuário não cadastrado às funcionalidades do app
------------------------------------------------------------------------
## Limitações e melhorias futuras
- Dependência de Conexão: Como a geração de conteúdo via IA e o banco de dados em nuvem dependem de requisições HTTP e conexão com o Firebase, o app pode ter funcionalidades reduzidas em modo offline.
- Escopo da IA: A geração de perguntas depende da precisão da API utilizada; em temas muito específicos ou recentes, a IA pode gerar questões genéricas.
- Gamificação: Implementação de um sistema de níveis, conquistas (badges) e rankings semanais para aumentar o engajamento dos estudantes.
- Modo Offline Aprimorado: Expandir o uso do banco de dados local para permitir que o usuário baixe decks de flashcards inteiros para estudar sem internet, sincronizando o progresso quando a conexão retornar.
------------------------------------------------------------------------


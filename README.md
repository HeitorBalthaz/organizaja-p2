# OrganizaJá — Projeto Final P2

**Aplicativo de tarefas pessoais desenvolvido em Flutter, Dart e SQLite.**

O OrganizaJá permite que cada pessoa crie uma conta local, entre com e-mail e senha e gerencie suas próprias tarefas. O sistema funciona em Android, iOS e Chrome com persistência local (não requer Firebase para a demonstração).

> **Escopo acadêmico:** o login foi implementado localmente para a atividade. As senhas não são armazenadas em texto puro: são derivadas com PBKDF2-HMAC-SHA256 e salt individual; o identificador de sessão é armazenado usando `flutter_secure_storage`. Isso **não equivale a uma autenticação segura por servidor** nem oferece sincronização entre dispositivos. Não use dados reais sensíveis nesta demonstração.

## Funcionalidades

- Cadastro com nome, e-mail único e senha; validação de campos e confirmação da senha.
- Login, tratamento de credenciais inválidas, sessão local persistente e logout.
- Proteção da tela de formulário quando não há usuário autenticado.
- CRUD completo: criar, listar, editar e excluir tarefas.
- Marcar tarefa como concluída ou pendente.
- Prioridades baixa, média e alta; descrição e data de vencimento opcionais.
- Busca por título/descrição, filtros e indicadores de progresso.
- Isolamento das tarefas por ID de usuário no banco SQLite.
- Confirmação antes de excluir e mensagens de erro.
- Material Design 3 com interface responsiva em Português.

## Tecnologias

| Ferramenta | Utilização |
| --- | --- |
| Flutter e Dart | UI, estado e navegação de telas |
| sqflite | Banco de dados SQLite nativo em Android/iOS/macOS |
| sqflite_common_ffi_web | SQLite em WebAssembly com persistência no IndexedDB do Chrome |
| flutter_secure_storage | Persistência protegida do ID da sessão |
| cryptography + cryptography_flutter | PBKDF2 com salt individual e aceleração nas plataformas compatíveis |
| path | Montagem do caminho do banco SQLite |
| flutter_test | Testes unitários de modelo e validações |

## Preparando e executando o projeto

**Requisitos:** Flutter 3.41+ (Dart 3.10+), Android Studio/SDK para Android ou Xcode para iOS em macOS. O Flutter e o Android SDK devem estar configurados e `flutter doctor` sem erros bloqueantes.

Este ZIP traz o **código de aplicação, testes e pasta `web/`**. Os diretórios nativos `android/` e `ios/` são gerados pelo próprio Flutter instalado no computador, evitando incluir templates nativos desatualizados. Para o Chrome, o projeto também precisa gerar os arquivos `web/sqlite3.wasm` e `web/sqflite_sw.js` pelo comando indicado abaixo.

### Chrome (Flutter Web) — solução do erro no cadastro

O antigo projeto usava `sqflite` diretamente, que não inicializa o banco no Chrome. A versão atual usa o SQLite compilado para WebAssembly no navegador, guardando o arquivo de banco dentro do IndexedDB do site. Execute **na pasta que contém `pubspec.yaml`**:

```powershell
flutter pub get
dart run sqflite_common_ffi_web:setup
flutter run -d chrome --web-port 8080
```

O segundo comando gera os dois arquivos necessários ao SQLite Web. **Não pule essa etapa.** Caso atualize as dependências do SQLite posteriormente, execute `dart run sqflite_common_ffi_web:setup --force` para atualizar o worker.

Quando estiver pronto para publicar, execute:

```powershell
flutter build web --release
```

O resultado fica em `build/web/`. Publique toda essa pasta, incluindo `sqlite3.wasm` e `sqflite_sw.js`. O armazenamento do navegador é associado à origem (domínio e porta); para não parecer que as contas sumiram a cada execução, mantenha `--web-port 8080`. Limpar os dados do site no Chrome pode apagar usuários e tarefas locais. Para o armazenamento da sessão criptografada, o Web exige **HTTPS ou `localhost`**.

### Windows (PowerShell)

Abra o PowerShell dentro da pasta do projeto e execute:

```powershell
flutter doctor
powershell -ExecutionPolicy Bypass -File .\scripts\preparar_windows.ps1
flutter devices
flutter run
```

O script cria a estrutura Android que ainda estiver faltando, executa `flutter pub get` e desativa o backup automático do Android para evitar conflito com chaves do armazenamento seguro.

**Alternativa manual:**

```powershell
flutter create --project-name organizaja --platforms=android,web .
flutter pub get
dart run sqflite_common_ffi_web:setup
flutter run
```

No modo manual, altere a tag `<application>` no `android/app/src/main/AndroidManifest.xml` para incluir `android:allowBackup="false"`.

### macOS (Android ou iOS)

```bash
flutter doctor
bash scripts/preparar_macos.sh
flutter run
```

Também configure `android:allowBackup="false"` no Manifest, caso execute no Android. O iOS precisa de Xcode e assinatura configurada conforme necessário.

**Importante:** a versão do `flutter_secure_storage` utilizada exige Android API 23+. Se houver erro de `minSdk`, ajuste `minSdk = 23` no arquivo `android/app/build.gradle.kts` gerado (ou `minSdkVersion 23` se o projeto usar Groovy). Para Chrome, prepare primeiro os binários do SQLite Web.

## Testes e validações

```bash
flutter analyze
flutter test
```

Roteiro de verificação em celular/emulador:

1. Abrir o aplicativo, tentar entrar com conta inexistente e confirmar erro.
2. Criar conta com e-mail válido e senha de pelo menos 8 caracteres.
3. Tentar criar outra conta com o mesmo e-mail e observar a validação.
4. Criar tarefa com título, descrição, prioridade e prazo.
5. Verificar a tarefa na lista, editar seus dados e marcar como concluída.
6. Pesquisar e filtrar tarefas, excluir uma com confirmação.
7. Fazer logout, confirmar que o formulário de tarefas só abre após login.
8. Entrar novamente e conferir a persistência das tarefas.
9. Criar um segundo usuário e conferir que suas tarefas não aparecem na conta anterior.

## Organização do código

```text
lib/
├── main.dart                   # Tema, rotas e proteção de navegação
├── controllers/
│   └── session_controller.dart # Estado da sessão
├── models/
│   ├── app_user.dart           # Modelo do usuário
│   └── task_item.dart          # Modelo da tarefa
├── screens/
│   ├── login_screen.dart       # Login
│   ├── register_screen.dart    # Cadastro
│   ├── home_screen.dart        # Lista, filtros e dashboard
│   └── task_form_screen.dart   # Criar e editar
├── services/
│   ├── database_service.dart   # Tabelas SQLite
│   ├── auth_service.dart       # Cadastro, login, logout e hash
│   └── task_service.dart       # CRUD de tarefas
├── utils/
│   └── validators.dart         # Validação de formulários
└── widgets/
    ├── task_card.dart         # Cartão de tarefa
    └── empty_state.dart       # Estado vazio

test/
├── validators_test.dart
└── task_item_test.dart
```

## Como funciona o banco

O SQLite cria automaticamente o banco `organizaja.db` na primeira execução. No Android/iOS ele fica no armazenamento do aplicativo; no Chrome, os dados ficam no IndexedDB do navegador. Há duas tabelas:

**users:** `id`, `name`, `email` (único), `password_hash`, `password_salt`, `created_at`.

**tasks:** `id`, `user_id`, `title`, `description`, `completed`, `priority`, `due_date`, `created_at`.

O campo `user_id` é uma chave estrangeira para `users.id`. Todas as operações de leitura, edição e exclusão de tarefas usam o ID do usuário autenticado como filtro. O banco mantém os dados entre reinicializações, mas apenas **no mesmo dispositivo/navegador e origem**.

## Como funciona a navegação e a autenticação

1. `main.dart` inicializa o SQLite de forma preguiçosa (nativo ou WebAssembly) e tenta restaurar a sessão do armazenamento seguro.
2. O `SessionController` atualiza o estado de autenticação, e o `AnimatedBuilder` escolhe entre login e home.
3. O usuário pode navegar de login para cadastro pela rota `/register`.
4. Depois de entrar, a home permite navegar à rota `/task-form` para criar/editar tarefas.
5. Essa rota verifica se há usuário autenticado; se não houver, apresenta uma tela de acesso restrito.
6. Ao sair, a sessão local é apagada e a home volta para o login.

Os dados de senha nunca são salvos em texto puro. O projeto é um exercício offline: para autenticação de produção seriam necessários backend confiável, políticas de sessão, limites de tentativas e controles adicionais.

## Autoria

**Nome:** Heitor Faria Balthazar

**Curso:**  Desenvolvimento de Software Multiplataforma - 5°Semestre

**Disciplina:** Programação para Dispositivos Móveis II 

**Data:** 19 de Novembro de 2026

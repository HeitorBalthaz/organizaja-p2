# OrganizaJá — Gerenciador de Tarefas

**Projeto desenvolvido para a P2 da matéria de Programação Para dispositivos móveis II do 5° Semestre de Desenvolvimento de Software Multiplataforma na FATEC Osasco Prefeito Hirant Sanazar**  
**Aplicativo desenvolvido usando Flutter, Dart e SQLite**

## 1. Descrição do aplicativo

O **OrganizaJá** é um aplicativo de organização pessoal que ajuda o usuário a registrar, acompanhar e concluir suas tarefas do dia a dia.

O projeto foi desenvolvido para a P2, utilizando Flutter na interface e SQLite no armazenamento local. Cada pessoa pode criar uma conta e gerenciar sua própria lista de tarefas. O aplicativo não depende de uma conexão com um servidor para realizar as operações principais.

## 2. Funcionalidades principais

- **Cadastro de usuário:** criação de conta com nome, e-mail e senha, com validação dos campos.
- **Login e logout:** acesso às tarefas após autenticação e opção de encerrar a sessão.
- **Gerenciamento de tarefas (CRUD):** cadastrar, visualizar, editar e excluir tarefas.
- **Conclusão de tarefas:** marcar uma tarefa como concluída ou pendente.
- **Organização:** definir responsável, prioridade (baixa, média ou alta), descrição e data de vencimento.
- **Busca e filtros:** localizar tarefas por texto e visualizar tarefas pendentes ou concluídas.
- **Indicadores:** acompanhar a quantidade de tarefas e o progresso da lista.
- **Persistência local:** manter contas e tarefas salvas mesmo após fechar o aplicativo, desde que os dados locais não sejam apagados.
- **Separação por usuário:** cada conta visualiza e altera apenas suas próprias tarefas.

## 3. Tecnologias utilizadas

| Tecnologia | Finalidade |
| --- | --- |
| **Flutter** | Construção da interface do aplicativo e navegação entre telas. |
| **Dart** | Implementação das regras de negócio e das funcionalidades. |
| **SQLite** | Armazenamento local de usuários e tarefas. |
| **sqflite** | Acesso ao SQLite em dispositivos Android e outras plataformas nativas compatíveis. |
| **sqflite_common_ffi_web** | Execução do SQLite no navegador por meio de WebAssembly, com persistência no IndexedDB. |
| **flutter_secure_storage** | Armazenamento local do identificador da sessão do usuário. |
| **cryptography** | Geração e verificação do hash das senhas. |

## 4. Instruções para executar o projeto

### Pré-requisitos

- Flutter instalado e configurado, com Dart compatível com o projeto (**Dart 3.10 ou superior, abaixo de 4.0**).
- VS Code ou Android Studio.
- Google Chrome para executar a versão Web.
- Para Android, um emulador ou celular com depuração USB ativada e o Android SDK configurado.

Abra o terminal **na pasta que contém o arquivo `pubspec.yaml`**.

### Executar no Google Chrome

1. Instale as dependências:

   ```powershell
   flutter pub get
   ```

2. Prepare os arquivos necessários para o SQLite no navegador:

   ```powershell
   dart run sqflite_common_ffi_web:setup
   ```

3. Inicie o aplicativo:

   ```powershell
   flutter run -d chrome --web-port 8080
   ```

O SQLite Web utiliza arquivos WebAssembly e mantém os dados localmente no armazenamento do navegador. É recomendável usar a mesma porta ao testar para acessar a mesma base de dados local.

### Executar no Android (Windows)

Se a pasta `android/` ainda não existir, execute o script de preparação incluído no projeto:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\preparar_windows.ps1
```

Esse script prepara a estrutura Android, instala as dependências e configura o projeto para execução.

Depois, conecte um celular ou abra um emulador e execute:

```powershell
flutter devices
flutter run
```

Se houver mais de um dispositivo disponível, selecione o Android solicitado pelo Flutter ou informe seu identificador com `flutter run -d ID_DO_DISPOSITIVO`.

### Verificações do projeto

Para executar as verificações disponíveis no Flutter:

```powershell
flutter analyze
flutter test
```

Esses comandos verificam, respectivamente, possíveis problemas na análise estática e os testes automatizados incluídos no projeto.

## 5. Autenticação e base de dados

### Como funciona a autenticação

O usuário se cadastra informando nome, e-mail e senha. O sistema valida os dados e não permite duas contas com o mesmo e-mail.

Ao cadastrar uma senha, o aplicativo **não a grava em texto puro**. Ele utiliza **PBKDF2-HMAC-SHA256**, com um *salt* individual, para gerar um hash. Durante o login, a senha digitada é verificada a partir desse processo.

Depois de entrar, o identificador do usuário é salvo localmente por meio de `flutter_secure_storage`, permitindo restaurar a sessão. O logout remove essa identificação de sessão.

**Importante:** essa autenticação é local e foi desenvolvida para fins acadêmicos. Ela não utiliza um servidor de autenticação e não oferece sincronização entre dispositivos.

### Como funciona o banco SQLite

O banco de dados chama-se **`organizaja.db`** e é criado automaticamente na primeira execução. Ele contém duas tabelas principais:

| Tabela | Dados armazenados |
| --- | --- |
| **`users`** | Identificador do usuário, nome, e-mail, hash da senha, salt e data de cadastro. |
| **`tasks`** | Identificador da tarefa, usuário proprietário (`user_id`), nome do responsável (`responsible`), título, descrição, status de conclusão, prioridade, vencimento e data de criação. |

Cada tarefa possui um campo `user_id`, que identifica a conta à qual ela pertence. As consultas e alterações consideram esse identificador para manter as listas separadas.

O campo `responsible` é preenchido no formulário e exibido no card. O banco está na **versão 2**; instalações anteriores recebem a nova coluna automaticamente, sem excluir contas ou tarefas existentes.

No **Android**, o banco fica no armazenamento local do aplicativo. No **Chrome**, a implementação utiliza SQLite em WebAssembly, com persistência no **IndexedDB** do navegador. Os dados não são compartilhados automaticamente entre os dois ambientes.

## Estrutura principal do projeto

```text
lib/
├── main.dart                # Inicialização, tema e navegação
├── controllers/             # Controle da sessão
├── models/                  # Modelos de usuários e tarefas
├── screens/                 # Telas de login, cadastro, início e formulário
├── services/                # Autenticação, SQLite e operações com tarefas
├── utils/                   # Validações dos formulários
└── widgets/                 # Componentes reutilizáveis

test/                        # Testes automatizados
web/                         # Configuração da aplicação Web
scripts/                     # Preparação do ambiente de execução
```

## Identificação acadêmica

- **Aluno:** Heitor Faria Balthazar
- **Curso:** Desenvolvimento de Software Multiplataforma
- **Matéria:** Programação para Dispositivos Móveis II
- **Repositório:** https://github.com/HeitorBalthaz/organizaja-p2

---

*OrganizaJá — organize suas tarefas de forma simples e prática.*

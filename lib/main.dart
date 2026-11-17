import 'package:flutter/material.dart';

import 'controllers/session_controller.dart';
import 'models/task_item.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/task_form_screen.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'services/task_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = DatabaseService();
  final session = SessionController(AuthService(database));
  await session.restore();
  runApp(OrganizaJaApp(session: session, tasks: TaskService(database)));
}

class OrganizaJaApp extends StatelessWidget {
  const OrganizaJaApp({super.key, required this.session, required this.tasks});
  final SessionController session;
  final TaskService tasks;

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 9, 127, 4),
      brightness: Brightness.dark,
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OrganizaJá',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,

        // Fundo principal
        scaffoldBackgroundColor: const Color(0xFF111318),

        // Barra superior
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF111318),
          foregroundColor: Colors.white,
          centerTitle: false,
        ),

        // Campos de texto
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1D2028),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),

        // Cartões das tarefas
        cardTheme: CardThemeData(
          color: const Color(0xFF1D2028),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Colors.white12),
          ),
        ),
      ),
      home: AnimatedBuilder(
        animation: session,
        builder: (_, __) => session.authenticated
            ? HomeScreen(
                key: ValueKey('home_${session.user!.id}'),
                session: session,
                tasks: tasks,
              )
            : LoginScreen(session: session),
      ),
      onGenerateRoute: (settings) {
        if (settings.name == '/register') {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => RegisterScreen(session: session),
          );
        }
        if (settings.name == '/task-form') {
          final arg = settings.arguments;
          final task = arg is TaskItem ? arg : null;
          return MaterialPageRoute<bool>(
            settings: settings,
            builder: (_) => AnimatedBuilder(
              animation: session,
              builder: (_, __) => session.authenticated
                  ? TaskFormScreen(
                      session: session,
                      tasks: tasks,
                      existing: task,
                    )
                  : const _NotAuthenticatedScreen(),
            ),
          );
        }
        return null;
      },
    );
  }
}

class _NotAuthenticatedScreen extends StatelessWidget {
  const _NotAuthenticatedScreen();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Acesso restrito')),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_outline, size: 56),
          const SizedBox(height: 12),
          const Text('Faça login para acessar suas tarefas.'),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Voltar para o login'),
          ),
        ],
      ),
    ),
  );
}

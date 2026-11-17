import 'package:flutter/material.dart';

import '../controllers/session_controller.dart';
import '../models/task_item.dart';
import '../services/task_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/task_card.dart';

enum TaskFilter { all, pending, completed }

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.session,
    required this.tasks,
  });

  final SessionController session;
  final TaskService tasks;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<TaskItem> _all = [];
  bool _loading = true;
  TaskFilter _filter = TaskFilter.all;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final user = widget.session.user;
    if (user == null) return;
    setState(() => _loading = true);
    try {
      final list = await widget.tasks.list(user.id);
      if (!mounted) return;
      setState(() => _all = list);
    } catch (_) {
      if (mounted) _message('Não foi possível carregar as tarefas.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _message(String message) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(message)));

  Future<void> _openForm([TaskItem? task]) async {
    final result = await Navigator.of(context).pushNamed(
      '/task-form',
      arguments: task,
    );
    if (!mounted) return;
    if (result == true) await _reload();
  }

  Future<void> _toggle(TaskItem task) async {
    try {
      final ok = await widget.tasks.update(
        task.copyWith(completed: !task.completed),
      );
      if (!ok) throw StateError('Tarefa não encontrada');
      await _reload();
    } catch (_) {
      if (mounted) _message('Não foi possível atualizar a tarefa.');
    }
  }

  Future<void> _delete(TaskItem task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir tarefa?'),
        content: Text('“${task.title}” será excluída permanentemente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final ok = await widget.tasks.delete(task);
      if (!ok) throw StateError('Tarefa não encontrada');
      await _reload();
      if (mounted) _message('Tarefa excluída.');
    } catch (_) {
      if (mounted) _message('Não foi possível excluir a tarefa.');
    }
  }

  Future<void> _logout() async {
    try {
      await widget.session.logout();
    } catch (_) {
      if (mounted) _message('Não foi possível sair. Tente novamente.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.session.user;
    final pending = _all.where((e) => !e.completed).length;
    final done = _all.where((e) => e.completed).length;
    final query = _search.trim().toLowerCase();
    final visible = _all.where((task) {
      final matchesFilter = switch (_filter) {
        TaskFilter.all => true,
        TaskFilter.pending => !task.completed,
        TaskFilter.completed => task.completed,
      };
      final matchesSearch = query.isEmpty ||
          task.title.toLowerCase().contains(query) ||
          task.description.toLowerCase().contains(query);
      return matchesFilter && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('OrganizaJá', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: 'Sair da conta',
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'new_task',
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Nova tarefa'),
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 110),
              children: [
                Text(
                  'Olá, ${user?.name.split(' ').first ?? 'usuário'}!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 5),
                Text('Organize seus compromissos e acompanhe seu progresso.',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _Counter(label: 'Total', number: _all.length,
                        icon: Icons.list_alt_outlined)),
                    const SizedBox(width: 9),
                    Expanded(child: _Counter(label: 'Pendentes', number: pending,
                        icon: Icons.timelapse_outlined)),
                    const SizedBox(width: 9),
                    Expanded(child: _Counter(label: 'Concluídas', number: done,
                        icon: Icons.check_circle_outline)),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Minhas tarefas',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        )),
                const SizedBox(height: 13),
                TextField(
                  onChanged: (value) => setState(() => _search = value),
                  decoration: const InputDecoration(
                    hintText: 'Pesquisar tarefas',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Todas'),
                      selected: _filter == TaskFilter.all,
                      onSelected: (_) => setState(() => _filter = TaskFilter.all),
                    ),
                    ChoiceChip(
                      label: const Text('Pendentes'),
                      selected: _filter == TaskFilter.pending,
                      onSelected: (_) => setState(() => _filter = TaskFilter.pending),
                    ),
                    ChoiceChip(
                      label: const Text('Concluídas'),
                      selected: _filter == TaskFilter.completed,
                      onSelected: (_) => setState(() => _filter = TaskFilter.completed),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.all(36),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (visible.isEmpty)
                  EmptyState(hasFilter: _filter != TaskFilter.all || query.isNotEmpty)
                else
                  ...visible.map((task) => TaskCard(
                        key: ValueKey(task.id),
                        task: task,
                        onToggle: () => _toggle(task),
                        onEdit: () => _openForm(task),
                        onDelete: () => _delete(task),
                      )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter({
    required this.label,
    required this.number,
    required this.icon,
  });

  final String label;
  final int number;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 17),
          child: Column(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 6),
              Text('$number',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      )),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(label, style: Theme.of(context).textTheme.labelMedium),
              ),
            ],
          ),
        ),
      );
}

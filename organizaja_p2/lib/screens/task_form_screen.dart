import 'package:flutter/material.dart';

import '../controllers/session_controller.dart';
import '../models/task_item.dart';
import '../services/task_service.dart';
import '../utils/validators.dart';

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({
    super.key,
    required this.session,
    required this.tasks,
    this.existing,
  });
  final SessionController session;
  final TaskService tasks;
  final TaskItem? existing;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late int _priority;
  DateTime? _dueDate;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.existing?.title ?? '');
    _description = TextEditingController(text: widget.existing?.description ?? '');
    _priority = widget.existing?.priority ?? 2;
    _dueDate = widget.existing?.dueDate;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  String _date(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final chosen = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: _dueDate ?? now,
      helpText: 'Prazo da tarefa',
    );
    if (chosen != null && mounted) setState(() => _dueDate = chosen);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _busy) return;
    final user = widget.session.user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Faça login novamente.')),
      );
      return;
    }
    setState(() => _busy = true);
    final existing = widget.existing;
    final item = TaskItem(
      id: existing?.id,
      userId: user.id,
      title: _title.text.trim(),
      description: _description.text.trim(),
      completed: existing?.completed ?? false,
      priority: _priority,
      dueDate: _dueDate,
      createdAt: existing?.createdAt ?? DateTime.now(),
    );
    try {
      if (existing == null) {
        await widget.tasks.create(item);
      } else {
        final ok = await widget.tasks.update(item);
        if (!ok) throw StateError('Tarefa não encontrada');
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao salvar tarefa.')),
      );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final edit = widget.existing != null;
    return Scaffold(
      appBar: AppBar(title: Text(edit ? 'Editar tarefa' : 'Nova tarefa')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      edit ? 'Atualize os detalhes' : 'O que você precisa fazer?',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _title,
                      enabled: !_busy,
                      textCapitalization: TextCapitalization.sentences,
                      maxLength: 80,
                      textInputAction: TextInputAction.next,
                      validator: Validators.taskTitle,
                      decoration: const InputDecoration(
                        labelText: 'Título da tarefa',
                        prefixIcon: Icon(Icons.title),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _description,
                      enabled: !_busy,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 4,
                      maxLength: 500,
                      validator: Validators.taskDescription,
                      decoration: const InputDecoration(
                        labelText: 'Descrição (opcional)',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<int>(
                      initialValue: _priority,
                      decoration: const InputDecoration(
                        labelText: 'Prioridade', prefixIcon: Icon(Icons.flag_outlined),
                      ),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('Baixa')),
                        DropdownMenuItem(value: 2, child: Text('Média')),
                        DropdownMenuItem(value: 3, child: Text('Alta')),
                      ],
                      onChanged: _busy ? null : (value) {
                        if (value != null) setState(() => _priority = value);
                      },
                    ),
                    const SizedBox(height: 18),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(_dueDate == null
                                  ? 'Sem data de vencimento'
                                  : 'Prazo: ${_date(_dueDate!)}'),
                            ),
                            if (_dueDate != null)
                              IconButton(
                                tooltip: 'Remover prazo',
                                onPressed: _busy ? null : () => setState(() => _dueDate = null),
                                icon: const Icon(Icons.close),
                              ),
                            TextButton(
                              onPressed: _busy ? null : _pickDate,
                              child: const Text('Escolher'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _busy ? null : _save,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 17),
                      ),
                      icon: const Icon(Icons.save_outlined),
                      label: Text(_busy
                          ? 'Salvando...'
                          : edit ? 'Salvar alterações' : 'Criar tarefa'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

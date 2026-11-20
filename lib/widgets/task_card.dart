import 'package:flutter/material.dart';

import '../models/task_item.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final TaskItem task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  String _date(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';

  @override
  Widget build(BuildContext context) {
    final priority = switch (task.priority) {
      1 => 'Baixa',
      3 => 'Alta',
      _ => 'Média',
    };
    final priorityColor = switch (task.priority) {
      1 => Colors.green,
      3 => Colors.deepOrange,
      _ => Colors.blue,
    };
    final overdue =
        task.dueDate != null &&
        !task.completed &&
        DateUtils.dateOnly(
          task.dueDate!,
        ).isBefore(DateUtils.dateOnly(DateTime.now()));
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Tooltip(
              message: task.completed ? 'Marcar pendente' : 'Concluir tarefa',
              child: Checkbox(
                value: task.completed,
                onChanged: (_) => onToggle(),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 7),
                  Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      decoration: task.completed
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 17),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          'Responsável: ${task.responsible.isEmpty ? 'Não informado' : task.responsible}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 9,
                    runSpacing: 5,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.flag_outlined,
                            size: 16,
                            color: priorityColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            priority,
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ],
                      ),
                      if (task.dueDate != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.event_outlined,
                              size: 16,
                              color: overdue ? Colors.red : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _date(task.dueDate!),
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: overdue ? Colors.red.shade700 : null,
                                  ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  tooltip: 'Editar tarefa',
                  icon: const Icon(Icons.edit_outlined, size: 21),
                  onPressed: onEdit,
                ),
                IconButton(
                  tooltip: 'Excluir tarefa',
                  icon: const Icon(Icons.delete_outline, size: 21),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

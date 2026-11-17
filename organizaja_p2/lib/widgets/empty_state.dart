import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.hasFilter});
  final bool hasFilter;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 42),
        child: Column(
          children: [
            Icon(
              hasFilter ? Icons.search_off_outlined : Icons.task_alt_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 15),
            Text(
              hasFilter ? 'Nenhuma tarefa encontrada' : 'Sua lista está vazia',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              hasFilter
                  ? 'Experimente mudar o filtro ou a pesquisa.'
                  : 'Toque em “Nova tarefa” para começar.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
}

import 'package:flutter_test/flutter_test.dart';
import 'package:organizaja/models/task_item.dart';

void main() {
  test('modelo converte para mapa e volta sem perder os dados', () {
    final task = TaskItem(
      id: 7,
      userId: 3,
      title: 'Entregar P2',
      description: 'Enviar ao GitHub',
      responsible: 'Heitor',
      priority: 3,
      dueDate: DateTime(2026, 11, 18),
      createdAt: DateTime.utc(2026, 11, 11), 
    );
    final restored = TaskItem.fromMap({'id': 7, ...task.toMap()});
    expect(restored.userId, 3);
    expect(restored.title, 'Entregar P2');
    expect(restored.responsible, 'Heitor');
    expect(restored.dueDate!.day, 18);
    expect(restored.priority, 3);
    expect(restored.completed, false);
    expect(restored.copyWith(completed: true).completed, true);
    expect(restored.copyWith(completed: true).responsible, 'Heitor');
    expect(task.toMap()['responsible'], 'Heitor');
  });

  test('tarefa antiga sem campo responsible não quebra a listagem', () {
    final antiga = TaskItem.fromMap({
      'id': 1,
      'user_id': 1,
      'title': 'Tarefa antiga',
      'description': '',
      'completed': 0,
      'priority': 2,
      'due_date': null,
      'created_at': DateTime.utc(2026, 11, 1).toIso8601String(),
    });
    expect(antiga.responsible, '');
  });
}

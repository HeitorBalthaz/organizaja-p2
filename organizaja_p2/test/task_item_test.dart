import 'package:flutter_test/flutter_test.dart';
import 'package:organizaja/models/task_item.dart';

void main() {
  test('modelo converte para mapa e volta sem perder os dados', () {
    final task = TaskItem(
      id: 7,
      userId: 3,
      title: 'Entregar P2',
      description: 'Enviar ao GitHub',
      priority: 3,
      dueDate: DateTime(2026, 11, 18),
      createdAt: DateTime.utc(2026, 11, 11),
    );
    final restored = TaskItem.fromMap({'id': 7, ...task.toMap()});
    expect(restored.userId, 3);
    expect(restored.title, 'Entregar P2');
    expect(restored.dueDate!.day, 18);
    expect(restored.priority, 3);
    expect(restored.completed, false);
    expect(restored.copyWith(completed: true).completed, true);
  });
}

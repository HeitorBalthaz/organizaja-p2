class TaskItem {
  const TaskItem({
    this.id,
    required this.userId,
    required this.title,
    required this.responsible,
    this.description = '',
    this.completed = false,
    this.priority = 2,
    this.dueDate,
    required this.createdAt,
  });

  final int? id;
  final int userId;
  final String title;
  final String description;
  final String responsible;
  final bool completed;
  final int priority; // 1 = baixa, 2 = média, 3 = alta
  final DateTime? dueDate;
  final DateTime createdAt;

  Map<String, Object?> toMap() => {
    'user_id': userId,
    'title': title,
    'description': description,
    'responsible': responsible,
    'completed': completed ? 1 : 0,
    'priority': priority,
    'due_date': dueDate == null
        ? null
        : '${dueDate!.year.toString().padLeft(4, '0')}-'
              '${dueDate!.month.toString().padLeft(2, '0')}-'
              '${dueDate!.day.toString().padLeft(2, '0')}',
    'created_at': createdAt.toUtc().toIso8601String(),
  };

  factory TaskItem.fromMap(Map<String, Object?> map) => TaskItem(
    id: map['id'] as int,
    userId: map['user_id'] as int,
    title: map['title'] as String,
    description: map['description'] as String,
    // Registros anteriores à migração não tinham esse campo.
    responsible: map['responsible'] as String? ?? '',
    completed: (map['completed'] as int) == 1,
    priority: map['priority'] as int,
    dueDate: map['due_date'] == null
        ? null
        : DateTime.parse(map['due_date'] as String),
    createdAt: DateTime.parse(map['created_at'] as String),
  );

  TaskItem copyWith({
    String? title,
    String? description,
    String? responsible,
    bool? completed,
    int? priority,
    DateTime? dueDate,
    bool clearDueDate = false,
  }) => TaskItem(
    id: id,
    userId: userId,
    title: title ?? this.title,
    description: description ?? this.description,
    completed: completed ?? this.completed,
    priority: priority ?? this.priority,
    dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
    createdAt: createdAt,
    responsible: responsible ?? this.responsible,
  );
}

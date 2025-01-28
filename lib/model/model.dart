import 'package:hive/hive.dart';

part 'model.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String dueDate;

  @HiveField(2)
  final String time;

  @HiveField(3)
  String priority;

  @HiveField(4)
  bool isCompleted;

  Task(
    {
      required this.title,
      required this.dueDate,
      required this.time,
      required this.priority,
      required this.isCompleted,
    }
  );
}

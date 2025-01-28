import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:to_do/model/model.dart';

class TaskProvider with ChangeNotifier {
  final Box<Task> taskBox = Hive.box<Task>('tasks');

  List<Task> get tasks => taskBox.values.toList();

  void addTask(Task task) {
    taskBox.add(task);
    notifyListeners();
  }

  void updateTask(int index, Task task) {
    taskBox.putAt(index, task);
    notifyListeners();
  }

  void deleteTask(int index) {
    taskBox.deleteAt(index);
    notifyListeners();
  }

  void toggleTaskCompletion(int index) {
    final task = taskBox.getAt(index)!;
    task.isCompleted = !task.isCompleted;
    taskBox.putAt(index, task);
    notifyListeners();
  }

}
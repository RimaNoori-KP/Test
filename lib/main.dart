import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:to_do/view/add.dart';
import 'package:to_do/view/edit.dart';
import 'package:to_do/model/model.dart';
import 'package:to_do/control/function.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  await Hive.openBox<Task>('tasks');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        final tasks = provider.tasks;

        return Scaffold(
          appBar: AppBar(
            title: const Text('My To-Dos'),
            titleTextStyle: const TextStyle(fontSize: 25, color: Colors.white),
            centerTitle: true,
            backgroundColor: Colors.teal,
          ),
          body: tasks.isEmpty
              ? Center(
                  child: Text(
                    'No tasks added. Tap + to add one!',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                )
              : ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return TaskCard(
                      task: task,
                      onEdit: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditTaskScreen(task: task, index: index),
                          ),
                        );
                      },
                      onDelete: () => provider.deleteTask(index),
                      onToggleCompletion: () => provider.toggleTaskCompletion(index),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.teal,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddTaskScreen()),
              );
            },
            child: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleCompletion;

  const TaskCard({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleCompletion,
  });

  Color getPriorityColor(String priority) {
    return {
      'High': const Color.fromARGB(255, 250, 113, 104),
      'Medium': const Color.fromARGB(255, 248, 179, 5),
      'Low': const Color.fromARGB(255, 93, 203, 97),
    }[priority] ?? Colors.white;
  }

  String formatTime(String time) {
    try {
      final timeParts = time.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final period = hour >= 12 ? 'PM' : 'AM';
      final formattedHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '${formattedHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return time; // Return original time if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Container(
        color: getPriorityColor(task.priority),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Checkbox(
                value: task.isCompleted,
                onChanged: (_) => onToggleCompletion(),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Due Date: ${task.dueDate}',
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Time: ${formatTime(task.time)}',
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Priority: ${task.priority}',
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Color.fromARGB(255, 6, 125, 83)),
                    onPressed: onEdit,
                  ),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: Colors.teal,
                            title: Center(
                              child: Column(
                                children: [
                                  const Text(
                                    'Do you want to delete this Task?',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 19,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 55),
                                  const Divider(thickness: 2,color: Color.fromARGB(255, 1, 95, 86)),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(color: Color.fromARGB(255, 235, 234, 234), fontSize: 20),
                                        ),
                                      ),
                                      Container(
                                        height: 35,
                                        width: 2,
                                        color: const Color.fromARGB(255, 1, 95, 86),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          onDelete();
                                          Navigator.pop(context); 
                                        },
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(
                                            color: Color.fromARGB(255, 252, 21, 5),
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Icon(
                      Icons.delete,
                      color: Colors.red[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do/model/model.dart';
import 'package:to_do/control/function.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AddTaskScreen(),
    );
  }
}

class AddTaskScreen extends StatelessWidget {
  const AddTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController dateController = TextEditingController();
    final TextEditingController timeController = TextEditingController();
    final ValueNotifier<String> selectedPriority = ValueNotifier<String>('Medium');

    void pickDate() {
      showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      ).then((pickedDate) {
        if (pickedDate != null) {
          dateController.text = "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
        }
      });
    }

    void pickTime() {
      showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      ).then((pickedTime) {
        if (pickedTime != null) {
          timeController.text = "${pickedTime.hour}:${pickedTime.minute}";
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Task',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Task Title',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter task title',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Date',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: dateController,
                        readOnly: true,
                        onTap: pickDate,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Select date',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Time',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: timeController,
                        readOnly: true,
                        onTap: pickTime,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Select time',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Priority',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<String>(
              valueListenable: selectedPriority,
              builder: (context, value, _) {
                return DropdownButtonFormField<String>(
                  value: value,
                  items: const [
                    DropdownMenuItem(value: 'High', child: Text('High', style: TextStyle(color: Color.fromARGB(255, 211, 17, 3)),)),
                    DropdownMenuItem(value: 'Medium', child: Text('Medium', style: TextStyle(color: Color.fromARGB(255, 245, 181, 4)))),
                    DropdownMenuItem(value: 'Low', child: Text('Low', style: TextStyle(color: Color.fromARGB(255, 63, 146, 66)))),
                  ],
                  onChanged: (newValue) {
                    if (newValue != null) {
                      selectedPriority.value = newValue;
                    }
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Select priority',
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  final task = Task(
                    title: titleController.text,
                    dueDate: dateController.text,
                    time: timeController.text,
                    priority: selectedPriority.value,
                    isCompleted: false,
                  );
                  Provider.of<TaskProvider>(context, listen: false).addTask(task);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:task_manager/add_task.dart';
import 'package:task_manager/edit_task.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Manager',
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, String>> tasks = [];
  String? selectedPriority;

  Future<void> _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tasksString = prefs.getString('tasks');
    if (tasksString != null) {
      List<dynamic> decodedTasks = jsonDecode(tasksString);
      setState(() {
        tasks.clear();
        tasks.addAll(
          decodedTasks.map((e) => Map<String, String>.from(e)).toList(),
        );
      });
    }
  }

  Future<void> _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('tasks', jsonEncode(tasks));
  }

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _editTask(int index) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => EditTask(
              task: tasks[index],
              onSave: (updatedTask) {
                setState(() {
                  tasks[index] = updatedTask;
                });
                _saveTasks();
              },
            ),
      ),
    );
  }

  void _toggleTaskCompletion(int index) async {
    setState(() {
      tasks[index]["completed"] =
          tasks[index]["completed"] == "yes" ? "no" : "yes";
    });
    _saveTasks();
  }

  void _deleteTask(int index) async {
    setState(() {
      tasks.removeAt(index);
    });
    _saveTasks();
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Filter by Priority"),
              DropdownButton<String>(
                value: selectedPriority,
                hint: const Text("Select Priority"),
                items:
                    ["High", "Medium", "Low"].map((priority) {
                      return DropdownMenuItem<String>(
                        value: priority,
                        child: Text(priority),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedPriority = value;
                  });
                  Navigator.pop(context);
                },
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedPriority = null;
                  });
                  Navigator.pop(context);
                },
                child: const Text("Clear Filter"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> filteredTasks =
        selectedPriority == null
            ? tasks
            : tasks
                .where((task) => task['priority'] == selectedPriority)
                .toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Task Manager'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _openFilterSheet,
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 120),
            child: ListView.builder(
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _editTask(index),
                  child: GlassmorphismTaskCard(
                    task: filteredTasks[index],
                    onToggleCompletion: () => _toggleTaskCompletion(index),
                    onDelete: () => _deleteTask(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTask = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTask()),
          );
          if (newTask != null) {
            setState(() {
              tasks.add(newTask);
            });
            _saveTasks();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class GlassmorphismTaskCard extends StatelessWidget {
  final Map<String, String> task;
  final VoidCallback onToggleCompletion;
  final VoidCallback onDelete;

  const GlassmorphismTaskCard({
    super.key,
    required this.task,
    required this.onToggleCompletion,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.skew(0.05, 0.05),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.2 * 255).toInt()),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withAlpha((0.3 * 255).toInt()),
                ),
              ),
              child: ListTile(
                title: Text(
                  task["title"]!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  "Priority: ${task["priority"]}\nDue: ${task["dueDateTime"]}",
                  style: TextStyle(
                    color: Colors.white.withAlpha((0.7 * 255).toInt()),
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: onToggleCompletion,
                      child: Icon(
                        task["completed"] == "yes"
                            ? Icons.check_circle
                            : Icons.cancel,
                        color:
                            task["completed"] == "yes"
                                ? Colors.greenAccent
                                : Colors.redAccent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onDelete,
                      child: const Icon(Icons.delete, color: Colors.redAccent),
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

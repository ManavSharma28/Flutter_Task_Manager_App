import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditTask extends StatefulWidget {
  final Map<String, String> task;
  final Function(Map<String, String>) onSave;

  const EditTask({super.key, required this.task, required this.onSave});

  @override
  State<EditTask> createState() => _EditTaskState();
}

class _EditTaskState extends State<EditTask> {
  late TextEditingController _taskController;
  late String _selectedPriority;
  DateTime? _selectedDateTime;
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();
    _taskController = TextEditingController(text: widget.task["title"]);
    _selectedPriority = widget.task["priority"] ?? "Medium";
    _selectedDateTime =
        widget.task["dueDateTime"] != null
            ? DateFormat.yMMMd().add_jm().parse(widget.task["dueDateTime"]!)
            : DateTime.now();
    _isCompleted = widget.task["completed"] == "yes";
  }

  Future<void> _pickDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime!),
      );
      if (pickedTime != null && mounted) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _saveTask() {
    if (_taskController.text.isEmpty || _selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("All fields must be filled."),
          backgroundColor: Colors.white,
        ),
      );
      return;
    }

    widget.onSave({
      "title": _taskController.text,
      "priority": _selectedPriority,
      "dueDateTime": DateFormat.yMMMd().add_jm().format(_selectedDateTime!),
      "completed": _isCompleted ? "yes" : "no",
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Edit Task',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveTask),
        ],
        centerTitle: true,
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
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextField(
                  controller: _taskController,
                  decoration: const InputDecoration(
                    labelText: "Edit Task Name",
                  ),
                ),
                SizedBox(height: 10),
                Column(
                  children: [
                    Text('Change Task Priority'),
                    DropdownButton<String>(
                      value: _selectedPriority,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedPriority = newValue!;
                        });
                      },
                      items:
                          ["High", "Medium", "Low"].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Column(
                  children: [
                    TextButton(
                      onPressed: _pickDateTime,
                      child: const Text("Change Due Date and Time"),
                    ),
                    Text(
                      _selectedDateTime != null
                          ? "Selected Date and Time: ${DateFormat.yMMMd().add_jm().format(_selectedDateTime!)}"
                          : "No date selected",
                    ),
                    SizedBox(height: 10),
                  ],
                ),
                SizedBox(height: 10),
                CheckboxListTile(
                  title: const Text('Completed'),
                  value: _isCompleted,
                  onChanged: (value) {
                    setState(() {
                      _isCompleted = value!;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

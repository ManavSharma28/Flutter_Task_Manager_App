import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddTask extends StatefulWidget {
  const AddTask({super.key});

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  final TextEditingController _taskController = TextEditingController();
  String _selectedPriority = "Medium";
  DateTime? _selectedDateTime;

  Future<void> _pickDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
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

  void _validateAndSubmit() {
    if (_taskController.text.isEmpty || _selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields before adding the task."),
          backgroundColor: Colors.white,
        ),
      );
      return;
    }

    Navigator.pop(context, {
      "title": _taskController.text,
      "priority": _selectedPriority,
      "dueDateTime": DateFormat.yMMMd().add_jm().format(_selectedDateTime!),
      "Completed": "No",
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Add New Task"),
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
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: TextField(
                    controller: _taskController,
                    decoration: InputDecoration(labelText: "Task Name"),
                  ),
                ),
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
                TextButton(
                  onPressed: _pickDateTime,
                  child: Text("Pick Due Date and Time"),
                ),
                SizedBox(height: 8),
                if (_selectedDateTime != null)
                  Text(
                    "Selected Date and Time: ${DateFormat.yMMMd().add_jm().format(_selectedDateTime!)}",
                  ),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _validateAndSubmit,
                  child: Text("Add Task"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

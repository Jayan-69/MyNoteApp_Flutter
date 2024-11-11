import 'package:flutter/material.dart';
import 'note_model.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart';

class NoteEditor extends StatefulWidget {
  final Note? note;
  final bool isDarkMode;

  NoteEditor({this.note, required this.isDarkMode});

  @override
  _NoteEditorState createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _priority = 'Medium';
  String _category = '';

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _priority = widget.note!.priority;
    }
  }

  Future<void> _saveNote() async {
    String title = _titleController.text;
    String content = _contentController.text;
    String date = DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now());

    if (widget.note == null) {
      Note newNote = Note(
        title: title,
        content: content,
        dateTime: DateTime.now(),
        priority: _priority,
        date: date,
        category: _category,
      );
      await DatabaseHelper.instance.insert(newNote);
    } else {
      Note updatedNote = Note(
        id: widget.note!.id,
        title: title,
        content: content,
        dateTime: DateTime.now(),
        priority: _priority,
        date: date,
        category: _category,
      );
      await DatabaseHelper.instance.update(updatedNote);
    }

    Navigator.pop(context, true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Note saved successfully")),
    );
  }

  // Function to return color based on priority
  Color getPriorityColor(String priority) {
    switch (priority) {
      case 'Medium':
        return widget.isDarkMode ? Color(0xFF04cf18) : Color(0xFF04cf18); // Green
      case 'Low':
        return widget.isDarkMode ? Color(0xFFE3EB09) : Color(0xFFE3EB09); // Yellow
      case 'High':
        return widget.isDarkMode ? Color(0xFFC40202) : Color(0xFFC40202); // Red
      default:
        return widget.isDarkMode ? Colors.white : Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = widget.isDarkMode ? Colors.black : Colors.white;
    Color tileColor = widget.isDarkMode ? Colors.grey[850]! : Colors.grey[200]!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Note',
          style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: widget.isDarkMode ? Colors.grey[900] : Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: widget.isDarkMode ? Colors.white : Colors.black),
            onPressed: () async {
              await _saveNote();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Note saved successfully")),
              );
            },
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(  // Wrap the entire body in a SingleChildScrollView
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Note preview (if editing existing note)
            if (widget.note != null) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: Container(
                  color: widget.isDarkMode ? Colors.grey[850] : Colors.grey[200],
                  padding: EdgeInsets.all(10),
                  child: Text(
                    widget.note!.content.length > 100
                        ? widget.note!.content.substring(0, 100) + '...'
                        : widget.note!.content,
                    style: TextStyle(
                      color: widget.isDarkMode ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
            SizedBox(height: 15),
            // Title input
            Container(
              decoration: BoxDecoration(
                color: tileColor,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: InputBorder.none,
                  labelStyle: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black),
                ),
                style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 15),
            // Content input
            Container(
              decoration: BoxDecoration(
                color: tileColor,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: TextField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: 'Content',
                  border: InputBorder.none,
                  labelStyle: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black),
                ),
                style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
                maxLines: 8,
              ),
            ),
            SizedBox(height: 15),
            // Priority dropdown
            Container(
              decoration: BoxDecoration(
                color: tileColor,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButton<String>(
                value: _priority,
                items: ['Low', 'Medium', 'High'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(
                        color: getPriorityColor(value), // Reflect the priority color here
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _priority = newValue!;
                  });
                },
                dropdownColor: widget.isDarkMode ? Colors.grey[800] : Colors.white,
                icon: Icon(Icons.arrow_drop_down, color: widget.isDarkMode ? Colors.white : Colors.black),
                style: TextStyle(color: getPriorityColor(_priority)),
              ),
            ),
            SizedBox(height: 15),
            // Category input
            Container(
              decoration: BoxDecoration(
                color: tileColor,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: InputBorder.none,
                  labelStyle: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black),
                ),
                onChanged: (value) {
                  setState(() {
                    _category = value;
                  });
                },
                style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black),
              ),
            ),
            SizedBox(height: 15),
            // Cancel button to discard changes
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Discard changes and return
              },
              child: Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}

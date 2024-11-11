import 'package:flutter/material.dart';
import 'note_model.dart';
import 'database_helper.dart';
import 'note_editor.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<bool> onThemeChanged;

  HomeScreen({required this.onThemeChanged});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Note>> _notes;
  List<Note> _filteredNotes = [];
  String _searchQuery = '';
  bool _isDarkMode = false;
  String _filterOption = 'All';

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() {
    _notes = DatabaseHelper.instance.getNotes();
    _notes.then((value) {
      setState(() {
        _filteredNotes = value;
      });
    });
  }

  void _filterNotes(String query) {
    setState(() {
      _searchQuery = query;
      _filteredNotes = _filteredNotes.where((note) =>
          note.title.toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  void _applyFilter() {
    setState(() {
      if (_filterOption == 'All') {
        _loadNotes();
      } else {
        _filteredNotes = _filteredNotes.where((note) =>
        note.priority == _filterOption.split(' ')[0]).toList();
      }
    });
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Color(0xFFC40202); // Dark Red
      case 'Medium':
        return Color(0xFF04CF18); // Dark Green
      case 'Low':
        return Color(0xFFE3EB09); // Dark Yellow
      default:
        return Colors.grey;
    }
  }

  Future<void> _confirmDelete(Note note) async {
    final theme = Theme.of(context);
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to close
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.dialogBackgroundColor,
          title: Text(
            'Delete Note',
            style: TextStyle(color: theme.textTheme.bodyLarge?.color),
          ),
          content: Text(
            'Are you sure you want to delete this note?',
            style: TextStyle(color: theme.textTheme.bodyMedium?.color),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: theme.primaryColor)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: theme.colorScheme.error)),
              onPressed: () {
                DatabaseHelper.instance.delete(note.id!);
                _loadNotes();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Simple Note',
          style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
        ),
        backgroundColor: _isDarkMode ? Colors.black87 : theme.primaryColor,
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.wb_sunny : Icons.nights_stay),
            onPressed: () {
              setState(() {
                _isDarkMode = !_isDarkMode;
                widget.onThemeChanged(_isDarkMode);
              });
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _filterOption = value;
                _applyFilter();
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'All', child: Text('All')),
              PopupMenuItem(value: 'High Priority', child: Text('High Priority')),
              PopupMenuItem(value: 'Medium Priority', child: Text('Medium Priority')),
              PopupMenuItem(value: 'Low Priority', child: Text('Low Priority')),
            ],
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NoteEditor(isDarkMode: _isDarkMode)),
              );
              if (result == true) _loadNotes();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(labelText: 'Search notes...'),
              onChanged: _filterNotes,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Note>>(
              future: _notes,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final notesToShow = _searchQuery.isEmpty ? snapshot.data! : _filteredNotes;
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                  ),
                  itemCount: notesToShow.length,
                  itemBuilder: (context, index) {
                    Note note = notesToShow[index];
                    return Card(
                      color: _getPriorityColor(note.priority),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              note.content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: _isDarkMode ? Colors.white70 : Colors.black87),
                            ),
                            Spacer(),
                            Text(
                              note.dateTime.toString(),
                              style: TextStyle(color: _isDarkMode ? Colors.white60 : Colors.black54),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: _isDarkMode ? Colors.white : Colors.black),
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => NoteEditor(note: note, isDarkMode: _isDarkMode)),
                                    );
                                    if (result == true) _loadNotes();
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: _isDarkMode ? Colors.white : Colors.black),
                                  onPressed: () {
                                    _confirmDelete(note);
                                  },
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
            ),
          ),
        ],
      ),
      backgroundColor: _isDarkMode ? Colors.black : Colors.white,
    );
  }
}

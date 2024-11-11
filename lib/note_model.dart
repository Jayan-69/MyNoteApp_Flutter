class Note {
  int? id;
  String title;
  String content;
  String priority;
  DateTime dateTime; // Storing the date as a DateTime object

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.priority,
    required this.dateTime, required String date, required String category,
  });

  // Map conversion for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'priority': priority,
      'dateTime': dateTime.toIso8601String(), // Store as ISO 8601 string
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      priority: map['priority'],
      dateTime: DateTime.parse(map['dateTime']), date: '', category: '', // Parse the date from string
    );
  }
}

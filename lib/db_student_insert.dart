import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

void main() {
  runApp(const MaterialApp(
    home: DbStudentInsertScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class DbStudentInsertScreen extends StatefulWidget {
  const DbStudentInsertScreen({super.key});

  @override
  State<DbStudentInsertScreen> createState() => _DbStudentInsertScreenState();
}

class _DbStudentInsertScreenState extends State<DbStudentInsertScreen> {
  Database? _database;
  List<Map<String, dynamic>> _students = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  // Initialize SQLite Database with "students" table
  Future<void> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'students_db.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE students (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            age INTEGER,
            course TEXT
          )
        ''');
      },
    );

    _refreshStudents();
  }

  // Fetch all student records
  Future<void> _refreshStudents() async {
    if (_database == null) return;
    final data = await _database!.query('students');
    setState(() {
      _students = data;
    });
  }

  // Insert a new record into the "students" table
  Future<void> _insertStudent() async {
    final name = _nameController.text.trim();
    final ageStr = _ageController.text.trim();
    final course = _courseController.text.trim();

    if (name.isEmpty || ageStr.isEmpty || course.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter name, age, and course')),
      );
      return;
    }

    final age = int.tryParse(ageStr) ?? 0;

    // Execute SQLite Insert query
    final id = await _database!.insert(
      'students',
      {
        'name': name,
        'age': age,
        'course': course,
      },
    );

    _nameController.clear();
    _ageController.clear();
    _courseController.clear();

    _refreshStudents();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Student inserted successfully with ID: $id')),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _courseController.dispose();
    _database?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQLite - Insert Student'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Card(
              color: Colors.lightBlueAccent,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(Icons.person_add, color: Colors.white, size: 30),
                    SizedBox(width: 12),
                    Text(
                      'Insert Record into "students" Table',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Student Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Age',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.cake),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _courseController,
              decoration: const InputDecoration(
                labelText: 'Course',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.school),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: _insertStudent,
              icon: const Icon(Icons.save),
              label: const Text('Insert Student Record'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              'Inserted Records in "students" Table:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _students.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text('No student records inserted yet.'),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      final student = _students[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            child: Text('${student['id']}'),
                          ),
                          title: Text(
                            student['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                              'Age: ${student['age']} | Course: ${student['course']}'),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

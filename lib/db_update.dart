import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

void main() {
  runApp(const MaterialApp(
    home: DbUpdateScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class DbUpdateScreen extends StatefulWidget {
  const DbUpdateScreen({super.key});

  @override
  State<DbUpdateScreen> createState() => _DbUpdateScreenState();
}

class _DbUpdateScreenState extends State<DbUpdateScreen> {
  Database? _database;
  List<Map<String, dynamic>> _records = [];

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  // Initialize SQLite Database and seed sample records
  Future<void> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'students_update_db.db');

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

        // Seed sample data
        await db.insert('students', {'name': 'John Doe', 'age': 20, 'course': 'Computer Science'});
        await db.insert('students', {'name': 'Jane Smith', 'age': 21, 'course': 'Electrical Eng'});
      },
    );

    _refreshRecords();
  }

  // Refresh records list from SQLite table
  Future<void> _refreshRecords() async {
    if (_database == null) return;
    final data = await _database!.query('students');
    setState(() {
      _records = data;
    });
  }

  // Select record for updating when tapped from list
  void _selectRecordToEdit(Map<String, dynamic> record) {
    _idController.text = record['id'].toString();
    _nameController.text = record['name'];
    _ageController.text = record['age'].toString();
    _courseController.text = record['course'];
  }

  // Update specific record in SQLite table based on id
  Future<void> _updateRecord() async {
    final idStr = _idController.text.trim();
    final name = _nameController.text.trim();
    final ageStr = _ageController.text.trim();
    final course = _courseController.text.trim();

    if (idStr.isEmpty || name.isEmpty || ageStr.isEmpty || course.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Record ID and new details')),
      );
      return;
    }

    final id = int.tryParse(idStr);
    final age = int.tryParse(ageStr);

    if (id == null || age == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID and Age must be valid numbers')),
      );
      return;
    }

    // Execute SQLite UPDATE statement
    final count = await _database!.update(
      'students',
      {
        'name': name,
        'age': age,
        'course': course,
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    if (count > 0) {
      _idController.clear();
      _nameController.clear();
      _ageController.clear();
      _courseController.clear();
      _refreshRecords();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Record ID $id updated successfully!')),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No record found with ID $id')),
      );
    }
  }

  @override
  void dispose() {
    _idController.dispose();
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
        title: const Text('SQLite - Update Record by ID'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Update Record Form:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _idController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Target Record ID to Update',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.key),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'New Student Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'New Age',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.cake),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _courseController,
              decoration: const InputDecoration(
                labelText: 'New Course',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.school),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: _updateRecord,
              icon: const Icon(Icons.edit),
              label: const Text('Update Record in SQLite'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              'Current Records in Table (Tap to Edit):',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _records.isEmpty
                ? const Center(child: Text('No records available.'))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _records.length,
                    itemBuilder: (context, index) {
                      final record = _records[index];
                      return Card(
                        child: ListTile(
                          onTap: () => _selectRecordToEdit(record),
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            child: Text('${record['id']}'),
                          ),
                          title: Text(
                            record['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                              'Age: ${record['age']} | Course: ${record['course']}'),
                          trailing: const Icon(Icons.touch_app, color: Colors.teal),
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

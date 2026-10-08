import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

void main() {
  runApp(const MaterialApp(
    home: DbDeleteScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class DbDeleteScreen extends StatefulWidget {
  const DbDeleteScreen({super.key});

  @override
  State<DbDeleteScreen> createState() => _DbDeleteScreenState();
}

class _DbDeleteScreenState extends State<DbDeleteScreen> {
  Database? _database;
  List<Map<String, dynamic>> _records = [];

  final TextEditingController _idController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  // Initialize SQLite Database and populate sample records
  Future<void> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'students_delete_db.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE students (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            course TEXT
          )
        ''');

        // Seed sample records
        await db.insert('students', {'name': 'Alice Johnson', 'course': 'Computer Engineering'});
        await db.insert('students', {'name': 'Bob Smith', 'course': 'Electrical Engineering'});
        await db.insert('students', {'name': 'Charlie Davis', 'course': 'Mechanical Engineering'});
        await db.insert('students', {'name': 'David Wilson', 'course': 'Civil Engineering'});
      },
    );

    _refreshRecords();
  }

  // Refresh records list from SQLite
  Future<void> _refreshRecords() async {
    if (_database == null) return;
    final data = await _database!.query('students');
    setState(() {
      _records = data;
    });
  }

  // Delete specific record by ID
  Future<void> _deleteRecordById(int id) async {
    final count = await _database!.delete(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (count > 0) {
      _refreshRecords();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Record with ID $id deleted successfully!')),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No record found with ID $id')),
      );
    }
  }

  // Delete via TextField ID input
  void _deleteFromTextField() {
    final idStr = _idController.text.trim();
    if (idStr.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an ID to delete')),
      );
      return;
    }

    final id = int.tryParse(idStr);
    if (id == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid numeric ID')),
      );
      return;
    }

    _deleteRecordById(id);
    _idController.clear();
  }

  @override
  void dispose() {
    _idController.dispose();
    _database?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQLite - Delete Record by ID'),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _idController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Enter Record ID to Delete',
                        prefixIcon: Icon(Icons.delete_forever),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _deleteFromTextField,
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete Record'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Current Records in Table:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _records.isEmpty
                  ? const Center(
                      child: Text('Table is empty. All records deleted!'),
                    )
                  : ListView.builder(
                      itemCount: _records.length,
                      itemBuilder: (context, index) {
                        final record = _records[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              child: Text('${record['id']}'),
                            ),
                            title: Text(
                              record['name'],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('Course: ${record['course']}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _deleteRecordById(record['id']),
                              tooltip: 'Delete Record ID ${record['id']}',
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

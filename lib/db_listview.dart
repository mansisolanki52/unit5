import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

void main() {
  runApp(const MaterialApp(
    home: DbListViewScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class DbListViewScreen extends StatefulWidget {
  const DbListViewScreen({super.key});

  @override
  State<DbListViewScreen> createState() => _DbListViewScreenState();
}

class _DbListViewScreenState extends State<DbListViewScreen> {
  Database? _database;
  List<Map<String, dynamic>> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  // Initialize SQLite database and populate sample records if empty
  Future<void> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'records_list_db.db');

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

        // Seed sample records
        await db.insert('students', {'name': 'Alice Smith', 'age': 20, 'course': 'Computer Science'});
        await db.insert('students', {'name': 'Bob Johnson', 'age': 22, 'course': 'Information Tech'});
        await db.insert('students', {'name': 'Charlie Brown', 'age': 21, 'course': 'Data Science'});
        await db.insert('students', {'name': 'Diana Prince', 'age': 23, 'course': 'Cyber Security'});
      },
    );

    _fetchAllRecords();
  }

  // Query all records from SQLite table
  Future<void> _fetchAllRecords() async {
    if (_database == null) return;
    setState(() => _isLoading = true);
    final data = await _database!.query('students');
    setState(() {
      _records = data;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _database?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQLite Records - ListView'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAllRecords,
            tooltip: 'Refresh ListView',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _records.isEmpty
              ? const Center(
                  child: Text('No records found in SQLite table.'),
                )
              : Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.view_list, color: Colors.purple),
                            const SizedBox(width: 10),
                            Text(
                              'Displaying ${_records.length} records from SQLite',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _records.length,
                          itemBuilder: (context, index) {
                            final record = _records[index];
                            return Card(
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.purple,
                                  foregroundColor: Colors.white,
                                  child: Text('${record['id']}'),
                                ),
                                title: Text(
                                  record['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Text(
                                  'Age: ${record['age']} | Course: ${record['course']}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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

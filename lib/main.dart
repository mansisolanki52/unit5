import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'sp_username.dart';
import 'sp_darkmode.dart';
import 'db_products.dart';
import 'db_student_insert.dart';
import 'db_listview.dart';
import 'db_update.dart';
import 'db_delete.dart';
import 'hive_todo.dart';
import 'hive_user.dart';
import 'file_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('todoBox');
  await Hive.openBox('userBox');
  runApp(const ModuleVApp());
}

class ModuleVApp extends StatelessWidget {
  const ModuleVApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Module V - Data Persistence',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const MainMenuScreen(),
    );
  }
}

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> tasks = [
      {
        'title': 'Task 1: Shared Prefs Username',
        'subtitle': 'Save username & display after app restarts',
        'icon': Icons.person,
        'color': Colors.indigo,
        'screen': const SpUsernameScreen(),
      },
      {
        'title': 'Task 2: Shared Prefs Dark Mode',
        'subtitle': 'Switch to save & load Dark Mode setting',
        'icon': Icons.dark_mode,
        'color': Colors.teal,
        'screen': const SpDarkModeApp(),
      },
      {
        'title': 'Task 3: SQLite Products Table',
        'subtitle': 'Create "products" table (id, name, price)',
        'icon': Icons.shopping_bag,
        'color': Colors.deepOrange,
        'screen': const DbProductsScreen(),
      },
      {
        'title': 'Task 4: SQLite Insert Student',
        'subtitle': 'Insert new record into "students" table',
        'icon': Icons.person_add,
        'color': Colors.blueAccent,
        'screen': const DbStudentInsertScreen(),
      },
      {
        'title': 'Task 5: SQLite ListView Display',
        'subtitle': 'Display all records using ListView',
        'icon': Icons.view_list,
        'color': Colors.purple,
        'screen': const DbListViewScreen(),
      },
      {
        'title': 'Task 6: SQLite Update Record',
        'subtitle': 'Update specific record based on id',
        'icon': Icons.edit_note,
        'color': Colors.teal,
        'screen': const DbUpdateScreen(),
      },
      {
        'title': 'Task 7: SQLite Delete Record',
        'subtitle': 'Delete specific record based on id',
        'icon': Icons.delete_forever,
        'color': Colors.redAccent,
        'screen': const DbDeleteScreen(),
      },
      {
        'title': 'Task 8: Hive To-Do Note',
        'subtitle': 'Hive to save & display simple To-Do note',
        'icon': Icons.note_alt,
        'color': Colors.amber.shade800,
        'screen': const HiveTodoScreen(),
      },
      {
        'title': 'Task 9: Hive User Name & Age',
        'subtitle': 'Hive to store & display name and age together',
        'icon': Icons.badge,
        'color': Colors.deepPurple,
        'screen': const HiveUserScreen(),
      },
      {
        'title': 'Task 10: File Storage (path_provider)',
        'subtitle': 'Read & write text to local file',
        'icon': Icons.folder,
        'color': Colors.green.shade700,
        'screen': const FileStorageScreen(),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Module V: Data Persistence'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: task['color'],
                foregroundColor: Colors.white,
                child: Icon(task['icon']),
              ),
              title: Text(
                task['title'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              subtitle: Text(
                task['subtitle'],
                style: const TextStyle(fontSize: 12),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => task['screen'],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('todoBox');
  runApp(const MaterialApp(
    home: HiveTodoScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class HiveTodoScreen extends StatefulWidget {
  const HiveTodoScreen({super.key});

  @override
  State<HiveTodoScreen> createState() => _HiveTodoScreenState();
}

class _HiveTodoScreenState extends State<HiveTodoScreen> {
  Box? _todoBox;
  final TextEditingController _noteController = TextEditingController();
  String _savedNote = '';

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  // Open Hive box and load existing To-Do note
  Future<void> _openBox() async {
    if (!Hive.isBoxOpen('todoBox')) {
      _todoBox = await Hive.openBox('todoBox');
    } else {
      _todoBox = Hive.box('todoBox');
    }
    _loadNote();
  }

  // Read saved note from Hive box
  void _loadNote() {
    setState(() {
      _savedNote = _todoBox?.get('todoNote', defaultValue: 'No To-Do note saved yet.') ??
          'No To-Do note saved yet.';
    });
  }

  // Save note to Hive box
  Future<void> _saveNote() async {
    final note = _noteController.text.trim();
    if (note.isEmpty) return;

    await _todoBox?.put('todoNote', note);
    _noteController.clear();
    _loadNote();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('To-Do note saved to Hive!')),
      );
    }
  }

  // Delete note from Hive box
  Future<void> _clearNote() async {
    await _todoBox?.delete('todoNote');
    _loadNote();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('To-Do note cleared from Hive!')),
      );
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hive - To-Do Note'),
        backgroundColor: Colors.amber.shade800,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              color: Colors.amber.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Icon(Icons.note_alt, size: 50, color: Colors.amber),
                    const SizedBox(height: 10),
                    const Text(
                      'Saved To-Do Note in Hive:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _savedNote,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Enter To-Do Note',
                hintText: 'e.g. Complete Flutter Data Persistence assignment',
                prefixIcon: const Icon(Icons.edit_note),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _saveNote,
              icon: const Icon(Icons.save),
              label: const Text('Save Note to Hive', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade800,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _clearNote,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Clear Saved Note'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

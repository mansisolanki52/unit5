import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MaterialApp(
    home: FileStorageScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class FileStorageScreen extends StatefulWidget {
  const FileStorageScreen({super.key});

  @override
  State<FileStorageScreen> createState() => _FileStorageScreenState();
}

class _FileStorageScreenState extends State<FileStorageScreen> {
  final TextEditingController _textController = TextEditingController();
  String _fileContent = 'No text read from file yet.';
  String _filePath = '';

  @override
  void initState() {
    super.initState();
    _initFilePath();
  }

  // Get directory path using path_provider
  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    setState(() {
      _filePath = '${directory.path}/my_notes.txt';
    });
    return File('${directory.path}/my_notes.txt');
  }

  Future<void> _initFilePath() async {
    await _getLocalFile();
    _readFromFile();
  }

  // Write text to local file
  Future<void> _writeToFile() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some text to save')),
      );
      return;
    }

    try {
      final file = await _getLocalFile();
      await file.writeAsString(text);
      _textController.clear();
      _readFromFile();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Text written to local file successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error writing file: $e')),
        );
      }
    }
  }

  // Read text from local file
  Future<void> _readFromFile() async {
    try {
      final file = await _getLocalFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        setState(() {
          _fileContent = content.isEmpty ? 'File is empty.' : content;
        });
      } else {
        setState(() {
          _fileContent = 'File does not exist yet.';
        });
      }
    } catch (e) {
      setState(() {
        _fileContent = 'Error reading file: $e';
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Storage (path_provider)'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              color: Colors.green.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.folder, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'File Path:',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _filePath.isEmpty ? 'Loading path...' : _filePath,
                      style: const TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                    const Divider(height: 20),
                    const Row(
                      children: [
                        Icon(Icons.description, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'Content Read From File:',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _fileContent,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _textController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Enter text to save to local file',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.edit),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _writeToFile,
                    icon: const Icon(Icons.save),
                    label: const Text('Write to File'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _readFromFile,
                    icon: const Icon(Icons.file_open),
                    label: const Text('Read File'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.green.shade700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

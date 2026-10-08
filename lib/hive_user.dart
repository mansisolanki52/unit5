import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('userBox');
  runApp(const MaterialApp(
    home: HiveUserScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class HiveUserScreen extends StatefulWidget {
  const HiveUserScreen({super.key});

  @override
  State<HiveUserScreen> createState() => _HiveUserScreenState();
}

class _HiveUserScreenState extends State<HiveUserScreen> {
  Box? _userBox;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String _savedName = '';
  String _savedAge = '';

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  // Open Hive box and fetch stored user details
  Future<void> _openBox() async {
    if (!Hive.isBoxOpen('userBox')) {
      _userBox = await Hive.openBox('userBox');
    } else {
      _userBox = Hive.box('userBox');
    }
    _loadUserData();
  }

  // Load user name and age together from Hive
  void _loadUserData() {
    setState(() {
      _savedName = _userBox?.get('userName', defaultValue: 'Not set') ?? 'Not set';
      _savedAge = _userBox?.get('userAge', defaultValue: 'Not set') ?? 'Not set';
    });
  }

  // Store user name and age together into Hive box
  Future<void> _saveUserData() async {
    final name = _nameController.text.trim();
    final age = _ageController.text.trim();

    if (name.isEmpty || age.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both name and age')),
      );
      return;
    }

    await _userBox?.put('userName', name);
    await _userBox?.put('userAge', age);

    _nameController.clear();
    _ageController.clear();
    _loadUserData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User details saved in Hive!')),
      );
    }
  }

  // Clear saved user data
  Future<void> _clearUserData() async {
    await _userBox?.delete('userName');
    await _userBox?.delete('userAge');
    _loadUserData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User details cleared!')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hive - User Name & Age'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              color: Colors.deepPurple.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.deepPurple,
                      child: Icon(Icons.person, size: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Stored User Profile (Hive):',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.badge, color: Colors.deepPurple),
                        const SizedBox(width: 8),
                        Text(
                          'Name: $_savedName',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cake, color: Colors.deepPurple),
                        const SizedBox(width: 8),
                        Text(
                          'Age: $_savedAge',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Enter Name',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter Age',
                prefixIcon: const Icon(Icons.numbers),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _saveUserData,
              icon: const Icon(Icons.save),
              label: const Text('Save User Info to Hive',
                  style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _clearUserData,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Clear User Data'),
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

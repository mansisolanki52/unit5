import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MaterialApp(
    home: SpUsernameScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class SpUsernameScreen extends StatefulWidget {
  const SpUsernameScreen({super.key});

  @override
  State<SpUsernameScreen> createState() => _SpUsernameScreenState();
}

class _SpUsernameScreenState extends State<SpUsernameScreen> {
  final TextEditingController _controller = TextEditingController();
  String _savedUsername = 'No username saved';

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  // Load username from Shared Preferences
  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedUsername = prefs.getString('username') ?? 'No username saved';
    });
  }

  // Save username to Shared Preferences
  Future<void> _saveUsername() async {
    if (_controller.text.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _controller.text.trim());
    _controller.clear();
    _loadUsername();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username saved successfully!')),
      );
    }
  }

  // Clear username from Shared Preferences
  Future<void> _clearUsername() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    _loadUsername();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username cleared!')),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Preferences - Username'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              color: Colors.indigo.shade50,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Icon(Icons.account_circle,
                        size: 60, color: Colors.indigo),
                    const SizedBox(height: 10),
                    const Text(
                      'Saved Username:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _savedUsername,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter Username',
                hintText: 'e.g. JohnDoe',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _saveUsername,
              icon: const Icon(Icons.save),
              label: const Text('Save Username', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _clearUsername,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Clear Username'),
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

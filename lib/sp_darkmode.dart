import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const SpDarkModeApp());
}

class SpDarkModeApp extends StatefulWidget {
  const SpDarkModeApp({super.key});

  @override
  State<SpDarkModeApp> createState() => _SpDarkModeAppState();
}

class _SpDarkModeAppState extends State<SpDarkModeApp> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadDarkModeSetting();
  }

  // Load dark mode setting from Shared Preferences
  Future<void> _loadDarkModeSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  // Save dark mode setting to Shared Preferences
  Future<void> _toggleDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    setState(() {
      _isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: SpDarkModeScreen(
        isDarkMode: _isDarkMode,
        onChanged: _toggleDarkMode,
      ),
    );
  }
}

class SpDarkModeScreen extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onChanged;

  const SpDarkModeScreen({
    super.key,
    required this.isDarkMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Preferences - Dark Mode'),
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              size: 100,
              color: isDarkMode ? Colors.amber : Colors.orange,
            ),
            const SizedBox(height: 20),
            Text(
              isDarkMode ? 'Dark Mode Enabled' : 'Light Mode Enabled',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Toggle the switch below to change and save the mode using Shared Preferences.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: SwitchListTile(
                title: const Text(
                  'Dark Mode',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  isDarkMode ? 'Saved in SharedPreferences as true' : 'Saved in SharedPreferences as false',
                ),
                value: isDarkMode,
                onChanged: onChanged,
                secondary: Icon(
                  isDarkMode ? Icons.nights_stay : Icons.wb_sunny,
                  color: isDarkMode ? Colors.amber : Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

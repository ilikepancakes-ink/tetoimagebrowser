import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'localization/custom_localizations.dart';
import 'widgets/image_browser_page.dart';

void main() {
  // Stel app titel en icoon in voor desktop platformen
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;
  String _currentLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _currentLanguage = prefs.getString('language') ?? 'en';
    });
  }

  Future<void> _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  Future<void> _updateLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLanguage = languageCode;
    });
    await prefs.setString('language', languageCode);
  }

  // Root widget voor de applicatie.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tuff Image Browser',
      localizationsDelegates: const [
        CustomLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // Engels
        Locale('ja', ''), // Japans
        Locale('ko', ''), // Koreaans
        Locale('nl', ''), // Nederlands
      ],
      locale: Locale(_currentLanguage, ''),
      theme: ThemeData(
        primarySwatch: Colors.red, // Gewijzigd naar rood om bij Teto's kleurenschema te passen
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE91E63), // Roze kleur voor Teto
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.red,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE91E63), // Roze kleur voor Teto
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: ImageBrowserPage(
        onThemeToggle: _toggleTheme,
        isDarkMode: _isDarkMode,
        onLanguageChange: _updateLanguage,
        currentLanguage: _currentLanguage,
      ),
    );
  }
}

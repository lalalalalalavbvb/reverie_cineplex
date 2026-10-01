import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/app_scroll_behavior.dart';
import 'core/theme.dart';
import 'firebase_options.dart';
import 'screens/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reverie Cineplex',

      debugShowCheckedModeBanner: false,

      theme: AppTheme.light,

      darkTheme: AppTheme.dark,

      themeMode: _themeMode,

      scrollBehavior: const AppScrollBehavior(),

      home: AppShell(
        isDarkMode: _themeMode == ThemeMode.dark,

        onThemeChanged: (isDark) {
          setState(() {
            _themeMode = isDark
                ? ThemeMode.dark
                : ThemeMode.light;
          });
        },
      ),
    );
  }
}
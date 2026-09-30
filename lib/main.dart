import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'core/app_scroll_behavior.dart';
import 'screens/app_shell.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Reverie Cineplex',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: _themeMode,
    scrollBehavior: const AppScrollBehavior(),
    home: AppShell(
      isDarkMode: _themeMode == ThemeMode.dark,
      onThemeChanged: (isDark) => setState(
        () => _themeMode = isDark ? ThemeMode.dark : ThemeMode.light,
      ),
    ),
  );
}

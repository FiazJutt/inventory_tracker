import 'package:flutter/material.dart';
import 'package:inventory_tracker/core/theme/app_theme.dart';
import 'package:inventory_tracker/views/home/home_screen.dart';
import 'package:inventory_tracker/views/onboarding/onboarding_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: MyAppTheme.darkTheme,
      home: const OnboardingScreen(),
    );
  }
}

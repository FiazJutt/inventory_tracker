import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:inventory_tracker/core/theme/app_theme.dart';
import 'package:inventory_tracker/viewmodels/inventory_provider.dart';
import 'package:inventory_tracker/views/home/.fgot/home.dart';
import 'package:inventory_tracker/views/onboarding/onboarding_screen_1.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: MyAppTheme.darkTheme,
      home: const OnboardingScreen1(),
      ),
    );
  }
}

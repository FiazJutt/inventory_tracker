// import 'package:flutter/material.dart' hide ThemeMode;
// import 'package:inventory_tracker/core/theme/theme_provider.dart';
// import 'package:inventory_tracker/core/theme/theme_provider.dart' as app_theme;
// import 'package:provider/provider.dart';
// import 'package:inventory_tracker/core/theme/app_theme.dart';
// import 'package:inventory_tracker/viewmodels/inventory_provider.dart';
// import 'package:inventory_tracker/views/onboarding/onboarding_screen_1.dart';

// void main() {
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => InventoryProvider()),
//         ChangeNotifierProvider(create: (_) => app_theme.ThemeProvider()),
//       ],
//       child: const MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // return MultiProvider(
//     // providers: [
//     //   ChangeNotifierProvider(create: (_) => InventoryProvider()),
//     //   ChangeNotifierProvider(create: (_) => ThemeProvider()),
//     // ],
//     // child:
//     return Consumer<app_theme.ThemeProvider>(
//       builder: (context, themeProvider, _) {
//         return MaterialApp(
//           debugShowCheckedModeBanner: false,
//           theme: MyAppTheme.lightTheme,
//           darkTheme: MyAppTheme.darkTheme,
//           home: const OnboardingScreen1(),
//         );
//       }
//     );
//     // );
//   }
// }







//lm
///
import 'package:flutter/material.dart';
import 'package:inventory_tracker/views/onboarding/onboarding_screen_1.dart';
import 'package:provider/provider.dart';
import 'package:inventory_tracker/core/theme/theme_provider.dart';
import 'package:inventory_tracker/viewmodels/inventory_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'Inventory Tracker',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const OnboardingScreen1(),
        );
      },
    );
  }
}

// gp
///
///import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:inventory_tracker/core/theme/app_theme.dart';
// import 'package:inventory_tracker/core/theme/theme_provider.dart';
// import 'package:inventory_tracker/viewmodels/inventory_provider.dart';
// import 'package:inventory_tracker/views/onboarding/onboarding_screen_1.dart';

// void main() {
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => InventoryProvider()),
//         ChangeNotifierProvider(create: (_) => ThemeProvider()),
//       ],
//       child: const MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<ThemeProvider>(
//       builder: (context, themeProvider, _) {
//         final systemBrightness =
//             MediaQuery.platformBrightnessOf(context);

//         /// Select correct light/dark theme
//         final theme = themeProvider.getTheme(systemBrightness);

//         return MaterialApp(
//           debugShowCheckedModeBanner: false,
//           theme: MyAppTheme.lightTheme,
//           darkTheme: MyAppTheme.darkTheme,
//           themeMode: themeProvider.themeMode == ThemeMode.system
//               ? ThemeMode.system
//               : themeProvider.themeMode == ThemeMode.dark
//                   ? ThemeMode.dark
//                   : ThemeMode.light,
//           home: const OnboardingScreen1(),
//         );
//       },
//     );
//   }
// }

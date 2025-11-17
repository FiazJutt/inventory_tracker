import 'package:flutter/material.dart';
import 'package:inventory_tracker/views/onboarding/onboarding_screen_1.dart';
import 'package:inventory_tracker/views/mian_screen.dart';
import 'package:provider/provider.dart';
import 'package:inventory_tracker/viewmodels/inventory_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLaunchStatus();
  }

  Future<void> _checkLaunchStatus() async {
    try {
      // Add a small delay to show the splash screen
      await Future.delayed(const Duration(milliseconds: 1500));
      
      final prefs = await SharedPreferences.getInstance();
      final hasLaunched = prefs.getBool('has_launched') ?? false;
      
      // Check if there's existing data
      final inventoryProvider = Provider.of<InventoryProvider>(
        context,
        listen: false,
      );
      
      // Refresh data from database
      await inventoryProvider.refreshFromDatabase();
      
      final hasData = inventoryProvider.rooms.isNotEmpty;
      
      // Mark as launched if not already marked and we have data
      if (!hasLaunched && hasData) {
        await prefs.setBool('has_launched', true);
      }
      
      // Navigate to appropriate screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => hasLaunched || hasData 
                ? const MainScreen() 
                : const OnboardingScreen1(),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error checking launch status: $e');
      // Default to onboarding if there's an error
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const OnboardingScreen1(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).primaryColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 20),
              Text(
                'Inventory Tracker',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 30),
              CircularProgressIndicator(
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
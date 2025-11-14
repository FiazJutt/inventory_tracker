import 'package:flutter/material.dart';
import 'package:inventory_tracker/core/theme/app_colors.dart';
import 'package:inventory_tracker/views/onboarding/onboarding_screen_2.dart';
import 'widgets/onboarding_header.dart';
import 'widgets/suggestion_chip.dart';

class OnboardingScreen1 extends StatefulWidget {
  const OnboardingScreen1({super.key});

  @override
  State<OnboardingScreen1> createState() => _OnboardingScreen1State();
}

class _OnboardingScreen1State extends State<OnboardingScreen1> {
  late final TextEditingController _controller;

  final List<String> locationSuggestions = const [
    'Home',
    'Office',
    'Parent\'s House',
    'Vacation Home',
    'Storage Unit',
    'Small Retail Store',
    'Workshop',
    'Studio',
    'Kitchen',
    'Garage',
  ];

  String? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OnboardingHeader(
                        title: "Let's get started 👋",
                        subtitle:
                            "Create your first location to organize your inventory.",
                      ),
                      TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Location Name',
                          hintStyle: TextStyle(color: colors.textSecondary),
                          filled: true,
                          fillColor: colors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _selectedLocation =
                                value.trim().isEmpty ? null : value;
                          });
                        },
                      ),
                      const SizedBox(height: 32),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: locationSuggestions.map((suggestion) {
                          return SuggestionChip(
                            label: suggestion,
                            isSelected: _selectedLocation == suggestion,
                            onTap: () {
                              setState(() {
                                _selectedLocation = suggestion;
                                _controller.text = suggestion;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedLocation != null &&
                          _selectedLocation!.isNotEmpty
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OnboardingScreen2(
                                locationName: _selectedLocation!,
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    disabledBackgroundColor: colors.primary.withOpacity(0.5),
                    foregroundColor: colors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:inventory_tracker/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:inventory_tracker/viewmodels/inventory_provider.dart';
import 'package:inventory_tracker/views/roomScreens/room_creation_screen.dart';
import 'package:inventory_tracker/views/onboarding/widgets/onboarding_header.dart';
import 'package:inventory_tracker/core/widgets/suggestion_chip.dart';

class AddLocationScreen extends StatefulWidget {
  const AddLocationScreen({super.key});

  @override
  State<AddLocationScreen> createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends State<AddLocationScreen> {
  late final TextEditingController _controller;

  // Same suggestions as onboarding screen for consistency
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

  Future<void> _addLocation() async {
    if (_selectedLocation != null && _selectedLocation!.isNotEmpty) {
      final inventoryProvider = Provider.of<InventoryProvider>(
        context,
        listen: false,
      );
      final colors = context.appColors;

      try {
        await inventoryProvider.addLocation(_selectedLocation!);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add location: $e'),
            backgroundColor: colors.error,
          ),
        );
        return;
      }

      // Show success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location "${_selectedLocation}" added successfully!'),
          backgroundColor: colors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      // Navigate to room creation screen with the selected location
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  RoomCreationScreen(selectedLocation: _selectedLocation!),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Location',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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
                      const SizedBox(height: 40),
                      OnboardingHeader(
                        title: "Let's add a location 📍",
                        subtitle:
                            "Create a new location to organize your inventory.",
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _controller,
                        style: TextStyle(color: colors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Location Name',
                          hintStyle: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 16,
                          ),
                          filled: true,
                          fillColor: colors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            borderSide: BorderSide(
                              color: colors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _selectedLocation = value.trim().isEmpty
                                ? null
                                : value;
                          });
                        },
                      ),
                      const SizedBox(height: 32),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: locationSuggestions.map((s) {
                          return SuggestionChip(
                            label: s,
                            isSelected: _selectedLocation == s,
                            onTap: () {
                              setState(() {
                                _selectedLocation = s;
                                _controller.text = s;
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

              // Fixed Bottom Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _selectedLocation != null &&
                            _selectedLocation!.isNotEmpty
                        ? () => _addLocation()
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _selectedLocation != null &&
                              _selectedLocation!.isNotEmpty
                          ? colors.primary
                          : colors.primary.withOpacity(0.5),
                      disabledBackgroundColor: colors.primary.withOpacity(0.5),
                      foregroundColor: colors.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Add Location',
                      style: TextStyle(fontSize: 16),
                    ),
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

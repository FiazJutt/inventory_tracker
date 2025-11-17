import 'package:flutter/material.dart';
import 'package:inventory_tracker/core/theme/app_colors.dart';
import 'package:inventory_tracker/views/mian_screen.dart';
import 'package:provider/provider.dart';
import 'package:inventory_tracker/viewmodels/inventory_provider.dart';
import 'package:inventory_tracker/models/room_model.dart';
import 'widgets/onboarding_header.dart';
import 'widgets/location_badge.dart';
import 'widgets/suggestion_chip.dart';
import 'widgets/room_counter_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen2 extends StatefulWidget {
  final String locationName;

  const OnboardingScreen2({super.key, required this.locationName});

  @override
  State<OnboardingScreen2> createState() => _OnboardingScreen2State();
}

class _OnboardingScreen2State extends State<OnboardingScreen2> {
  late final TextEditingController _controller;

  final List<String> roomSuggestions = const [
    'Living Room',
    'Bedroom',
    'Bathroom',
    'Kitchen',
    'Dining Room',
    'Office',
    'Garage',
    'Hallway',
    'Pantry',
    'Basement',
    'Attic',
    'Closet',
    'Balcony',
    'Garden',
    'Playroom',
    'Gym',
    'Storage Room',
    'Guest Room',
    'Nursery',
    'Study Room',
    'Media Room',
  ];

  final Map<String, int> addedRooms = {};

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

  Future<void> _saveRoomsAndNavigate() async {
    if (addedRooms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one room'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final inventoryProvider = Provider.of<InventoryProvider>(
      context,
      listen: false,
    );

    try {
      for (final entry in addedRooms.entries) {
        for (int i = 0; i < entry.value; i++) {
          final finalRoomName = entry.value > 1
              ? '${entry.key} ${i + 1}'
              : entry.key;

          final room = Room(
            id: '${DateTime.now().millisecondsSinceEpoch}_$i',
            name: finalRoomName,
            location: widget.locationName,
          );

          await inventoryProvider.addRoom(room);
        }
      }

      // Mark app as launched after successful onboarding
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_launched', true);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save rooms: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OnboardingHeader(
                        title: "Add Rooms 🏡",
                        subtitle:
                            "Add rooms where your items belong. You can create your own or choose from suggestions.",
                      ),
                      const SizedBox(height: 16),
                      LocationBadge(location: widget.locationName),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              decoration: InputDecoration(
                                hintText: 'Custom Room Name',
                                hintStyle: TextStyle(
                                  color: colors.textSecondary.withOpacity(0.6),
                                ),
                                filled: true,
                                fillColor: colors.surface,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () {
                              final name = _controller.text.trim();
                              if (name.isNotEmpty) {
                                setState(() {
                                  addedRooms[name] =
                                      (addedRooms[name] ?? 0) + 1;
                                  _controller.clear();
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.primary,
                              foregroundColor: colors.onPrimary,
                              padding: const EdgeInsets.all(14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Icon(Icons.add),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (addedRooms.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            'No rooms added yet. Tap suggestions below to add.',
                            style: TextStyle(color: colors.textSecondary),
                          ),
                        )
                      else
                        ...addedRooms.entries.map((entry) {
                          return RoomCounterCard(
                            roomName: entry.key,
                            count: entry.value,
                            onDecrement: () {
                              setState(() {
                                final current = addedRooms[entry.key] ?? 1;
                                if (current > 1) {
                                  addedRooms[entry.key] = current - 1;
                                } else {
                                  addedRooms.remove(entry.key);
                                }
                              });
                            },
                            onIncrement: () {
                              setState(() {
                                addedRooms[entry.key] =
                                    (addedRooms[entry.key] ?? 0) + 1;
                              });
                            },
                          );
                        }),
                      const SizedBox(height: 32),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.start,
                        children: roomSuggestions.map((suggestion) {
                          return SuggestionChip(
                            label: suggestion,
                            isSelected: addedRooms.containsKey(suggestion),
                            onTap: () {
                              setState(() {
                                if (addedRooms.containsKey(suggestion)) {
                                  addedRooms.remove(suggestion);
                                } else {
                                  addedRooms[suggestion] = 1;
                                }
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
                child: ElevatedButton.icon(
                  label: const Text('Create', style: TextStyle(fontSize: 16)),
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () => _saveRoomsAndNavigate(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
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
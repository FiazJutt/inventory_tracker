import 'package:flutter/material.dart';
import 'package:inventory_tracker/core/theme/app_colors.dart';
import 'package:inventory_tracker/views/locationScreens/location_selection_screen.dart';
import 'package:provider/provider.dart';
import 'package:inventory_tracker/viewmodels/inventory_provider.dart';
import 'package:inventory_tracker/models/room_model.dart';
import 'package:inventory_tracker/views/onboarding/widgets/onboarding_header.dart';
import 'package:inventory_tracker/views/onboarding/widgets/location_badge.dart';
import 'package:inventory_tracker/views/onboarding/widgets/suggestion_chip.dart';
import 'package:inventory_tracker/views/onboarding/widgets/room_counter_card.dart';

class RoomCreationScreen extends StatefulWidget {
  final String? selectedLocation;

  const RoomCreationScreen({super.key, this.selectedLocation});

  @override
  State<RoomCreationScreen> createState() => _RoomCreationScreenState();
}

class _RoomCreationScreenState extends State<RoomCreationScreen> {
  late final TextEditingController _controller;
  String? _selectedLocation;

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
    // Initialize with the passed location if provided
    if (widget.selectedLocation != null) {
      _selectedLocation = widget.selectedLocation;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _selectLocation() async {
    final selectedLocation = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const LocationSelectionScreen()),
    );

    if (selectedLocation != null && mounted) {
      setState(() {
        _selectedLocation = selectedLocation;
      });
    }
  }

  Future<void> _saveRoomsAndNavigate() async {
    if (_selectedLocation == null || _selectedLocation!.isEmpty) {
      final colors = context.appColors;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a location first'),
          backgroundColor: colors.error,
        ),
      );
      return;
    }

    if (addedRooms.isEmpty) {
      final colors = context.appColors;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please add at least one room'),
          backgroundColor: colors.error,
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
            id: DateTime.now().millisecondsSinceEpoch.toString() + i.toString(),
            name: finalRoomName,
            location: _selectedLocation!,
          );

          await inventoryProvider.addRoom(room);
        }
      }
    } catch (e) {
      final colors = context.appColors;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save rooms: $e'),
            backgroundColor: colors.error,
          ),
        );
      }
      return;
    }

    // Show success message
    final colors = context.appColors;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${addedRooms.length} room${addedRooms.length == 1 ? "" : "s"} added to $_selectedLocation!',
        ),
        backgroundColor: colors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    // Navigate back to home screen
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Rooms',
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
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _selectLocation,
                        child: _selectedLocation == null
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: colors.textSecondary.withOpacity(
                                      0.3,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: colors.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Select Location',
                                      style: TextStyle(
                                        color: colors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: colors.textSecondary,
                                    ),
                                  ],
                                ),
                              )
                            : LocationBadge(location: _selectedLocation!),
                      ),

                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              style: TextStyle(color: colors.textPrimary),
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
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: colors.primary,
                                    width: 2,
                                  ),
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
                              padding: const EdgeInsets.all(14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Icon(Icons.add, color: colors.textPrimary),
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
                            'No rooms added yet. Create a Custom One OR tap suggestions below to add.',
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

              // Fixed button at bottom
              Padding(
                padding: const EdgeInsets.symmetric(),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    label: Text(
                      'Create',
                      style: TextStyle(fontSize: 16, color: colors.textPrimary),
                    ),
                    icon: Icon(Icons.check, color: colors.textPrimary),
                    onPressed: _selectedLocation != null
                        ? () => _saveRoomsAndNavigate()
                        : _selectLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
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

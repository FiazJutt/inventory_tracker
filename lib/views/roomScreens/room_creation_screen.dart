import 'package:flutter/material.dart';
import 'package:inventory_tracker/core/theme/app_colors.dart';
import 'package:inventory_tracker/views/locationScreens/location_selection_screen.dart';
import 'package:provider/provider.dart';
import 'package:inventory_tracker/viewmodels/inventory_provider.dart';
import 'package:inventory_tracker/models/room_model.dart';

class RoomCreationScreen extends StatefulWidget {
  final String? selectedLocation;

  const RoomCreationScreen({Key? key, this.selectedLocation}) : super(key: key);

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
      MaterialPageRoute(
        builder: (context) => const LocationSelectionScreen(),
      ),
    );

    if (selectedLocation != null && mounted) {
      setState(() {
        _selectedLocation = selectedLocation;
      });
    }
  }

  void _saveRoomsAndNavigate() {
    if (_selectedLocation == null || _selectedLocation!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (addedRooms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one room'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);

    // Add all rooms to the provider
    addedRooms.forEach((roomName, count) {
      for (int i = 0; i < count; i++) {
        // If count > 1, append number to room name
        final finalRoomName = count > 1 ? '$roomName ${i + 1}' : roomName;

        final room = Room(
          id: DateTime.now().millisecondsSinceEpoch.toString() + i.toString(),
          name: finalRoomName,
          location: _selectedLocation!,
        );

        inventoryProvider.addRoom(room);
      }
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${addedRooms.length} room${addedRooms.length == 1 ? "" : "s"} added to $_selectedLocation!'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    // Navigate back to home screen
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Rooms',
          style: TextStyle(
            color: AppColors.textPrimary,
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
                      Text(
                        "Add Rooms 🏡",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Text(
                        "Add rooms where your items belong. You can create your own or choose from suggestions.",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _selectLocation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _selectedLocation == null
                                ? AppColors.surface
                                : AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedLocation == null
                                  ? AppColors.textSecondary.withOpacity(0.3)
                                  : AppColors.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              if (_selectedLocation == null)
                                const Text(
                                  'Select Location',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              else
                                Text(
                                  _selectedLocation!,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              const Spacer(),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              style: const TextStyle(color: AppColors.textPrimary),
                              decoration: InputDecoration(
                                hintText: 'Custom Room Name',
                                hintStyle: TextStyle(
                                  color: AppColors.textSecondary.withOpacity(0.6),
                                ),
                                filled: true,
                                fillColor: AppColors.surface,
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
                                    color: AppColors.primary,
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
                                  addedRooms[name] = (addedRooms[name] ?? 0) + 1;
                                  _controller.clear();
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.all(14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Icon(Icons.add, color: Colors.black),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (addedRooms.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text(
                            'No rooms added yet. Create a Custom One OR tap suggestions below to add.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      else
                        Column(
                          children: addedRooms.entries.map((entry) {
                            final roomName = entry.key;
                            final count = entry.value;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.12),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    roomName,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            final current = addedRooms[roomName] ?? 1;
                                            if (current > 1) {
                                              addedRooms[roomName] = current - 1;
                                            } else {
                                              addedRooms.remove(roomName);
                                            }
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      Text(
                                        '$count',
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            addedRooms[roomName] = (addedRooms[roomName] ?? 0) + 1;
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 32),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.start,
                        children: roomSuggestions.map((suggestion) {
                          final isSelected = addedRooms.containsKey(suggestion);
                          return ChoiceChip(
                            label: Text(suggestion),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                            selectedColor: AppColors.primary,
                            backgroundColor: AppColors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.primary.withOpacity(0.25),
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() {
                                if (isSelected) {
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
                    label: const Text(
                      'Create',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    icon: const Icon(Icons.check, color: Colors.black),
                    onPressed: _selectedLocation != null ? _saveRoomsAndNavigate : _selectLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
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
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:inventory_tracker/viewmodels/room_provider.dart';
import 'package:inventory_tracker/models/room_model.dart';
import 'package:inventory_tracker/core/theme/app_colors.dart';

class AddContainerBottomSheet extends StatefulWidget {
  const AddContainerBottomSheet({Key? key}) : super(key: key);

  static Future<void> show(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (context) => const AddContainerBottomSheet(),
    );
  }

  @override
  _AddContainerBottomSheetState createState() => _AddContainerBottomSheetState();
}

class _AddContainerBottomSheetState extends State<AddContainerBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Room? _selectedRoom;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddContainerDialog() {
    if (_selectedRoom == null) return;
    
    final containerNameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Add New Container',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.meeting_room,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedRoom!.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _selectedRoom!.location,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: containerNameController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Container Name',
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                hintText: 'e.g., Drawer, Cabinet, Box',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.5),
                ),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Consumer<RoomProvider>(
            builder: (context, roomProvider, _) => ElevatedButton(
              onPressed: () {
                final containerName = containerNameController.text.trim();
                if (containerName.isNotEmpty && _selectedRoom != null) {
                  roomProvider.addContainer(_selectedRoom!.id, containerName);
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close bottom sheet
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Container "$containerName" added to ${_selectedRoom!.name}',
                      ),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'ADD',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Container',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedRoom == null
                      ? 'Select a room to add a container'
                      : 'Selected: ${_selectedRoom!.name}',
                  style: TextStyle(
                    color: _selectedRoom == null 
                        ? AppColors.textSecondary 
                        : AppColors.primary,
                    fontSize: 14,
                    fontWeight: _selectedRoom == null 
                        ? FontWeight.normal 
                        : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search rooms...',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.6),
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                ),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Room list
          Expanded(
            child: Consumer<RoomProvider>(
              builder: (context, roomProvider, _) {
                final filteredRooms = roomProvider.rooms.where((room) {
                  return room.name.toLowerCase().contains(_searchQuery) ||
                      room.location.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredRooms.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchQuery.isEmpty 
                              ? Icons.meeting_room_outlined 
                              : Icons.search_off,
                          size: 64,
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No rooms available'
                              : 'No rooms found for "$_searchQuery"',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                        if (_searchQuery.isEmpty) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'Add a room first from the home screen',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filteredRooms.length,
                  itemBuilder: (context, index) {
                    final room = filteredRooms[index];
                    final isSelected = _selectedRoom?.id == room.id;
                    final containerCount = roomProvider.getContainers(room.id).length;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? AppColors.primary.withOpacity(0.1)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected 
                              ? AppColors.primary 
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.meeting_room,
                            color: isSelected ? Colors.black : AppColors.primary,
                            size: 24,
                          ),
                        ),
                        title: Text(
                          room.name,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  room.location,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            if (containerCount > 0) ...[
                              const SizedBox(height: 4),
                              Text(
                                '$containerCount container${containerCount == 1 ? '' : 's'}',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                        trailing: Icon(
                          isSelected 
                              ? Icons.check_circle 
                              : Icons.arrow_forward_ios,
                          color: isSelected 
                              ? AppColors.primary 
                              : AppColors.textSecondary,
                          size: isSelected ? 24 : 16,
                        ),
                        onTap: () {
                          setState(() {
                            _selectedRoom = room;
                          });
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          // Bottom action button
          if (_selectedRoom != null)
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showAddContainerDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}














// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:inventory_tracker/viewmodels/room_provider.dart';
// import 'package:inventory_tracker/models/room_model.dart';
// import 'package:inventory_tracker/core/theme/app_colors.dart';

// class AddContainerBottomSheet extends StatefulWidget {
//   const AddContainerBottomSheet({Key? key}) : super(key: key);

//   static Future<void> show(BuildContext context) async {
//     await showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => const AddContainerBottomSheet(),
//     );
//   }

//   @override
//   _AddContainerBottomSheetState createState() => _AddContainerBottomSheetState();
// }

// class _AddContainerBottomSheetState extends State<AddContainerBottomSheet> {
//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _showAddContainerDialog(Room room) {
//     final containerNameController = TextEditingController();
    
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Add New Container'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Room: ${room.name} (${room.location})'),
//             const SizedBox(height: 16),
//             TextField(
//               controller: containerNameController,
//               decoration: const InputDecoration(
//                 labelText: 'Container Name',
//                 border: OutlineInputBorder(),
//               ),
//               autofocus: true,
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('CANCEL'),
//           ),
//           Consumer<RoomProvider>(
//             builder: (context, roomProvider, _) => ElevatedButton(
//               onPressed: () {
//                 final containerName = containerNameController.text.trim();
//                 if (containerName.isNotEmpty) {
//                   roomProvider.addContainer(room.id, containerName);
//                   Navigator.pop(context);
//                   Navigator.pop(context); // Close the bottom sheet
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('Container "$containerName" added to ${room.name}'),
//                       behavior: SnackBarBehavior.floating,
//                     ),
//                   );
//                 }
//               },
//               child: const Text('ADD'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Add Container To Room',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 16),
//           TextField(
//             controller: _searchController,
//             decoration: InputDecoration(
//               hintText: 'Search rooms...',
//               prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
//               filled: true,
//               fillColor: AppColors.surface,
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(30.0),
//                 borderSide: BorderSide.none,
//               ),
//               contentPadding: const EdgeInsets.symmetric(vertical: 0),
//             ),
//             onChanged: (value) {
//               setState(() {
//                 _searchQuery = value.toLowerCase();
//               });
//             },
//           ),
//           const SizedBox(height: 16),
//           Expanded(
//             child: Consumer<RoomProvider>(
//               builder: (context, roomProvider, _) {
//                 final filteredRooms = roomProvider.rooms.where((room) {
//                   return room.name.toLowerCase().contains(_searchQuery) ||
//                       room.location.toLowerCase().contains(_searchQuery);
//                 }).toList();

//                 if (filteredRooms.isEmpty) {
//                   return Center(
//                     child: Text(
//                       _searchQuery.isEmpty
//                           ? 'No rooms available. Add a room first.'
//                           : 'No rooms found for "$_searchQuery"',
//                       style: const TextStyle(color: AppColors.textSecondary),
//                     ),
//                   );
//                 }

//                 return ListView.builder(
//                   itemCount: filteredRooms.length,
//                   itemBuilder: (context, index) {
//                     final room = filteredRooms[index];
//                     return ListTile(
//                       title: Text(room.name),
//                       subtitle: Text(room.location),
//                       trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//                       onTap: () => _showAddContainerDialog(room),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

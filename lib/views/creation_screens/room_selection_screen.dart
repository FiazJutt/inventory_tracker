import 'package:flutter/material.dart';
import 'package:inventory_tracker/views/creation_screens/container_item_form_page.dart';
import 'package:provider/provider.dart';
import 'package:inventory_tracker/viewmodels/inventory_provider.dart';
import 'package:inventory_tracker/models/room_model.dart';
import 'package:inventory_tracker/models/container_model.dart';
import 'package:inventory_tracker/core/theme/app_colors.dart';

class RoomSelectionScreen extends StatefulWidget {
  final bool isAddItemScreen;

  const RoomSelectionScreen({
    Key? key,
    this.isAddItemScreen = false,
  }) : super(key: key);

  @override
  _RoomSelectionScreenState createState() => _RoomSelectionScreenState();
}

class _RoomSelectionScreenState extends State<RoomSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Room? _selectedRoom;
  ContainerModel? _selectedContainer;
  bool _showContainers = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToForm() {
    if (_selectedRoom == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContainerItemFormPage(
          room: _selectedRoom!,
          container: _selectedContainer, // Pass selected container (can be null)
          isAddItemScreen: widget.isAddItemScreen,
        ),
      ),
    );
  }

  void _onRoomSelected(Room room) {
    setState(() {
      _selectedRoom = room;
      _selectedContainer = null;
      
      // For items, show container selection screen
      if (widget.isAddItemScreen) {
        _showContainers = true;
      }
    });
  }

  void _onContainerSelected(ContainerModel? container) {
    setState(() {
      _selectedContainer = container;
    });
  }

  void _backToRoomSelection() {
    setState(() {
      _showContainers = false;
      _selectedRoom = null;
      _selectedContainer = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            if (_showContainers) {
              _backToRoomSelection();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          widget.isAddItemScreen ? 'Add Item' : 'Add Container',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _showContainers && widget.isAddItemScreen
          ? _buildContainerSelectionView()
          : _buildRoomSelectionView(),
    );
  }

  Widget _buildRoomSelectionView() {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedRoom == null
                    ? widget.isAddItemScreen
                        ? 'Select a room to add an item'
                        : 'Select a room to add a container'
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
          child: Consumer<InventoryProvider>(
            builder: (context, inventoryProvider, _) {
              final filteredRooms = inventoryProvider.rooms.where((room) {
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
                  final containerCount = inventoryProvider.getContainers(room.id).length;
                  
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
                        style: const TextStyle(
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
                              const Icon(
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
                          if (containerCount > 0 && widget.isAddItemScreen) ...[
                            const SizedBox(height: 4),
                            Text(
                              '$containerCount container${containerCount == 1 ? '' : 's'}',
                              style: const TextStyle(
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
                      onTap: () => _onRoomSelected(room),
                    ),
                  );
                },
              );
            },
          ),
        ),
        
        // Bottom action button for containers (skip container selection)
        if (_selectedRoom != null && !widget.isAddItemScreen)
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _navigateToForm,
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
    );
  }

  Widget _buildContainerSelectionView() {
    return Consumer<InventoryProvider>(
      builder: (context, inventoryProvider, _) {
        final containers = inventoryProvider.getContainers(_selectedRoom!.id);

        return Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Room: ${_selectedRoom!.name}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedContainer == null
                        ? 'Where do you want to add the item?'
                        : 'Selected: ${_selectedContainer!.name}',
                    style: TextStyle(
                      color: _selectedContainer == null 
                          ? AppColors.textPrimary 
                          : AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Add directly to room option
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: _selectedContainer == null
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _selectedContainer == null
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
                      color: _selectedContainer == null
                          ? AppColors.primary
                          : AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.meeting_room,
                      color: _selectedContainer == null ? Colors.black : AppColors.primary,
                      size: 24,
                    ),
                  ),
                  title: const Text(
                    'Directly in Room',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: const Text(
                    'Not in a container',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  trailing: Icon(
                    _selectedContainer == null
                        ? Icons.check_circle
                        : Icons.arrow_forward_ios,
                    color: _selectedContainer == null
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    size: _selectedContainer == null ? 24 : 16,
                  ),
                  onTap: () => _onContainerSelected(null),
                ),
              ),
            ),

            if (containers.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Divider(),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  'OR SELECT A CONTAINER',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],

            // Container list
            Expanded(
              child: containers.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          'No containers in this room.\nYou can add the item directly to the room.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: containers.length,
                      itemBuilder: (context, index) {
                        final container = containers[index];
                        final isSelected = _selectedContainer?.id == container.id;
                        final itemCount = inventoryProvider.getContainerItemCount(
                          _selectedRoom!.id,
                          container.id,
                        );

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
                                Icons.inventory_2,
                                color: isSelected ? Colors.black : AppColors.primary,
                                size: 24,
                              ),
                            ),
                            title: Text(
                              container.name,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: itemCount > 0
                                ? Text(
                                    '$itemCount item${itemCount == 1 ? '' : 's'}',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  )
                                : null,
                            trailing: Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.arrow_forward_ios,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              size: isSelected ? 24 : 16,
                            ),
                            onTap: () => _onContainerSelected(container),
                          ),
                        );
                      },
                    ),
            ),

            // Continue button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _navigateToForm,
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
        );
      },
    );
  }
}












// import 'package:flutter/material.dart';
// import 'package:inventory_tracker/views/creation_screens/container_item_form_page.dart';
// import 'package:provider/provider.dart';
// import 'package:inventory_tracker/viewmodels/inventory_provider.dart';
// import 'package:inventory_tracker/models/room_model.dart';
// import 'package:inventory_tracker/core/theme/app_colors.dart';

// class RoomSelectionScreen extends StatefulWidget {
//   final bool isAddItemScreen;

//   const RoomSelectionScreen({
//     Key? key,
//     this.isAddItemScreen = false,
//   }) : super(key: key);

//   @override
//   _RoomSelectionScreenState createState() => _RoomSelectionScreenState();
// }

// class _RoomSelectionScreenState extends State<RoomSelectionScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';
//   Room? _selectedRoom;

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _navigateToContainerDetails() {
//     if (_selectedRoom == null) return;
    
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ContainerItemFormPage(
//           room: _selectedRoom!,
//           isAddItemScreen: widget.isAddItemScreen,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         backgroundColor: AppColors.background,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           widget.isAddItemScreen ? 'Add Item' : 'Add Container',
//           style: const TextStyle(
//             color: AppColors.textPrimary,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           // Header
//           Padding(
//             padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   _selectedRoom == null
//                       ? widget.isAddItemScreen
//                           ? 'Select a room to add an item'
//                           : 'Select a room to add a container'
//                       : 'Selected: ${_selectedRoom!.name}',
//                   style: TextStyle(
//                     color: _selectedRoom == null 
//                         ? AppColors.textSecondary 
//                         : AppColors.primary,
//                     fontSize: 14,
//                     fontWeight: _selectedRoom == null 
//                         ? FontWeight.normal 
//                         : FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
          
//           // Search bar
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: TextField(
//               controller: _searchController,
//               style: const TextStyle(color: AppColors.textPrimary),
//               decoration: InputDecoration(
//                 hintText: 'Search rooms...',
//                 hintStyle: TextStyle(
//                   color: AppColors.textSecondary.withOpacity(0.6),
//                 ),
//                 prefixIcon: const Icon(
//                   Icons.search,
//                   color: AppColors.textSecondary,
//                 ),
//                 filled: true,
//                 fillColor: AppColors.surface,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(15),
//                   borderSide: BorderSide.none,
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(vertical: 0),
//               ),
//               onChanged: (value) {
//                 setState(() {
//                   _searchQuery = value.toLowerCase();
//                 });
//               },
//             ),
//           ),
          
//           const SizedBox(height: 16),
          
//           // Room list
//           Expanded(
//             child: Consumer<InventoryProvider>(
//               builder: (context, inventoryProvider, _) {
//                 final filteredRooms = inventoryProvider.rooms.where((room) {
//                   return room.name.toLowerCase().contains(_searchQuery) ||
//                       room.location.toLowerCase().contains(_searchQuery);
//                 }).toList();

//                 if (filteredRooms.isEmpty) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           _searchQuery.isEmpty 
//                               ? Icons.meeting_room_outlined 
//                               : Icons.search_off,
//                           size: 64,
//                           color: AppColors.textSecondary.withOpacity(0.5),
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           _searchQuery.isEmpty
//                               ? 'No rooms available'
//                               : 'No rooms found for "$_searchQuery"',
//                           style: const TextStyle(
//                             color: AppColors.textSecondary,
//                             fontSize: 16,
//                           ),
//                         ),
//                         if (_searchQuery.isEmpty) ...[
//                           const SizedBox(height: 8),
//                           const Text(
//                             'Add a room first from the home screen',
//                             style: TextStyle(
//                               color: AppColors.textSecondary,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                   );
//                 }

//                 return ListView.builder(
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   itemCount: filteredRooms.length,
//                   itemBuilder: (context, index) {
//                     final room = filteredRooms[index];
//                     final isSelected = _selectedRoom?.id == room.id;
//                     final containerCount = inventoryProvider.getContainers(room.id).length;
                    
//                     return Container(
//                       margin: const EdgeInsets.only(bottom: 10),
//                       decoration: BoxDecoration(
//                         color: isSelected 
//                             ? AppColors.primary.withOpacity(0.1)
//                             : AppColors.surface,
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(
//                           color: isSelected 
//                               ? AppColors.primary 
//                               : Colors.transparent,
//                           width: 2,
//                         ),
//                       ),
//                       child: ListTile(
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 8,
//                         ),
//                         leading: Container(
//                           padding: const EdgeInsets.all(10),
//                           decoration: BoxDecoration(
//                             color: isSelected
//                                 ? AppColors.primary
//                                 : AppColors.primary.withOpacity(0.2),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Icon(
//                             Icons.meeting_room,
//                             color: isSelected ? Colors.black : AppColors.primary,
//                             size: 24,
//                           ),
//                         ),
//                         title: Text(
//                           room.name,
//                           style: const TextStyle(
//                             color: AppColors.textPrimary,
//                             fontWeight: FontWeight.w600,
//                             fontSize: 16,
//                           ),
//                         ),
//                         subtitle: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const SizedBox(height: 4),
//                             Row(
//                               children: [
//                                 const Icon(
//                                   Icons.location_on,
//                                   size: 14,
//                                   color: AppColors.textSecondary,
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Text(
//                                   room.location,
//                                   style: const TextStyle(
//                                     color: AppColors.textSecondary,
//                                     fontSize: 13,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             if (containerCount > 0) ...[
//                               const SizedBox(height: 4),
//                               Text(
//                                 widget.isAddItemScreen
//                                     ? '$containerCount item${containerCount == 1 ? '' : 's'}'
//                                     : '$containerCount container${containerCount == 1 ? '' : 's'}',
//                                 style: const TextStyle(
//                                   color: AppColors.primary,
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ],
//                           ],
//                         ),
//                         trailing: Icon(
//                           isSelected 
//                               ? Icons.check_circle 
//                               : Icons.arrow_forward_ios,
//                           color: isSelected 
//                               ? AppColors.primary 
//                               : AppColors.textSecondary,
//                           size: isSelected ? 24 : 16,
//                         ),
//                         onTap: () {
//                           setState(() {
//                             _selectedRoom = room;
//                           });
//                         },
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
          
//           // Bottom action button
//           if (_selectedRoom != null)
//             Padding(
//               padding: const EdgeInsets.all(20),
//               child: SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _navigateToContainerDetails,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primary,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                   ),
//                   child: const Text(
//                     'Continue',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
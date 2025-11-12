import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventory_tracker/core/theme/app_colors.dart';
import 'package:inventory_tracker/views/widgets/add_container_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:inventory_tracker/viewmodels/room_provider.dart';
import 'package:inventory_tracker/models/room_model.dart';

class FloatingNavbar extends StatefulWidget {
  const FloatingNavbar({Key? key}) : super(key: key);

  @override
  State<FloatingNavbar> createState() => _FloatingNavbarState();
}

class _FloatingNavbarState extends State<FloatingNavbar>
    with SingleTickerProviderStateMixin {
  bool _isFabExpanded = false;
  int _selectedIndex = 0;
  late AnimationController _fabAnimationController;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _toggleFab() {
    setState(() {
      _isFabExpanded = !_isFabExpanded;
      if (_isFabExpanded) {
        _fabAnimationController.forward();
      } else {
        _fabAnimationController.reverse();
      }
    });
    HapticFeedback.lightImpact();
  }

  void _closeFab() {
    if (_isFabExpanded) {
      setState(() {
        _isFabExpanded = false;
        _fabAnimationController.reverse();
      });
    }
  }

  // ----------------------------
  // Dialogs
  // ----------------------------
  void _showAddLocationDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add New Location',
            style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            labelText: 'Location Name',
            labelStyle: const TextStyle(color: AppColors.textSecondary),
            hintText: 'e.g., Home, Office, Warehouse',
            hintStyle: TextStyle(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Provider.of<RoomProvider>(context, listen: false)
                    .addLocation(name);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Location "$name" added'),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('ADD', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showAddRoomDialog() {
    final nameController = TextEditingController();
    String? selectedLocation;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final roomProvider =
              Provider.of<RoomProvider>(context, listen: false);
          final locations = roomProvider.allLocations;

          return AlertDialog(
            backgroundColor: AppColors.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Add New Room',
                style: TextStyle(color: AppColors.textPrimary)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Room Name',
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (locations.isEmpty)
                  Text('No locations available. Please add a location first.',
                      style: TextStyle(
                          color: Colors.orange.shade300, fontSize: 12))
                else
                  DropdownButtonFormField<String>(
                    value: selectedLocation,
                    dropdownColor: AppColors.surface,
                    decoration: InputDecoration(
                      labelText: 'Location',
                      labelStyle:
                          const TextStyle(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: locations.map((loc) {
                      return DropdownMenuItem(
                        value: loc,
                        child: Text(loc,
                            style:
                                const TextStyle(color: AppColors.textPrimary)),
                      );
                    }).toList(),
                    onChanged: (v) {
                      setDialogState(() => selectedLocation = v);
                    },
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                onPressed: locations.isEmpty
                    ? null
                    : () {
                        final name = nameController.text.trim();
                        if (name.isNotEmpty && selectedLocation != null) {
                          final room = Room(
                            id: DateTime.now().millisecondsSinceEpoch
                                .toString(),
                            name: name,
                            location: selectedLocation!,
                          );
                          roomProvider.addRoom(room);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Room "$name" added to $selectedLocation'),
                              backgroundColor: AppColors.primary,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor:
                      AppColors.primary.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('ADD', style: TextStyle(color: Colors.black)),
              ),
            ],
          );
        },
      ),
    );
  }

  // ----------------------------
  // BUILD
  // ----------------------------
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Dim background when expanded
        if (_isFabExpanded)
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeFab,
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),
          ),

        // ✅ Navbar container (unchanged design)
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Container(
              height: 66,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withOpacity(0.95),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(0, context, Icons.home_filled, 'Home'),
                  const SizedBox(width: 56),
                  _buildNavItem(1, context, Icons.format_list_bulleted, 'Items'),
                ],
              ),
            ),
          ),
        ),

        // ✅ Floating Action Button + options (above everything)
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isFabExpanded) ...[
                _buildAddOption(
                    'Add Location', Icons.location_on, _showAddLocationDialog),
                const SizedBox(height: 12),
                _buildAddOption(
                    'Add Room', Icons.meeting_room, _showAddRoomDialog),
                const SizedBox(height: 12),
                _buildAddOption('Add Container', Icons.inventory_2, () {
                  AddContainerBottomSheet.show(context);
                }),
                const SizedBox(height: 12),
                _buildAddOption('Add Item', Icons.add_box, () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Add Item feature coming soon!')),
                  );
                }),
                const SizedBox(height: 16),
              ],
              FloatingActionButton(
                onPressed: _toggleFab,
                backgroundColor: AppColors.primary,
                elevation: _isFabExpanded ? 8 : 4,
                child: AnimatedRotation(
                  duration: const Duration(milliseconds: 300),
                  turns: _isFabExpanded ? 0.125 : 0,
                  child: Icon(
                    _isFabExpanded ? Icons.close : Icons.add,
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ----------------------------
  // Widgets
  // ----------------------------
  Widget _buildAddOption(String label, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
          Future.delayed(const Duration(milliseconds: 150), _closeFab);
        },
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant.withOpacity(0.95),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 10),
              Text(label,
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      int index, BuildContext context, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() => _selectedIndex = index);
        _closeFab();
        HapticFeedback.selectionClick();
      },
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: isSelected
                    ? AppColors.primary
                    : Colors.white.withOpacity(0.7),
                size: isSelected ? 26 : 24),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    color: isSelected ? AppColors.primary : Colors.white70,
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}




















// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:inventory_tracker/core/theme/app_colors.dart';
// import 'package:inventory_tracker/views/home/home_screen.dart';
// import 'package:inventory_tracker/views/widgets/add_container_bottom_sheet.dart';
// import 'package:provider/provider.dart';
// import 'package:inventory_tracker/viewmodels/room_provider.dart';
// import 'package:inventory_tracker/models/room_model.dart';

// class FloatingNavbar extends StatefulWidget {
//   const FloatingNavbar({Key? key}) : super(key: key);

//   @override
//   _FloatingNavbarState createState() => _FloatingNavbarState();
// }

// class _FloatingNavbarState extends State<FloatingNavbar>
//     with SingleTickerProviderStateMixin {
//   bool _isFabExpanded = false;
//   int _selectedIndex = 0;
//   late AnimationController _fabAnimationController;

//   @override
//   void initState() {
//     super.initState();
//     _fabAnimationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );
//   }

//   @override
//   void dispose() {
//     _fabAnimationController.dispose();
//     super.dispose();
//   }

//   void _toggleFab() {
//     setState(() {
//       _isFabExpanded = !_isFabExpanded;
//       if (_isFabExpanded) {
//         _fabAnimationController.forward();
//       } else {
//         _fabAnimationController.reverse();
//       }
//     });
//     HapticFeedback.lightImpact();
//   }

//   void _closeFab() {
//     if (_isFabExpanded) {
//       setState(() {
//         _isFabExpanded = false;
//         _fabAnimationController.reverse();
//       });
//     }
//   }

//   void _showAddLocationDialog() {
//     final controller = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: AppColors.background,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: const Text(
//           'Add New Location',
//           style: TextStyle(color: AppColors.textPrimary),
//         ),
//         content: TextField(
//           controller: controller,
//           style: const TextStyle(color: AppColors.textPrimary),
//           decoration: InputDecoration(
//             labelText: 'Location Name',
//             labelStyle: const TextStyle(color: AppColors.textSecondary),
//             hintText: 'e.g., Home, Office, Warehouse',
//             hintStyle: TextStyle(
//               color: AppColors.textSecondary.withOpacity(0.5),
//             ),
//             filled: true,
//             fillColor: AppColors.surface,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide.none,
//             ),
//           ),
//           autofocus: true,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text(
//               'CANCEL',
//               style: TextStyle(color: AppColors.textSecondary),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               final name = controller.text.trim();
//               if (name.isNotEmpty) {
//                 Provider.of<RoomProvider>(
//                   context,
//                   listen: false,
//                 ).addLocation(name);
//                 Navigator.pop(context);
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text('Location "$name" added'),
//                     backgroundColor: AppColors.primary,
//                     behavior: SnackBarBehavior.floating,
//                   ),
//                 );
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primary,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             child: const Text('ADD', style: TextStyle(color: Colors.black)),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showAddRoomDialog() {
//     final nameController = TextEditingController();
//     String? selectedLocation;

//     showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setDialogState) {
//           final roomProvider = Provider.of<RoomProvider>(
//             context,
//             listen: false,
//           );
//           final locations = roomProvider.allLocations;

//           return AlertDialog(
//             backgroundColor: AppColors.background,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20),
//             ),
//             title: const Text(
//               'Add New Room',
//               style: TextStyle(color: AppColors.textPrimary),
//             ),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 TextField(
//                   controller: nameController,
//                   style: const TextStyle(color: AppColors.textPrimary),
//                   decoration: InputDecoration(
//                     labelText: 'Room Name',
//                     labelStyle: const TextStyle(color: AppColors.textSecondary),
//                     hintText: 'e.g., Living Room, Kitchen',
//                     hintStyle: TextStyle(
//                       color: AppColors.textSecondary.withOpacity(0.5),
//                     ),
//                     filled: true,
//                     fillColor: AppColors.surface,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide.none,
//                     ),
//                   ),
//                   autofocus: true,
//                 ),
//                 const SizedBox(height: 16),
//                 if (locations.isEmpty)
//                   Text(
//                     'No locations available. Please add a location first.',
//                     style: TextStyle(
//                       color: Colors.orange.shade300,
//                       fontSize: 12,
//                     ),
//                   )
//                 else
//                   DropdownButtonFormField<String>(
//                     value: selectedLocation,
//                     dropdownColor: AppColors.surface,
//                     decoration: InputDecoration(
//                       labelText: 'Location',
//                       labelStyle: const TextStyle(
//                         color: AppColors.textSecondary,
//                       ),
//                       filled: true,
//                       fillColor: AppColors.surface,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                     items: locations.map((location) {
//                       return DropdownMenuItem(
//                         value: location,
//                         child: Text(
//                           location,
//                           style: const TextStyle(color: AppColors.textPrimary),
//                         ),
//                       );
//                     }).toList(),
//                     onChanged: (value) {
//                       setDialogState(() {
//                         selectedLocation = value;
//                       });
//                     },
//                   ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text(
//                   'CANCEL',
//                   style: TextStyle(color: AppColors.textSecondary),
//                 ),
//               ),
//               ElevatedButton(
//                 onPressed: locations.isEmpty
//                     ? null
//                     : () {
//                         final name = nameController.text.trim();
//                         if (name.isNotEmpty && selectedLocation != null) {
//                           final room = Room(
//                             id: DateTime.now().millisecondsSinceEpoch
//                                 .toString(),
//                             name: name,
//                             location: selectedLocation!,
//                           );
//                           roomProvider.addRoom(room);
//                           Navigator.pop(context);
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                               content: Text(
//                                 'Room "$name" added to $selectedLocation',
//                               ),
//                               backgroundColor: AppColors.primary,
//                               behavior: SnackBarBehavior.floating,
//                             ),
//                           );
//                         }
//                       },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primary,
//                   disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child: const Text('ADD', style: TextStyle(color: Colors.black)),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       clipBehavior: Clip.none,
//       children: [
//         // Backdrop to close FAB when tapped outside - MUST be first so it doesn't block taps
//         if (_isFabExpanded)
//           Positioned.fill(
//             child: GestureDetector(
//               onTap: _closeFab,
//               child: Container(color: Colors.black.withOpacity(0.3)),
//             ),
//           ),

//         // Main navbar container
//         Positioned(
//           left: 0,
//           right: 0,
//           bottom: 0,
//           child: Container(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 24.0,
//               vertical: 8.0,
//             ),
//             child: Stack(
//               clipBehavior: Clip.none,
//               alignment: Alignment.center,
//               children: [
//                 // The background container
//                 Container(
//                   height: 66,
//                   decoration: BoxDecoration(
//                     color: AppColors.surfaceVariant.withOpacity(0.95),
//                     borderRadius: BorderRadius.circular(40),
//                     border: Border.all(color: Colors.white.withOpacity(0.1)),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.25),
//                         blurRadius: 12,
//                         offset: const Offset(0, 6),
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       _buildNavItem(0, context, Icons.home_filled, 'Home'),
//                       const SizedBox(width: 56),
//                       _buildNavItem(
//                         1,
//                         context,
//                         Icons.format_list_bulleted,
//                         'Items',
//                       ),
//                     ],
//                   ),
//                 ),

//                 // The central Floating Action Button with options
//                 Positioned(
//                   bottom: 20,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       // Expanded options (appear above the FAB)
//                       if (_isFabExpanded) ...[
//                         _buildAddOption(
//                           'Add Location',
//                           Icons.location_on,
//                           _showAddLocationDialog,
//                         ),
//                         const SizedBox(height: 12),
//                         _buildAddOption(
//                           'Add Room',
//                           Icons.meeting_room,
//                           _showAddRoomDialog,
//                         ),
//                         const SizedBox(height: 12),
//                         _buildAddOption('Add Container', Icons.inventory_2, () {
//                           print('Container tapped!'); // Debug
//                           AddContainerBottomSheet.show(context);
//                         }),
//                         const SizedBox(height: 12),
//                         _buildAddOption('Add Item', Icons.add_box, () {
//                           print('Item tapped!'); // Debug
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: Text('Add Item feature coming soon!'),
//                             ),
//                           );
//                         }),
//                         const SizedBox(height: 16),
//                       ],

//                       // The FAB itself
//                       FloatingActionButton(
//                         onPressed: _toggleFab,
//                         backgroundColor: AppColors.primary,
//                         elevation: _isFabExpanded ? 8 : 4,
//                         child: AnimatedRotation(
//                           duration: const Duration(milliseconds: 300),
//                           turns: _isFabExpanded ? 0.125 : 0,
//                           child: Icon(
//                             _isFabExpanded ? Icons.close : Icons.add,
//                             color: AppColors.onPrimary,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),

//         // // Backdrop to close FAB when tapped outside - MOVED TO BOTTOM after navbar
//         // if (_isFabExpanded)
//         //   Positioned.fill(
//         //     child: GestureDetector(
//         //       onTap: _closeFab,
//         //       child: Container(color: Colors.black.withOpacity(0.3)),
//         //     ),
//         //   ),
//       ],
//     );
//   }

//   Widget _buildAddOption(String label, IconData icon, VoidCallback onTap) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(28),
//         onTap: () {
//           print('$label tapped - callback will execute'); // Debug print
//           HapticFeedback.selectionClick();

//           // Execute the callback FIRST, then close the FAB
//           onTap();

//           // Close FAB after a short delay to let the dialog/bottom sheet open
//           Future.delayed(const Duration(milliseconds: 100), () {
//             if (mounted) {
//               _closeFab();
//             }
//           });
//         },
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           decoration: BoxDecoration(
//             color: AppColors.surfaceVariant.withOpacity(0.95),
//             borderRadius: BorderRadius.circular(28),
//             border: Border.all(color: Colors.white.withOpacity(0.1)),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.15),
//                 blurRadius: 8,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(icon, size: 20, color: AppColors.primary),
//               const SizedBox(width: 10),
//               Text(
//                 label,
//                 style: const TextStyle(
//                   color: AppColors.primary,
//                   fontSize: 15,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildNavItem(
//     int index,
//     BuildContext context,
//     IconData icon,
//     String label,
//   ) {
//     final isSelected = _selectedIndex == index;
//     return InkWell(
//       onTap: () {
//         setState(() {
//           _selectedIndex = index;
//         });
//         print('Hello Clicked');
//         _closeFab(); // Close FAB when navigating
//         HapticFeedback.selectionClick();
//       },
//       borderRadius: BorderRadius.circular(24),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               icon,
//               color: isSelected
//                   ? AppColors.primary
//                   : Colors.white.withOpacity(0.7),
//               size: isSelected ? 26 : 24,
//             ),
//             const SizedBox(height: 4),
//             Text(
//               label,
//               style: TextStyle(
//                 color: isSelected ? AppColors.primary : Colors.white70,
//                 fontSize: 12,
//                 fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

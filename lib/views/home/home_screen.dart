import 'package:flutter/material.dart';
import 'package:inventory_tracker/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:inventory_tracker/viewmodels/room_provider.dart';
import 'package:inventory_tracker/views/home/floating_navbar.dart';
import 'package:inventory_tracker/views/widgets/add_container_bottom_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // static void showAddContainerBottomSheet(BuildContext context) {
  //   AddContainerBottomSheet.show(context);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),

          actions: [
            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: () => ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Scan QR tapped'))),
            ),
            IconButton(
              icon: const Icon(Icons.tune),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Color tuning tapped')),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.sort),
              onPressed: () => ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Sort tapped'))),
            ),
          ],
        ),
        body: Consumer<RoomProvider>(
          builder: (context, roomProvider, _) {
            return Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search rooms...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (value) {
                      // Implement search functionality
                    },
                  ),
                ),
                Expanded(child: _buildRoomList(roomProvider)),
              ],
            );
          },
        ),
        bottomNavigationBar: const FloatingNavbar(),
    );
  }


  Widget _buildRoomList(RoomProvider roomProvider) {
    if (roomProvider.rooms.isEmpty) {
      return const Center(
        child: Text('No rooms found. Add a room to get started.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: roomProvider.rooms.length,
      itemBuilder: (context, index) {
        final room = roomProvider.rooms[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            title: Text(
              room.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              room.location,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Room',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            onTap: () {
              // Navigate to room detail
            },
          ),
        );
      },
    );
  }
}














// import 'package:flutter/material.dart';
// import 'package:inventory_tracker/core/theme/app_colors.dart';
// import 'package:inventory_tracker/views/home/floating_navbar.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBody: true,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.settings_outlined),
//           onPressed: () {},
//         ),

//         actions: [
//           IconButton(
//             icon: const Icon(Icons.qr_code_scanner),
//             onPressed: () => ScaffoldMessenger.of(
//               context,
//             ).showSnackBar(const SnackBar(content: Text('Scan QR tapped'))),
//           ),
//           IconButton(
//             icon: const Icon(Icons.tune),
//             onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('Color tuning tapped')),
//             ),
//           ),
//           IconButton(
//             icon: const Icon(Icons.sort),
//             onPressed: () => ScaffoldMessenger.of(
//               context,
//             ).showSnackBar(const SnackBar(content: Text('Sort tapped'))),
//           ),
//         ],
//       ),
//       body: SafeArea(
//         // Use bottom: false to allow content to scroll behind the transparent nav bar
//         bottom: false,
//         child: Column(
//           children: [
//             // 1. A single, clear search bar at the top
//             Padding(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 16.0,
//                 vertical: 8.0,
//               ),
//               child: TextField(
//                 decoration: InputDecoration(
//                   hintText: 'Search inventory...',
//                   prefixIcon: const Icon(
//                     Icons.search,
//                     color: AppColors.textSecondary,
//                   ),
//                   filled: true,
//                   fillColor: AppColors.surface,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(30.0),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),
//             ),

//             // 2. The actual content of the screen
//             const Expanded(child: _InventoryList()),
//           ],
//         ),
//       ),
//       // 3. The floating nav bar placed in the correct Scaffold property
//       bottomNavigationBar: const FloatingNavbar(),
//     );
//   }
// }

// // A placeholder widget to demonstrate how content looks with the new layout
// class _InventoryList extends StatelessWidget {
//   const _InventoryList();

//   @override
//   Widget build(BuildContext context) {
//     // Using a ListView to show how the content scrolls under the app bar
//     return ListView.builder(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0),
//       itemCount: 20,
//       itemBuilder: (context, index) {
//         return Card(
//           color: AppColors.surface,
//           margin: const EdgeInsets.symmetric(vertical: 8),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: ListTile(
//             leading: CircleAvatar(
//               backgroundColor: AppColors.primary.withOpacity(0.2),
//               child: const Icon(
//                 Icons.inventory_2_outlined,
//                 color: AppColors.primary,
//               ),
//             ),
//             title: Text(
//               'Inventory Item ${index + 1}',
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//             subtitle: Text(
//               'In "Living Room"',
//               style: TextStyle(color: AppColors.textSecondary),
//             ),
//             trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//           ),
//         );
//       },
//     );
//   }
// }

// // Small reusable action button used under the search bar
// class _HomeActionButton extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final VoidCallback onTap;

//   const _HomeActionButton({
//     required this.icon,
//     required this.label,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Material(
//           color: AppColors.surface,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: InkWell(
//             borderRadius: BorderRadius.circular(12),
//             onTap: onTap,
//             child: Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: Icon(icon, color: AppColors.primary),
//             ),
//           ),
//         ),
//         const SizedBox(height: 6),
//         Text(
//           label,
//           style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
//         ),
//       ],
//     );
//   }
// }

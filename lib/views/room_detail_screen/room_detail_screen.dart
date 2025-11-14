import 'package:flutter/material.dart';
import 'package:inventory_tracker/views/containerItem/detail/container_item_detail_screen.dart';
import 'package:inventory_tracker/views/containerItem/move_item_screen.dart'; // ADD THIS IMPORT
import 'package:inventory_tracker/views/room_detail_screen/tabs/container_tab.dart';
import 'package:inventory_tracker/views/room_detail_screen/tabs/item_tab.dart';
import 'package:inventory_tracker/views/room_detail_screen/widgets/room_tabbar.dart';
import 'package:provider/provider.dart';
import 'package:inventory_tracker/core/theme/app_colors.dart';
import 'package:inventory_tracker/models/room_model.dart';
import 'package:inventory_tracker/viewmodels/inventory_provider.dart';

import '../containerItem/container_item_form_page.dart';

class RoomDetailScreen extends StatefulWidget {
  final Room room;

  const RoomDetailScreen({super.key, required this.room});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          onPressed: Navigator
              .of(context)
              .pop,
        ),
      ),
      body: Consumer<InventoryProvider>(
        builder: (context, inventoryProvider, _) {
          final containers = inventoryProvider.getContainers(widget.room.id);
          final items = inventoryProvider.getItems(widget.room.id);

          return Column(
            children: [
              _RoomInfoCard(room: widget.room),
              RoomTabBar(tabController: _tabController),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    ContainersTab(
                      containers: containers,
                      room: widget.room,
                      onAddPressed: () => _navigateToAdd(context, false),
                      onTap: (context, container) =>
                          _navigateToDetail(context, container, isItem: false),
                      onOptions: _showContainerOptions,
                    ),
                    ItemsTab(
                      items: items,
                      room: widget.room,
                      onAddPressed: () => _navigateToAdd(context, true),
                      onTap: (context, item) =>
                          _navigateToDetail(context, item, isItem: true),
                      onOptions: _showContainerOptions,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _navigateToAdd(BuildContext context, bool isItemScreen) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            ContainerItemFormPage(
              room: widget.room,
              isAddItemScreen: isItemScreen,
              fromRoomDetailScreen: true,
            ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context,
      dynamic item, {
        required bool isItem,
      }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            ContainerItemDetailScreen(item: item, isItem: isItem),
      ),
    );
  }

  void _showContainerOptions(BuildContext context,
      dynamic containerOrItem,
      String roomId,
      bool isItem,) {
    final colors = context.appColors;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) =>
          SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Icon(
                    Icons.drive_file_move_outline,
                    color: colors.primary,
                  ),
                  title: Text(
                    'Move',
                    style: TextStyle(color: colors.textPrimary),
                  ),
                  onTap: () async {
                    Navigator.pop(context); // Close the bottom sheet

                    if (isItem) {
                      // Navigate to move item screen
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MoveItemScreen(
                                item: containerOrItem,
                                currentRoomId: roomId,
                              ),
                        ),
                      );

                      // If item was moved, refresh the screen
                      if (result == true && mounted) {
                        setState(() {
                          // This will trigger a rebuild and refresh the item list
                        });
                      }
                    }
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
    );
  }
}
//
// ---------- Small Reusable Widgets Below ----------
//

class _RoomInfoCard extends StatelessWidget {
  final Room room;

  const _RoomInfoCard({required this.room});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: colors.surface,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                room.name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    room.location,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:inventory_tracker/views/container_item_detail_screen.dart';
import 'package:inventory_tracker/views/creation_screens/container_item_form_page.dart';
import 'package:inventory_tracker/views/room_detail_screen/widgets/empty_state.dart';
import 'package:inventory_tracker/views/room_detail_screen/widgets/room_tabbar.dart';
import 'package:provider/provider.dart';
import 'package:inventory_tracker/core/theme/app_colors.dart';
import 'package:inventory_tracker/models/room_model.dart';
import 'package:inventory_tracker/viewmodels/inventory_provider.dart';

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: Navigator.of(context).pop,
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
                    _ContainersTab(
                      containers: containers,
                      room: widget.room,
                      onAddPressed: () => _navigateToAdd(context, false),
                      onTap: (context, container) =>
                          _navigateToDetail(context, container, isItem: false),
                      onDelete: _deleteContainerOrItem,
                      onOptions: _showContainerOptions,
                    ),
                    _ItemsTab(
                      items: items,
                      room: widget.room,
                      onAddPressed: () => _navigateToAdd(context, true),
                      onTap: (context, item) =>
                          _navigateToDetail(context, item, isItem: true),
                      onDelete: _deleteContainerOrItem,
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
        builder: (context) => ContainerItemFormPage(
          room: widget.room,
          isAddItemScreen: isItemScreen,
          fromRoomDetailScreen: true,
        ),
      ),
    );
  }

  void _navigateToDetail(
    BuildContext context,
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

  void _showContainerOptions(
    BuildContext context,
    dynamic containerOrItem,
    String roomId,
    bool isItem,
  ) {
    final name = containerOrItem is String
        ? containerOrItem
        : (containerOrItem.name ?? 'Unnamed');
    final id = containerOrItem is String ? null : containerOrItem.id;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(
                Icons.drive_file_move_outline,
                color: AppColors.primary,
              ),
              title: const Text(
                'Move',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Move feature coming soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.primary),
              title: const Text(
                'Edit',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit feature coming soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteContainerOrItem(
                  context,
                  roomId,
                  id ?? name,
                  name,
                  isItem,
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _deleteContainerOrItem(
    BuildContext context,
    String roomId,
    String idOrName,
    String name,
    bool isItem,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Delete ${isItem ? 'Item' : 'Container'}',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete "$name"?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final provider = context.read<InventoryProvider>();
              if (isItem) {
                // Try to delete by ID first, fallback to name
                try {
                  provider.removeItemById(roomId, idOrName);
                } catch (e) {
                  provider.removeItem(roomId, name);
                }
              } else {
                // Try to delete by ID first, fallback to name
                try {
                  provider.removeContainerById(roomId, idOrName);
                } catch (e) {
                  provider.removeContainer(roomId, name);
                }
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${isItem ? 'Item' : 'Container'} deleted'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: AppColors.surface,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                room.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    room.location,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
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

class _ContainersTab extends StatelessWidget {
  final List<dynamic> containers;
  final Room room;
  final VoidCallback onAddPressed;
  final void Function(BuildContext, dynamic) onTap;
  final void Function(BuildContext, dynamic, String, bool) onOptions;
  final void Function(BuildContext, String, String, String, bool) onDelete;

  const _ContainersTab({
    required this.containers,
    required this.room,
    required this.onAddPressed,
    required this.onTap,
    required this.onOptions,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          _HeaderRow(title: 'Containers', onAddPressed: onAddPressed),
          const SizedBox(height: 12),
          if (containers.isEmpty)
            const EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'No containers added yet',
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: containers.length,
              itemBuilder: (context, i) {
                final container = containers[i];
                final containerName = container is String
                    ? container
                    : (container.name ?? 'Unnamed');

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () => onTap(context, container),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.inventory_2_outlined,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  containerName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                if (container is! String) ...[
                                  if (container.description?.isNotEmpty ??
                                      false) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      container.description!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                  if (container.brand?.isNotEmpty ?? false) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      container.brand!,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.primary.withOpacity(
                                          0.8,
                                        ),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.more_vert,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () =>
                                onOptions(context, container, room.id, false),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _ItemsTab extends StatelessWidget {
  final List<dynamic> items;
  final Room room;
  final VoidCallback onAddPressed;
  final void Function(BuildContext, dynamic) onTap;
  final void Function(BuildContext, dynamic, String, bool) onOptions;
  final void Function(BuildContext, String, String, String, bool) onDelete;

  const _ItemsTab({
    required this.items,
    required this.room,
    required this.onAddPressed,
    required this.onTap,
    required this.onOptions,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          _HeaderRow(title: 'Items', onAddPressed: onAddPressed),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const EmptyState(
              icon: Icons.shopping_bag_outlined,
              title: 'No items added yet',
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final item = items[i];
                final itemName = item is String
                    ? item
                    : (item.name ?? 'Unnamed');

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () => onTap(context, item),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.shopping_bag_outlined,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        itemName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    if (item is! String &&
                                        item.quantity != null &&
                                        item.quantity > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(
                                            0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          'Qty: ${item.quantity}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                if (item is! String) ...[
                                  if (item.description?.isNotEmpty ??
                                      false) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      item.description!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                  if (item.brand?.isNotEmpty ?? false) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      item.brand!,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.primary.withOpacity(
                                          0.8,
                                        ),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.more_vert,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () =>
                                onOptions(context, item, room.id, true),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final String title;
  final VoidCallback onAddPressed;

  const _HeaderRow({required this.title, required this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        ElevatedButton.icon(
          onPressed: onAddPressed,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
      ],
    );
  }
}

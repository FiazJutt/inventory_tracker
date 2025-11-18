import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:inventory_tracker/viewmodels/inventory_provider.dart';
import 'package:inventory_tracker/models/room_model.dart';
import 'package:inventory_tracker/models/container_model.dart';
import 'package:inventory_tracker/models/item_model.dart';
import 'package:inventory_tracker/core/theme/app_colors.dart';
import 'widgets/moving_item_info_card.dart';
import 'widgets/destination_info_card.dart';
import 'package:inventory_tracker/core/widgets/list_items/room_list_item.dart';
import 'package:inventory_tracker/core/widgets/list_items/container_list_item.dart';
import 'package:inventory_tracker/views/roomScreens/widgets/direct_room_option.dart';
import 'package:inventory_tracker/core/widgets/universal_search_bar.dart';
import 'package:inventory_tracker/core/widgets/empty_state.dart';

class MoveItemScreen extends StatefulWidget {
  final Item item;
  final String currentRoomId;

  const MoveItemScreen({
    super.key,
    required this.item,
    required this.currentRoomId,
  });

  @override
  _MoveItemScreenState createState() => _MoveItemScreenState();
}

class _MoveItemScreenState extends State<MoveItemScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Room? _selectedRoom;
  ContainerModel? _selectedContainer;
  bool _showContainers = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onRoomSelected(Room room) {
    setState(() {
      _selectedRoom = room;
      _selectedContainer = null;
      _showContainers = true;
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

  Future<void> _moveItem() async {
    final colors = context.appColors;
    if (_selectedRoom == null) return;

    setState(() {
      _isLoading = true;
    });

    final inventoryProvider = Provider.of<InventoryProvider>(
      context,
      listen: false,
    );

    try {
      await inventoryProvider.moveItem(
        currentRoomId: widget.currentRoomId,
        itemId: widget.item.id,
        targetRoomId: _selectedRoom!.id,
        targetContainerId: _selectedContainer?.id,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to move item: $e'),
            backgroundColor: colors.error,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = false;
    });

    // Show success message
    final destination = _selectedContainer != null
        ? 'container "${_selectedContainer!.name}" in ${_selectedRoom!.name}'
        : 'room "${_selectedRoom!.name}"';

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.item.name} moved to $destination'),
          backgroundColor: colors.primary,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      // Go back to previous screen
      Navigator.pop(context, true); // Return true to indicate item was moved
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
          onPressed: () {
            if (_showContainers) {
              _backToRoomSelection();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          'Move Item',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _showContainers
          ? _buildContainerSelectionView()
          : _buildRoomSelectionView(),
    );
  }

  Widget _buildRoomSelectionView() {
    final colors = context.appColors;
    return Column(
      children: [
        MovingItemInfoCard(item: widget.item),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Select destination room:',
            style: TextStyle(color: colors.textSecondary, fontSize: 14),
          ),
        ),
        const SizedBox(height: 12),
        UniversalSearchBar(
          controller: _searchController,
          hintText: 'Search rooms...',
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
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
                return EmptyState(
                  icon: Icons.search_off,
                  message: 'No rooms found',
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: filteredRooms.length,
                itemBuilder: (context, index) {
                  final room = filteredRooms[index];
                  final containerCount = inventoryProvider
                      .getContainers(room.id)
                      .length;

                  return RoomListItem(
                    room: room,
                    isSelected: _selectedRoom?.id == room.id,
                    isCurrentRoom: room.id == widget.currentRoomId,
                    containerCount: containerCount,
                    onTap: () => _onRoomSelected(room),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContainerSelectionView() {
    final colors = context.appColors;
    return Consumer<InventoryProvider>(
      builder: (context, inventoryProvider, _) {
        final containers = inventoryProvider.getContainers(_selectedRoom!.id);
        final isSameRoom = _selectedRoom!.id == widget.currentRoomId;

        return Column(
          children: [
            DestinationInfoCard(
              room: _selectedRoom!,
              label: 'Destination room:',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Select destination:',
                style: TextStyle(color: colors.textSecondary, fontSize: 14),
              ),
            ),
            const SizedBox(height: 12),
            DirectRoomOption(
              isSelected: _selectedContainer == null,
              subtitle: isSameRoom && widget.item.containerId == null
                  ? 'Current location'
                  : 'Not in a container',
              onTap: () => _onContainerSelected(null),
            ),

            if (containers.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Divider(),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  'OR SELECT A CONTAINER',
                  style: TextStyle(
                    color: colors.textSecondary,
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
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          'No containers in this room.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.textSecondary,
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
                        final itemCount = inventoryProvider
                            .getContainerItemCount(
                              _selectedRoom!.id,
                              container.id,
                            );

                        return ContainerListItem(
                          container: container,
                          isSelected: _selectedContainer?.id == container.id,
                          isCurrentLocation:
                              isSameRoom &&
                              widget.item.containerId == container.id,
                          itemCount: itemCount,
                          onTap: () => _onContainerSelected(container),
                        );
                      },
                    ),
            ),

            // Move button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _moveItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Move Item',
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

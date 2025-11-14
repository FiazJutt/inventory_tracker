import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:inventory_tracker/viewmodels/inventory_provider.dart';
import 'package:inventory_tracker/models/room_model.dart';
import 'package:inventory_tracker/models/container_model.dart';
import 'package:inventory_tracker/core/theme/app_colors.dart';

import '../containerItem/container_item_form_page.dart';
import 'widgets/room_list_item.dart';
import 'widgets/container_list_item.dart';
import 'widgets/direct_room_option.dart';
import 'package:inventory_tracker/views/locationScreens/widgets/location_search_bar.dart';
import 'package:inventory_tracker/views/shared/empty_state.dart';

class RoomSelectionScreen extends StatefulWidget {
  final bool isAddItemScreen;

  const RoomSelectionScreen({
    super.key,
    this.isAddItemScreen = false,
  });

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
          widget.isAddItemScreen ? 'Add Item' : 'Add Container',
          style: TextStyle(
            color: colors.textPrimary,
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
    final colors = context.appColors;
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
                      ? colors.textSecondary 
                      : colors.primary,
                  fontSize: 14,
                  fontWeight: _selectedRoom == null 
                      ? FontWeight.normal 
                      : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        
        LocationSearchBar(
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
                  icon: _searchQuery.isEmpty
                      ? Icons.meeting_room_outlined
                      : Icons.search_off,
                  message: _searchQuery.isEmpty
                      ? 'No rooms available'
                      : 'No rooms found for "$_searchQuery"',
                  subtitle: _searchQuery.isEmpty
                      ? 'Add a room first from the home screen'
                      : null,
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: filteredRooms.length,
                itemBuilder: (context, index) {
                  final room = filteredRooms[index];
                  final containerCount = inventoryProvider.getContainers(room.id).length;

                  return RoomListItem(
                    room: room,
                    isSelected: _selectedRoom?.id == room.id,
                    containerCount: widget.isAddItemScreen ? containerCount : null,
                    onTap: () => _onRoomSelected(room),
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
                  backgroundColor: colors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ),
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
                    style: TextStyle(
                      color: colors.textSecondary,
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
                          ? colors.textPrimary 
                          : colors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            DirectRoomOption(
              isSelected: _selectedContainer == null,
              subtitle: 'Not in a container',
              onTap: () => _onContainerSelected(null),
            ),

            if (containers.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Divider(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          'No containers in this room.\nYou can add the item directly to the room.',
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
                        final itemCount = inventoryProvider.getContainerItemCount(
                          _selectedRoom!.id,
                          container.id,
                        );

                        return ContainerListItem(
                          container: container,
                          isSelected: _selectedContainer?.id == container.id,
                          itemCount: itemCount,
                          onTap: () => _onContainerSelected(container),
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
                    backgroundColor: colors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
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
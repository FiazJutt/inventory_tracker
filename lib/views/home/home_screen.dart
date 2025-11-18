import 'package:flutter/material.dart';
import 'package:inventory_tracker/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:inventory_tracker/viewmodels/inventory_provider.dart';
import 'package:inventory_tracker/models/room_model.dart';
import 'package:inventory_tracker/models/container_model.dart';
import 'package:inventory_tracker/models/item_model.dart';
import '../room_detail_screen/room_detail_screen.dart';
import '../containerItem_detail/container_item_detail_screen.dart';
import '../location_detail_list/location_detail_list_screen.dart';
import 'widgets/filter_segment_control.dart';
import 'widgets/home_search_bar.dart';
import 'widgets/room_list_item.dart';
import 'widgets/container_list_item.dart';
import 'widgets/item_list_item.dart';
import 'widgets/location_list_item.dart';
import 'widgets/empty_state_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeViewType _selectedView = HomeViewType.rooms;
  String _searchQuery = '';

  String get _searchHint {
    switch (_selectedView) {
      case HomeViewType.rooms:
        return 'Search rooms...';
      case HomeViewType.containers:
        return 'Search containers...';
      case HomeViewType.items:
        return 'Search items...';
      case HomeViewType.locations:
        return 'Search locations...';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      extendBody: true,
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        // leading: IconButton(
        //   icon: Icon(Icons.settings_outlined, color: colors.textPrimary),
        //   onPressed: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => const SettingsScreen(),
        //       ),
        //     );
        //   },
        // ),
        title: Text(
          'Home',
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code_scanner, color: colors.textPrimary),
            onPressed: () => ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Scan QR tapped'))),
          ),
          IconButton(
            icon: Icon(Icons.tune, color: colors.textPrimary),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Color tuning tapped')),
            ),
          ),
          IconButton(
            icon: Icon(Icons.sort, color: colors.textPrimary),
            onPressed: () => ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Sort tapped'))),
          ),
        ],
      ),
      body: Consumer<InventoryProvider>(
        builder: (context, inventoryProvider, _) {
          if (inventoryProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (inventoryProvider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Unable to load inventory',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      inventoryProvider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: inventoryProvider.refreshFromDatabase,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              // Filter segment control
              FilterSegmentControl(
                selectedView: _selectedView,
                onViewChanged: (viewType) {
                  setState(() {
                    _selectedView = viewType;
                    _searchQuery = ''; // Clear search when switching views
                  });
                },
              ),
              // Search bar
              HomeSearchBar(
                hintText: _searchHint,
                searchQuery: _searchQuery,
                onSearchChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                  });
                },
              ),
              // Content list
              Expanded(child: _buildContentList(inventoryProvider, context)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContentList(
    InventoryProvider inventoryProvider,
    BuildContext context,
  ) {
    switch (_selectedView) {
      case HomeViewType.rooms:
        return _buildRoomsList(inventoryProvider, context);
      case HomeViewType.containers:
        return _buildContainersList(inventoryProvider, context);
      case HomeViewType.items:
        return _buildItemsList(inventoryProvider, context);
      case HomeViewType.locations:
        return _buildLocationsList(inventoryProvider, context);
    }
  }

  Widget _buildRoomsList(
    InventoryProvider inventoryProvider,
    BuildContext context,
  ) {
    List<Room> rooms = inventoryProvider.rooms;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      rooms = rooms.where((room) {
        return room.name.toLowerCase().contains(query) ||
            room.location.toLowerCase().contains(query);
      }).toList();
    }

    if (rooms.isEmpty) {
      return EmptyStateWidget(
        viewType: _selectedView,
        isSearching: _searchQuery.isNotEmpty,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8).add(
        const EdgeInsets.only(bottom: 100), // Add padding for bottom navbar
      ),
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        final room = rooms[index];
        return RoomListItem(
          room: room,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => RoomDetailScreen(room: room),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildContainersList(
    InventoryProvider inventoryProvider,
    BuildContext context,
  ) {
    List<ContainerModel> containers = inventoryProvider.allContainers;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      containers = inventoryProvider.searchContainers(_searchQuery);
    }

    if (containers.isEmpty) {
      return EmptyStateWidget(
        viewType: _selectedView,
        isSearching: _searchQuery.isNotEmpty,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8).add(
        const EdgeInsets.only(bottom: 100), // Add padding for bottom navbar
      ),
      itemCount: containers.length,
      itemBuilder: (context, index) {
        final container = containers[index];
        final room = inventoryProvider.getRoomById(container.roomId);

        return ContainerListItem(
          container: container,
          room: room,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    ContainerItemDetailScreen(item: container, isItem: false),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildItemsList(
    InventoryProvider inventoryProvider,
    BuildContext context,
  ) {
    List<Item> items = inventoryProvider.allItems;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      items = inventoryProvider.searchItems(_searchQuery);
    }

    if (items.isEmpty) {
      return EmptyStateWidget(
        viewType: _selectedView,
        isSearching: _searchQuery.isNotEmpty,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8).add(
        const EdgeInsets.only(bottom: 100), // Add padding for bottom navbar
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final room = inventoryProvider.getRoomById(item.roomId);
        ContainerModel? container;
        if (item.containerId != null) {
          container = inventoryProvider.getContainerById(
            item.roomId,
            item.containerId!,
          );
        }

        return ItemListItem(
          item: item,
          room: room,
          container: container,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    ContainerItemDetailScreen(item: item, isItem: true),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLocationsList(
    InventoryProvider inventoryProvider,
    BuildContext context,
  ) {
    List<String> locations = inventoryProvider.allLocations;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      locations = locations
          .where((location) => location.toLowerCase().contains(query))
          .toList();
    }

    if (locations.isEmpty) {
      return EmptyStateWidget(
        viewType: _selectedView,
        isSearching: _searchQuery.isNotEmpty,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8).add(
        const EdgeInsets.only(bottom: 100), // Add padding for bottom navbar
      ),
      itemCount: locations.length,
      itemBuilder: (context, index) {
        final location = locations[index];
        return LocationListItem(
          location: location,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    LocationDetailListScreen(location: location),
              ),
            );
          },
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:inventory_tracker/viewmodels/inventory_provider.dart';
import 'package:inventory_tracker/core/theme/app_colors.dart';
import 'package:inventory_tracker/views/room_detail_screen/room_detail_screen.dart';
import 'widgets/location_section_header.dart';
import 'widgets/location_room_card.dart';
import 'package:inventory_tracker/core/widgets/empty_state.dart';

class LocationDetailListScreen extends StatefulWidget {
  final String? location;

  const LocationDetailListScreen({super.key, this.location});

  @override
  State<LocationDetailListScreen> createState() => _LocationDetailListScreenState();
}

class _LocationDetailListScreenState extends State<LocationDetailListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: widget.location != null
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: colors.textPrimary),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          widget.location ?? 'Locations',
          style: TextStyle(color: colors.textPrimary),
        ),
      ),
      body: Consumer<InventoryProvider>(
        builder: (context, inventoryProvider, _) {
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
                    hintText: 'Search locations or rooms...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: colors.textSecondary,
                    ),
                    filled: true,
                    fillColor: colors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
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
              Expanded(
                child: _buildGroupedLocationList(inventoryProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGroupedLocationList(InventoryProvider inventoryProvider) {
    if (inventoryProvider.rooms.isEmpty) {
      return EmptyState(
        icon: Icons.location_on_outlined,
        message: 'No locations found. Add a location to get started.',
      );
    }

    // Group rooms by location
    final Map<String, List<dynamic>> groupedRooms = {};
    for (var room in inventoryProvider.rooms) {
      if (!groupedRooms.containsKey(room.location)) {
        groupedRooms[room.location] = [];
      }
      groupedRooms[room.location]!.add(room);
    }

    // Filter by location if provided
    Map<String, List<dynamic>> filteredGroupedRooms = groupedRooms;
    if (widget.location != null) {
      filteredGroupedRooms = {
        widget.location!: groupedRooms[widget.location!] ?? [],
      };
    }

    // Filter based on search query
    final filteredLocations = filteredGroupedRooms.entries.where((entry) {
      if (_searchQuery.isEmpty) return true;
      
      final locationMatches = entry.key.toLowerCase().contains(_searchQuery);
      final roomMatches = entry.value.any(
        (room) => room.name.toLowerCase().contains(_searchQuery),
      );
      
      return locationMatches || roomMatches;
    }).toList();

    if (filteredLocations.isEmpty) {
      return EmptyState(
        icon: Icons.search_off,
        message: 'No matching locations or rooms found.',
      );
    }

    // Sort locations alphabetically
    filteredLocations.sort((a, b) => a.key.compareTo(b.key));

    return ListView.builder(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: 100, // Extra padding for bottom nav
      ),
      itemCount: filteredLocations.length,
      itemBuilder: (context, index) {
        final location = filteredLocations[index].key;
        // Apply search filter to rooms within each location
        final allRooms = filteredLocations[index].value;
        final filteredRooms = _searchQuery.isEmpty 
            ? allRooms 
            : allRooms.where((room) => 
                room.name.toLowerCase().contains(_searchQuery) ||
                location.toLowerCase().contains(_searchQuery)
              ).toList();
        
        return _buildLocationSection(location, filteredRooms);
      },
    );
  }

  Widget _buildLocationSection(String location, List<dynamic> rooms) {
    // Don't show sections with no matching rooms
    if (rooms.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LocationSectionHeader(
          location: location,
          roomCount: rooms.length,
        ),
        ...rooms.map((room) => LocationRoomCard(
              room: room,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => RoomDetailScreen(room: room),
                  ),
                );
              },
            )),
        const SizedBox(height: 8),
      ],
    );
  }
}
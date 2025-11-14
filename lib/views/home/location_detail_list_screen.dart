import 'package:flutter/material.dart';
import 'package:inventory_tracker/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:inventory_tracker/viewmodels/inventory_provider.dart';
import 'package:inventory_tracker/views/room_detail_screen/room_detail_screen.dart';

class LocationDetailListScreen extends StatefulWidget {
  const LocationDetailListScreen({super.key});

  @override
  State<LocationDetailListScreen> createState() => _LocationDetailListScreenState();
}

class _LocationDetailListScreenState extends State<LocationDetailListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Locations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sort tapped'),
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.only(bottom: 80, left: 16, right: 16),
                ),
              );
            },
          ),
        ],
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
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'No locations found. Add a location to get started.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ),
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

    // Filter based on search query
    final filteredLocations = groupedRooms.entries.where((entry) {
      if (_searchQuery.isEmpty) return true;
      
      final locationMatches = entry.key.toLowerCase().contains(_searchQuery);
      final roomMatches = entry.value.any(
        (room) => room.name.toLowerCase().contains(_searchQuery),
      );
      
      return locationMatches || roomMatches;
    }).toList();

    if (filteredLocations.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'No matching locations or rooms found.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ),
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
        final rooms = filteredLocations[index].value;

        return _buildLocationSection(location, rooms);
      },
    );
  }

  Widget _buildLocationSection(String location, List<dynamic> rooms) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Location Header
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8, left: 4),
          child: Row(
            children: [
              Icon(
                Icons.location_on,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                location.toUpperCase(),
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${rooms.length}',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Rooms List
        ...rooms.map((room) => _buildRoomCard(room)).toList(),
        
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildRoomCard(dynamic room) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.meeting_room,
            color: AppColors.primary,
            size: 22,
          ),
        ),
        title: Text(
          room.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            room.location,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => RoomDetailScreen(room: room),
            ),
          );
        },
      ),
    );
  }
}
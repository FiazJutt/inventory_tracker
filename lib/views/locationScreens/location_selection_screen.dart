import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:inventory_tracker/viewmodels/inventory_provider.dart';
import 'package:inventory_tracker/core/theme/app_colors.dart';
import 'widgets/location_search_bar.dart';
import 'widgets/location_list_item.dart';
import 'package:inventory_tracker/views/shared/empty_state.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  State<LocationSelectionScreen> createState() => _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedLocation;

  @override
  void dispose() {
    _searchController.dispose();
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Select Location',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedLocation == null
                      ? 'Select a location for your rooms'
                      : 'Selected: $_selectedLocation',
                  style: TextStyle(
                    color: _selectedLocation == null
                        ? colors.textSecondary
                        : colors.primary,
                    fontSize: 14,
                    fontWeight: _selectedLocation == null
                        ? FontWeight.normal
                        : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

        LocationSearchBar(
          controller: _searchController,
          hintText: 'Search locations...',
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
        ),

          const SizedBox(height: 16),

          // Location list
          Expanded(
            child: Consumer<InventoryProvider>(
              builder: (context, inventoryProvider, _) {
                // Get all unique locations
                final allLocations = inventoryProvider.locations
                    .where((location) => location.toLowerCase().contains(_searchQuery))
                    .toList();

                if (allLocations.isEmpty) {
                  return EmptyState(
                    icon: _searchQuery.isEmpty
                        ? Icons.location_on_outlined
                        : Icons.search_off,
                    message: _searchQuery.isEmpty
                        ? 'No locations available'
                        : 'No locations found for "$_searchQuery"',
                    subtitle: _searchQuery.isEmpty
                        ? 'Add a location first from the home screen'
                        : null,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: allLocations.length,
                  itemBuilder: (context, index) {
                    final location = allLocations[index];
                    return LocationListItem(
                      location: location,
                      isSelected: _selectedLocation == location,
                      onTap: () {
                        setState(() {
                          _selectedLocation = location;
                        });

                        Future.delayed(const Duration(milliseconds: 300), () {
                          if (mounted) {
                            Navigator.pop(context, location);
                          }
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),

          // Bottom action button
          if (_selectedLocation != null)
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, _selectedLocation);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    'Confirm Selection',
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
      ),
    );
  }
}
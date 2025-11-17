import 'package:flutter/material.dart';
import 'package:inventory_tracker/viewmodels/base_inventory_provider.dart';
import 'package:inventory_tracker/models/location_model.dart';

/// Extension for location-related functionality
mixin LocationProvider on BaseInventoryProvider {
  /// Add a new location
  Future<void> addLocation(String location) async {
    final trimmed = location.trim();
    if (trimmed.isEmpty || locations.contains(trimmed)) return;

    locationsList.add(trimmed);
    notifyListeners();

    final model = LocationModel(id: generateId('loc'), name: trimmed);

    try {
      await repository.upsertLocation(model);
    } catch (e, stackTrace) {
      debugPrint('Failed to save location: $e\n$stackTrace');
      locationsList.remove(trimmed);
      notifyListeners();
      rethrow;
    }
  }

  /// Remove a location (and all its rooms)
  Future<void> removeLocation(String location) async {
    final roomsToRemove = roomsList
        .where((room) => room.location == location)
        .toList();

    locationsList.remove(location);
    for (final room in roomsToRemove) {
      roomsList.removeWhere((r) => r.id == room.id);
      containersMap.remove(room.id);
      itemsMap.remove(room.id);
    }
    notifyListeners();

    try {
      await repository.deleteLocationByName(location);
    } catch (e, stackTrace) {
      debugPrint('Failed to delete location: $e\n$stackTrace');
      // We'll need to implement refreshFromDatabase in the base class
      // For now, we'll just rethrow the error
      rethrow;
    }
  }

  /// Check if location exists
  bool hasLocation(String location) {
    return locations.contains(location);
  }
}
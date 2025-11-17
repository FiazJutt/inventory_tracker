import 'package:flutter/material.dart';
import 'package:inventory_tracker/viewmodels/base_inventory_provider.dart';
import 'package:inventory_tracker/models/room_model.dart';
import 'package:inventory_tracker/models/container_model.dart';
import 'package:inventory_tracker/models/item_model.dart';

/// Extension for utility-related functionality
mixin UtilityProvider on BaseInventoryProvider {
  /// Clear all data (useful for testing or reset)
  void clearAll() {
    locationsList.clear();
    roomsList.clear();
    containersMap.clear();
    itemsMap.clear();
    notifyListeners();
  }

  /// Export data to JSON (useful for backup)
  Map<String, dynamic> toJson() {
    return {
      'locations': locationsList,
      'rooms': roomsList.map((r) => r.toJson()).toList(),
      'containers': containersMap.map(
        (key, value) => MapEntry(key, value.map((c) => c.toJson()).toList()),
      ),
      'items': itemsMap.map(
        (key, value) => MapEntry(key, value.map((i) => i.toJson()).toList()),
      ),
    };
  }

  /// Import data from JSON (useful for restore)
  void fromJson(Map<String, dynamic> json) {
    try {
      // Clear existing data
      locationsList.clear();
      roomsList.clear();
      containersMap.clear();
      itemsMap.clear();

      // Import locations
      if (json['locations'] != null) {
        locationsList.addAll(List<String>.from(json['locations']));
      }

      // Import rooms
      if (json['rooms'] != null) {
        for (var roomJson in json['rooms']) {
          roomsList.add(Room.fromJson(roomJson));
        }
      }

      // Import containers
      if (json['containers'] != null) {
        final containersMapJson = json['containers'] as Map<String, dynamic>;
        for (var entry in containersMapJson.entries) {
          containersMap[entry.key] = (entry.value as List)
              .map((c) => ContainerModel.fromJson(c))
              .toList();
        }
      }

      // Import items
      if (json['items'] != null) {
        final itemsMapJson = json['items'] as Map<String, dynamic>;
        for (var entry in itemsMapJson.entries) {
          itemsMap[entry.key] = (entry.value as List)
              .map((i) => Item.fromJson(i))
              .toList();
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error importing data: $e');
    }
  }
}
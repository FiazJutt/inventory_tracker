import 'package:flutter/material.dart';
import 'package:inventory_tracker/data/repositories/inventory_repository.dart';
import 'package:inventory_tracker/models/container_model.dart';
import 'package:inventory_tracker/models/item_model.dart';
import 'package:inventory_tracker/models/location_model.dart';
import 'package:inventory_tracker/models/room_model.dart';
import 'dart:async';

class BaseInventoryProvider with ChangeNotifier {
  BaseInventoryProvider({InventoryRepository? inventoryRepository})
    : _inventoryRepository = inventoryRepository ?? InventoryRepository();

  final InventoryRepository _inventoryRepository;
  final List<String> _locations = [];
  final List<Room> _rooms = [];
  final Map<String, List<ContainerModel>> _containers =
      {}; // roomId -> list of ContainerModel objects
  final Map<String, List<Item>> _items = {}; // roomId -> list of Item objects
  bool _isLoading = false; // Start with false to avoid initial loading state
  String? _errorMessage;
  int _idCounter = 0;
  bool _isInitialized = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  set errorMessage(String? value) => _errorMessage = value;

  // Public getters for private fields (accessible by extensions)
  List<String> get locationsList => _locations;
  List<Room> get roomsList => _rooms;
  Map<String, List<ContainerModel>> get containersMap => _containers;
  Map<String, List<Item>> get itemsMap => _items;
  InventoryRepository get repository => _inventoryRepository;
  bool get isInitialized => _isInitialized;
  set isInitialized(bool value) => _isInitialized = value;
  bool get isLoadingState => _isLoading;
  set isLoadingState(bool value) => _isLoading = value;

  // ==================== GETTERS ====================

  /// Get all locations
  List<String> get locations => List.unmodifiable(_locations);

  /// Get all rooms
  List<Room> get rooms => List.unmodifiable(_rooms);

  /// Get containers for a specific room
  List<ContainerModel> getContainers(String roomId) {
    return List.unmodifiable(_containers[roomId] ?? []);
  }

  /// Get items for a specific room
  List<Item> getItems(String roomId) {
    return List.unmodifiable(_items[roomId] ?? []);
  }

  /// Get all unique locations from rooms
  List<String> get allLocations {
    final locations = _rooms.map((room) => room.location).toSet().toList();
    locations.sort();
    return locations;
  }

  /// Get total number of containers across all rooms
  int get totalContainers {
    return _containers.values.fold(
      0,
      (sum, containers) => sum + containers.length,
    );
  }

  /// Get total number of items across all rooms
  int get totalItems {
    return _items.values.fold(0, (sum, items) => sum + items.length);
  }

  /// Get item by ID
  Item? getItemById(String roomId, String itemId) {
    try {
      return _items[roomId]?.firstWhere((i) => i.id == itemId);
    } catch (e) {
      return null;
    }
  }

  /// Get room by ID
  Room? getRoomById(String roomId) {
    try {
      return _rooms.firstWhere((room) => room.id == roomId);
    } catch (e) {
      return null;
    }
  }

  /// Get container by ID
  ContainerModel? getContainerById(String roomId, String containerId) {
    try {
      return _containers[roomId]?.firstWhere((c) => c.id == containerId);
    } catch (e) {
      return null;
    }
  }

  /// Get all containers across all rooms
  List<ContainerModel> get allContainers {
    final List<ContainerModel> all = [];
    for (var containerList in _containers.values) {
      all.addAll(containerList);
    }
    return all;
  }

  /// Get all items across all rooms
  List<Item> get allItems {
    final List<Item> all = [];
    for (var itemList in _items.values) {
      all.addAll(itemList);
    }
    return all;
  }

  /// Get items directly in a room (not in containers)
  List<Item> getRoomItems(String roomId) {
    return (_items[roomId] ?? [])
        .where((item) => item.containerId == null)
        .toList();
  }

  /// Get items in a specific container
  List<Item> getContainerItems(String roomId, String containerId) {
    return (_items[roomId] ?? [])
        .where((item) => item.containerId == containerId)
        .toList();
  }

  /// Get total item count in a container
  int getContainerItemCount(String roomId, String containerId) {
    return getContainerItems(roomId, containerId).length;
  }

  String _generateId(String prefix) {
    _idCounter++;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${prefix}_${timestamp}_$_idCounter';
  }

  // Make _generateId accessible to extensions
  String generateId(String prefix) => _generateId(prefix);

  // This method will be overridden in the main InventoryProvider
  Future<void> refreshFromDatabase() async {
    // Default implementation - will be overridden
  }
}
import 'package:flutter/material.dart';
import 'package:inventory_tracker/data/repositories/inventory_repository.dart';
import 'package:inventory_tracker/models/container_model.dart';
import 'package:inventory_tracker/models/item_model.dart';
import 'package:inventory_tracker/models/location_model.dart';
import 'package:inventory_tracker/models/room_model.dart';
import 'dart:async';

class InventoryProvider with ChangeNotifier {
  InventoryProvider({InventoryRepository? inventoryRepository})
    : _inventoryRepository = inventoryRepository ?? InventoryRepository() {
    // Don't call _loadInitialData here to avoid setState during build
    // Data loading will be handled by the UI when needed
  }

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

  Future<void> refreshFromDatabase() async {
    if (!_isInitialized) {
      _isLoading = true;
      notifyListeners();
    }
    
    await _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // Don't call notifyListeners here if we're initializing for the first time
    // Only set loading state if we're already initialized
    if (_isInitialized) {
      _isLoading = true;
      // Use scheduleMicrotask to avoid calling notifyListeners during build
      scheduleMicrotask(() {
        if (hasListeners) {
          notifyListeners();
        }
      });
    }

    try {
      final locations = await _inventoryRepository.fetchLocations();
      final rooms = await _inventoryRepository.fetchRooms();
      final containers = await _inventoryRepository.fetchContainers();
      final items = await _inventoryRepository.fetchItems();

      final locationNames = locations.map((loc) => loc.name).toSet();
      _locations
        ..clear()
        ..addAll(locationNames);
      _locations.sort();

      _rooms
        ..clear()
        ..addAll(rooms);

      _containers.clear();
      _items.clear();

      for (final room in _rooms) {
        _containers.putIfAbsent(room.id, () => []);
        _items.putIfAbsent(room.id, () => []);
        locationNames.add(room.location);
      }

      for (final container in containers) {
        _containers.putIfAbsent(container.roomId, () => []);
        _containers[container.roomId]!.add(container);
      }

      for (final item in items) {
        _items.putIfAbsent(item.roomId, () => []);
        _items[item.roomId]!.add(item);
      }

      _errorMessage = null;
      _isInitialized = true;
    } catch (e, stackTrace) {
      debugPrint('Error loading inventory data: $e\n$stackTrace');
      _errorMessage = 'Failed to load inventory data';
    } finally {
      _isLoading = false;
      // Use scheduleMicrotask to avoid calling notifyListeners during build
      scheduleMicrotask(() {
        if (hasListeners) {
          notifyListeners();
        }
      });
    }
  }

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

  // ==================== LOCATION METHODS ====================

  /// Add a new location
  Future<void> addLocation(String location) async {
    final trimmed = location.trim();
    if (trimmed.isEmpty || _locations.contains(trimmed)) return;

    _locations.add(trimmed);
    notifyListeners();

    final model = LocationModel(id: _generateId('loc'), name: trimmed);

    try {
      await _inventoryRepository.upsertLocation(model);
    } catch (e, stackTrace) {
      debugPrint('Failed to save location: $e\n$stackTrace');
      _locations.remove(trimmed);
      notifyListeners();
      rethrow;
    }
  }

  /// Remove a location (and all its rooms)
  Future<void> removeLocation(String location) async {
    final roomsToRemove = _rooms
        .where((room) => room.location == location)
        .toList();

    _locations.remove(location);
    for (final room in roomsToRemove) {
      _rooms.removeWhere((r) => r.id == room.id);
      _containers.remove(room.id);
      _items.remove(room.id);
    }
    notifyListeners();

    try {
      await _inventoryRepository.deleteLocationByName(location);
    } catch (e, stackTrace) {
      debugPrint('Failed to delete location: $e\n$stackTrace');
      await _loadInitialData();
      rethrow;
    }
  }

  /// Check if location exists
  bool hasLocation(String location) {
    return _locations.contains(location);
  }

  // ==================== ROOM METHODS ====================

  /// Add a new room
  Future<void> addRoom(Room room) async {
    final isNewLocation = !_locations.contains(room.location);

    _rooms.add(room);
    _containers[room.id] = [];
    _items[room.id] = [];

    if (isNewLocation) {
      _locations.add(room.location);
    }

    notifyListeners();

    try {
      if (isNewLocation) {
        final locationModel = LocationModel(
          id: _generateId('loc'),
          name: room.location,
        );
        await _inventoryRepository.upsertLocation(locationModel);
      }
      await _inventoryRepository.upsertRoom(room);
    } catch (e, stackTrace) {
      debugPrint('Failed to add room: $e\n$stackTrace');
      _rooms.removeWhere((r) => r.id == room.id);
      _containers.remove(room.id);
      _items.remove(room.id);
      if (isNewLocation) {
        _locations.remove(room.location);
      }
      notifyListeners();
      rethrow;
    }
  }

  /// Add multiple rooms at once (useful for onboarding)
  Future<void> addRooms(List<Room> rooms) async {
    for (var room in rooms) {
      await addRoom(room);
    }
  }

  /// Update a room
  Future<void> updateRoom(Room updatedRoom) async {
    final index = _rooms.indexWhere((room) => room.id == updatedRoom.id);
    if (index == -1) return;

    final previousRoom = _rooms[index];
    final oldLocation = previousRoom.location;
    final locationChanged = oldLocation != updatedRoom.location;
    var addedLocation = false;

    _rooms[index] = updatedRoom;

    if (locationChanged) {
      if (!_locations.contains(updatedRoom.location)) {
        _locations.add(updatedRoom.location);
        addedLocation = true;
      }

      if (!_rooms.any(
        (room) => room.id != updatedRoom.id && room.location == oldLocation,
      )) {
        _locations.remove(oldLocation);
      }
    }

    notifyListeners();

    try {
      if (locationChanged && addedLocation) {
        final locationModel = LocationModel(
          id: _generateId('loc'),
          name: updatedRoom.location,
        );
        await _inventoryRepository.upsertLocation(locationModel);
      }

      await _inventoryRepository.upsertRoom(updatedRoom);

      if (locationChanged) {
        final isOldLocationUsed = _rooms.any(
          (room) => room.location == oldLocation,
        );
        if (!isOldLocationUsed) {
          await _inventoryRepository.deleteLocationByName(oldLocation);
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Failed to update room: $e\n$stackTrace');
      _rooms[index] = previousRoom;

      if (locationChanged) {
        if (addedLocation) {
          _locations.remove(updatedRoom.location);
        }
        if (!_locations.contains(oldLocation)) {
          _locations.add(oldLocation);
        }
      }

      notifyListeners();
      rethrow;
    }
  }

  /// Remove a room and all its containers/items
  Future<void> removeRoom(String roomId) async {
    final roomIndex = _rooms.indexWhere((room) => room.id == roomId);
    if (roomIndex == -1) return;

    final room = _rooms[roomIndex];
    final location = room.location;

    _rooms.removeAt(roomIndex);
    _containers.remove(roomId);
    _items.remove(roomId);

    var removedLocation = false;
    if (!_rooms.any((r) => r.location == location)) {
      _locations.remove(location);
      removedLocation = true;
    }

    notifyListeners();

    try {
      await _inventoryRepository.deleteRoom(roomId);
      if (removedLocation) {
        await _inventoryRepository.deleteLocationByName(location);
      }
    } catch (e, stackTrace) {
      debugPrint('Failed to delete room: $e\n$stackTrace');
      await _loadInitialData();
      rethrow;
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

  /// Get rooms by location
  List<Room> getRoomsByLocation(String location) {
    return _rooms.where((room) => room.location == location).toList();
  }

  // ==================== CONTAINER METHODS ====================

  /// Add a container to a room
  Future<ContainerModel?> addContainer(
    String roomId,
    String containerName, {
    String? serialNumber,
    String? notes,
    String? description,
    double? purchasePrice,
    DateTime? purchaseDate,
    double? currentValue,
    String? currentCondition,
    DateTime? expirationDate,
    double? weight,
    String? retailer,
    String? brand,
    String? model,
    String? searchMetadata,
  }) async {
    if (containerName.trim().isEmpty) return null;

    _containers.putIfAbsent(roomId, () => []);

    final container = ContainerModel(
      id: _generateId('con'),
      name: containerName,
      roomId: roomId,
      serialNumber: serialNumber,
      notes: notes,
      description: description,
      purchasePrice: purchasePrice,
      purchaseDate: purchaseDate,
      currentValue: currentValue,
      currentCondition: currentCondition,
      expirationDate: expirationDate,
      weight: weight,
      retailer: retailer,
      brand: brand,
      model: model,
      searchMetadata: searchMetadata,
    );

    _containers[roomId]!.add(container);
    notifyListeners();

    try {
      await _inventoryRepository.upsertContainer(container);
      return container;
    } catch (e, stackTrace) {
      debugPrint('Failed to add container: $e\n$stackTrace');
      _containers[roomId]!.removeWhere((c) => c.id == container.id);
      notifyListeners();
      rethrow;
    }
  }

  /// Update a container
  Future<void> updateContainer(
    String roomId,
    ContainerModel updatedContainer,
  ) async {
    final containers = _containers[roomId];
    if (containers == null) return;

    final index = containers.indexWhere((c) => c.id == updatedContainer.id);
    if (index == -1) return;

    final previous = containers[index];
    containers[index] = updatedContainer;
    notifyListeners();

    try {
      await _inventoryRepository.updateContainer(updatedContainer);
    } catch (e, stackTrace) {
      debugPrint('Failed to update container: $e\n$stackTrace');
      containers[index] = previous;
      notifyListeners();
      rethrow;
    }
  }

  /// Remove a container by ID
  Future<void> removeContainerById(String roomId, String containerId) async {
    final containers = _containers[roomId];
    if (containers == null) return;

    final containerIndex = containers.indexWhere((c) => c.id == containerId);
    if (containerIndex == -1) return;

    final removedContainer = containers.removeAt(containerIndex);
    notifyListeners();

    try {
      await _inventoryRepository.deleteContainer(containerId);

      final items = _items[roomId];
      if (items != null) {
        for (var i = 0; i < items.length; i++) {
          final item = items[i];
          if (item.containerId == containerId) {
            items[i] = item.copyWith(containerId: null);
          }
        }
        notifyListeners();
      }
    } catch (e, stackTrace) {
      debugPrint('Failed to delete container: $e\n$stackTrace');
      containers.insert(containerIndex, removedContainer);
      notifyListeners();
      rethrow;
    }
  }

  /// Remove a container by name (legacy support)
  Future<void> removeContainer(String roomId, String containerName) async {
    final containers = _containers[roomId];
    if (containers == null) return;

    final idsToRemove = containers
        .where((c) => c.name == containerName)
        .map((c) => c.id)
        .toList();

    for (final id in idsToRemove) {
      await removeContainerById(roomId, id);
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

  // ==================== ITEM METHODS ====================

  /// Add an item to a room
  Future<Item?> addItem(
    String roomId,
    String itemName, {
    String? containerId,
    int? quantity,
    String? serialNumber,
    String? notes,
    String? description,
    double? purchasePrice,
    DateTime? purchaseDate,
    double? currentValue,
    String? currentCondition,
    DateTime? expirationDate,
    double? weight,
    String? retailer,
    String? brand,
    String? model,
    String? searchMetadata,
  }) async {
    if (itemName.trim().isEmpty) return null;

    _items.putIfAbsent(roomId, () => []);

    final item = Item(
      id: _generateId('item'),
      name: itemName,
      roomId: roomId,
      containerId: containerId,
      quantity: quantity ?? 1,
      serialNumber: serialNumber,
      notes: notes,
      description: description,
      purchasePrice: purchasePrice,
      purchaseDate: purchaseDate,
      currentValue: currentValue,
      currentCondition: currentCondition,
      expirationDate: expirationDate,
      weight: weight,
      retailer: retailer,
      brand: brand,
      model: model,
      searchMetadata: searchMetadata,
    );

    _items[roomId]!.add(item);
    notifyListeners();

    try {
      await _inventoryRepository.upsertItem(item);
      return item;
    } catch (e, stackTrace) {
      debugPrint('Failed to add item: $e\n$stackTrace');
      _items[roomId]!.removeWhere((i) => i.id == item.id);
      notifyListeners();
      rethrow;
    }
  }

  /// Update an item
  Future<void> updateItem(String roomId, Item updatedItem) async {
    final items = _items[roomId];
    if (items == null) return;

    final index = items.indexWhere((i) => i.id == updatedItem.id);
    if (index == -1) return;

    final previous = items[index];
    items[index] = updatedItem;
    notifyListeners();

    try {
      await _inventoryRepository.updateItem(updatedItem);
    } catch (e, stackTrace) {
      debugPrint('Failed to update item: $e\n$stackTrace');
      items[index] = previous;
      notifyListeners();
      rethrow;
    }
  }

  /// Remove an item by ID
  Future<void> removeItemById(String roomId, String itemId) async {
    final items = _items[roomId];
    if (items == null) return;

    final index = items.indexWhere((i) => i.id == itemId);
    if (index == -1) return;

    final removedItem = items.removeAt(index);
    notifyListeners();

    try {
      await _inventoryRepository.deleteItem(itemId);
    } catch (e, stackTrace) {
      debugPrint('Failed to delete item: $e\n$stackTrace');
      items.insert(index, removedItem);
      notifyListeners();
      rethrow;
    }
  }

  /// Remove an item by name (legacy support)
  Future<void> removeItem(String roomId, String itemName) async {
    final items = _items[roomId];
    if (items == null) return;

    final idsToRemove = items
        .where((i) => i.name == itemName)
        .map((i) => i.id)
        .toList();

    for (final id in idsToRemove) {
      await removeItemById(roomId, id);
    }
  }

  /// Get item by ID
  Item? getItemById(String roomId, String itemId) {
    try {
      return _items[roomId]?.firstWhere((i) => i.id == itemId);
    } catch (e) {
      return null;
    }
  }

  /// Get all items across all rooms
  List<Item> get allItems {
    final List<Item> all = [];
    for (var itemList in _items.values) {
      all.addAll(itemList);
    }
    return all;
  }

  // Add these helper methods after the existing getItems method:

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

  // Add these methods to your InventoryProvider class

  // ==================== MOVE METHODS ====================

  /// Move an item to a different room or container
  Future<void> moveItem({
    required String currentRoomId,
    required String itemId,
    required String targetRoomId,
    String? targetContainerId,
  }) async {
    final items = _items[currentRoomId];
    if (items == null) return;

    final itemIndex = items.indexWhere((item) => item.id == itemId);
    if (itemIndex == -1) return;

    final item = items.removeAt(itemIndex);

    final updatedItem = item.copyWith(
      roomId: targetRoomId,
      containerId: targetContainerId,
    );

    _items.putIfAbsent(targetRoomId, () => []);
    _items[targetRoomId]!.add(updatedItem);

    notifyListeners();

    try {
      await _inventoryRepository.moveItem(
        itemId: itemId,
        newRoomId: targetRoomId,
        newContainerId: targetContainerId,
      );
    } catch (e, stackTrace) {
      debugPrint('Failed to move item: $e\n$stackTrace');
      _items[targetRoomId]!.removeWhere((i) => i.id == updatedItem.id);
      items.insert(itemIndex, item);
      notifyListeners();
      rethrow;
    }
  }

  /// Move a container (and all its items) to a different room
  Future<void> moveContainer({
    required String currentRoomId,
    required String containerId,
    required String targetRoomId,
  }) async {
    final containers = _containers[currentRoomId];
    if (containers == null) return;

    final containerIndex = containers.indexWhere((c) => c.id == containerId);
    if (containerIndex == -1) return;

    final container = containers.removeAt(containerIndex);
    final updatedContainer = container.copyWith(roomId: targetRoomId);

    _containers.putIfAbsent(targetRoomId, () => []);
    _containers[targetRoomId]!.add(updatedContainer);

    final currentRoomItems = _items[currentRoomId];
    _items.putIfAbsent(targetRoomId, () => []);
    final targetRoomItems = _items[targetRoomId]!;

    final itemsToMove = <Item>[];
    if (currentRoomItems != null) {
      final matchingItems = currentRoomItems.where(
        (item) => item.containerId == containerId,
      );
      for (final item in matchingItems.toList()) {
        currentRoomItems.remove(item);
        final updatedItem = item.copyWith(roomId: targetRoomId);
        itemsToMove.add(updatedItem);
        targetRoomItems.add(updatedItem);
      }
    }

    notifyListeners();

    try {
      await _inventoryRepository.updateContainer(updatedContainer);

      await Future.wait(
        itemsToMove.map(
          (item) => _inventoryRepository.moveItem(
            itemId: item.id,
            newRoomId: targetRoomId,
            newContainerId: item.containerId,
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Failed to move container: $e\n$stackTrace');
      _containers[targetRoomId]!.removeWhere((c) => c.id == containerId);
      _containers.putIfAbsent(currentRoomId, () => []);
      _containers[currentRoomId]!.insert(containerIndex, container);

      _items.putIfAbsent(currentRoomId, () => []);
      for (final item in itemsToMove) {
        _items[targetRoomId]!.removeWhere((i) => i.id == item.id);
        _items[currentRoomId]!.add(item.copyWith(roomId: currentRoomId));
      }

      notifyListeners();
      rethrow;
    }
  }

  /// Get item location info (room and optional container)
  Map<String, dynamic> getItemLocation(String roomId, String itemId) {
    final item = getItemById(roomId, itemId);
    if (item == null) return {};

    final room = getRoomById(roomId);
    ContainerModel? container;

    if (item.containerId != null) {
      container = getContainerById(roomId, item.containerId!);
    }

    return {'room': room, 'container': container};
  }

  // ==================== SEARCH METHODS ====================

  /// Search containers by query
  List<ContainerModel> searchContainers(String query) {
    if (query.trim().isEmpty) return [];

    final lowerQuery = query.toLowerCase();
    final List<ContainerModel> results = [];

    for (var containerList in _containers.values) {
      for (var container in containerList) {
        if (container.name.toLowerCase().contains(lowerQuery) ||
            (container.description?.toLowerCase().contains(lowerQuery) ??
                false) ||
            (container.brand?.toLowerCase().contains(lowerQuery) ?? false) ||
            (container.model?.toLowerCase().contains(lowerQuery) ?? false) ||
            (container.serialNumber?.toLowerCase().contains(lowerQuery) ??
                false) ||
            (container.searchMetadata?.toLowerCase().contains(lowerQuery) ??
                false)) {
          results.add(container);
        }
      }
    }

    return results;
  }

  /// Search items by query
  List<Item> searchItems(String query) {
    if (query.trim().isEmpty) return [];

    final lowerQuery = query.toLowerCase();
    final List<Item> results = [];

    for (var itemList in _items.values) {
      for (var item in itemList) {
        if (item.name.toLowerCase().contains(lowerQuery) ||
            (item.description?.toLowerCase().contains(lowerQuery) ?? false) ||
            (item.brand?.toLowerCase().contains(lowerQuery) ?? false) ||
            (item.model?.toLowerCase().contains(lowerQuery) ?? false) ||
            (item.serialNumber?.toLowerCase().contains(lowerQuery) ?? false) ||
            (item.searchMetadata?.toLowerCase().contains(lowerQuery) ??
                false)) {
          results.add(item);
        }
      }
    }

    return results;
  }

  // ==================== STATISTICS METHODS ====================

  /// Get total value of all items and containers
  double getTotalValue() {
    double total = 0.0;

    // Add container values
    for (var containerList in _containers.values) {
      for (var container in containerList) {
        total += container.currentValue ?? container.purchasePrice ?? 0.0;
      }
    }

    // Add item values
    for (var itemList in _items.values) {
      for (var item in itemList) {
        final value = item.currentValue ?? item.purchasePrice ?? 0.0;
        total += value * item.quantity;
      }
    }

    return total;
  }

  /// Get items expiring soon (within specified days)
  List<Item> getExpiringItems({int days = 30}) {
    final List<Item> expiring = [];
    final now = DateTime.now();
    final threshold = now.add(Duration(days: days));

    for (var itemList in _items.values) {
      for (var item in itemList) {
        if (item.expirationDate != null &&
            item.expirationDate!.isAfter(now) &&
            item.expirationDate!.isBefore(threshold)) {
          expiring.add(item);
        }
      }
    }

    // Sort by expiration date
    expiring.sort((a, b) => a.expirationDate!.compareTo(b.expirationDate!));

    return expiring;
  }

  /// Get expired items
  List<Item> getExpiredItems() {
    final List<Item> expired = [];
    final now = DateTime.now();

    for (var itemList in _items.values) {
      for (var item in itemList) {
        if (item.expirationDate != null && item.expirationDate!.isBefore(now)) {
          expired.add(item);
        }
      }
    }

    return expired;
  }

  /// Get containers expiring soon (within specified days)
  List<ContainerModel> getExpiringContainers({int days = 30}) {
    final List<ContainerModel> expiring = [];
    final now = DateTime.now();
    final threshold = now.add(Duration(days: days));

    for (var containerList in _containers.values) {
      for (var container in containerList) {
        if (container.expirationDate != null &&
            container.expirationDate!.isAfter(now) &&
            container.expirationDate!.isBefore(threshold)) {
          expiring.add(container);
        }
      }
    }

    // Sort by expiration date
    expiring.sort((a, b) => a.expirationDate!.compareTo(b.expirationDate!));

    return expiring;
  }

  /// Get expired containers
  List<ContainerModel> getExpiredContainers() {
    final List<ContainerModel> expired = [];
    final now = DateTime.now();

    for (var containerList in _containers.values) {
      for (var container in containerList) {
        if (container.expirationDate != null &&
            container.expirationDate!.isBefore(now)) {
          expired.add(container);
        }
      }
    }

    return expired;
  }

  // ==================== UTILITY METHODS ====================

  /// Clear all data (useful for testing or reset)
  void clearAll() {
    _locations.clear();
    _rooms.clear();
    _containers.clear();
    _items.clear();
    notifyListeners();
  }

  /// Get statistics summary
  Map<String, dynamic> getStatistics() {
    return {
      'totalRooms': _rooms.length,
      'totalLocations': allLocations.length,
      'totalContainers': totalContainers,
      'totalItems': totalItems,
      'totalValue': getTotalValue(),
      'expiringItemsCount': getExpiringItems().length,
      'expiredItemsCount': getExpiredItems().length,
      'expiringContainersCount': getExpiringContainers().length,
      'expiredContainersCount': getExpiredContainers().length,
    };
  }

  /// Export data to JSON (useful for backup)
  Map<String, dynamic> toJson() {
    return {
      'locations': _locations,
      'rooms': _rooms.map((r) => r.toJson()).toList(),
      'containers': _containers.map(
        (key, value) => MapEntry(key, value.map((c) => c.toJson()).toList()),
      ),
      'items': _items.map(
        (key, value) => MapEntry(key, value.map((i) => i.toJson()).toList()),
      ),
    };
  }

  /// Import data from JSON (useful for restore)
  void fromJson(Map<String, dynamic> json) {
    try {
      // Clear existing data
      _locations.clear();
      _rooms.clear();
      _containers.clear();
      _items.clear();

      // Import locations
      if (json['locations'] != null) {
        _locations.addAll(List<String>.from(json['locations']));
      }

      // Import rooms
      if (json['rooms'] != null) {
        for (var roomJson in json['rooms']) {
          _rooms.add(Room.fromJson(roomJson));
        }
      }

      // Import containers
      if (json['containers'] != null) {
        final containersMap = json['containers'] as Map<String, dynamic>;
        for (var entry in containersMap.entries) {
          _containers[entry.key] = (entry.value as List)
              .map((c) => ContainerModel.fromJson(c))
              .toList();
        }
      }

      // Import items
      if (json['items'] != null) {
        final itemsMap = json['items'] as Map<String, dynamic>;
        for (var entry in itemsMap.entries) {
          _items[entry.key] = (entry.value as List)
              .map((i) => Item.fromJson(i))
              .toList();
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error importing data: $e');
    }
  }

  String _generateId(String prefix) {
    _idCounter++;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${prefix}_${timestamp}_$_idCounter';
  }
}

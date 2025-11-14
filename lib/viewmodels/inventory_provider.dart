import 'package:flutter/material.dart';
import 'package:inventory_tracker/models/room_model.dart';
import 'package:inventory_tracker/models/container_model.dart';
import 'package:inventory_tracker/models/item_model.dart';

class InventoryProvider with ChangeNotifier {
  final List<String> _locations = [];
  final List<Room> _rooms = [];
  final Map<String, List<ContainerModel>> _containers =
      {}; // roomId -> list of ContainerModel objects
  final Map<String, List<Item>> _items = {}; // roomId -> list of Item objects

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
  void addLocation(String location) {
    if (location.trim().isNotEmpty && !_locations.contains(location)) {
      _locations.add(location);
      notifyListeners();
    }
  }

  /// Remove a location (and all its rooms)
  void removeLocation(String location) {
    _locations.remove(location);
    // Remove all rooms in this location
    final roomsToRemove = _rooms
        .where((room) => room.location == location)
        .toList();
    for (var room in roomsToRemove) {
      removeRoom(room.id);
    }
    notifyListeners();
  }

  /// Check if location exists
  bool hasLocation(String location) {
    return _locations.contains(location);
  }

  // ==================== ROOM METHODS ====================

  /// Add a new room
  void addRoom(Room room) {
    _rooms.add(room);
    _containers[room.id] = [];
    _items[room.id] = [];

    // Also add location if it doesn't exist
    if (!_locations.contains(room.location)) {
      _locations.add(room.location);
    }

    notifyListeners();
  }

  /// Add multiple rooms at once (useful for onboarding)
  void addRooms(List<Room> rooms) {
    for (var room in rooms) {
      _rooms.add(room);
      _containers[room.id] = [];
      _items[room.id] = [];

      if (!_locations.contains(room.location)) {
        _locations.add(room.location);
      }
    }
    notifyListeners();
  }

  /// Update a room
  void updateRoom(Room updatedRoom) {
    final index = _rooms.indexWhere((room) => room.id == updatedRoom.id);
    if (index != -1) {
      final oldLocation = _rooms[index].location;
      _rooms[index] = updatedRoom;

      // Update location if changed
      if (oldLocation != updatedRoom.location) {
        if (!_locations.contains(updatedRoom.location)) {
          _locations.add(updatedRoom.location);
        }
        // Remove old location if no other rooms use it
        if (!_rooms.any((room) => room.location == oldLocation)) {
          _locations.remove(oldLocation);
        }
      }

      notifyListeners();
    }
  }

  /// Remove a room and all its containers/items
  void removeRoom(String roomId) {
    _rooms.removeWhere((room) => room.id == roomId);
    _containers.remove(roomId);
    _items.remove(roomId);
    notifyListeners();
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
  void addContainer(
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
  }) {
    if (containerName.trim().isEmpty) return;

    // Ensure the room exists in the containers map
    if (!_containers.containsKey(roomId)) {
      _containers[roomId] = [];
    }

    final container = ContainerModel(
      id: '${DateTime.now().millisecondsSinceEpoch}_${_containers[roomId]!.length}',
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
  }

  /// Update a container
  void updateContainer(String roomId, ContainerModel updatedContainer) {
    final containers = _containers[roomId];
    if (containers != null) {
      final index = containers.indexWhere((c) => c.id == updatedContainer.id);
      if (index != -1) {
        containers[index] = updatedContainer;
        notifyListeners();
      }
    }
  }

  /// Remove a container by ID
  void removeContainerById(String roomId, String containerId) {
    final containers = _containers[roomId];
    if (containers != null) {
      containers.removeWhere((c) => c.id == containerId);
      notifyListeners();
    }
  }

  /// Remove a container by name (legacy support)
  void removeContainer(String roomId, String containerName) {
    final containers = _containers[roomId];
    if (containers != null) {
      containers.removeWhere((c) => c.name == containerName);
      notifyListeners();
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
  void addItem(
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
  }) {
    if (itemName.trim().isEmpty) return;

    // Ensure the room exists in the items map
    if (!_items.containsKey(roomId)) {
      _items[roomId] = [];
    }

    final item = Item(
      id: '${DateTime.now().millisecondsSinceEpoch}_${_items[roomId]!.length}',
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
  }

  /// Update an item
  void updateItem(String roomId, Item updatedItem) {
    final items = _items[roomId];
    if (items != null) {
      final index = items.indexWhere((i) => i.id == updatedItem.id);
      if (index != -1) {
        items[index] = updatedItem;
        notifyListeners();
      }
    }
  }

  /// Remove an item by ID
  void removeItemById(String roomId, String itemId) {
    final items = _items[roomId];
    if (items != null) {
      items.removeWhere((i) => i.id == itemId);
      notifyListeners();
    }
  }

  /// Remove an item by name (legacy support)
  void removeItem(String roomId, String itemName) {
    final items = _items[roomId];
    if (items != null) {
      items.removeWhere((i) => i.name == itemName);
      notifyListeners();
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
void moveItem({
  required String currentRoomId,
  required String itemId,
  required String targetRoomId,
  String? targetContainerId,
}) {
  // Find the item in current room
  final items = _items[currentRoomId];
  if (items == null) return;
  
  final itemIndex = items.indexWhere((item) => item.id == itemId);
  if (itemIndex == -1) return;
  
  final item = items[itemIndex];
  
  // Create updated item with new location
  final updatedItem = item.copyWith(
    roomId: targetRoomId,
    containerId: targetContainerId,
  );
  
  // Remove from current room
  items.removeAt(itemIndex);
  
  // Add to target room
  if (!_items.containsKey(targetRoomId)) {
    _items[targetRoomId] = [];
  }
  _items[targetRoomId]!.add(updatedItem);
  
  notifyListeners();
}

/// Move a container (and all its items) to a different room
void moveContainer({
  required String currentRoomId,
  required String containerId,
  required String targetRoomId,
}) {
  // Find the container in current room
  final containers = _containers[currentRoomId];
  if (containers == null) return;
  
  final containerIndex = containers.indexWhere((c) => c.id == containerId);
  if (containerIndex == -1) return;
  
  final container = containers[containerIndex];
  
  // Create updated container with new room
  final updatedContainer = container.copyWith(roomId: targetRoomId);
  
  // Remove from current room
  containers.removeAt(containerIndex);
  
  // Add to target room
  if (!_containers.containsKey(targetRoomId)) {
    _containers[targetRoomId] = [];
  }
  _containers[targetRoomId]!.add(updatedContainer);
  
  // Move all items in this container to the new room
  final items = _items[currentRoomId];
  if (items != null) {
    final itemsToMove = items.where((item) => item.containerId == containerId).toList();
    
    for (var item in itemsToMove) {
      items.remove(item);
      final updatedItem = item.copyWith(roomId: targetRoomId);
      
      if (!_items.containsKey(targetRoomId)) {
        _items[targetRoomId] = [];
      }
      _items[targetRoomId]!.add(updatedItem);
    }
  }
  
  notifyListeners();
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
  
  return {
    'room': room,
    'container': container,
  };
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
}






















// import 'package:flutter/material.dart';
// import 'package:inventory_tracker/models/room_model.dart';
// import 'package:inventory_tracker/models/container_model.dart';
// import 'package:inventory_tracker/models/item_model.dart';

// class InventoryProvider with ChangeNotifier {
//   final List<String> _locations = [];
//   final List<Room> _rooms = [];
//   final Map<String, List<Container>> _containers = {}; // roomId -> list of Container objects
//   final Map<String, List<Item>> _items = {}; // roomId -> list of Item objects
  
//   // Get all locations
//   List<String> get locations => _locations;
  
//   // Get all rooms
//   List<Room> get rooms => _rooms;
  
//   // Get containers for a room
//   List<Container> getContainers(String roomId) {
//     return List.unmodifiable(_containers[roomId] ?? []);
//   }

//   // Get items for a room
//   List<Item> getItems(String roomId) {
//     return List.unmodifiable(_items[roomId] ?? []);
//   }
  
//   // Add a new location
//   void addLocation(String location) {
//     if (location.trim().isNotEmpty && !_locations.contains(location)) {
//       _locations.add(location);
//       notifyListeners();
//     }
//   }
  
//   // Add a new room
//   void addRoom(Room room) {
//     _rooms.add(room);
//     _containers[room.id] = [];
//     _items[room.id] = [];
    
//     // Also add location if it doesn't exist
//     if (!_locations.contains(room.location)) {
//       _locations.add(room.location);
//     }
    
//     notifyListeners();
//   }
  
//   // Add multiple rooms at once (useful for onboarding)
//   void addRooms(List<Room> rooms) {
//     for (var room in rooms) {
//       _rooms.add(room);
//       _containers[room.id] = [];
//       _items[room.id] = [];
      
//       if (!_locations.contains(room.location)) {
//         _locations.add(room.location);
//       }
//     }
//     notifyListeners();
//   }
  
//   // Add a container to a room
//   void addContainer(
//     String roomId, 
//     String containerName, {
//     String? serialNumber,
//     String? notes,
//     String? description,
//     double? purchasePrice,
//     DateTime? purchaseDate,
//     double? currentValue,
//     String? currentCondition,
//     DateTime? expirationDate,
//     double? weight,
//     String? retailer,
//     String? brand,
//     String? model,
//     String? searchMetadata,
//   }) {
//     if (containerName.trim().isNotEmpty) {
//       final container = ContainerModel(
//         id: DateTime.now().millisecondsSinceEpoch.toString(),
//         name: containerName,
//         roomId: roomId,
//         serialNumber: serialNumber,
//         notes: notes,
//         description: description,
//         purchasePrice: purchasePrice,
//         purchaseDate: purchaseDate,
//         currentValue: currentValue,
//         currentCondition: currentCondition,
//         expirationDate: expirationDate,
//         weight: weight,
//         retailer: retailer,
//         brand: brand,
//         model: model,
//         searchMetadata: searchMetadata,
//       );
      
//       _containers[roomId] = [..._containers[roomId] ?? [], container];
//       notifyListeners();
//     }
//   }
  
//   // Add an item to a room
//   void addItem(
//     String roomId, 
//     String itemName, {
//     int? quantity,
//     String? serialNumber,
//     String? notes,
//     String? description,
//     double? purchasePrice,
//     DateTime? purchaseDate,
//     double? currentValue,
//     String? currentCondition,
//     DateTime? expirationDate,
//     double? weight,
//     String? retailer,
//     String? brand,
//     String? model,
//     String? searchMetadata,
//   }) {
//     if (itemName.trim().isNotEmpty) {
//       final item = Item(
//         id: DateTime.now().millisecondsSinceEpoch.toString(),
//         name: itemName,
//         roomId: roomId,
//         quantity: quantity ?? 1,
//         serialNumber: serialNumber,
//         notes: notes,
//         description: description,
//         purchasePrice: purchasePrice,
//         purchaseDate: purchaseDate,
//         currentValue: currentValue,
//         currentCondition: currentCondition,
//         expirationDate: expirationDate,
//         weight: weight,
//         retailer: retailer,
//         brand: brand,
//         model: model,
//         searchMetadata: searchMetadata,
//       );
      
//       _items[roomId] = [..._items[roomId] ?? [], item];
//       notifyListeners();
//     }
//   }
  
//   // Remove a location (and all its rooms)
//   void removeLocation(String location) {
//     _locations.remove(location);
//     _rooms.removeWhere((room) => room.location == location);
//     notifyListeners();
//   }
  
//   // Remove a room
//   void removeRoom(String roomId) {
//     _rooms.removeWhere((room) => room.id == roomId);
//     _containers.remove(roomId);
//     _items.remove(roomId);
//     notifyListeners();
//   }
  
//   // Remove a container by ID
//   void removeContainerById(String roomId, String containerId) {
//     _containers[roomId]?.removeWhere((c) => c.id == containerId);
//     notifyListeners();
//   }
  
//   // Remove a container by name (legacy support)
//   void removeContainer(String roomId, String containerName) {
//     _containers[roomId]?.removeWhere((c) => c.name == containerName);
//     notifyListeners();
//   }
  
//   // Remove an item by ID
//   void removeItemById(String roomId, String itemId) {
//     _items[roomId]?.removeWhere((i) => i.id == itemId);
//     notifyListeners();
//   }
  
//   // Remove an item by name (legacy support)
//   void removeItem(String roomId, String itemName) {
//     _items[roomId]?.removeWhere((i) => i.name == itemName);
//     notifyListeners();
//   }
  
//   // Update a room
//   void updateRoom(Room updatedRoom) {
//     final index = _rooms.indexWhere((room) => room.id == updatedRoom.id);
//     if (index != -1) {
//       _rooms[index] = updatedRoom;
//       notifyListeners();
//     }
//   }
  
//   // Update a container
//   void updateContainer(String roomId, Container updatedContainer) {
//     final containers = _containers[roomId];
//     if (containers != null) {
//       final index = containers.indexWhere((c) => c.id == updatedContainer.id);
//       if (index != -1) {
//         containers[index] = updatedContainer;
//         notifyListeners();
//       }
//     }
//   }
  
//   // Update an item
//   void updateItem(String roomId, Item updatedItem) {
//     final items = _items[roomId];
//     if (items != null) {
//       final index = items.indexWhere((i) => i.id == updatedItem.id);
//       if (index != -1) {
//         items[index] = updatedItem;
//         notifyListeners();
//       }
//     }
//   }
  
//   // Get container by ID
//   Container? getContainerById(String roomId, String containerId) {
//     try {
//       return _containers[roomId]?.firstWhere((c) => c.id == containerId);
//     } catch (e) {
//       return null;
//     }
//   }
  
//   // Get item by ID
//   Item? getItemById(String roomId, String itemId) {
//     try {
//       return _items[roomId]?.firstWhere((i) => i.id == itemId);
//     } catch (e) {
//       return null;
//     }
//   }
  
//   // Get rooms by location
//   List<Room> getRoomsByLocation(String location) {
//     return _rooms.where((room) => room.location == location).toList();
//   }
  
//   // Get all unique locations from rooms
//   List<String> get allLocations {
//     final locations = _rooms.map((room) => room.location).toSet().toList();
//     locations.sort();
//     return locations;
//   }
  
//   // Get total number of containers across all rooms
//   int get totalContainers {
//     return _containers.values.fold(0, (sum, containers) => sum + containers.length);
//   }
  
//   // Get total number of items across all rooms
//   int get totalItems {
//     return _items.values.fold(0, (sum, items) => sum + items.length);
//   }
  
//   // Get room by ID
//   Room? getRoomById(String roomId) {
//     try {
//       return _rooms.firstWhere((room) => room.id == roomId);
//     } catch (e) {
//       return null;
//     }
//   }
  
//   // Check if location exists
//   bool hasLocation(String location) {
//     return _locations.contains(location);
//   }
  
//   // Clear all data (useful for testing or reset)
//   void clearAll() {
//     _locations.clear();
//     _rooms.clear();
//     _containers.clear();
//     _items.clear();
//     notifyListeners();
//   }
// }

















// // import 'package:flutter/material.dart';
// // import 'package:inventory_tracker/models/room_model.dart';

// // class InventoryProvider with ChangeNotifier {
// //   final List<String> _locations = [];
// //   final List<Room> _rooms = [];
// //   final Map<String, List<String>> _containers = {}; // roomId -> list of container names
// //   final Map<String, List<String>> _items = {}; // roomId -> list of container names
  
// //   // Get all locations
// //   List<String> get locations => _locations;
  
// //   // Get all rooms
// //   List<Room> get rooms => _rooms;
  
// //   // Get containers for a room
// //   List<String> getContainers(String roomId) {
// //     return List.unmodifiable(_containers[roomId] ?? []);
// //   }

// //   // Get containers for a room
// //   List<String> getItems(String roomId) {
// //     return List.unmodifiable(_items[roomId] ?? []);
// //   }
  
// //   // Add a new location
// //   void addLocation(String location) {
// //     if (location.trim().isNotEmpty && !_locations.contains(location)) {
// //       _locations.add(location);
// //       notifyListeners();
// //     }
// //   }
  
// //   // Add a new room
// //   void addRoom(Room room) {
// //     _rooms.add(room);
// //     _containers[room.id] = [];
    
// //     // Also add location if it doesn't exist
// //     if (!_locations.contains(room.location)) {
// //       _locations.add(room.location);
// //     }
    
// //     notifyListeners();
// //   }
  
// //   // Add multiple rooms at once (useful for onboarding)
// //   void addRooms(List<Room> rooms) {
// //     for (var room in rooms) {
// //       _rooms.add(room);
// //       _containers[room.id] = [];
      
// //       if (!_locations.contains(room.location)) {
// //         _locations.add(room.location);
// //       }
// //     }
// //     notifyListeners();
// //   }
  
// //   // Add a container to a room
// //   void addContainer(String roomId, String containerName, {required String serialNumber, required String notes, required String description, double? purchasePrice, DateTime? purchaseDate, double? currentValue, String? currentCondition, DateTime? expirationDate, double? weight, required String retailer, required String brand, required String model, required String searchMetadata,}) {
// //     if (containerName.trim().isNotEmpty) {
// //       _containers[roomId] = [..._containers[roomId] ?? [], containerName];
// //       notifyListeners();
// //     }
// //   }
  
// //   // Add an item to a room (alias for addContainer, used for item tracking)
// //   void addItem(String roomId, String itemName, {required String serialNumber, required String notes, required String description, double? purchasePrice, DateTime? purchaseDate, double? currentValue, String? currentCondition, DateTime? expirationDate, double? weight, required String retailer, required String brand, required String model, required String searchMetadata, int? quantity}) {
// //     // Items are stored the same way as containers in the data model
// //     if (itemName.trim().isNotEmpty) {
// //       _items[roomId] = [..._items[roomId] ?? [], itemName];
// //       notifyListeners();
// //     }
// //   }
  
// //   // Remove a location (and all its rooms)
// //   void removeLocation(String location) {
// //     _locations.remove(location);
// //     _rooms.removeWhere((room) => room.location == location);
// //     notifyListeners();
// //   }
  
// //   // Remove a room
// //   void removeRoom(String roomId) {
// //     _rooms.removeWhere((room) => room.id == roomId);
// //     _containers.remove(roomId);
// //     notifyListeners();
// //   }
  
// //   // Remove a container
// //   void removeContainer(String roomId, String containerName) {
// //     _containers[roomId]?.remove(containerName);
// //     notifyListeners();
// //   }
  
// //   // Update a room
// //   void updateRoom(Room updatedRoom) {
// //     final index = _rooms.indexWhere((room) => room.id == updatedRoom.id);
// //     if (index != -1) {
// //       _rooms[index] = updatedRoom;
// //       notifyListeners();
// //     }
// //   }
  
// //   // Get rooms by location
// //   List<Room> getRoomsByLocation(String location) {
// //     return _rooms.where((room) => room.location == location).toList();
// //   }
  
// //   // Get all unique locations from rooms
// //   List<String> get allLocations {
// //     final locations = _rooms.map((room) => room.location).toSet().toList();
// //     locations.sort();
// //     return locations;
// //   }
  
// //   // Get total number of containers across all rooms
// //   int get totalContainers {
// //     return _containers.values.fold(0, (sum, containers) => sum + containers.length);
// //   }
  
// //   // Get room by ID
// //   Room? getRoomById(String roomId) {
// //     try {
// //       return _rooms.firstWhere((room) => room.id == roomId);
// //     } catch (e) {
// //       return null;
// //     }
// //   }
  
// //   // Check if location exists
// //   bool hasLocation(String location) {
// //     return _locations.contains(location);
// //   }
  
// //   // Clear all data (useful for testing or reset)
// //   void clearAll() {
// //     _locations.clear();
// //     _rooms.clear();
// //     _containers.clear();
// //     notifyListeners();
// //   }
// // }










// // import 'package:flutter/material.dart';
// // import 'package:inventory_tracker/models/room_model.dart';

// // class RoomProvider with ChangeNotifier {
// //   final List<Room> _rooms = [];
// //   final Map<String, List<String>> _containers = {}; // roomId -> list of container names
  
// //   // Get all rooms
// //   List<Room> get rooms => List.unmodifiable(_rooms);
  
// //   // Get containers for a room
// //   List<String> getContainers(String roomId) {
// //     return List.unmodifiable(_containers[roomId] ?? []);
// //   }
  
// //   // Add a new room
// //   void addRoom(Room room) {
// //     _rooms.add(room);
// //     _containers[room.id] = [];
// //     notifyListeners();
// //   }
  
// //   // Add a container to a room
// //   void addContainer(String roomId, String containerName) {
// //     if (containerName.trim().isNotEmpty) {
// //       _containers[roomId] = [..._containers[roomId] ?? [], containerName];
// //       notifyListeners();
// //     }
// //   }
  
// //   // Remove a room
// //   void removeRoom(String roomId) {
// //     _rooms.removeWhere((room) => room.id == roomId);
// //     _containers.remove(roomId);
// //     notifyListeners();
// //   }
  
// //   // Update a room
// //   void updateRoom(Room updatedRoom) {
// //     final index = _rooms.indexWhere((room) => room.id == updatedRoom.id);
// //     if (index != -1) {
// //       _rooms[index] = updatedRoom;
// //       notifyListeners();
// //     }
// //   }
  
// //   // Get rooms by location
// //   List<Room> getRoomsByLocation(String location) {
// //     return _rooms.where((room) => room.location == location).toList();
// //   }
  
// //   // Get all unique locations
// //   List<String> get allLocations {
// //     final locations = _rooms.map((room) => room.location).toSet().toList();
// //     locations.sort();
// //     return locations;
// //   }
// // }

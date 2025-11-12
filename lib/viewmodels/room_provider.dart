import 'package:flutter/material.dart';
import 'package:inventory_tracker/models/room_model.dart';

class RoomProvider with ChangeNotifier {
  final List<String> _locations = [];
  final List<Room> _rooms = [];
  final Map<String, List<String>> _containers = {}; // roomId -> list of container names
  
  // Get all locations
  List<String> get locations => List.unmodifiable(_locations);
  
  // Get all rooms
  List<Room> get rooms => List.unmodifiable(_rooms);
  
  // Get containers for a room
  List<String> getContainers(String roomId) {
    return List.unmodifiable(_containers[roomId] ?? []);
  }
  
  // Add a new location
  void addLocation(String location) {
    if (location.trim().isNotEmpty && !_locations.contains(location)) {
      _locations.add(location);
      notifyListeners();
    }
  }
  
  // Add a new room
  void addRoom(Room room) {
    _rooms.add(room);
    _containers[room.id] = [];
    
    // Also add location if it doesn't exist
    if (!_locations.contains(room.location)) {
      _locations.add(room.location);
    }
    
    notifyListeners();
  }
  
  // Add multiple rooms at once (useful for onboarding)
  void addRooms(List<Room> rooms) {
    for (var room in rooms) {
      _rooms.add(room);
      _containers[room.id] = [];
      
      if (!_locations.contains(room.location)) {
        _locations.add(room.location);
      }
    }
    notifyListeners();
  }
  
  // Add a container to a room
  void addContainer(String roomId, String containerName) {
    if (containerName.trim().isNotEmpty) {
      _containers[roomId] = [..._containers[roomId] ?? [], containerName];
      notifyListeners();
    }
  }
  
  // Remove a location (and all its rooms)
  void removeLocation(String location) {
    _locations.remove(location);
    _rooms.removeWhere((room) => room.location == location);
    notifyListeners();
  }
  
  // Remove a room
  void removeRoom(String roomId) {
    _rooms.removeWhere((room) => room.id == roomId);
    _containers.remove(roomId);
    notifyListeners();
  }
  
  // Remove a container
  void removeContainer(String roomId, String containerName) {
    _containers[roomId]?.remove(containerName);
    notifyListeners();
  }
  
  // Update a room
  void updateRoom(Room updatedRoom) {
    final index = _rooms.indexWhere((room) => room.id == updatedRoom.id);
    if (index != -1) {
      _rooms[index] = updatedRoom;
      notifyListeners();
    }
  }
  
  // Get rooms by location
  List<Room> getRoomsByLocation(String location) {
    return _rooms.where((room) => room.location == location).toList();
  }
  
  // Get all unique locations from rooms
  List<String> get allLocations {
    final locations = _rooms.map((room) => room.location).toSet().toList();
    locations.sort();
    return locations;
  }
  
  // Get total number of containers across all rooms
  int get totalContainers {
    return _containers.values.fold(0, (sum, containers) => sum + containers.length);
  }
  
  // Get room by ID
  Room? getRoomById(String roomId) {
    try {
      return _rooms.firstWhere((room) => room.id == roomId);
    } catch (e) {
      return null;
    }
  }
  
  // Check if location exists
  bool hasLocation(String location) {
    return _locations.contains(location);
  }
  
  // Clear all data (useful for testing or reset)
  void clearAll() {
    _locations.clear();
    _rooms.clear();
    _containers.clear();
    notifyListeners();
  }
}










// import 'package:flutter/material.dart';
// import 'package:inventory_tracker/models/room_model.dart';

// class RoomProvider with ChangeNotifier {
//   final List<Room> _rooms = [];
//   final Map<String, List<String>> _containers = {}; // roomId -> list of container names
  
//   // Get all rooms
//   List<Room> get rooms => List.unmodifiable(_rooms);
  
//   // Get containers for a room
//   List<String> getContainers(String roomId) {
//     return List.unmodifiable(_containers[roomId] ?? []);
//   }
  
//   // Add a new room
//   void addRoom(Room room) {
//     _rooms.add(room);
//     _containers[room.id] = [];
//     notifyListeners();
//   }
  
//   // Add a container to a room
//   void addContainer(String roomId, String containerName) {
//     if (containerName.trim().isNotEmpty) {
//       _containers[roomId] = [..._containers[roomId] ?? [], containerName];
//       notifyListeners();
//     }
//   }
  
//   // Remove a room
//   void removeRoom(String roomId) {
//     _rooms.removeWhere((room) => room.id == roomId);
//     _containers.remove(roomId);
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
  
//   // Get rooms by location
//   List<Room> getRoomsByLocation(String location) {
//     return _rooms.where((room) => room.location == location).toList();
//   }
  
//   // Get all unique locations
//   List<String> get allLocations {
//     final locations = _rooms.map((room) => room.location).toSet().toList();
//     locations.sort();
//     return locations;
//   }
// }

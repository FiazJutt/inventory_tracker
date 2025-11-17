import 'package:flutter/material.dart';
import 'package:inventory_tracker/viewmodels/base_inventory_provider.dart';
import 'package:inventory_tracker/models/room_model.dart';
import 'package:inventory_tracker/models/location_model.dart';

/// Extension for room-related functionality
mixin RoomProvider on BaseInventoryProvider {
  /// Add a new room
  Future<void> addRoom(Room room) async {
    final isNewLocation = locations.contains(room.location);

    roomsList.add(room);
    containersMap[room.id] = [];
    itemsMap[room.id] = [];

    if (isNewLocation) {
      locationsList.add(room.location);
    }

    notifyListeners();

    try {
      if (isNewLocation) {
        final locationModel = LocationModel(
          id: generateId('loc'),
          name: room.location,
        );
        await repository.upsertLocation(locationModel);
      }
      await repository.upsertRoom(room);
    } catch (e, stackTrace) {
      debugPrint('Failed to add room: $e\n$stackTrace');
      roomsList.removeWhere((r) => r.id == room.id);
      containersMap.remove(room.id);
      itemsMap.remove(room.id);
      if (isNewLocation) {
        locationsList.remove(room.location);
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
    final index = roomsList.indexWhere((room) => room.id == updatedRoom.id);
    if (index == -1) return;

    final previousRoom = roomsList[index];
    final oldLocation = previousRoom.location;
    final locationChanged = oldLocation != updatedRoom.location;
    var addedLocation = false;

    roomsList[index] = updatedRoom;

    if (locationChanged) {
      if (!locationsList.contains(updatedRoom.location)) {
        locationsList.add(updatedRoom.location);
        addedLocation = true;
      }

      if (!roomsList.any(
        (room) => room.id != updatedRoom.id && room.location == oldLocation,
      )) {
        locationsList.remove(oldLocation);
      }
    }

    notifyListeners();

    try {
      if (locationChanged && addedLocation) {
        final locationModel = LocationModel(
          id: generateId('loc'),
          name: updatedRoom.location,
        );
        await repository.upsertLocation(locationModel);
      }

      await repository.upsertRoom(updatedRoom);

      if (locationChanged) {
        final isOldLocationUsed = roomsList.any(
          (room) => room.location == oldLocation,
        );
        if (!isOldLocationUsed) {
          await repository.deleteLocationByName(oldLocation);
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Failed to update room: $e\n$stackTrace');
      roomsList[index] = previousRoom;

      if (locationChanged) {
        if (addedLocation) {
          locationsList.remove(updatedRoom.location);
        }
        if (!locationsList.contains(oldLocation)) {
          locationsList.add(oldLocation);
        }
      }

      notifyListeners();
      rethrow;
    }
  }

  /// Remove a room and all its containers/items
  Future<void> removeRoom(String roomId) async {
    final roomIndex = roomsList.indexWhere((room) => room.id == roomId);
    if (roomIndex == -1) return;

    final room = roomsList[roomIndex];
    final location = room.location;

    roomsList.removeAt(roomIndex);
    containersMap.remove(roomId);
    itemsMap.remove(roomId);

    var removedLocation = false;
    if (!roomsList.any((r) => r.location == location)) {
      locationsList.remove(location);
      removedLocation = true;
    }

    notifyListeners();

    try {
      await repository.deleteRoom(roomId);
      if (removedLocation) {
        await repository.deleteLocationByName(location);
      }
    } catch (e, stackTrace) {
      debugPrint('Failed to delete room: $e\n$stackTrace');
      // We'll need to implement refreshFromDatabase in the base class
      // For now, we'll just rethrow the error
      rethrow;
    }
  }

  /// Get rooms by location
  List<Room> getRoomsByLocation(String location) {
    return roomsList.where((room) => room.location == location).toList();
  }
}
import 'package:flutter/material.dart';
import 'package:inventory_tracker/viewmodels/base_inventory_provider.dart';
import 'package:inventory_tracker/models/item_model.dart';
import 'package:inventory_tracker/models/container_model.dart';

/// Extension for move-related functionality
mixin MoveProvider on BaseInventoryProvider {
  /// Move an item to a different room or container
  Future<void> moveItem({
    required String currentRoomId,
    required String itemId,
    required String targetRoomId,
    String? targetContainerId,
  }) async {
    final items = itemsMap[currentRoomId];
    if (items == null) return;

    final itemIndex = items.indexWhere((item) => item.id == itemId);
    if (itemIndex == -1) return;

    final item = items.removeAt(itemIndex);

    final updatedItem = item.copyWith(
      roomId: targetRoomId,
      containerId: targetContainerId,
    );

    itemsMap.putIfAbsent(targetRoomId, () => []);
    itemsMap[targetRoomId]!.add(updatedItem);

    notifyListeners();

    try {
      await repository.moveItem(
        itemId: itemId,
        newRoomId: targetRoomId,
        newContainerId: targetContainerId,
      );
    } catch (e, stackTrace) {
      debugPrint('Failed to move item: $e\n$stackTrace');
      itemsMap[targetRoomId]!.removeWhere((i) => i.id == updatedItem.id);
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
    final containers = containersMap[currentRoomId];
    if (containers == null) return;

    final containerIndex = containers.indexWhere((c) => c.id == containerId);
    if (containerIndex == -1) return;

    final container = containers.removeAt(containerIndex);
    final updatedContainer = container.copyWith(roomId: targetRoomId);

    containersMap.putIfAbsent(targetRoomId, () => []);
    containersMap[targetRoomId]!.add(updatedContainer);

    final currentRoomItems = itemsMap[currentRoomId];
    itemsMap.putIfAbsent(targetRoomId, () => []);
    final targetRoomItems = itemsMap[targetRoomId]!;

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
      await repository.updateContainer(updatedContainer);

      await Future.wait(
        itemsToMove.map(
          (item) => repository.moveItem(
            itemId: item.id,
            newRoomId: targetRoomId,
            newContainerId: item.containerId,
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Failed to move container: $e\n$stackTrace');
      containersMap[targetRoomId]!.removeWhere((c) => c.id == containerId);
      containersMap.putIfAbsent(currentRoomId, () => []);
      containersMap[currentRoomId]!.insert(containerIndex, container);

      itemsMap.putIfAbsent(currentRoomId, () => []);
      for (final item in itemsToMove) {
        itemsMap[targetRoomId]!.removeWhere((i) => i.id == item.id);
        itemsMap[currentRoomId]!.add(item.copyWith(roomId: currentRoomId));
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
}
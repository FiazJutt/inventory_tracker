import 'package:flutter/material.dart';
import 'package:inventory_tracker/viewmodels/base_inventory_provider.dart';
import 'package:inventory_tracker/models/container_model.dart';

/// Extension for container-related functionality
mixin ContainerProvider on BaseInventoryProvider {
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

    containersMap.putIfAbsent(roomId, () => []);

    final container = ContainerModel(
      id: generateId('con'),
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

    containersMap[roomId]!.add(container);
    notifyListeners();

    try {
      await repository.upsertContainer(container);
      return container;
    } catch (e, stackTrace) {
      debugPrint('Failed to add container: $e\n$stackTrace');
      containersMap[roomId]!.removeWhere((c) => c.id == container.id);
      notifyListeners();
      rethrow;
    }
  }

  /// Update a container
  Future<void> updateContainer(
    String roomId,
    ContainerModel updatedContainer,
  ) async {
    final containers = containersMap[roomId];
    if (containers == null) return;

    final index = containers.indexWhere((c) => c.id == updatedContainer.id);
    if (index == -1) return;

    final previous = containers[index];
    containers[index] = updatedContainer;
    notifyListeners();

    try {
      await repository.updateContainer(updatedContainer);
    } catch (e, stackTrace) {
      debugPrint('Failed to update container: $e\n$stackTrace');
      containers[index] = previous;
      notifyListeners();
      rethrow;
    }
  }

  /// Remove a container by ID
  Future<void> removeContainerById(String roomId, String containerId) async {
    final containers = containersMap[roomId];
    if (containers == null) return;

    final containerIndex = containers.indexWhere((c) => c.id == containerId);
    if (containerIndex == -1) return;

    final removedContainer = containers.removeAt(containerIndex);
    notifyListeners();

    try {
      await repository.deleteContainer(containerId);

      final items = itemsMap[roomId];
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
    final containers = containersMap[roomId];
    if (containers == null) return;

    final idsToRemove = containers
        .where((c) => c.name == containerName)
        .map((c) => c.id)
        .toList();

    for (final id in idsToRemove) {
      await removeContainerById(roomId, id);
    }
  }
}
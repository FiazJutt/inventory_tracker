import 'package:flutter/material.dart';
import 'package:inventory_tracker/viewmodels/base_inventory_provider.dart';
import 'package:inventory_tracker/models/item_model.dart';

/// Extension for item-related functionality
mixin ItemProvider on BaseInventoryProvider {
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

    itemsMap.putIfAbsent(roomId, () => []);

    final item = Item(
      id: generateId('item'),
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

    itemsMap[roomId]!.add(item);
    notifyListeners();

    try {
      await repository.upsertItem(item);
      return item;
    } catch (e, stackTrace) {
      debugPrint('Failed to add item: $e\n$stackTrace');
      itemsMap[roomId]!.removeWhere((i) => i.id == item.id);
      notifyListeners();
      rethrow;
    }
  }

  /// Update an item
  Future<void> updateItem(String roomId, Item updatedItem) async {
    final items = itemsMap[roomId];
    if (items == null) return;

    final index = items.indexWhere((i) => i.id == updatedItem.id);
    if (index == -1) return;

    final previous = items[index];
    items[index] = updatedItem;
    notifyListeners();

    try {
      await repository.updateItem(updatedItem);
    } catch (e, stackTrace) {
      debugPrint('Failed to update item: $e\n$stackTrace');
      items[index] = previous;
      notifyListeners();
      rethrow;
    }
  }

  /// Remove an item by ID
  Future<void> removeItemById(String roomId, String itemId) async {
    final items = itemsMap[roomId];
    if (items == null) return;

    final index = items.indexWhere((i) => i.id == itemId);
    if (index == -1) return;

    final removedItem = items.removeAt(index);
    notifyListeners();

    try {
      await repository.deleteItem(itemId);
    } catch (e, stackTrace) {
      debugPrint('Failed to delete item: $e\n$stackTrace');
      items.insert(index, removedItem);
      notifyListeners();
      rethrow;
    }
  }

  /// Remove an item by name (legacy support)
  Future<void> removeItem(String roomId, String itemName) async {
    final items = itemsMap[roomId];
    if (items == null) return;

    final idsToRemove = items
        .where((i) => i.name == itemName)
        .map((i) => i.id)
        .toList();

    for (final id in idsToRemove) {
      await removeItemById(roomId, id);
    }
  }
}
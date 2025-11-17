import 'package:inventory_tracker/viewmodels/base_inventory_provider.dart';
import 'package:inventory_tracker/models/container_model.dart';
import 'package:inventory_tracker/models/item_model.dart';

/// Extension for search-related functionality
mixin SearchProvider on BaseInventoryProvider {
  /// Search containers by query
  List<ContainerModel> searchContainers(String query) {
    if (query.trim().isEmpty) return [];

    final lowerQuery = query.toLowerCase();
    final List<ContainerModel> results = [];

    for (var containerList in containersMap.values) {
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

    for (var itemList in itemsMap.values) {
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
}
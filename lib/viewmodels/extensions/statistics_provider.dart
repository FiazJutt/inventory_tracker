import 'package:inventory_tracker/viewmodels/base_inventory_provider.dart';
import 'package:inventory_tracker/models/item_model.dart';
import 'package:inventory_tracker/models/container_model.dart';

/// Extension for statistics-related functionality
mixin StatisticsProvider on BaseInventoryProvider {
  /// Get total value of all items and containers
  double getTotalValue() {
    double total = 0.0;

    // Add container values
    for (var containerList in containersMap.values) {
      for (var container in containerList) {
        total += container.currentValue ?? container.purchasePrice ?? 0.0;
      }
    }

    // Add item values
    for (var itemList in itemsMap.values) {
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

    for (var itemList in itemsMap.values) {
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

    for (var itemList in itemsMap.values) {
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

    for (var containerList in containersMap.values) {
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

    for (var containerList in containersMap.values) {
      for (var container in containerList) {
        if (container.expirationDate != null &&
            container.expirationDate!.isBefore(now)) {
          expired.add(container);
        }
      }
    }

    return expired;
  }

  /// Get statistics summary
  Map<String, dynamic> getStatistics() {
    return {
      'totalRooms': rooms.length,
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
}
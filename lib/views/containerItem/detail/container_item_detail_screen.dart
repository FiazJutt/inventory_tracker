import 'package:flutter/material.dart';
import 'package:inventory_tracker/core/theme/app_colors.dart';
import 'package:inventory_tracker/models/container_model.dart';
import 'package:inventory_tracker/models/item_model.dart';

import 'widgets/detail_header.dart';
import 'widgets/quick_stats_card.dart';
import 'widgets/section_title.dart';
import 'widgets/info_card.dart';
import 'widgets/info_row.dart';
import 'widgets/detail_helpers.dart';

class ContainerItemDetailScreen extends StatelessWidget {
  final dynamic item; // Can be Container, Item, or String
  final bool isItem;

  const ContainerItemDetailScreen({
    super.key,
    required this.item,
    this.isItem = false,
  });

  // Helper methods to safely get properties
  String get itemName {
    if (item is String) return item;
    try {
      return item.name ?? 'Unnamed';
    } catch (e) {
      return 'Unnamed';
    }
  }

  String? get itemId {
    if (item is String) return null;
    try {
      return item.id;
    } catch (e) {
      return null;
    }
  }

  int? get itemQuantity {
    if (item is String) return null;
    try {
      return item.quantity;
    } catch (e) {
      return null;
    }
  }

  String? get itemBrand {
    if (item is String) return null;
    try {
      return (item as dynamic).brand;
    } catch (e) {
      return null;
    }
  }

  String? get itemModel {
    if (item is String) return null;
    try {
      return (item as dynamic).model;
    } catch (e) {
      return null;
    }
  }

  String? get itemSerialNumber {
    if (item is String) return null;
    try {
      return (item as dynamic).serialNumber;
    } catch (e) {
      return null;
    }
  }

  String? get itemDescription {
    if (item is String) return null;
    try {
      return (item as dynamic).description;
    } catch (e) {
      return null;
    }
  }

  String? get itemRetailer {
    if (item is String) return null;
    try {
      return (item as dynamic).retailer;
    } catch (e) {
      return null;
    }
  }

  String? get itemCurrentCondition {
    if (item is String) return null;
    try {
      return (item as dynamic).currentCondition;
    } catch (e) {
      return null;
    }
  }

  String? get itemNotes {
    if (item is String) return null;
    try {
      return (item as dynamic).notes;
    } catch (e) {
      return null;
    }
  }

  String? get itemSearchMetadata {
    if (item is String) return null;
    try {
      return (item as dynamic).searchMetadata;
    } catch (e) {
      return null;
    }
  }

  double? get itemPurchasePrice {
    if (item is String) return null;
    try {
      return (item as dynamic).purchasePrice;
    } catch (e) {
      return null;
    }
  }

  double? get itemCurrentValue {
    if (item is String) return null;
    try {
      return (item as dynamic).currentValue;
    } catch (e) {
      return null;
    }
  }

  double? get itemWeight {
    if (item is String) return null;
    try {
      return (item as dynamic).weight;
    } catch (e) {
      return null;
    }
  }

  DateTime? get itemPurchaseDate {
    if (item is String) return null;
    try {
      return (item as dynamic).purchaseDate;
    } catch (e) {
      return null;
    }
  }

  DateTime? get itemExpirationDate {
    if (item is String) return null;
    try {
      return (item as dynamic).expirationDate;
    } catch (e) {
      return null;
    }
  }

  DateTime? get itemCreatedAt {
    if (item is String) return null;
    try {
      return (item as dynamic).createdAt;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (item is String) {
      return _buildSimpleScreen(context);
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DetailHeader(name: itemName, isItem: isItem),
            const SizedBox(height: 24),
            if (_shouldShowQuickStats())
              QuickStatsCard(
                quantity: isItem ? itemQuantity : null,
                currentValue: itemCurrentValue,
                currentCondition: itemCurrentCondition,
              ),
            const SizedBox(height: 24),
            if (_hasBasicInfo()) ...[
              SectionTitle(title: 'Basic Information', icon: Icons.info_outline),
              const SizedBox(height: 12),
              InfoCard(
                children: [
                  if (isItem && itemQuantity != null && itemQuantity! > 0)
                    InfoRow(
                      icon: Icons.numbers,
                      label: 'Quantity',
                      value: itemQuantity.toString(),
                    ),
                  if (itemBrand?.isNotEmpty ?? false)
                    InfoRow(
                      icon: Icons.business_outlined,
                      label: 'Brand',
                      value: itemBrand!,
                    ),
                  if (itemModel?.isNotEmpty ?? false)
                    InfoRow(
                      icon: Icons.label_outline,
                      label: 'Model',
                      value: itemModel!,
                    ),
                  if (itemSerialNumber?.isNotEmpty ?? false)
                    InfoRow(
                      icon: Icons.qr_code,
                      label: 'Serial Number',
                      value: itemSerialNumber!,
                      showCopyButton: true,
                    ),
                  if (itemDescription?.isNotEmpty ?? false)
                    InfoRow(
                      icon: Icons.description_outlined,
                      label: 'Description',
                      value: itemDescription!,
                      maxLines: 5,
                    ),
                ],
              ),
              const SizedBox(height: 24),
            ],
            if (_hasPurchaseInfo()) ...[
              SectionTitle(
                title: 'Purchase Information',
                icon: Icons.shopping_cart,
              ),
              const SizedBox(height: 12),
              InfoCard(
                children: [
                  if (itemPurchasePrice != null)
                    InfoRow(
                      icon: Icons.attach_money,
                      label: 'Purchase Price',
                      value: '\$${itemPurchasePrice!.toStringAsFixed(2)}',
                      valueColor: colors.primary,
                    ),
                  if (itemPurchaseDate != null)
                    InfoRow(
                      icon: Icons.calendar_today,
                      label: 'Purchase Date',
                      value: DetailHelpers.formatDate(itemPurchaseDate!),
                      subtitle: DetailHelpers.getTimeSince(itemPurchaseDate),
                    ),
                  if (itemRetailer?.isNotEmpty ?? false)
                    InfoRow(
                      icon: Icons.store_outlined,
                      label: 'Retailer',
                      value: itemRetailer!,
                    ),
                ],
              ),
              const SizedBox(height: 24),
            ],
            if (_hasCurrentInfo()) ...[
              SectionTitle(
                title: 'Current Information',
                icon: Icons.trending_up,
              ),
              const SizedBox(height: 12),
              InfoCard(
                children: [
                  if (itemCurrentValue != null)
                    InfoRow(
                      icon: Icons.payments_outlined,
                      label: 'Current Value',
                      value: '\$${itemCurrentValue!.toStringAsFixed(2)}',
                      valueColor: colors.primary,
                      subtitle: DetailHelpers.getValueChangeText(
                        itemPurchasePrice,
                        itemCurrentValue,
                      ),
                    ),
                  if (itemCurrentCondition?.isNotEmpty ?? false)
                    InfoRow(
                      icon: Icons.star_outline,
                      label: 'Condition',
                      value: itemCurrentCondition!,
                      badge: DetailHelpers.getConditionBadge(itemCurrentCondition),
                    ),
                  if (itemExpirationDate != null)
                    InfoRow(
                      icon: Icons.event_busy,
                      label: 'Expiration Date',
                      value: DetailHelpers.formatDate(itemExpirationDate!),
                      subtitle: DetailHelpers.getExpirationStatus(itemExpirationDate),
                      valueColor: DetailHelpers.isExpired(itemExpirationDate)
                          ? Colors.red
                          : DetailHelpers.isExpiringSoon(itemExpirationDate)
                              ? Colors.orange
                              : null,
                    ),
                ],
              ),
              const SizedBox(height: 24),
            ],
            if (_hasAdditionalInfo()) ...[
              SectionTitle(
                title: 'Additional Information',
                icon: Icons.more_horiz,
              ),
              const SizedBox(height: 12),
              InfoCard(
                children: [
                  if (itemWeight != null)
                    InfoRow(
                      icon: Icons.scale_outlined,
                      label: 'Weight',
                      value: '${itemWeight!.toStringAsFixed(2)} kg',
                    ),
                  if (itemNotes?.isNotEmpty ?? false)
                    InfoRow(
                      icon: Icons.note_outlined,
                      label: 'Notes',
                      value: itemNotes!,
                      maxLines: 10,
                    ),
                  if (itemSearchMetadata?.isNotEmpty ?? false)
                    InfoRow(
                      icon: Icons.search,
                      label: 'Search Keywords',
                      value: itemSearchMetadata!,
                      maxLines: 3,
                    ),
                ],
              ),
              const SizedBox(height: 24),
            ],
            if (itemId != null || itemCreatedAt != null) ...[
              SectionTitle(title: 'Metadata', icon: Icons.code),
              const SizedBox(height: 12),
              InfoCard(
                children: [
                  if (itemId != null)
                    InfoRow(
                      icon: Icons.tag,
                      label: 'ID',
                      value: itemId!,
                      showCopyButton: true,
                    ),
                  if (itemCreatedAt != null)
                    InfoRow(
                      icon: Icons.access_time,
                      label: 'Created',
                      value: DetailHelpers.formatDate(itemCreatedAt!, includeTime: true),
                      subtitle: DetailHelpers.getTimeSince(itemCreatedAt),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleScreen(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.onPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(itemName, style: TextStyle(color: colors.onPrimary)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isItem ? Icons.shopping_bag : Icons.inventory_2,
                  size: 80,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                itemName,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isItem ? 'ITEM' : 'CONTAINER',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: colors.textSecondary,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No additional details available',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Edit this item to add more information',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _shouldShowQuickStats() {
    return (isItem && itemQuantity != null && itemQuantity! > 0) ||
        itemCurrentValue != null ||
        (itemCurrentCondition?.isNotEmpty ?? false);
  }

  bool _hasBasicInfo() {
    return (isItem && itemQuantity != null && itemQuantity! > 0) ||
        (itemBrand?.isNotEmpty ?? false) ||
        (itemModel?.isNotEmpty ?? false) ||
        (itemSerialNumber?.isNotEmpty ?? false) ||
        (itemDescription?.isNotEmpty ?? false);
  }

  bool _hasPurchaseInfo() {
    return itemPurchasePrice != null ||
        itemPurchaseDate != null ||
        (itemRetailer?.isNotEmpty ?? false);
  }

  bool _hasCurrentInfo() {
    return itemCurrentValue != null ||
        (itemCurrentCondition?.isNotEmpty ?? false) ||
        itemExpirationDate != null;
  }

  bool _hasAdditionalInfo() {
    return itemWeight != null ||
        (itemNotes?.isNotEmpty ?? false) ||
        (itemSearchMetadata?.isNotEmpty ?? false);
  }
}

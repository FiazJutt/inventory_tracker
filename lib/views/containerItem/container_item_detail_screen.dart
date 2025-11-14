// lib/views/container_item_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:inventory_tracker/core/theme/app_colors.dart';

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
      return item.brand;
    } catch (e) {
      return null;
    }
  }

  String? get itemModel {
    if (item is String) return null;
    try {
      return item.model;
    } catch (e) {
      return null;
    }
  }

  String? get itemSerialNumber {
    if (item is String) return null;
    try {
      return item.serialNumber;
    } catch (e) {
      return null;
    }
  }

  String? get itemDescription {
    if (item is String) return null;
    try {
      return item.description;
    } catch (e) {
      return null;
    }
  }

  double? get itemPurchasePrice {
    if (item is String) return null;
    try {
      return item.purchasePrice;
    } catch (e) {
      return null;
    }
  }

  DateTime? get itemPurchaseDate {
    if (item is String) return null;
    try {
      return item.purchaseDate;
    } catch (e) {
      return null;
    }
  }

  String? get itemRetailer {
    if (item is String) return null;
    try {
      return item.retailer;
    } catch (e) {
      return null;
    }
  }

  double? get itemCurrentValue {
    if (item is String) return null;
    try {
      return item.currentValue;
    } catch (e) {
      return null;
    }
  }

  String? get itemCurrentCondition {
    if (item is String) return null;
    try {
      return item.currentCondition;
    } catch (e) {
      return null;
    }
  }

  DateTime? get itemExpirationDate {
    if (item is String) return null;
    try {
      return item.expirationDate;
    } catch (e) {
      return null;
    }
  }

  double? get itemWeight {
    if (item is String) return null;
    try {
      return item.weight;
    } catch (e) {
      return null;
    }
  }

  String? get itemNotes {
    if (item is String) return null;
    try {
      return item.notes;
    } catch (e) {
      return null;
    }
  }

  String? get itemSearchMetadata {
    if (item is String) return null;
    try {
      return item.searchMetadata;
    } catch (e) {
      return null;
    }
  }

  DateTime? get itemCreatedAt {
    if (item is String) return null;
    try {
      return item.createdAt;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (item is String) {
      return _buildSimpleScreen(context);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
      backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- COMPACT HEADER ----------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                // color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 64,
                    width: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isItem ? Icons.shopping_bag : Icons.inventory_2,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          itemName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isItem ? 'ITEM' : 'CONTAINER',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ---------- QUICK STATS ----------
            if (isItem && itemQuantity != null && itemQuantity! > 0 ||
                itemCurrentValue != null ||
                itemCurrentCondition?.isNotEmpty == true)
              _buildQuickStatsCard(),

            const SizedBox(height: 24),

            // ---------- BASIC INFO ----------
            if (_hasBasicInfo()) ...[
              _buildSectionTitle('Basic Information', Icons.info_outline),
              const SizedBox(height: 12),
              _buildInfoCard([
                if (isItem && itemQuantity != null && itemQuantity! > 0)
                  _buildInfoRow(
                    icon: Icons.numbers,
                    label: 'Quantity',
                    value: itemQuantity.toString(),
                  ),
                if (itemBrand?.isNotEmpty ?? false)
                  _buildInfoRow(
                    icon: Icons.business_outlined,
                    label: 'Brand',
                    value: itemBrand!,
                  ),
                if (itemModel?.isNotEmpty ?? false)
                  _buildInfoRow(
                    icon: Icons.label_outline,
                    label: 'Model',
                    value: itemModel!,
                  ),
                if (itemSerialNumber?.isNotEmpty ?? false)
                  _buildInfoRowWithCopy(
                    icon: Icons.qr_code,
                    label: 'Serial Number',
                    value: itemSerialNumber!,
                  ),
                if (itemDescription?.isNotEmpty ?? false)
                  _buildInfoRow(
                    icon: Icons.description_outlined,
                    label: 'Description',
                    value: itemDescription!,
                    maxLines: 5,
                  ),
              ]),
              const SizedBox(height: 24),
            ],

            // ---------- PURCHASE INFO ----------
            if (_hasPurchaseInfo()) ...[
              _buildSectionTitle('Purchase Information', Icons.shopping_cart),
              const SizedBox(height: 12),
              _buildInfoCard([
                if (itemPurchasePrice != null)
                  _buildInfoRow(
                    icon: Icons.attach_money,
                    label: 'Purchase Price',
                    value: '\$${itemPurchasePrice!.toStringAsFixed(2)}',
                    valueColor: AppColors.primary,
                  ),
                if (itemPurchaseDate != null)
                  _buildInfoRow(
                    icon: Icons.calendar_today,
                    label: 'Purchase Date',
                    value: DateFormat(
                      'MMMM dd, yyyy',
                    ).format(itemPurchaseDate!),
                    subtitle: _getTimeSincePurchase(),
                  ),
                if (itemRetailer?.isNotEmpty ?? false)
                  _buildInfoRow(
                    icon: Icons.store_outlined,
                    label: 'Retailer',
                    value: itemRetailer!,
                  ),
              ]),
              const SizedBox(height: 24),
            ],

            // ---------- CURRENT INFO ----------
            if (_hasCurrentInfo()) ...[
              _buildSectionTitle('Current Information', Icons.trending_up),
              const SizedBox(height: 12),
              _buildInfoCard([
                if (itemCurrentValue != null)
                  _buildInfoRow(
                    icon: Icons.payments_outlined,
                    label: 'Current Value',
                    value: '\$${itemCurrentValue!.toStringAsFixed(2)}',
                    valueColor: AppColors.primary,
                    subtitle: _getValueChangeText(),
                  ),
                if (itemCurrentCondition?.isNotEmpty ?? false)
                  _buildInfoRow(
                    icon: Icons.star_outline,
                    label: 'Condition',
                    value: itemCurrentCondition!,
                    badge: _getConditionBadge(),
                  ),
                if (itemExpirationDate != null)
                  _buildInfoRow(
                    icon: Icons.event_busy,
                    label: 'Expiration Date',
                    value: DateFormat(
                      'MMMM dd, yyyy',
                    ).format(itemExpirationDate!),
                    subtitle: _getExpirationStatus(),
                    valueColor: _isExpired()
                        ? Colors.red
                        : _isExpiringSoon()
                        ? Colors.orange
                        : null,
                  ),
              ]),
              const SizedBox(height: 24),
            ],

            // ---------- ADDITIONAL INFO ----------
            if (_hasAdditionalInfo()) ...[
              _buildSectionTitle('Additional Information', Icons.more_horiz),
              const SizedBox(height: 12),
              _buildInfoCard([
                if (itemWeight != null)
                  _buildInfoRow(
                    icon: Icons.scale_outlined,
                    label: 'Weight',
                    value: '${itemWeight!.toStringAsFixed(2)} kg',
                  ),
                if (itemNotes?.isNotEmpty ?? false)
                  _buildInfoRow(
                    icon: Icons.note_outlined,
                    label: 'Notes',
                    value: itemNotes!,
                    maxLines: 10,
                  ),
                if (itemSearchMetadata?.isNotEmpty ?? false)
                  _buildInfoRow(
                    icon: Icons.search,
                    label: 'Search Keywords',
                    value: itemSearchMetadata!,
                    maxLines: 3,
                  ),
              ]),
              const SizedBox(height: 24),
            ],

            // ---------- METADATA ----------
            if (itemId != null || itemCreatedAt != null) ...[
              _buildSectionTitle('Metadata', Icons.code),
              const SizedBox(height: 12),
              _buildInfoCard([
                if (itemId != null)
                  _buildInfoRowWithCopy(
                    icon: Icons.tag,
                    label: 'ID',
                    value: itemId!,
                  ),
                if (itemCreatedAt != null)
                  _buildInfoRow(
                    icon: Icons.access_time,
                    label: 'Created',
                    value: DateFormat(
                      'MMMM dd, yyyy - hh:mm a',
                    ).format(itemCreatedAt!),
                    subtitle: _getTimeSinceCreation(),
                  ),
              ]),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(itemName, style: const TextStyle(color: Colors.white)),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {

            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 12),
                    Text('Edit'),
                  ],
                ),
              ),
            ],
          ),
        ],
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
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isItem ? Icons.shopping_bag : Icons.inventory_2,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                itemName,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isItem ? 'ITEM' : 'CONTAINER',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
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
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.textSecondary,
                      size: 40,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No additional details available',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Edit this item to add more information',
                      style: TextStyle(
                        color: AppColors.textSecondary,
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

  Widget _buildQuickStatsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (isItem && itemQuantity != null && itemQuantity! > 0)
            _buildQuickStat(
              Icons.inventory_outlined,
              'Quantity',
              itemQuantity.toString(),
            ),
          if (itemCurrentValue != null)
            _buildQuickStat(
              Icons.monetization_on_outlined,
              'Value',
              '\$${itemCurrentValue!.toStringAsFixed(0)}',
            ),
          if (itemCurrentCondition?.isNotEmpty ?? false)
            _buildQuickStat(
              Icons.star_outline,
              'Condition',
              _getShortCondition(),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children.map((child) {
          final index = children.indexOf(child);
          return Column(
            children: [
              child,
              if (index < children.length - 1) ...[
                const SizedBox(height: 16),
                Divider(
                  color: AppColors.textSecondary.withOpacity(0.1),
                  height: 1,
                ),
                const SizedBox(height: 16),
              ],
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    int maxLines = 2,
    String? subtitle,
    Color? valueColor,
    Widget? badge,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: TextStyle(
                        color: valueColor ?? AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: maxLines,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (badge != null) ...[const SizedBox(width: 8), badge],
                ],
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.8),
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRowWithCopy({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Builder(
      builder: (context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            color: AppColors.primary,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$label copied to clipboard'),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _getConditionBadge() {
    final condition = itemCurrentCondition?.toLowerCase() ?? '';
    Color badgeColor;

    if (condition.contains('excellent') || condition.contains('new')) {
      badgeColor = Colors.green;
    } else if (condition.contains('good')) {
      badgeColor = Colors.blue;
    } else if (condition.contains('fair')) {
      badgeColor = Colors.orange;
    } else if (condition.contains('poor')) {
      badgeColor = Colors.red;
    } else {
      badgeColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Icon(Icons.circle, size: 8, color: badgeColor),
    );
  }

  String _getShortCondition() {
    final condition = itemCurrentCondition ?? '';
    if (condition.length > 10) {
      return condition.substring(0, 8);
    }
    return condition;
  }

  String? _getValueChangeText() {
    if (itemPurchasePrice != null && itemCurrentValue != null) {
      final change = itemCurrentValue! - itemPurchasePrice!;
      final percentage = ((change / itemPurchasePrice!) * 100).toStringAsFixed(
        1,
      );

      if (change > 0) {
        return '↑ \$${change.toStringAsFixed(2)} (+$percentage%) appreciation';
      } else if (change < 0) {
        return '↓ \$${change.abs().toStringAsFixed(2)} ($percentage%) depreciation';
      } else {
        return 'No change in value';
      }
    }
    return null;
  }

  String? _getTimeSincePurchase() {
    if (itemPurchaseDate != null) {
      final duration = DateTime.now().difference(itemPurchaseDate!);
      return '${_formatDuration(duration)} ago';
    }
    return null;
  }

  String? _getTimeSinceCreation() {
    if (itemCreatedAt != null) {
      final duration = DateTime.now().difference(itemCreatedAt!);
      return '${_formatDuration(duration)} ago';
    }
    return null;
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 365) {
      final years = (duration.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''}';
    } else if (duration.inDays > 30) {
      final months = (duration.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''}';
    } else if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays > 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''}';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Just now';
    }
  }

  String? _getExpirationStatus() {
    if (itemExpirationDate != null) {
      final now = DateTime.now();
      final expirationDate = itemExpirationDate!;

      if (expirationDate.isBefore(now)) {
        final duration = now.difference(expirationDate);
        return 'Expired ${_formatDuration(duration)} ago';
      } else {
        final duration = expirationDate.difference(now);
        return 'Expires in ${_formatDuration(duration)}';
      }
    }
    return null;
  }

  bool _isExpired() {
    if (itemExpirationDate != null) {
      return itemExpirationDate!.isBefore(DateTime.now());
    }
    return false;
  }

  bool _isExpiringSoon() {
    if (itemExpirationDate != null) {
      final daysUntilExpiration = itemExpirationDate!
          .difference(DateTime.now())
          .inDays;
      return daysUntilExpiration > 0 && daysUntilExpiration <= 30;
    }
    return false;
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

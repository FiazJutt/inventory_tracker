import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailHelpers {
  static String formatDuration(Duration duration) {
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

  static String? getTimeSince(DateTime? date) {
    if (date == null) return null;
    final duration = DateTime.now().difference(date);
    return '${formatDuration(duration)} ago';
  }

  static String? getExpirationStatus(DateTime? expirationDate) {
    if (expirationDate == null) return null;
    final now = DateTime.now();

    if (expirationDate.isBefore(now)) {
      final duration = now.difference(expirationDate);
      return 'Expired ${formatDuration(duration)} ago';
    } else {
      final duration = expirationDate.difference(now);
      return 'Expires in ${formatDuration(duration)}';
    }
  }

  static String? getValueChangeText(
    double? purchasePrice,
    double? currentValue,
  ) {
    if (purchasePrice == null || currentValue == null) return null;

    final change = currentValue - purchasePrice;
    final percentage = ((change / purchasePrice) * 100).toStringAsFixed(1);

    if (change > 0) {
      return '↑ \$${change.toStringAsFixed(2)} (+$percentage%) appreciation';
    } else if (change < 0) {
      return '↓ \$${change.abs().toStringAsFixed(2)} ($percentage%) depreciation';
    } else {
      return 'No change in value';
    }
  }

  static bool isExpired(DateTime? expirationDate) {
    if (expirationDate == null) return false;
    return expirationDate.isBefore(DateTime.now());
  }

  static bool isExpiringSoon(DateTime? expirationDate) {
    if (expirationDate == null) return false;
    final daysUntilExpiration =
        expirationDate.difference(DateTime.now()).inDays;
    return daysUntilExpiration > 0 && daysUntilExpiration <= 30;
  }

  static Widget getConditionBadge(String? condition) {
    if (condition == null) return const SizedBox.shrink();

    final conditionLower = condition.toLowerCase();
    Color badgeColor;

    if (conditionLower.contains('excellent') || conditionLower.contains('new')) {
      badgeColor = Colors.green;
    } else if (conditionLower.contains('good')) {
      badgeColor = Colors.blue;
    } else if (conditionLower.contains('fair')) {
      badgeColor = Colors.orange;
    } else if (conditionLower.contains('poor')) {
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

  static String formatDate(DateTime date, {bool includeTime = false}) {
    if (includeTime) {
      return DateFormat('MMMM dd, yyyy - hh:mm a').format(date);
    }
    return DateFormat('MMMM dd, yyyy').format(date);
  }
}


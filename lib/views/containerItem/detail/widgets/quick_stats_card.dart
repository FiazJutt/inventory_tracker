import 'package:flutter/material.dart';
import 'package:inventory_tracker/core/theme/app_colors.dart';

class QuickStatsCard extends StatelessWidget {
  final int? quantity;
  final double? currentValue;
  final String? currentCondition;

  const QuickStatsCard({
    super.key,
    this.quantity,
    this.currentValue,
    this.currentCondition,
  });

  String _getShortCondition(String condition) {
    if (condition.length > 10) {
      return condition.substring(0, 8);
    }
    return condition;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary.withOpacity(0.1),
            colors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.primary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (quantity != null && quantity! > 0)
            _buildQuickStat(
              Icons.inventory_outlined,
              'Quantity',
              quantity.toString(),
              colors,
            ),
          if (currentValue != null)
            _buildQuickStat(
              Icons.monetization_on_outlined,
              'Value',
              '\$${currentValue!.toStringAsFixed(0)}',
              colors,
            ),
          if (currentCondition != null && currentCondition!.isNotEmpty)
            _buildQuickStat(
              Icons.star_outline,
              'Condition',
              _getShortCondition(currentCondition!),
              colors,
            ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(
    IconData icon,
    String label,
    String value,
    AppColorsTheme colors,
  ) {
    return Column(
      children: [
        Icon(icon, color: colors.primary, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: colors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}


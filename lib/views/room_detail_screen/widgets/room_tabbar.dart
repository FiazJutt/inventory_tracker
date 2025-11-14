import 'package:flutter/material.dart';
import 'package:inventory_tracker/core/theme/app_colors.dart';

class RoomTabBar extends StatelessWidget {
  final TabController tabController;

  const RoomTabBar({required this.tabController});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: colors.surface,
        ),
        child: TabBar(
          controller: tabController,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: colors.primary,
            boxShadow: [
              BoxShadow(
                color: colors.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          dividerColor: Colors.transparent,
          labelColor: colors.onPrimary,
          unselectedLabelColor: colors.textSecondary,
          indicatorSize: TabBarIndicatorSize.tab,
          padding: const EdgeInsets.all(4),
          tabs: const [
            _TabIconText(icon: Icons.inventory_2_outlined, text: 'Containers'),
            _TabIconText(icon: Icons.shopping_bag_outlined, text: 'Items'),
          ],
        ),
      ),
    );
  }
}

class _TabIconText extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TabIconText({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Icon(icon, size: 18), const SizedBox(width: 8), Text(text)],
    ),
  );
}

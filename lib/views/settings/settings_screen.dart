import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:inventory_tracker/core/theme/app_colors.dart';
import 'package:inventory_tracker/core/theme/theme_provider.dart';
import 'package:inventory_tracker/viewmodels/inventory_provider.dart';

/// Settings screen with theme selection options
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        // leading: IconButton(
        //   icon: Icon(
        //     Icons.arrow_back,
        //     color: colors.textPrimary,
        //   ),
        //   onPressed: () => Navigator.pop(context),
        // ),
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 24,
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appearance Section
            _buildSectionHeader(context, 'Appearance', Icons.palette_outlined),
            const SizedBox(height: 12),
            _buildAppearanceSection(context),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final colors = context.appColors;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: colors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildAppearanceSection(BuildContext context) {
    final colors = context.appColors;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.primary.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              _buildThemeOption(
                context,
                title: 'System Default',
                subtitle: 'Follow system theme',
                icon: Icons.brightness_auto,
                isSelected: themeProvider.themeMode == ThemeMode.system,
                onTap: () => themeProvider.setTheme(ThemeMode.system),
              ),
              Divider(height: 1, color: colors.divider),
              _buildThemeOption(
                context,
                title: 'Light Mode',
                subtitle: 'Light theme',
                icon: Icons.light_mode,
                isSelected: themeProvider.themeMode == ThemeMode.light,
                onTap: () => themeProvider.setTheme(ThemeMode.light),
              ),
              Divider(height: 1, color: colors.divider),
              _buildThemeOption(
                context,
                title: 'Dark Mode',
                subtitle: 'Dark theme',
                icon: Icons.dark_mode,
                isSelected: themeProvider.themeMode == ThemeMode.dark,
                onTap: () => themeProvider.setTheme(ThemeMode.dark),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colors = context.appColors;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withOpacity(0.2)
              : colors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isSelected ? colors.primary : colors.textSecondary,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: colors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: colors.textSecondary),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: colors.primary, size: 24)
          : null,
      onTap: onTap,
    );
  }
}

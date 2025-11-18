import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:inventory_tracker/core/theme/app_colors.dart';
import 'package:inventory_tracker/core/theme/theme_provider.dart';
import 'package:inventory_tracker/viewmodels/inventory_provider.dart';
import 'package:inventory_tracker/views/subscription/subscription_plan_screen.dart';
import 'package:inventory_tracker/views/settings/widgets/section_header.dart';
import 'package:inventory_tracker/views/settings/widgets/settings_tile.dart';
import 'package:inventory_tracker/views/settings/widgets/theme_option.dart';

/// Settings screen with comprehensive options
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
            const SectionHeader(title: 'Appearance', icon: Icons.palette_outlined),
            const SizedBox(height: 12),
            _buildAppearanceSection(context),

            const SizedBox(height: 32),
            
            // Subscription Section
            const SectionHeader(title: 'Subscription', icon: Icons.star_border_rounded),
            const SizedBox(height: 12),
            _buildSubscriptionSection(context),

            const SizedBox(height: 32),
            
            // App Section
            const SectionHeader(title: 'App', icon: Icons.apps_outlined),
            const SizedBox(height: 12),
            _buildAppSection(context),

            const SizedBox(height: 32),
            
            // Support Section
            const SectionHeader(title: 'Support', icon: Icons.support_agent_outlined),
            const SizedBox(height: 12),
            _buildSupportSection(context),

            const SizedBox(height: 32),
            
            // Legal Section
            const SectionHeader(title: 'Legal', icon: Icons.description_outlined),
            const SizedBox(height: 12),
            _buildLegalSection(context),
            
            const SizedBox(height: 32),
            
            // Data Section
            const SectionHeader(title: 'Data', icon: Icons.data_usage_outlined),
            const SizedBox(height: 12),
            _buildDataSection(context),
            
            // Add padding to prevent navbar overlap
            const SizedBox(height: 100),
          ],
        ),
      ),
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
              ThemeOption(
                title: 'System Default',
                subtitle: 'Follow system theme',
                icon: Icons.brightness_auto,
                isSelected: themeProvider.themeMode == ThemeMode.system,
                onTap: () => themeProvider.setTheme(ThemeMode.system),
              ),
              Divider(height: 1, color: colors.divider),
              ThemeOption(
                title: 'Light Mode',
                subtitle: 'Light theme',
                icon: Icons.light_mode,
                isSelected: themeProvider.themeMode == ThemeMode.light,
                onTap: () => themeProvider.setTheme(ThemeMode.light),
              ),
              Divider(height: 1, color: colors.divider),
              ThemeOption(
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

  Widget _buildSubscriptionSection(BuildContext context) {
    final colors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.primary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          SettingsTile(
            icon: Icons.star_border_rounded,
            title: 'Manage Subscription',
            subtitle: 'Manage your subscription status',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubscriptionPlanScreen(),
                ),
              );
            },
          ),
          Divider(height: 1, color: colors.divider),
          SettingsTile(
            icon: Icons.restore_rounded,
            title: 'Restore Purchases',
            subtitle: 'Restore your previous purchases',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Restore Purchases tapped'),
                  backgroundColor: colors.primary,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppSection(BuildContext context) {
    final colors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.primary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          SettingsTile(
            icon: Icons.rate_review_outlined,
            title: 'Write a Review',
            subtitle: 'Rate us on the App Store',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Write a Review tapped'),
                  backgroundColor: colors.primary,
                ),
              );
            },
          ),
          Divider(height: 1, color: colors.divider),
          SettingsTile(
            icon: Icons.share_outlined,
            title: 'Share the App',
            subtitle: 'Tell your friends about us',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Share the App tapped'),
                  backgroundColor: colors.primary,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    final colors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.primary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          SettingsTile(
            icon: Icons.support_agent_outlined,
            title: 'Contact Support',
            subtitle: 'Get help with any issues',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Contact Support tapped'),
                  backgroundColor: colors.primary,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegalSection(BuildContext context) {
    final colors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.primary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'How we handle your data',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Privacy Policy tapped'),
                  backgroundColor: colors.primary,
                ),
              );
            },
          ),
          Divider(height: 1, color: colors.divider),
          SettingsTile(
            icon: Icons.description_outlined,
            title: 'Terms of Use',
            subtitle: 'App Usage Terms and Conditions',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Terms of Use tapped'),
                  backgroundColor: colors.primary,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDataSection(BuildContext context) {
    final colors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.primary.withOpacity(0.1)),
      ),
      child: Consumer<InventoryProvider>(
        builder: (context, inventoryProvider, _) {
          return Column(
            children: [
              SettingsTile(
                icon: Icons.backup_outlined,
                title: 'Backup Data',
                subtitle: 'Create a backup of your inventory',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Backup Data tapped'),
                      backgroundColor: colors.primary,
                    ),
                  );
                },
              ),
              Divider(height: 1, color: colors.divider),
              SettingsTile(
                icon: Icons.restore_outlined,
                title: 'Restore Data',
                subtitle: 'Restore inventory from backup',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Restore Data tapped'),
                      backgroundColor: colors.primary,
                    ),
                  );
                },
              ),
              Divider(height: 1, color: colors.divider),
              SettingsTile(
                icon: Icons.delete_outline,
                title: 'Clear All Data',
                subtitle: 'Delete all inventory data',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Confirm Data Deletion'),
                        content: Text('Are you sure you want to delete all inventory data? This action cannot be undone.'),
                        backgroundColor: colors.surface,
                        titleTextStyle: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        contentTextStyle: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 16,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('Cancel', style: TextStyle(color: colors.textSecondary)),
                          ),
                          TextButton(
                            onPressed: () {
                              inventoryProvider.clearAll();
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('All data cleared'),
                                  backgroundColor: colors.error,
                                ),
                              );
                            },
                            child: Text('Delete', style: TextStyle(color: colors.error)),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
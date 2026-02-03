/// Settings screen for VibeEdit AI
/// App preferences, account, and configuration
library;

import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../../core/constants/constants.dart';

/// Settings screen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('Settings', style: AppTextStyles.titleLarge),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        children: [
          // Account Section
          _buildSectionHeader('Account'),
          _SettingsCard(
            children: [
              _buildSettingsTile(
                icon: Icons.person_outline_rounded,
                title: 'Profile',
                subtitle: 'Manage your account details',
                onTap: () {},
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.cloud_outlined,
                title: 'Cloud Storage',
                subtitle: '2.4 GB of 5 GB used',
                trailing: _buildStorageIndicator(0.48),
                onTap: () {},
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.workspace_premium_outlined,
                title: 'Subscription',
                subtitle: 'Free Plan',
                trailing: _buildBadge('Upgrade', AppColors.primary),
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing24),

          // Editor Settings
          _buildSectionHeader('Editor'),
          _SettingsCard(
            children: [
              _buildSettingsTile(
                icon: Icons.high_quality_outlined,
                title: 'Default Quality',
                subtitle: '1080p HD',
                onTap: () {},
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.aspect_ratio_outlined,
                title: 'Default Aspect Ratio',
                subtitle: '9:16 (Vertical)',
                onTap: () {},
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.auto_fix_high_outlined,
                title: 'Auto-enhance',
                subtitle: 'Automatically enhance video quality',
                value: true,
                onChanged: (v) {},
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.closed_caption_outlined,
                title: 'Auto-captions',
                subtitle: 'Generate captions automatically',
                value: false,
                onChanged: (v) {},
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing24),

          // Export Settings
          _buildSectionHeader('Export'),
          _SettingsCard(
            children: [
              _buildSettingsTile(
                icon: Icons.folder_outlined,
                title: 'Export Location',
                subtitle: 'Gallery / Camera Roll',
                onTap: () {},
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.branding_watermark_outlined,
                title: 'Watermark',
                subtitle: 'Add VibeEdit watermark (Free)',
                value: true,
                onChanged: (v) {},
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.speed_outlined,
                title: 'Export Speed',
                subtitle: 'Balanced',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing24),

          // AI Settings
          _buildSectionHeader('AI Features'),
          _SettingsCard(
            children: [
              _buildSwitchTile(
                icon: Icons.smart_toy_outlined,
                title: 'AI Copilot',
                subtitle: 'Enable AI assistant',
                value: true,
                onChanged: (v) {},
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.language_outlined,
                title: 'AI Language',
                subtitle: 'English (US)',
                onTap: () {},
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.music_note_outlined,
                title: 'Music Suggestions',
                subtitle: 'Based on video content',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing24),

          // App Settings
          _buildSectionHeader('App'),
          _SettingsCard(
            children: [
              _buildSettingsTile(
                icon: Icons.palette_outlined,
                title: 'Appearance',
                subtitle: 'Dark Mode',
                onTap: () {},
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Manage alerts',
                onTap: () {},
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.storage_outlined,
                title: 'Storage & Cache',
                subtitle: '1.2 GB cached',
                trailing: TextButton(
                  onPressed: () {},
                  child: Text(
                    'Clear',
                    style: TextStyle(color: AppColors.error, fontSize: 12),
                  ),
                ),
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing24),

          // About & Support
          _buildSectionHeader('About'),
          _SettingsCard(
            children: [
              _buildSettingsTile(
                icon: Icons.help_outline_rounded,
                title: 'Help Center',
                subtitle: 'FAQs and tutorials',
                onTap: () {},
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.feedback_outlined,
                title: 'Send Feedback',
                subtitle: 'Report bugs or suggest features',
                onTap: () {},
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.star_outline_rounded,
                title: 'Rate App',
                subtitle: 'Love VibeEdit? Leave a review!',
                onTap: () {},
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.info_outline_rounded,
                title: 'About',
                subtitle: 'Version 1.0.0',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing32),

          // Logout
          Center(
            child: TextButton(
              onPressed: () {},
              child: Text(
                'Log Out',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spacing32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSizes.spacing4,
        bottom: AppSizes.spacing12,
      ),
      child: Text(
        title,
        style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.textTertiary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacing16,
        vertical: AppSizes.spacing4,
      ),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 20),
      ),
      title: Text(title, style: AppTextStyles.bodyMedium),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
      ),
      trailing:
          trailing ??
          Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacing16,
        vertical: AppSizes.spacing4,
      ),
      secondary: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 20),
      ),
      title: Text(title, style: AppTextStyles.bodyMedium),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: AppColors.cardBorder, indent: 72);
  }

  Widget _buildStorageIndicator(double progress) {
    return SizedBox(
      width: 60,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.surfaceLight,
            valueColor: AlwaysStoppedAnimation(
              progress > 0.8 ? AppColors.error : AppColors.primary,
            ),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
          const SizedBox(height: 4),
          Text(
            '${(progress * 100).toInt()}%',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Settings card container
class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(children: children),
    );
  }
}

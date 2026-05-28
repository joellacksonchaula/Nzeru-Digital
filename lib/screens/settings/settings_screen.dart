import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../models/user_settings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/savings_provider.dart';
import '../../providers/theme_mode_provider.dart';
import '../../widgets/dashboard_kit.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _paymentMethodsController;
  late final TextEditingController _feedbackController;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _paymentMethodsController = TextEditingController();
    _feedbackController = TextEditingController();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = context.read<AuthProvider>().settings;
    _paymentMethodsController.text = settings.paymentMethods.join(', ');
    _feedbackController.text = settings.appFeedback;
  }

  @override
  void dispose() {
    _paymentMethodsController.dispose();
    _feedbackController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings(UserSettings settings) async {
    final auth = context.read<AuthProvider>();
    final success = await auth.updateSettings(settings);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Settings updated.'
              : (auth.error ?? 'Failed to update settings.'),
        ),
      ),
    );
  }

  Future<void> _openChangePasswordDialog() async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    final auth = context.read<AuthProvider>();

    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Change Password',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create a strong password to protect your account',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkTextMuted
                        : AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: currentController,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newController,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: () async {
                        if (newController.text != confirmController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Passwords do not match'),
                            ),
                          );
                          return;
                        }
                        final success = await auth.changePassword(
                          currentPassword: currentController.text,
                          newPassword: newController.text,
                        );
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? 'Password updated successfully.'
                                  : (auth.error ??
                                      'Password update failed.'),
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Update Password',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final savings = context.watch<SavingsProvider>();
    final themeMode = context.watch<ThemeModeProvider>();
    final settings = auth.settings;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Section
              _SettingsSectionCard(
                isDarkMode: isDarkMode,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(
                      icon: Icons.person_outline,
                      title: 'Profile & Personal Info',
                    ),
                    const Divider(height: 20),
                    _SettingsInfoRow(
                      label: 'Full Name',
                      value: auth.user?.name ?? '--',
                    ),
                    const SizedBox(height: 12),
                    _SettingsInfoRow(
                      label: 'Email',
                      value: auth.user?.email ?? '--',
                    ),
                    const SizedBox(height: 12),
                    _SettingsInfoRow(
                      label: 'Phone',
                      value: auth.user?.phone.isNotEmpty == true
                          ? auth.user!.phone
                          : '--',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Security & Authentication
              _SettingsSectionCard(
                isDarkMode: isDarkMode,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(
                      icon: Icons.security_outlined,
                      title: 'Security & Authentication',
                    ),
                    const Divider(height: 20),
                    _SettingsTile(
                      title: 'Change Password',
                      subtitle: 'Update your password securely',
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _openChangePasswordDialog,
                    ),
                    const SizedBox(height: 12),
                    _SettingsToggleTile(
                      title: 'Two-Factor Authentication',
                      subtitle: 'Add extra security to your account',
                      value: settings.twoFactorEnabled,
                      onChanged: (value) => _saveSettings(
                        settings.copyWith(twoFactorEnabled: value),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SettingsToggleTile(
                      title: 'Biometric Login',
                      subtitle: 'Use fingerprint or face recognition',
                      value: settings.biometricLoginEnabled,
                      onChanged: (value) => _saveSettings(
                        settings.copyWith(biometricLoginEnabled: value),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Notifications
              _SettingsSectionCard(
                isDarkMode: isDarkMode,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                    ),
                    const Divider(height: 20),
                    _SettingsToggleTile(
                      title: 'All Notifications',
                      subtitle: 'Enable or disable all notifications',
                      value: settings.notificationsEnabled,
                      onChanged: (value) => _saveSettings(
                        settings.copyWith(notificationsEnabled: value),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SettingsToggleTile(
                      title: 'Transaction Alerts',
                      subtitle: 'Get notified about every transaction',
                      value: settings.transactionAlerts,
                      onChanged: (value) => _saveSettings(
                        settings.copyWith(transactionAlerts: value),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Savings Preferences
              _SettingsSectionCard(
                isDarkMode: isDarkMode,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(
                      icon: Icons.savings_outlined,
                      title: 'Savings Preferences',
                    ),
                    const Divider(height: 20),
                    _SettingsToggleTile(
                      title: 'Auto-Save Enabled',
                      subtitle: 'Automatically save on your schedule',
                      value: settings.autoSaveEnabled,
                      onChanged: (value) => _saveSettings(
                        settings.copyWith(autoSaveEnabled: value),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Withdrawal Rules
              _SettingsSectionCard(
                isDarkMode: isDarkMode,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(
                      icon: Icons.lock_outline,
                      title: 'Withdrawal Rules',
                    ),
                    const Divider(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Credit Usage',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isDarkMode
                                    ? AppColors.darkBorder
                                    : AppColors.border,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: DropdownButton<String>(
                              isExpanded: true,
                              underline: const SizedBox(),
                              value: settings.creditUsagePreference,
                              items: const [
                                DropdownMenuItem(
                                  value: 'flexible',
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Text('Flexible'),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'instant',
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Text('All at Once'),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'daily_locked',
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Text('Daily Cashout'),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'weekly_locked',
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Text('Weekly Cashout'),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  _saveSettings(
                                    settings.copyWith(
                                      creditUsagePreference: value,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Appearance
              _SettingsSectionCard(
                isDarkMode: isDarkMode,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(
                      icon: Icons.palette_outlined,
                      title: 'Appearance',
                    ),
                    const Divider(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Theme',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _ThemeButton(
                                  icon: Icons.light_mode_outlined,
                                  label: 'Light',
                                  isSelected: !themeMode.isDarkMode,
                                  onTap: () {
                                    themeMode.setDarkMode(false);
                                    _saveSettings(
                                      settings.copyWith(
                                        preferredTheme: 'light',
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _ThemeButton(
                                  icon: Icons.dark_mode_outlined,
                                  label: 'Dark',
                                  isSelected: themeMode.isDarkMode,
                                  onTap: () {
                                    themeMode.setDarkMode(true);
                                    _saveSettings(
                                      settings.copyWith(preferredTheme: 'dark'),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Language
              _SettingsSectionCard(
                isDarkMode: isDarkMode,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(
                      icon: Icons.language_outlined,
                      title: 'Language & Region',
                    ),
                    const Divider(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Language',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isDarkMode
                                    ? AppColors.darkBorder
                                    : AppColors.border,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: DropdownButton<String>(
                              isExpanded: true,
                              underline: const SizedBox(),
                              value: settings.preferredLanguage,
                              items: const [
                                DropdownMenuItem(
                                  value: 'en',
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Text('English'),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'ny',
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Text('Chichewa'),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'sw',
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Text('Swahili'),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  _saveSettings(
                                    settings.copyWith(preferredLanguage: value),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Help & Support
              _SettingsSectionCard(
                isDarkMode: isDarkMode,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                    ),
                    const Divider(height: 20),
                    _SettingsInfoRow(
                      label: 'Contact Support',
                      value: '+265 992 579 666',
                    ),
                    const SizedBox(height: 12),
                    _SettingsInfoRow(
                      label: 'Email',
                      value: 'ndegejoel2000@gmail.com',
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Send Feedback',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _feedbackController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText:
                            'Tell us what we can improve...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => _saveSettings(
                          settings.copyWith(
                            appFeedback:
                                _feedbackController.text.trim(),
                          ),
                        ),
                        child: Text(
                          'Submit Feedback',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Privacy & Terms
              _SettingsSectionCard(
                isDarkMode: isDarkMode,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy & Terms',
                    ),
                    const Divider(height: 20),
                    _SettingsTile(
                      title: 'Privacy Policy',
                      trailing: const Icon(Icons.open_in_new),
                      onTap: () {},
                    ),
                    const SizedBox(height: 10),
                    _SettingsTile(
                      title: 'Terms of Service',
                      trailing: const Icon(Icons.open_in_new),
                      onTap: () {},
                    ),
                    const SizedBox(height: 10),
                    _SettingsTile(
                      title: 'Community Guidelines',
                      trailing: const Icon(Icons.open_in_new),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────── Settings UI Components ──────────────────

class _SettingsSectionCard extends StatelessWidget {
  final Widget child;
  final bool isDarkMode;

  const _SettingsSectionCard({
    required this.child,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDarkMode ? AppColors.darkBorder : AppColors.border,
          width: 1,
        ),
        gradient: LinearGradient(
          colors: [
            isDarkMode ? AppColors.darkCardBg : AppColors.cardSurface,
            isDarkMode ? AppColors.darkSurfaceAlt : AppColors.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.abyssalTeal.withAlpha(20),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppColors.abyssalTeal,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

class _SettingsInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _SettingsInfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? AppColors.darkTextMuted : AppColors.textMuted,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: isDarkMode
                            ? AppColors.darkTextMuted
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 12),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

class _SettingsToggleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsToggleTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color:
                      isDarkMode ? AppColors.darkTextMuted : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.abyssalTeal,
          inactiveThumbColor: isDarkMode
              ? AppColors.darkTextMuted
              : AppColors.textMuted,
        ),
      ],
    );
  }
}

class _ThemeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.abyssalTeal
                : (isDarkMode ? AppColors.darkBorder : AppColors.border),
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? AppColors.abyssalTeal.withAlpha(20)
              : (isDarkMode ? AppColors.darkSurfaceAlt : Colors.transparent),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.abyssalTeal : AppColors.textMuted,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.abyssalTeal : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

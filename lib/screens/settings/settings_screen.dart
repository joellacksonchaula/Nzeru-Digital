import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _paymentMethodsController;
  late final TextEditingController _feedbackController;

  @override
  void initState() {
    super.initState();
    _paymentMethodsController = TextEditingController();
    _feedbackController = TextEditingController();
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
    super.dispose();
  }

  Future<void> _saveSettings(UserSettings settings) async {
    final auth = context.read<AuthProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final success = await auth.updateSettings(settings);
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(success ? 'Settings updated.' : (auth.error ?? 'Failed to update settings.')),
      ),
    );
  }

  Future<void> _openChangePasswordDialog() async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final auth = context.read<AuthProvider>();
    final messenger = ScaffoldMessenger.of(context);

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentController,
              decoration: const InputDecoration(labelText: 'Current password'),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newController,
              decoration: const InputDecoration(labelText: 'New password'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final success = await auth.changePassword(
                currentPassword: currentController.text,
                newPassword: newController.text,
              );
              if (!context.mounted) return;
              Navigator.pop(context);
              messenger.showSnackBar(
                SnackBar(
                  content: Text(success ? 'Password updated.' : (auth.error ?? 'Password update failed.')),
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final savings = context.watch<SavingsProvider>();
    final themeMode = context.watch<ThemeModeProvider>();
    final settings = auth.settings;
    final plans = savings.plans;

    return DashboardPage(
      eyebrow: 'Nzelu Settings',
      title: 'Settings & Security',
      subtitle: 'Manage account security, app preferences, financial defaults, support, and engagement tools from one live settings page.',
      children: [
        _SettingsSection(
          title: 'Account & Security',
          children: [
            _InfoRow(label: 'Profile', value: auth.user?.name ?? '--'),
            _InfoRow(label: 'Email', value: auth.user?.email ?? '--'),
            _InfoRow(label: 'Phone', value: auth.user?.phone.isNotEmpty == true ? auth.user!.phone : '--'),
            _ActionRow(
              label: 'Change password',
              detail: 'Update your password securely',
              onTap: _openChangePasswordDialog,
            ),
            SwitchListTile.adaptive(
              value: settings.twoFactorEnabled,
              onChanged: (value) => _saveSettings(settings.copyWith(twoFactorEnabled: value)),
              title: const Text('Two-factor authentication'),
            ),
            SwitchListTile.adaptive(
              value: settings.biometricLoginEnabled,
              onChanged: (value) => _saveSettings(settings.copyWith(biometricLoginEnabled: value)),
              title: const Text('Biometric login'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SettingsSection(
          title: 'App Preferences',
          children: [
            SwitchListTile.adaptive(
              value: themeMode.isDarkMode,
              onChanged: (value) {
                themeMode.setDarkMode(value);
                _saveSettings(settings.copyWith(preferredTheme: value ? 'dark' : 'light'));
              },
              title: const Text('Dark theme'),
            ),
            _DropdownRow<String>(
              label: 'Language',
              value: settings.preferredLanguage,
              items: const ['en', 'ny', 'sw'],
              onChanged: (value) => _saveSettings(settings.copyWith(preferredLanguage: value)),
            ),
            _DropdownRow<String>(
              label: 'Currency',
              value: settings.preferredCurrency,
              items: const ['MWK', 'USD', 'ZAR'],
              onChanged: (value) => _saveSettings(settings.copyWith(preferredCurrency: value)),
            ),
            SwitchListTile.adaptive(
              value: settings.notificationsEnabled,
              onChanged: (value) => _saveSettings(settings.copyWith(notificationsEnabled: value)),
              title: const Text('Notifications'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SettingsSection(
          title: 'Financial Settings',
          children: [
            _DropdownRow<String?>(
              label: 'Default savings plan',
              value: settings.defaultSavingsPlanId,
              items: [
                null,
                ...plans.map((plan) => plan.id),
              ],
              itemLabel: (value) {
                if (value == null) return 'No default';
                final plan = plans.firstWhere((item) => item.id == value);
                return plan.isTrial ? '${plan.title} (Trial)' : plan.title;
              },
              onChanged: (value) => _saveSettings(settings.copyWith(defaultSavingsPlanId: value)),
            ),
            SwitchListTile.adaptive(
              value: settings.autoSaveEnabled,
              onChanged: (value) => _saveSettings(settings.copyWith(autoSaveEnabled: value)),
              title: const Text('Auto-save'),
            ),
            _DropdownRow<String>(
              label: 'Credit usage',
              value: settings.creditUsagePreference,
              items: const ['flexible', 'instant', 'daily_locked', 'weekly_locked'],
              onChanged: (value) => _saveSettings(settings.copyWith(creditUsagePreference: value)),
            ),
            SwitchListTile.adaptive(
              value: settings.transactionAlerts,
              onChanged: (value) => _saveSettings(settings.copyWith(transactionAlerts: value)),
              title: const Text('Transaction alerts'),
            ),
            TextField(
              controller: _paymentMethodsController,
              decoration: const InputDecoration(
                labelText: 'Payment methods',
                hintText: 'Bank transfer, Mobile money',
              ),
            ),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: () => _saveSettings(
                settings.copyWith(
                  paymentMethods: _paymentMethodsController.text
                      .split(',')
                      .map((item) => item.trim())
                      .where((item) => item.isNotEmpty)
                      .toList(),
                ),
              ),
              child: const Text('Save payment methods'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SettingsSection(
          title: 'Help & Support',
          children: const [
            _InfoRow(label: 'FAQs', value: 'Savings, credit, security, and trial mode guidance'),
            _InfoRow(label: 'Contact support', value: '+265 992 579 666'),
            _InfoRow(label: 'Support email', value: 'ndegejoel2000@gmail.com'),
            _InfoRow(label: 'Report an issue', value: 'Use the feedback box below'),
          ],
        ),
        const SizedBox(height: 16),
        _SettingsSection(
          title: 'App & Engagement',
          children: [
            const _InfoRow(label: 'About', value: 'Nzelu digital savings and credit vault'),
            const _InfoRow(label: 'Share app', value: 'Invite your team to test live savings and trial credit'),
            const _InfoRow(label: 'Rate app', value: 'Capture tester feedback after each build'),
            const _InfoRow(label: 'Changelog', value: 'Credit mode, trial plan, real dashboard data'),
            TextField(
              controller: _feedbackController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Feedback',
                hintText: 'Tell us what should improve next.',
              ),
            ),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: () => _saveSettings(settings.copyWith(appFeedback: _feedbackController.text.trim())),
              child: const Text('Save feedback'),
            ),
          ],
        ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.oswald(
              fontSize: 22,
              color: const Color(0xFF171412),
            ),
          ),
          const SizedBox(height: 12),
          ...children.expand((child) => [child, const SizedBox(height: 10)]).toList()..removeLast(),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6F665C)),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.oswald(fontSize: 16, color: const Color(0xFF171412)),
          ),
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  final String label;
  final String detail;
  final VoidCallback onTap;

  const _ActionRow({
    required this.label,
    required this.detail,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withValues(alpha: 0.75),
          border: Border.all(color: const Color(0xFFE6DAC7)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: GoogleFonts.oswald(fontSize: 18, color: const Color(0xFF171412))),
                  Text(detail, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6F665C))),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class _DropdownRow<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T?> items;
  final String Function(T value)? itemLabel;
  final ValueChanged<T?> onChanged;

  const _DropdownRow({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.itemLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6F665C)),
          ),
        ),
        Expanded(
          child: DropdownButtonFormField<T>(
            value: value,
            items: items
                .map(
                  (item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(
                      item == null ? 'None' : (itemLabel?.call(item as T) ?? item.toString()),
                    ),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

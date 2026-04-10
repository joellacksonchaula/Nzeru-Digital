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
    final auth = context.read<AuthProvider>();

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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'Password updated.'
                        : (auth.error ?? 'Password update failed.'),
                  ),
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
      eyebrow: 'Settings',
      title: 'Settings',
      subtitle: '',
      children: [
        DashboardPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GroupTitle(label: 'Account'),
              _InfoRow(label: 'Name', value: auth.user?.name ?? '--'),
              _InfoRow(label: 'Email', value: auth.user?.email ?? '--'),
              _InfoRow(
                label: 'Phone',
                value: auth.user?.phone.isNotEmpty == true
                    ? auth.user!.phone
                    : '--',
              ),
              const SizedBox(height: 10),
              _ActionTile(
                label: 'Change password',
                detail: 'Update your password securely',
                onTap: _openChangePasswordDialog,
              ),
              const SizedBox(height: 18),
              _GroupTitle(label: 'App preferences'),
              SwitchListTile.adaptive(
                value: themeMode.isDarkMode,
                onChanged: (value) {
                  themeMode.setDarkMode(value);
                  _saveSettings(
                    settings.copyWith(preferredTheme: value ? 'dark' : 'light'),
                  );
                },
                title: const Text('Dark theme'),
              ),
              _DropdownRow<String>(
                label: 'Language',
                value: settings.preferredLanguage,
                items: const ['en', 'ny', 'sw'],
                onChanged: (value) =>
                    _saveSettings(settings.copyWith(preferredLanguage: value)),
              ),
              _DropdownRow<String>(
                label: 'Currency',
                value: settings.preferredCurrency,
                items: const ['MWK', 'USD', 'ZAR'],
                onChanged: (value) =>
                    _saveSettings(settings.copyWith(preferredCurrency: value)),
              ),
              SwitchListTile.adaptive(
                value: settings.notificationsEnabled,
                onChanged: (value) => _saveSettings(
                  settings.copyWith(notificationsEnabled: value),
                ),
                title: const Text('Notifications'),
              ),
              SwitchListTile.adaptive(
                value: settings.transactionAlerts,
                onChanged: (value) =>
                    _saveSettings(settings.copyWith(transactionAlerts: value)),
                title: const Text('Transaction alerts'),
              ),
              const SizedBox(height: 18),
              _GroupTitle(label: 'Savings & credit'),
              _DropdownRow<String?>(
                label: 'Default savings plan',
                value: settings.defaultSavingsPlanId,
                items: [null, ...plans.map((plan) => plan.id)],
                itemLabel: (value) {
                  if (value == null) return 'No default';
                  final plan = plans.firstWhere((item) => item.id == value);
                  return plan.title;
                },
                onChanged: (value) => _saveSettings(
                  settings.copyWith(defaultSavingsPlanId: value),
                ),
              ),
              SwitchListTile.adaptive(
                value: settings.autoSaveEnabled,
                onChanged: (value) =>
                    _saveSettings(settings.copyWith(autoSaveEnabled: value)),
                title: const Text('Auto-save'),
              ),
              _DropdownRow<String>(
                label: 'Credit usage',
                value: settings.creditUsagePreference,
                items: const [
                  'flexible',
                  'instant',
                  'daily_locked',
                  'weekly_locked',
                ],
                itemLabel: (value) => _creditUsageLabel(value),
                onChanged: (value) => _saveSettings(
                  settings.copyWith(creditUsagePreference: value),
                ),
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
              const SizedBox(height: 18),
              _GroupTitle(label: 'Security'),
              SwitchListTile.adaptive(
                value: settings.twoFactorEnabled,
                onChanged: (value) =>
                    _saveSettings(settings.copyWith(twoFactorEnabled: value)),
                title: const Text('Two-factor authentication'),
              ),
              SwitchListTile.adaptive(
                value: settings.biometricLoginEnabled,
                onChanged: (value) => _saveSettings(
                  settings.copyWith(biometricLoginEnabled: value),
                ),
                title: const Text('Biometric login'),
              ),
              const SizedBox(height: 18),
              _GroupTitle(label: 'Support'),
              const _InfoRow(
                label: 'Contact support',
                value: '+265 992 579 666',
              ),
              const _InfoRow(
                label: 'Support email',
                value: 'ndegejoel2000@gmail.com',
              ),
              const SizedBox(height: 12),
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
                onPressed: () => _saveSettings(
                  settings.copyWith(
                    appFeedback: _feedbackController.text.trim(),
                  ),
                ),
                child: const Text('Save feedback'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _creditUsageLabel(String value) {
    switch (value) {
      case 'instant':
        return 'All at once';
      case 'daily_locked':
        return 'Daily cashout';
      case 'weekly_locked':
        return 'Weekly cashout';
      default:
        return 'Flexible';
    }
  }
}

class _GroupTitle extends StatelessWidget {
  final String label;

  const _GroupTitle({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: GoogleFonts.sora(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF171412),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: const Color(0xFF6F665C),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.sora(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF171412),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String label;
  final String detail;
  final VoidCallback onTap;

  const _ActionTile({
    required this.label,
    required this.detail,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE6DAC7)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.sora(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF171412),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    detail,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: const Color(0xFF6F665C),
                    ),
                  ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: const Color(0xFF6F665C),
              ),
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
                        item == null
                            ? 'None'
                            : (itemLabel?.call(item as T) ?? item.toString()),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

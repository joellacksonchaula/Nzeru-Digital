import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/app_routes.dart';
import '../../models/savings_plan.dart';
import '../../providers/finance_overview_provider.dart';
import '../../utils/currency_util.dart';
import '../../widgets/dashboard_kit.dart';
import 'create_plan_screen.dart';

class SavingsPlansScreen extends StatelessWidget {
  const SavingsPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceOverviewProvider>();
    final plans = finance.prioritizedPlans;
    final userName = _firstName(finance.user?.name);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF091018) : const Color(0xFFF7F4EC),
      body: Stack(
        children: [
          DashboardBackdrop(darkMode: isDark),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SavingsHeader(
                    name: userName,
                    darkMode: isDark,
                    onCreatePlan: () =>
                        Navigator.pushNamed(context, AppRoutes.createPlan),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    'Your Savings',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF111111),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 3,
                    width: 118,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: LinearGradient(
                        colors: isDark
                            ? const [Color(0xFFE7C768), Color(0x6673C7A3)]
                            : const [Color(0xFFCAA13B), Color(0x66CFE5D7)],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.createPlan),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFE0B449),
                        foregroundColor: const Color(0xFF3E2F0D),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: Text(
                        'New Plan',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (plans.isEmpty)
                    const _EmptySavingsState()
                  else
                    ...plans.map(
                      (plan) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _SavingsListCard(plan: plan),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    'Plan Setup',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF111111),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 3,
                    width: 108,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: LinearGradient(
                        colors: isDark
                            ? const [Color(0xFFE7C768), Color(0x6673C7A3)]
                            : const [Color(0xFFCAA13B), Color(0x66CFE5D7)],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const SavingsPlanComposer(embedded: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavingsHeader extends StatelessWidget {
  final String name;
  final bool darkMode;
  final VoidCallback onCreatePlan;

  const _SavingsHeader({
    required this.name,
    required this.darkMode,
    required this.onCreatePlan,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.isEmpty ? 'U' : name[0].toUpperCase();

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: darkMode
            ? const Color(0xCC111A24)
            : Colors.white.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: darkMode
              ? const Color(0x335F6E80)
              : const Color(0xFFE3DACC),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: darkMode ? 0.18 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFFF5D7),
                      Color(0xFFF5E6AA),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFB88616),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: darkMode
                            ? const Color(0xFFD8E0EB)
                            : const Color(0xFF4E4A44),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 30,
                        height: 0.95,
                        fontWeight: FontWeight.w700,
                        color: darkMode ? Colors.white : const Color(0xFF111111),
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: onCreatePlan,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFE0B449),
                  foregroundColor: const Color(0xFF3E2F0D),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(
                  'Create Plan',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: LinearGradient(
                colors: darkMode
                    ? const [Color(0xFFE7C768), Color(0x6673C7A3)]
                    : const [Color(0xFFD0AE56), Color(0x66B6D5C4)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavingsListCard extends StatelessWidget {
  final SavingsPlan plan;

  const _SavingsListCard({
    required this.plan,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(plan.health);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xE61B2430)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? const Color(0x334D5B6C) : const Color(0xFFE8E0D3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F1E9),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  _planIcon(plan.title),
                  color: const Color(0xFF4A8B62),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _displayTitle(plan.title),
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        height: 0.96,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _saveLabel(plan),
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF3F7454),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF3EB),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _statusLabel(plan.health),
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    DateFormat('d MMM yyyy').format(plan.endDate),
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: isDark
                          ? const Color(0xFFD8E0EB)
                          : const Color(0xFF232323),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              SizedBox(
                width: 96,
                height: 96,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: plan.progressPercent,
                      strokeWidth: 8,
                      backgroundColor: const Color(0xFFEEE6DB),
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    ),
                    Center(
                      child: Text(
                        '${(plan.progressPercent * 100).round()}%',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF111111),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MetricLine(
                      label: 'Target',
                      value: CurrencyUtil.formatNoDecimal(plan.goalAmount),
                    ),
                    const SizedBox(height: 8),
                    _MetricLine(
                      label: 'Saved',
                      value: CurrencyUtil.formatNoDecimal(plan.currentAmount),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: plan.progressPercent,
                        minHeight: 10,
                        backgroundColor: const Color(0xFFEFE6DD),
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _RateBadge(
                          label:
                              'Month ${CurrencyUtil.formatNoDecimal(plan.requiredPerMonth)}',
                          background: const Color(0xFFF7E6BC),
                          color: const Color(0xFF9B7420),
                        ),
                        _RateBadge(
                          label:
                              'Week ${CurrencyUtil.formatNoDecimal(plan.requiredPerWeek)}',
                          background: const Color(0xFFE1F0E3),
                          color: const Color(0xFF437355),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static IconData _planIcon(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('phone')) return Icons.smartphone_rounded;
    if (lower.contains('vacation')) return Icons.flight_takeoff_rounded;
    if (lower.contains('go')) return Icons.work_outline_rounded;
    return Icons.savings_rounded;
  }

  static String _displayTitle(String title) {
    final trimmed = title.trim();
    return trimmed.isEmpty ? 'Savings Plan' : trimmed;
  }

  static String _saveLabel(SavingsPlan plan) {
    switch (plan.frequency) {
      case PlanFrequency.daily:
        return 'Save ${CurrencyUtil.formatNoDecimal(plan.requiredPerDay)} per day';
      case PlanFrequency.weekly:
      case PlanFrequency.biweekly:
        return 'Save ${CurrencyUtil.formatNoDecimal(plan.requiredPerWeek)} per week';
      case PlanFrequency.monthly:
        return 'Save ${CurrencyUtil.formatNoDecimal(plan.requiredPerMonth)} per month';
    }
  }

  static String _statusLabel(PlanHealth health) {
    switch (health) {
      case PlanHealth.onTrack:
        return 'On Track';
      case PlanHealth.watch:
        return 'Watch';
      case PlanHealth.behind:
        return 'Behind';
    }
  }

  static Color _statusColor(PlanHealth health) {
    switch (health) {
      case PlanHealth.onTrack:
        return const Color(0xFF4A8B62);
      case PlanHealth.watch:
        return const Color(0xFFB79242);
      case PlanHealth.behind:
        return const Color(0xFFD16C5E);
    }
  }
}

class _MetricLine extends StatelessWidget {
  final String label;
  final String value;

  const _MetricLine({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        SizedBox(
          width: 54,
          child: Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              color: isDark
                  ? const Color(0xFFBBC6D3)
                  : const Color(0xFF55504A),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF111111),
            ),
          ),
        ),
      ],
    );
  }
}

class _RateBadge extends StatelessWidget {
  final String label;
  final Color background;
  final Color color;

  const _RateBadge({
    required this.label,
    required this.background,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _EmptySavingsState extends StatelessWidget {
  const _EmptySavingsState();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xE61B2430) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? const Color(0x334D5B6C) : const Color(0xFFE8E0D3),
        ),
      ),
      child: Text(
        'No savings plans yet. Create your first one below.',
        style: GoogleFonts.montserrat(
          fontSize: 14,
          color: isDark ? const Color(0xFFD8E0EB) : const Color(0xFF55504A),
        ),
      ),
    );
  }
}

String _firstName(String? name) {
  final trimmed = (name ?? '').trim();
  if (trimmed.isEmpty) return 'User';
  return trimmed.split(' ').first;
}

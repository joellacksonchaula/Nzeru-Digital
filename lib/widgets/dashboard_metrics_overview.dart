import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';

/// Enhanced Dashboard Metrics Component
/// Displays:
/// - Total Savings Overview
/// - Locked Savings Summary
/// - Savings Goals Progress
/// - Active Plans Count
/// - Goal Completion Percentages
/// - Upcoming Contribution Reminders

class DashboardMetricsOverview extends StatelessWidget {
  final double totalSavings;
  final double lockedSavings;
  final double unlockedSavings;
  final int activePlansCount;
  final int goalsCompletedCount;
  final int totalGoalsCount;
  final DateTime? nextContributionDate;
  final String currency;

  const DashboardMetricsOverview({
    required this.totalSavings,
    required this.lockedSavings,
    required this.unlockedSavings,
    required this.activePlansCount,
    required this.goalsCompletedCount,
    required this.totalGoalsCount,
    this.nextContributionDate,
    this.currency = '₦',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Metrics Row
        _MetricCard(
          title: 'Total Savings',
          value: '$currency${totalSavings.toStringAsFixed(2)}',
          subtitle: '${unlockedSavings.toStringAsFixed(2)} available',
          icon: Icons.account_balance_wallet_outlined,
          backgroundColor: AppColors.abyssalTeal,
          isDarkMode: isDarkMode,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _CompactMetricCard(
                title: 'Locked Savings',
                value: '$currency${lockedSavings.toStringAsFixed(2)}',
                icon: Icons.lock_outlined,
                backgroundColor: AppColors.brightCrimson,
                isDarkMode: isDarkMode,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CompactMetricCard(
                title: 'Active Plans',
                value: '$activePlansCount',
                icon: Icons.trending_up_outlined,
                backgroundColor: AppColors.success,
                isDarkMode: isDarkMode,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _CompactMetricCard(
                title: 'Goals Progress',
                value: '$goalsCompletedCount/$totalGoalsCount',
                icon: Icons.flag_outlined,
                backgroundColor: AppColors.primaryRed,
                isDarkMode: isDarkMode,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CompactMetricCard(
                title: 'Completion',
                value: _calculateCompletion(),
                icon: Icons.check_circle_outline,
                backgroundColor: AppColors.info,
                isDarkMode: isDarkMode,
              ),
            ),
          ],
        ),
        if (nextContributionDate != null) ...[
          const SizedBox(height: 12),
          _UpcomingContributionCard(
            nextDate: nextContributionDate!,
            isDarkMode: isDarkMode,
          ),
        ],
      ],
    );
  }

  String _calculateCompletion() {
    if (totalGoalsCount == 0) return '0%';
    return '${((goalsCompletedCount / totalGoalsCount) * 100).toStringAsFixed(0)}%';
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color backgroundColor;
  final bool isDarkMode;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.backgroundColor,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: backgroundColor.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: backgroundColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode
                        ? AppColors.darkTextMuted
                        : AppColors.textMuted,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: backgroundColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: isDarkMode
                        ? AppColors.darkTextMuted
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color backgroundColor;
  final bool isDarkMode;

  const _CompactMetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.backgroundColor,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: backgroundColor.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: backgroundColor,
              size: 18,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDarkMode
                  ? AppColors.darkTextMuted
                  : AppColors.textMuted,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: backgroundColor,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingContributionCard extends StatelessWidget {
  final DateTime nextDate;
  final bool isDarkMode;

  const _UpcomingContributionCard({
    required this.nextDate,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final daysUntil = nextDate.difference(DateTime.now()).inDays;
    final isToday = daysUntil == 0;
    final isTomorrow = daysUntil == 1;

    String dateText;
    if (isToday) {
      dateText = 'Today';
    } else if (isTomorrow) {
      dateText = 'Tomorrow';
    } else {
      dateText = 'In $daysUntil days';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.warning.withAlpha(40),
          width: 1.5,
        ),
        gradient: LinearGradient(
          colors: [
            AppColors.warning.withAlpha(15),
            AppColors.warning.withAlpha(8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.warning.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.calendar_today_outlined,
              color: AppColors.warning,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upcoming Contribution',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode
                        ? AppColors.darkTextMuted
                        : AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateText,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
          if (isToday)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Due',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Motivational Message Component
class MotivationalMessageWidget extends StatelessWidget {
  final int savingsStreak;
  final int totalPlans;
  final double totalSavings;
  final DateTime? lastContributionDate;

  const MotivationalMessageWidget({
    required this.savingsStreak,
    required this.totalPlans,
    required this.totalSavings,
    this.lastContributionDate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = false;
    final message = _generateMotivationalMessage();
    final icon = _getMotivationIcon();
    final color = _getMotivationColor();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withAlpha(40),
          width: 1.5,
        ),
        gradient: LinearGradient(
          colors: [
            color.withAlpha(15),
            color.withAlpha(8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Savings Motivation',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode
                        ? AppColors.darkTextMuted
                        : AppColors.textMuted,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _generateMotivationalMessage() {
    if (savingsStreak >= 30) {
      return '🔥 Amazing! $savingsStreak day streak! Keep it up!';
    } else if (savingsStreak >= 7) {
      return '✨ Great progress! $savingsStreak days saved!';
    } else if (savingsStreak > 0) {
      return "💪 You're off to a great start! $savingsStreak day(s) in!";
    } else if (totalPlans > 0) {
      return '🎯 Ready to start? Make your first contribution today!';
    } else {
      return '🚀 Time to create your first savings plan!';
    }
  }

  IconData _getMotivationIcon() {
    if (savingsStreak >= 30) {
      return Icons.local_fire_department_rounded;
    } else if (savingsStreak >= 7) {
      return Icons.star_rounded;
    } else if (savingsStreak > 0) {
      return Icons.trending_up_rounded;
    } else if (totalPlans > 0) {
      return Icons.lightbulb_outline_rounded;
    } else {
      return Icons.rocket_launch_rounded;
    }
  }

  Color _getMotivationColor() {
    if (savingsStreak >= 30) {
      return AppColors.brightCrimson;
    } else if (savingsStreak >= 7) {
      return AppColors.primaryRed;
    } else if (savingsStreak > 0) {
      return AppColors.success;
    } else if (totalPlans > 0) {
      return AppColors.info;
    } else {
      return AppColors.abyssalTeal;
    }
  }
}

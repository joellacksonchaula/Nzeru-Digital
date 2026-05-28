import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';
import '../models/savings_plan.dart';
import 'withdrawal_lock_card.dart';

/// Enhanced Savings Plan Card with Withdrawal Lock Indicator
/// Shows the plan details along with lock status and countdown timer

class EnhancedSavingsPlanCard extends StatelessWidget {
  final SavingsPlan plan;
  final bool hasActiveDebt;
  final double currentAmount;
  final String currency;
  final VoidCallback? onTap;
  final VoidCallback? onWithdraw;

  const EnhancedSavingsPlanCard({
    required this.plan,
    this.hasActiveDebt = false,
    this.currentAmount = 0,
    this.currency = '₦',
    this.onTap,
    this.onWithdraw,
    super.key,
  });

  bool get isMaturityDateReached => DateTime.now().isAfter(plan.endDate);
  bool get isLocked => !isMaturityDateReached;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // Main Plan Card
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDarkMode ? AppColors.darkBorder : AppColors.borderLight,
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isDarkMode ? 30 : 8),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Plan Title and Lock Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.title,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isDarkMode
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${plan.frequency.name.capitalize} • ${plan.durationMonths}mo',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDarkMode
                                  ? AppColors.darkTextMuted
                                  : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Lock Badge
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isLocked
                            ? AppColors.brightCrimson.withAlpha(20)
                            : AppColors.success.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
                        color: isLocked ? AppColors.brightCrimson : AppColors.success,
                        size: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Amount and Progress
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode
                                ? AppColors.darkTextMuted
                                : AppColors.textMuted,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$currency${currentAmount.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.abyssalTeal,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Goal',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode
                                ? AppColors.darkTextMuted
                                : AppColors.textMuted,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$currency${plan.goalAmount.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDarkMode
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: plan.progressPercent,
                    minHeight: 6,
                    backgroundColor:
                        isDarkMode ? AppColors.darkBorder : AppColors.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.abyssalTeal,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${(plan.progressPercent * 100).toStringAsFixed(0)}% Complete',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.abyssalTeal,
                  ),
                ),
              ],
            ),
          ),
          // Lock Status Overlay Badge
          if (isLocked)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.brightCrimson,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'LOCKED',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Plan Lock Details Bottom Sheet
class PlanLockDetailsSheet extends StatelessWidget {
  final SavingsPlan plan;
  final bool hasActiveDebt;
  final String currency;

  const PlanLockDetailsSheet({
    required this.plan,
    this.hasActiveDebt = false,
    this.currency = '₦',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isMaturityReached = DateTime.now().isAfter(plan.endDate);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          24,
          16,
          24 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? AppColors.darkBorder
                      : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Withdrawal Details',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 20),
            // Lock Card
            WithdrawalLockCard(
              maturityDate: plan.endDate,
              createdDate: plan.startDate,
              isLocked: !isMaturityReached,
              hasActiveDebt: hasActiveDebt,
            ),
            const SizedBox(height: 20),
            // Information Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plan Information',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                _InformationRow(
                  label: 'Start Date',
                  value: _formatDate(plan.startDate),
                  isDarkMode: isDarkMode,
                ),
                _InformationRow(
                  label: 'Maturity Date',
                  value: _formatDate(plan.endDate),
                  isDarkMode: isDarkMode,
                ),
                _InformationRow(
                  label: 'Duration',
                  value: '${plan.durationMonths} months',
                  isDarkMode: isDarkMode,
                ),
                _InformationRow(
                  label: 'Current Amount',
                  value: '$currency${plan.currentAmount.toStringAsFixed(2)}',
                  isDarkMode: isDarkMode,
                  valueColor: AppColors.abyssalTeal,
                ),
                _InformationRow(
                  label: 'Target Amount',
                  value: '$currency${plan.goalAmount.toStringAsFixed(2)}',
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Rules Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withAlpha(15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.info.withAlpha(40),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.info,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Withdrawal Rules',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '• Withdrawals are only allowed after the maturity date\n'
                    '• Early withdrawal is strictly prohibited\n'
                    '• Active debt prevents withdrawals\n'
                    '• All amounts are in ${currency.replaceAll('₦', 'Naira')}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.6,
                      color: isDarkMode
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Action Button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isMaturityReached && !hasActiveDebt
                    ? () => Navigator.pop(context)
                    : null,
                child: Text(
                  isMaturityReached
                      ? 'Ready to Withdraw'
                      : 'Savings Locked',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_monthName(date.month)} ${date.year}';
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}

class _InformationRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDarkMode;
  final Color? valueColor;

  const _InformationRow({
    required this.label,
    required this.value,
    required this.isDarkMode,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDarkMode
                  ? AppColors.darkTextMuted
                  : AppColors.textMuted,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: valueColor ??
                  (isDarkMode
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

extension on PlanFrequency {
  String get capitalize {
    return name.replaceFirst(name[0], name[0].toUpperCase());
  }
}

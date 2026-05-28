import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../config/app_colors.dart';

class WithdrawalLockCard extends StatefulWidget {
  final DateTime maturityDate;
  final DateTime createdDate;
  final bool isLocked;
  final bool hasActiveDebt;
  final VoidCallback? onUnlocked;
  final double? width;

  const WithdrawalLockCard({
    required this.maturityDate,
    required this.createdDate,
    this.isLocked = true,
    this.hasActiveDebt = false,
    this.onUnlocked,
    this.width,
    super.key,
  });

  @override
  State<WithdrawalLockCard> createState() => _WithdrawalLockCardState();
}

class _WithdrawalLockCardState extends State<WithdrawalLockCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(WithdrawalLockCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isLocked && oldWidget.isLocked) {
      widget.onUnlocked?.call();
      _animationController.stop();
    }
  }

  Duration _calculateRemainingTime() {
    return widget.maturityDate.difference(DateTime.now());
  }

  String _formatRemainingTime(Duration remaining) {
    if (remaining.isNegative) {
      return 'Available for withdrawal';
    }
    final days = remaining.inDays;
    final hours = remaining.inHours % 24;
    final minutes = remaining.inMinutes % 60;
    return '$days days, $hours hours';
  }

  int _calculateProgressPercentage() {
    final totalDuration =
        widget.maturityDate.difference(widget.createdDate).inDays;
    final elapsedDuration =
        DateTime.now().difference(widget.createdDate).inDays;
    if (totalDuration <= 0) return 100;
    return ((elapsedDuration / totalDuration) * 100).toInt().clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final remaining = _calculateRemainingTime();
    final isTimeUp = remaining.isNegative;
    final progressPercent = _calculateProgressPercentage();

    return Container(
      width: widget.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTimeUp
              ? AppColors.success
              : (widget.hasActiveDebt ? AppColors.brightCrimson : AppColors.abyssalTeal),
          width: 1.5,
        ),
        gradient: LinearGradient(
          colors: [
            (isDarkMode ? AppColors.darkCardBg : AppColors.cardSurface),
            (isDarkMode ? AppColors.darkSurfaceAlt : AppColors.surface),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (isTimeUp ? AppColors.success : AppColors.abyssalTeal)
                .withAlpha(20),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lock Status Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isTimeUp
                        ? AppColors.success.withAlpha(20)
                        : (widget.hasActiveDebt
                            ? AppColors.brightCrimson.withAlpha(20)
                            : AppColors.abyssalTeal.withAlpha(20)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isTimeUp
                        ? Icons.lock_open_rounded
                        : (widget.hasActiveDebt
                            ? Icons.warning_rounded
                            : Icons.lock_rounded),
                    color: isTimeUp
                        ? AppColors.success
                        : (widget.hasActiveDebt
                            ? AppColors.brightCrimson
                            : AppColors.abyssalTeal),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isTimeUp
                            ? 'Withdrawal Available'
                            : (widget.hasActiveDebt
                                ? 'Withdrawals Restricted'
                                : 'Savings Locked'),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.hasActiveDebt
                            ? 'Debt must be cleared first'
                            : (isTimeUp
                                ? 'Funds unlocked'
                                : 'Until ${DateFormat('MMM dd, yyyy').format(widget.maturityDate)}'),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
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
            const SizedBox(height: 16),
            // Countdown Timer
            if (!isTimeUp)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Time Remaining',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode
                          ? AppColors.darkTextMuted
                          : AppColors.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatRemainingTime(remaining),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.abyssalTeal,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            // Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Savings Progress',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode
                            ? AppColors.darkTextMuted
                            : AppColors.textMuted,
                      ),
                    ),
                    Text(
                      '$progressPercent%',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.abyssalTeal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progressPercent / 100,
                    minHeight: 8,
                    backgroundColor: isDarkMode
                        ? AppColors.darkBorder
                        : AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isTimeUp ? AppColors.success : AppColors.abyssalTeal,
                    ),
                  ),
                ),
              ],
            ),
            // Debt Warning
            if (widget.hasActiveDebt) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.brightCrimson.withAlpha(15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.brightCrimson.withAlpha(40),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.brightCrimson,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You have active debt. Clear it to withdraw savings.',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.brightCrimson,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

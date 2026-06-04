import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';

class SavingsStreakWidget extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  final int missedDays;
  final bool isTodayContributed;

  const SavingsStreakWidget({
    required this.currentStreak,
    required this.longestStreak,
    this.missedDays = 0,
    this.isTodayContributed = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = false;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.brightCrimson.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  color: AppColors.brightCrimson,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Savings Streak',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Streak Counter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StreakItem(
                value: '$currentStreak',
                label: 'Current',
                color: AppColors.brightCrimson,
                isDarkMode: isDarkMode,
              ),
              Container(
                width: 1,
                height: 60,
                color: isDarkMode ? AppColors.darkBorder : AppColors.border,
              ),
              _StreakItem(
                value: '$longestStreak',
                label: 'Personal Best',
                color: AppColors.abyssalTeal,
                isDarkMode: isDarkMode,
              ),
            ],
          ),
          if (missedDays > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.warning.withAlpha(15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$missedDays missed contribution${missedDays > 1 ? 's' : ''}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (isTodayContributed) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha(15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Great! You contributed today',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StreakItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final bool isDarkMode;

  const _StreakItem({
    required this.value,
    required this.label,
    required this.color,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? AppColors.darkTextMuted : AppColors.textMuted,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

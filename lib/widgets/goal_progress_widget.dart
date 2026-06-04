import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';

class GoalProgressWidget extends StatelessWidget {
  final String goalName;
  final double currentAmount;
  final double targetAmount;
  final String currency;
  final Color progressColor;
  final VoidCallback? onTap;

  const GoalProgressWidget({
    required this.goalName,
    required this.currentAmount,
    required this.targetAmount,
    this.currency = '₦',
    this.progressColor = AppColors.abyssalTeal,
    this.onTap,
    super.key,
  });

  double get progressPercentage =>
      ((currentAmount / targetAmount) * 100).clamp(0, 100);

  bool get isCompleted => currentAmount >= targetAmount;

  String get remainingAmount => (targetAmount - currentAmount).toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = false;

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            // Header with goal name and checkbox
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    goalName,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.success.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: AppColors.success,
                      size: 18,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Amount display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Progress',
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
                      '$currency${currentAmount.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: progressColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Target',
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
                      '$currency${targetAmount.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
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
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progressPercentage / 100,
                minHeight: 8,
                backgroundColor:
                    isDarkMode ? AppColors.darkBorder : AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
            const SizedBox(height: 8),
            // Progress percentage and remaining
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${progressPercentage.toStringAsFixed(0)}% Complete',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: progressColor,
                  ),
                ),
                Text(
                  'Remaining: $currency$remainingAmount',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color:
                        isDarkMode ? AppColors.darkTextMuted : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GoalGridView extends StatelessWidget {
  final List<({String name, double current, double target})> goals;
  final String currency;
  final VoidCallback? onGoalTap;

  const GoalGridView({
    required this.goals,
    this.currency = '₦',
    this.onGoalTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      AppColors.abyssalTeal,
      AppColors.brightCrimson,
      AppColors.primaryRed,
      AppColors.success,
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        final color = colors[index % colors.length];
        return GoalProgressWidget(
          goalName: goal.name,
          currentAmount: goal.current,
          targetAmount: goal.target,
          currency: currency,
          progressColor: color,
          onTap: onGoalTap,
        );
      },
    );
  }
}

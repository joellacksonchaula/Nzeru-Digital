import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../providers/savings_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/progress_ring.dart';
import '../../utils/currency_util.dart';

class SavingsPlansScreen extends StatelessWidget {
  const SavingsPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final savings = context.watch<SavingsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SAVINGS PLANS',
                    style: GoogleFonts.orbitron(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gold,
                      letterSpacing: 3,
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.createPlan),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.add, color: AppColors.gold, size: 22),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),
            Expanded(
              child: savings.plans.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.savings_outlined,
                              color: AppColors.textMuted, size: 64),
                          const SizedBox(height: 16),
                          Text(
                            'No savings plans yet',
                            style: GoogleFonts.inter(
                              color: AppColors.textMuted,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: savings.plans.length,
                      itemBuilder: (context, index) {
                        final plan = savings.plans[index];
                        return GlassCard(
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.planDetail),
                          child: Row(
                            children: [
                              ProgressRing(
                                progress: plan.progressPercent,
                                size: 80,
                                strokeWidth: 8,
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: plan.isActive
                                            ? AppColors.success.withAlpha(20)
                                            : AppColors.textMuted.withAlpha(20),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        plan.isActive ? 'Active' : 'Inactive',
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          color: plan.isActive
                                              ? AppColors.success
                                              : AppColors.textMuted,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${plan.frequencyLabel} Plan',
                                      style: GoogleFonts.orbitron(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${CurrencyUtil.format(plan.amountPerPeriod)} / ${plan.frequencyLabel.toLowerCase()}',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          CurrencyUtil.format(plan.currentAmount),
                                          style: GoogleFonts.orbitron(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.gold,
                                          ),
                                        ),
                                        Text(
                                          'of ${CurrencyUtil.format(plan.goalAmount)}',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(
                              delay: Duration(milliseconds: 200 + index * 100),
                            );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

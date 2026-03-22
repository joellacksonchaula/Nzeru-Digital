import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/app_colors.dart';
import '../../providers/savings_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/progress_ring.dart';
import '../../utils/currency_util.dart';

class PlanDetailScreen extends StatelessWidget {
  const PlanDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final savings = context.watch<SavingsProvider>();
    final plan = savings.plans.isNotEmpty ? savings.plans[0] : null;
    final planTransactions = savings.transactions
        .where((t) => t.planId == plan?.id)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('PLAN DETAILS',
            style: GoogleFonts.playfairDisplay(
                fontSize: 16, letterSpacing: 2, color: AppColors.gold)),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.gold),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: plan == null
          ? const Center(child: Text('No plan found'))
          : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Progress Ring
                  Center(
                    child: ProgressRing(
                      progress: plan.progressPercent,
                      size: 180,
                      strokeWidth: 14,
                      label: 'SAVINGS GOAL',
                    ),
                  ).animate().scale(duration: 600.ms, curve: Curves.easeOut),
                  const SizedBox(height: 20),
                  Text(
                    '${CurrencyUtil.format(plan.currentAmount)} of ${CurrencyUtil.format(plan.goalAmount)}',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 30),

                  // Plan Info
                  GlassCard(
                    child: Column(
                      children: [
                        _infoRow('Frequency', plan.frequencyLabel),
                        const Divider(color: AppColors.border, height: 24),
                        _infoRow('Amount per Period',
                            CurrencyUtil.format(plan.amountPerPeriod)),
                        const Divider(color: AppColors.border, height: 24),
                        _infoRow('Duration', '${plan.durationMonths} months'),
                        const Divider(color: AppColors.border, height: 24),
                        _infoRow('Start',
                            DateFormat('dd MMM yyyy').format(plan.startDate)),
                        const Divider(color: AppColors.border, height: 24),
                        _infoRow('End',
                            DateFormat('dd MMM yyyy').format(plan.endDate)),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms),

                  // Transactions
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'TRANSACTION HISTORY',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                  ...planTransactions.map(
                    (txn) => Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: AppColors.border, width: 0.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: txn.isCredit
                                  ? AppColors.success.withAlpha(20)
                                  : AppColors.actionRed.withAlpha(20),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              txn.isCredit
                                  ? Icons.arrow_downward_rounded
                                  : Icons.arrow_upward_rounded,
                              color: txn.isCredit
                                  ? AppColors.success
                                  : AppColors.actionRed,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(txn.typeLabel,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    )),
                                Text(
                                    DateFormat('dd MMM yyyy')
                                        .format(txn.date),
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: AppColors.textMuted,
                                    )),
                              ],
                            ),
                          ),
                          Text(
                            '${txn.isCredit ? '+' : '-'} ${CurrencyUtil.format(txn.amount)}',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: txn.isCredit
                                  ? AppColors.success
                                  : AppColors.actionRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 13, color: AppColors.textMuted)),
        Text(value,
            style: GoogleFonts.playfairDisplay(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
      ],
    );
  }
}

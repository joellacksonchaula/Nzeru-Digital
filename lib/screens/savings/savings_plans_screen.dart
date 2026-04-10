import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../config/app_routes.dart';
import '../../providers/finance_overview_provider.dart';
import '../../providers/savings_provider.dart';
import '../../utils/currency_util.dart';
import '../../widgets/dashboard_kit.dart';

class SavingsPlansScreen extends StatelessWidget {
  const SavingsPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceOverviewProvider>();
    final savings = context.watch<SavingsProvider>();
    final plans = finance.prioritizedPlans;

    return DashboardPage(
      eyebrow: 'Savings',
      title: 'Savings',
      subtitle: '',
      trailing: FilledButton.icon(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.createPlan),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF0F9D8A),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        icon: const Icon(Icons.add_rounded, size: 18),
        label: Text(
          'New',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
        ),
      ),
      children: [
        DashboardPanel(
          glowColor: const Color(0x660F9D8A),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your live savings',
                style: GoogleFonts.sora(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF171412),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'All savings plans are stacked below so you can scan them quickly.',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  color: const Color(0xFF6F665C),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _SummaryStat(
                      label: 'Saved',
                      value: CurrencyUtil.formatCompact(finance.totalSaved),
                      accent: const Color(0xFF0F9D8A),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SummaryStat(
                      label: 'Monthly target',
                      value: CurrencyUtil.formatCompact(
                        finance.monthlyCommitment,
                      ),
                      accent: const Color(0xFFB88E5A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: plans.isEmpty
                      ? null
                      : () => Navigator.pushNamed(context, AppRoutes.deposit),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F9D8A),
                    side: const BorderSide(color: Color(0xFFBDE0DB)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  icon: const Icon(Icons.south_west_rounded, size: 18),
                  label: Text(
                    'Deposit to savings',
                    style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (plans.isEmpty)
          DashboardPanel(
            child: SizedBox(
              height: 180,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.savings_rounded,
                      size: 40,
                      color: Color(0xFF0F9D8A),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No savings plans yet.',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        color: const Color(0xFF6F665C),
                      ),
                    ),
                    const SizedBox(height: 14),
                    FilledButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.createPlan),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0F9D8A),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        'Create first plan',
                        style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Column(
            children: [
              for (final plan in plans) ...[
                DashboardSavingsPlanCard(
                  plan: plan,
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.planDetail,
                    arguments: plan.id,
                  ),
                ),
                if (plan != plans.last) const SizedBox(height: 14),
              ],
            ],
          ),
        if (savings.error != null) ...[
          const SizedBox(height: 12),
          Text(
            savings.error!,
            style: GoogleFonts.manrope(
              fontSize: 12,
              color: const Color(0xFFC2545E),
            ),
          ),
        ],
      ],
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;

  const _SummaryStat({
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6F665C),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.sora(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF171412),
            ),
          ),
        ],
      ),
    );
  }
}

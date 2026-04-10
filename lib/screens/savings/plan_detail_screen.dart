import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/app_routes.dart';
import '../../models/savings_plan.dart';
import '../../models/savings_transaction.dart';
import '../../providers/auth_provider.dart';
import '../../providers/savings_provider.dart';
import '../../utils/currency_util.dart';
import '../../widgets/dashboard_kit.dart';
import '../../widgets/progress_ring.dart';
import 'deposit_screen.dart';

class PlanDetailScreen extends StatelessWidget {
  const PlanDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final savings = context.watch<SavingsProvider>();
    final planId = ModalRoute.of(context)?.settings.arguments as String?;
    final matchedPlans = planId == null
        ? const []
        : savings.plans.where((item) => item.id == planId).toList();
    final plan = matchedPlans.isNotEmpty
        ? matchedPlans.first
        : (savings.plans.isNotEmpty ? savings.plans.first : null);
    final planTransactions =
        savings.transactions.where((t) => t.planId == plan?.id).toList()
          ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'SAVINGS PLAN',
          style: GoogleFonts.sora(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
            color: const Color(0xFF171412),
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF171412),
          ),
        ),
      ),
      body: Stack(
        children: [
          const DashboardBackdrop(darkMode: false),
          if (plan == null)
            Center(
              child: Text(
                'No plan found',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: const Color(0xFF6F665C),
                ),
              ),
            )
          else
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ProgressRing(
                      progress: plan.progressPercent,
                      size: 170,
                      strokeWidth: 14,
                      label: plan.title.toUpperCase(),
                    ),
                  ).animate().scale(duration: 500.ms, curve: Curves.easeOut),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      '${CurrencyUtil.format(plan.currentAmount)} of ${CurrencyUtil.format(plan.goalAmount)}',
                      style: GoogleFonts.sora(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF171412),
                      ),
                    ),
                  ).animate().fadeIn(delay: 180.ms),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            AppRoutes.deposit,
                            arguments: DepositScreenArgs(
                              planId: plan.id,
                              planTitle: plan.title,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF0F9D8A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          icon: const Icon(Icons.south_west_rounded, size: 18),
                          label: Text(
                            'Deposit',
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showWithdrawalDialog(context, plan),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFD96069),
                            side: const BorderSide(color: Color(0xFFF0C7CB)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          icon: const Icon(Icons.north_east_rounded, size: 18),
                          label: Text(
                            'Withdraw',
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  DashboardPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Plan details',
                          style: GoogleFonts.sora(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF171412),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _InfoRow(
                          label: 'Frequency',
                          value: plan.frequencyLabel,
                        ),
                        const Divider(height: 24, color: Color(0xFFE6DAC7)),
                        _InfoRow(
                          label: 'Amount per period',
                          value: CurrencyUtil.format(plan.amountPerPeriod),
                        ),
                        const Divider(height: 24, color: Color(0xFFE6DAC7)),
                        _InfoRow(
                          label: 'Duration',
                          value: '${plan.durationMonths} months',
                        ),
                        const Divider(height: 24, color: Color(0xFFE6DAC7)),
                        _InfoRow(
                          label: 'Start',
                          value: DateFormat(
                            'dd MMM yyyy',
                          ).format(plan.startDate),
                        ),
                        const Divider(height: 24, color: Color(0xFFE6DAC7)),
                        _InfoRow(
                          label: 'End',
                          value: DateFormat('dd MMM yyyy').format(plan.endDate),
                        ),
                        const Divider(height: 24, color: Color(0xFFE6DAC7)),
                        _InfoRow(
                          label: 'Remaining',
                          value: CurrencyUtil.format(plan.remainingAmount),
                          valueColor: const Color(0xFFD96069),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 240.ms),
                  const SizedBox(height: 18),
                  Text(
                    'Transaction history',
                    style: GoogleFonts.sora(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF171412),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (planTransactions.isEmpty)
                    DashboardPanel(
                      child: Text(
                        'No transactions recorded for this plan yet.',
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          color: const Color(0xFF6F665C),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: planTransactions
                          .map(
                            (txn) => Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(0xFFE6DAC7),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: txn.isCredit
                                          ? const Color(
                                              0xFF0F9D8A,
                                            ).withValues(alpha: 0.12)
                                          : const Color(
                                              0xFFD96069,
                                            ).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      txn.isCredit
                                          ? Icons.arrow_downward_rounded
                                          : Icons.arrow_upward_rounded,
                                      color: txn.isCredit
                                          ? const Color(0xFF0F9D8A)
                                          : const Color(0xFFD96069),
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          txn.typeLabel,
                                          style: GoogleFonts.sora(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF171412),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          DateFormat(
                                            'dd MMM yyyy',
                                          ).format(txn.date),
                                          style: GoogleFonts.manrope(
                                            fontSize: 12,
                                            color: const Color(0xFF6F665C),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${txn.isCredit ? '+' : '-'} ${CurrencyUtil.format(txn.amount)}',
                                    style: GoogleFonts.sora(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: txn.isCredit
                                          ? const Color(0xFF0F9D8A)
                                          : const Color(0xFFD96069),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showWithdrawalDialog(
    BuildContext context,
    SavingsPlan plan,
  ) async {
    final amountController = TextEditingController();
    final reasonController = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Withdraw savings',
          style: GoogleFonts.sora(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: 'MK ',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason',
                hintText: 'Optional note',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text.trim());
              if (amount == null || amount <= 0) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Enter a valid withdrawal amount.'),
                  ),
                );
                return;
              }
              if (amount > plan.currentAmount) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Withdrawal amount exceeds current savings.'),
                  ),
                );
                return;
              }

              final auth = context.read<AuthProvider>();
              final success = await context
                  .read<SavingsProvider>()
                  .addWithdrawal(
                    SavingsTransaction(
                      id: '',
                      userId: auth.user?.id ?? '',
                      planId: plan.id,
                      amount: amount,
                      date: DateTime.now(),
                      type: TransactionType.withdrawal,
                      description: reasonController.text.trim().isEmpty
                          ? 'Savings withdrawal'
                          : reasonController.text.trim(),
                    ),
                  );

              if (!context.mounted) return;
              Navigator.pop(dialogContext);
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'Withdrawal of ${CurrencyUtil.format(amount)} recorded.'
                        : (context.read<SavingsProvider>().error ??
                              'Failed to record withdrawal.'),
                  ),
                ),
              );
            },
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
        const SizedBox(width: 10),
        Text(
          value,
          style: GoogleFonts.sora(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: valueColor ?? const Color(0xFF171412),
          ),
        ),
      ],
    );
  }
}

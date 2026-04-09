import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../models/credit.dart';
import '../../models/savings_plan.dart';
import '../../providers/credit_provider.dart';
import '../../providers/savings_provider.dart';
import '../../utils/currency_util.dart';
import '../../widgets/dashboard_kit.dart';
import '../../widgets/gold_button.dart';

class RequestLoanScreen extends StatefulWidget {
  const RequestLoanScreen({super.key});

  @override
  State<RequestLoanScreen> createState() => _RequestLoanScreenState();
}

class _RequestLoanScreenState extends State<RequestLoanScreen> {
  double _creditAmount = 500;
  int _durationMonths = 10;
  final double _interestRate = 10.0;
  bool _isProcessing = false;
  String? _selectedPlanId;
  CreditWithdrawalMode _withdrawalMode = CreditWithdrawalMode.instant;

  @override
  Widget build(BuildContext context) {
    final credits = context.watch<CreditProvider>();
    final savings = context.watch<SavingsProvider>();
    final plans = savings.activePlans;
    final selectedPlanMatches = _selectedPlanId == null
        ? const <SavingsPlan>[]
        : plans.where((plan) => plan.id == _selectedPlanId).toList();
    final selectedPlan = selectedPlanMatches.isNotEmpty
        ? selectedPlanMatches.first
        : (plans.isNotEmpty ? plans.first : null);
    final trackedSavings = selectedPlan?.currentAmount ?? 0;
    final maxCredit = trackedSavings * 0.4;
    final totalWithInterest = _creditAmount * (1 + _interestRate / 100);
    final suggestedRepayment = totalWithInterest / _durationMonths;

    if (_selectedPlanId == null && selectedPlan != null) {
      _selectedPlanId = selectedPlan.id;
      _creditAmount = maxCredit > 100 ? 100 : maxCredit.clamp(0, 100).toDouble();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EE),
      body: Stack(
        children: [
          const DashboardBackdrop(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'NZELU CREDIT',
                              style: GoogleFonts.oswald(
                                fontSize: 13,
                                letterSpacing: 2.2,
                                color: const Color(0xFF0ABAB5),
                              ),
                            ),
                            Text(
                              'Request Credit',
                              style: GoogleFonts.oswald(
                                fontSize: 28,
                                color: const Color(0xFF171412),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DashboardPanel(
                    glowColor: const Color(0x660ABAB5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Savings plan',
                          style: GoogleFonts.oswald(fontSize: 22, color: const Color(0xFF171412)),
                        ),
                        const SizedBox(height: 10),
                        if (plans.isEmpty)
                          Text(
                            'Create or load a savings plan before requesting credit.',
                            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6F665C)),
                          )
                        else
                          DropdownButtonFormField<String>(
                            value: _selectedPlanId,
                            items: plans
                                .map(
                                  (plan) => DropdownMenuItem<String>(
                                    value: plan.id,
                                    child: Text(plan.isTrial ? '${plan.title} (Trial)' : plan.title),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedPlanId = value;
                                final localPlan = plans.firstWhere((plan) => plan.id == value);
                                final nextMax = localPlan.currentAmount * 0.4;
                                _creditAmount = nextMax > 100 ? 100 : nextMax.clamp(0, 100).toDouble();
                              });
                              credits.checkEligibility(planId: value);
                            },
                          ),
                        if (selectedPlan?.isTrial == true) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37).withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'Trial mode: deposits, credit requests, repayments, interest rewards, and penalties stay isolated from real balances.',
                              style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6E5626)),
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),
                        Text(
                          'Choose your amount',
                          style: GoogleFonts.oswald(fontSize: 22, color: const Color(0xFF171412)),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            CurrencyUtil.format(_creditAmount),
                            style: GoogleFonts.oswald(fontSize: 34, color: const Color(0xFF0ABAB5)),
                          ),
                        ),
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: AppColors.loadingRed,
                            inactiveTrackColor: AppColors.tiffanyMist,
                            thumbColor: AppColors.loadingRed,
                            overlayColor: const Color(0x33801818),
                          ),
                          child: Slider(
                            value: (_creditAmount < 100 ? 100 : _creditAmount)
                                .clamp(100, maxCredit > 100 ? maxCredit : 101)
                                .toDouble(),
                            min: 100,
                            max: maxCredit > 100 ? maxCredit : 101,
                            divisions: maxCredit > 100 ? ((maxCredit - 100) / 50).round() : 1,
                            onChanged: plans.isEmpty
                                ? null
                                : (v) => setState(() => _creditAmount = (v / 50).round() * 50.0),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('MK 100', style: GoogleFonts.inter(fontSize: 11)),
                            Text(CurrencyUtil.formatNoDecimal(maxCredit), style: GoogleFonts.inter(fontSize: 11)),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Release mode',
                          style: GoogleFonts.oswald(fontSize: 18, color: const Color(0xFF171412)),
                        ),
                        const SizedBox(height: 8),
                        SegmentedButton<CreditWithdrawalMode>(
                          segments: const [
                            ButtonSegment(value: CreditWithdrawalMode.instant, label: Text('All at once')),
                            ButtonSegment(value: CreditWithdrawalMode.daily, label: Text('Daily')),
                            ButtonSegment(value: CreditWithdrawalMode.weekly, label: Text('Weekly')),
                          ],
                          selected: {_withdrawalMode},
                          onSelectionChanged: (selection) {
                            setState(() => _withdrawalMode = selection.first);
                          },
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Repayment period',
                          style: GoogleFonts.oswald(fontSize: 18, color: const Color(0xFF171412)),
                        ),
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: AppColors.loadingGreen,
                            inactiveTrackColor: AppColors.faluMist,
                            thumbColor: AppColors.loadingGreen,
                          ),
                          child: Slider(
                            value: _durationMonths.toDouble(),
                            min: 1,
                            max: 24,
                            divisions: 23,
                            label: '$_durationMonths months',
                            onChanged: (v) => setState(() => _durationMonths = v.round()),
                          ),
                        ),
                        Center(
                          child: Text(
                            '$_durationMonths months',
                            style: GoogleFonts.oswald(fontSize: 20, color: const Color(0xFF4C6A78)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  DashboardPanel(
                    glowColor: const Color(0x664B9957),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Credit breakdown',
                          style: GoogleFonts.oswald(fontSize: 22, color: const Color(0xFF171412)),
                        ),
                        const SizedBox(height: 12),
                        DashboardFixedGrid(
                          mainAxisExtent: 112,
                          children: [
                            _RequestMetric(
                              label: 'Eligibility',
                              value: CurrencyUtil.formatCompact(maxCredit),
                              accent: const Color(0xFFD4AF37),
                            ),
                            _RequestMetric(
                              label: 'Interest',
                              value: CurrencyUtil.formatCompact(_creditAmount * _interestRate / 100),
                              accent: const Color(0xFFC2545E),
                            ),
                            _RequestMetric(
                              label: 'Total repay',
                              value: CurrencyUtil.formatCompact(totalWithInterest),
                              accent: const Color(0xFF4C6A78),
                            ),
                            _RequestMetric(
                              label: 'Pay-as-you-go',
                              value: CurrencyUtil.formatCompact(suggestedRepayment),
                              accent: const Color(0xFF4B9957),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        DashboardInfoRow(
                          label: 'Tracked savings',
                          value: CurrencyUtil.formatNoDecimal(trackedSavings),
                          valueColor: const Color(0xFF4B9957),
                        ),
                        DashboardInfoRow(
                          label: 'Release mode',
                          value: Credit(
                            id: '',
                            userId: '',
                            amount: 0,
                            durationMonths: 1,
                            withdrawalMode: _withdrawalMode,
                          ).withdrawalModeLabel,
                          valueColor: const Color(0xFF4C6A78),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  GoldButton(
                    label: 'SUBMIT CREDIT REQUEST',
                    icon: Icons.send_rounded,
                    isLoading: _isProcessing,
                    width: double.infinity,
                    onPressed: () async {
                      if (plans.isEmpty || _selectedPlanId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Select a savings plan first.')),
                        );
                        return;
                      }
                      if (credits.activeCredit != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Finish your outstanding credit before requesting another one.')),
                        );
                        return;
                      }
                      if (maxCredit <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('You are not eligible for credit yet.')),
                        );
                        return;
                      }
                            setState(() => _isProcessing = true);
                            final navigator = Navigator.of(context);
                            final messenger = ScaffoldMessenger.of(context);

                            final success = await credits.requestCredit(
                              Credit(
                                id: '',
                                userId: '',
                                planId: _selectedPlanId,
                                amount: _creditAmount,
                                interestRate: _interestRate,
                                durationMonths: _durationMonths,
                                status: CreditStatus.pending,
                                withdrawalMode: _withdrawalMode,
                                lockedAmount: _withdrawalMode == CreditWithdrawalMode.instant
                                    ? 0
                                    : _withdrawalMode == CreditWithdrawalMode.daily
                                        ? (_creditAmount / (_durationMonths * 30))
                                        : (_creditAmount / (_durationMonths * 4)),
                                dueDate: DateTime.now().add(Duration(days: _durationMonths * 30)),
                                isTrial: selectedPlan?.isTrial ?? false,
                              ),
                            );

                            if (!mounted) return;
                            setState(() => _isProcessing = false);
                            if (success) {
                              navigator.pop();
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Credit request for ${CurrencyUtil.format(_creditAmount)} submitted.',
                                  ),
                                ),
                              );
                            } else {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(credits.error ?? 'Failed to submit credit request.'),
                                ),
                              );
                            }
                          },
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

class _RequestMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;

  const _RequestMetric({
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardPanel(
      glowColor: accent,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.oswald(fontSize: 11, letterSpacing: 1.2, color: accent),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.oswald(fontSize: 18, color: const Color(0xFF171412)),
          ),
        ],
      ),
    );
  }
}

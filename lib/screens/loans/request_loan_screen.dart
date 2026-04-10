import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../config/app_routes.dart';
import '../../models/credit.dart';
import '../../models/savings_plan.dart';
import '../../providers/credit_provider.dart';
import '../../providers/savings_provider.dart';
import '../../utils/currency_util.dart';
import '../../widgets/dashboard_kit.dart';

class RequestLoanScreen extends StatefulWidget {
  const RequestLoanScreen({super.key});

  @override
  State<RequestLoanScreen> createState() => _RequestLoanScreenState();
}

class _RequestLoanScreenState extends State<RequestLoanScreen> {
  static const double _minimumCreditAmount = 100;
  static const double _interestRate = 10.0;
  static const int _maxDurationMonths = 18;

  final TextEditingController _cashoutController = TextEditingController();

  double _creditAmount = 18050;
  bool _isProcessing = false;
  bool _hasCustomCashout = false;
  String? _selectedPlanId;
  CreditWithdrawalMode _withdrawalMode = CreditWithdrawalMode.instant;

  @override
  void dispose() {
    _cashoutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final credits = context.watch<CreditProvider>();
    final savings = context.watch<SavingsProvider>();
    final plans = savings.activePlans;
    final selectedPlan = _selectedPlan(plans);

    if (selectedPlan != null) {
      _syncDefaults(plans, credits);
    }

    final trackedSavings = selectedPlan?.currentAmount ?? 0.0;
    final maxCredit = trackedSavings * 0.4;
    final creditAmount = _effectiveCreditAmount(maxCredit);
    final totalRepayment = creditAmount * (1 + _interestRate / 100);
    final eligibilityValue = _parseDouble(
      credits.eligibility?['max_loan_amount'],
      fallback: maxCredit,
    );
    final outstandingCredit = credits.activeCredit?.remainingBalance ?? 0.0;
    final repaidCredit = credits.totalRepaid;
    final cashoutWarning = _cashoutWarning(totalAmount: creditAmount);
    final distributionCount = _distributionCount(totalAmount: creditAmount);
    final estimatedMonths = _estimatedMonths(totalAmount: creditAmount);

    final canSubmit =
        !_isProcessing &&
        plans.isNotEmpty &&
        selectedPlan != null &&
        maxCredit >= _minimumCreditAmount &&
        credits.activeCredit == null &&
        cashoutWarning == null;

    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF9),
      body: Stack(
        children: [
          const DashboardBackdrop(darkMode: false),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(onBack: () => Navigator.pop(context)),
                  const SizedBox(height: 18),
                  _StatusBanner(
                    label: _statusLabel(
                      plans: plans,
                      activeCredit: credits.activeCredit,
                      maxCredit: maxCredit,
                    ),
                    accent: _statusAccent(
                      plans: plans,
                      activeCredit: credits.activeCredit,
                      maxCredit: maxCredit,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionTitle(
                          title: 'Eligibility overview',
                          subtitle:
                              'A quick summary before you request credit.',
                        ),
                        const SizedBox(height: 14),
                        GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 1.55,
                          children: [
                            _OverviewTile(
                              label: 'Eligible',
                              value: CurrencyUtil.formatCompact(
                                eligibilityValue,
                              ),
                              icon: Icons.verified_rounded,
                              accent: const Color(0xFF0F9D8A),
                            ),
                            _OverviewTile(
                              label: 'Tracked',
                              value: CurrencyUtil.formatCompact(trackedSavings),
                              icon: Icons.savings_rounded,
                              accent: const Color(0xFF54738A),
                            ),
                            _OverviewTile(
                              label: 'Outstanding',
                              value: CurrencyUtil.formatCompact(
                                outstandingCredit,
                              ),
                              icon: Icons.account_balance_wallet_rounded,
                              accent: const Color(0xFFD96069),
                            ),
                            _OverviewTile(
                              label: 'Repaid',
                              value: CurrencyUtil.formatCompact(repaidCredit),
                              icon: Icons.paid_rounded,
                              accent: const Color(0xFFB88E5A),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionTitle(
                          title: 'Savings plan',
                          subtitle:
                              'Choose the savings plan backing this credit request.',
                        ),
                        const SizedBox(height: 12),
                        if (plans.isEmpty)
                          _EmptyStateCard(
                            message:
                                'Create a savings plan first before requesting credit.',
                            actionLabel: 'Create plan',
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.createPlan,
                            ),
                          )
                        else
                          DropdownButtonFormField<String>(
                            value: selectedPlan?.id,
                            decoration: _fieldDecoration('Savings plan'),
                            items: plans
                                .map(
                                  (plan) => DropdownMenuItem<String>(
                                    value: plan.id,
                                    child: Text(
                                      plan.title,
                                      style: GoogleFonts.manrope(
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF17303B),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              final nextPlan = plans.firstWhere(
                                (plan) => plan.id == value,
                              );
                              final nextMax = nextPlan.currentAmount * 0.4;
                              setState(() {
                                _selectedPlanId = value;
                                _creditAmount = _normalizedCreditAmount(
                                  _recommendedCreditAmount(nextMax),
                                  nextMax,
                                );
                                _hasCustomCashout = false;
                                _applySuggestedCashout();
                              });
                              credits.checkEligibility(planId: value);
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionTitle(
                          title: 'Choose your amount',
                          subtitle:
                              'Move the slider to select the credit amount you need.',
                        ),
                        const SizedBox(height: 14),
                        Center(
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: creditAmount),
                            duration: const Duration(milliseconds: 350),
                            builder: (context, value, _) => Text(
                              CurrencyUtil.format(value),
                              style: GoogleFonts.sora(
                                fontSize: 31,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1,
                                color: const Color(0xFF0F9D8A),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: const Color(0xFF0F9D8A),
                            inactiveTrackColor: const Color(0xFFDDEAE8),
                            thumbColor: const Color(0xFFD96069),
                            overlayColor: const Color(0x22D96069),
                            trackHeight: 6,
                          ),
                          child: Slider(
                            value: _sliderValue(
                              maxCredit: maxCredit,
                              creditAmount: creditAmount,
                            ),
                            min: _minimumCreditAmount,
                            max: maxCredit > _minimumCreditAmount
                                ? maxCredit
                                : _minimumCreditAmount,
                            divisions: maxCredit > _minimumCreditAmount
                                ? ((maxCredit - _minimumCreditAmount) / 50)
                                      .floor()
                                      .clamp(1, 5000)
                                : 1,
                            onChanged: maxCredit >= _minimumCreditAmount
                                ? (value) {
                                    setState(() {
                                      _creditAmount = _normalizedCreditAmount(
                                        value,
                                        maxCredit,
                                      );
                                      if (!_hasCustomCashout) {
                                        _applySuggestedCashout();
                                      }
                                    });
                                  }
                                : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'MK 100',
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                color: const Color(0xFF6A7C86),
                              ),
                            ),
                            Text(
                              CurrencyUtil.formatNoDecimal(maxCredit),
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                color: const Color(0xFF6A7C86),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionTitle(
                          title: 'Cash-out mode',
                          subtitle:
                              'Choose whether you want the full amount, daily cashout, or weekly cashout.',
                        ),
                        const SizedBox(height: 14),
                        _ModeSelector(
                          selectedMode: _withdrawalMode,
                          onSelected: (mode) {
                            setState(() {
                              _withdrawalMode = mode;
                              _hasCustomCashout = false;
                              _applySuggestedCashout();
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 260),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          child: _buildCashoutCard(
                            totalAmount: creditAmount,
                            distributionCount: distributionCount,
                            estimatedMonths: estimatedMonths,
                            warning: cashoutWarning,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionTitle(
                          title: 'Credit breakdown',
                          subtitle:
                              'See how this request is structured before you continue.',
                        ),
                        const SizedBox(height: 14),
                        GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 1.55,
                          children: [
                            _BreakdownTile(
                              label: 'Eligibility',
                              value: CurrencyUtil.formatCompact(
                                eligibilityValue,
                              ),
                              accent: const Color(0xFF0F9D8A),
                            ),
                            _BreakdownTile(
                              label: 'Interest',
                              value: CurrencyUtil.formatCompact(
                                creditAmount * _interestRate / 100,
                              ),
                              accent: const Color(0xFFD96069),
                            ),
                            _BreakdownTile(
                              label: 'Total repayment',
                              value: CurrencyUtil.formatCompact(totalRepayment),
                              accent: const Color(0xFF54738A),
                            ),
                            _BreakdownTile(
                              label: 'Estimated span',
                              value:
                                  _withdrawalMode ==
                                      CreditWithdrawalMode.instant
                                  ? 'Immediate'
                                  : _durationSummary(
                                      distributionCount: distributionCount,
                                      estimatedMonths: estimatedMonths,
                                    ),
                              accent: const Color(0xFFB88E5A),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: canSubmit
                          ? () => _submitRequest(context, selectedPlan)
                          : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0F9D8A),
                        disabledBackgroundColor: const Color(0xFFBFD7D3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        elevation: 0,
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              'Submit credit request',
                              style: GoogleFonts.sora(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  if (!canSubmit) ...[
                    const SizedBox(height: 10),
                    Text(
                      _submitHelperText(
                        plans: plans,
                        maxCredit: maxCredit,
                        activeCredit: credits.activeCredit,
                        warning: cashoutWarning,
                      ),
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: const Color(0xFF6A7C86),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SavingsPlan? _selectedPlan(List<SavingsPlan> plans) {
    if (plans.isEmpty) return null;
    for (final plan in plans) {
      if (plan.id == _selectedPlanId) return plan;
    }
    return plans.first;
  }

  void _syncDefaults(List<SavingsPlan> plans, CreditProvider credits) {
    final plan = _selectedPlan(plans);
    if (plan == null) return;

    final needsSelection = _selectedPlanId != plan.id;
    final maxCredit = plan.currentAmount * 0.4;
    final normalizedAmount = _normalizedCreditAmount(_creditAmount, maxCredit);
    final needsAmountUpdate = (_creditAmount - normalizedAmount).abs() > 0.01;

    if (!needsSelection && !needsAmountUpdate) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _selectedPlanId = plan.id;
        _creditAmount = normalizedAmount;
        if (!_hasCustomCashout) {
          _applySuggestedCashout();
        }
      });
      if (needsSelection) {
        credits.checkEligibility(planId: plan.id);
      }
    });
  }

  double _effectiveCreditAmount(double maxCredit) {
    if (maxCredit <= 0) return 0;
    return _normalizedCreditAmount(_creditAmount, maxCredit);
  }

  double _normalizedCreditAmount(double amount, double maxCredit) {
    if (maxCredit <= 0) return 0;
    if (maxCredit <= _minimumCreditAmount) {
      return maxCredit;
    }

    final clamped = amount.clamp(_minimumCreditAmount, maxCredit).toDouble();
    final rounded = (clamped / 50).round() * 50.0;
    return rounded.clamp(_minimumCreditAmount, maxCredit).toDouble();
  }

  double _recommendedCreditAmount(double maxCredit) {
    if (maxCredit <= 0) return 0;
    return _normalizedCreditAmount(math.min(maxCredit, 18050), maxCredit);
  }

  void _applySuggestedCashout() {
    if (_withdrawalMode == CreditWithdrawalMode.instant) return;

    final suggested = _recommendedCashout(
      mode: _withdrawalMode,
      totalAmount: _creditAmount,
    );
    _cashoutController.text = _cleanMoneyInput(suggested);
  }

  double _recommendedCashout({
    required CreditWithdrawalMode mode,
    required double totalAmount,
  }) {
    if (totalAmount <= 0) return 0;

    if (mode == CreditWithdrawalMode.daily) {
      final suggested = math.max(100.0, totalAmount / 180);
      return _roundMoney(suggested, step: 50);
    }

    if (mode == CreditWithdrawalMode.weekly) {
      final suggested = math.max(1000.0, totalAmount / 18);
      return _roundMoney(suggested, step: 100);
    }

    return totalAmount;
  }

  double _roundMoney(double value, {required double step}) {
    if (value <= 0) return 0;
    final rounded = (value / step).ceil() * step;
    return rounded.toDouble();
  }

  String _cleanMoneyInput(double value) {
    if (value == value.roundToDouble()) {
      return value.round().toString();
    }
    return value.toStringAsFixed(2);
  }

  double? _cashoutValue() {
    final raw = _cashoutController.text.trim().replaceAll(',', '');
    if (raw.isEmpty) return null;
    return double.tryParse(raw);
  }

  int? _distributionCount({required double totalAmount}) {
    if (_withdrawalMode == CreditWithdrawalMode.instant) return null;

    final payout = _cashoutValue();
    if (payout == null || payout <= 0) return null;

    return math.max(1, (totalAmount / payout).ceil());
  }

  double? _estimatedMonths({required double totalAmount}) {
    final count = _distributionCount(totalAmount: totalAmount);
    if (count == null) return null;

    if (_withdrawalMode == CreditWithdrawalMode.daily) {
      return count / 30;
    }

    if (_withdrawalMode == CreditWithdrawalMode.weekly) {
      return count / 4;
    }

    return null;
  }

  String? _cashoutWarning({required double totalAmount}) {
    if (_withdrawalMode == CreditWithdrawalMode.instant) return null;

    final payout = _cashoutValue();
    if (payout == null || payout <= 0) {
      return 'Enter a valid cashout amount.';
    }
    if (payout > totalAmount) {
      return 'Cashout cannot be more than the total credit amount.';
    }

    final count = _distributionCount(totalAmount: totalAmount);
    if (count == null) return 'Enter a valid cashout amount.';

    final minimumCount = _withdrawalMode == CreditWithdrawalMode.daily ? 30 : 4;
    final maximumCount = _withdrawalMode == CreditWithdrawalMode.daily
        ? 540
        : 72;

    if (count < minimumCount) {
      return 'Amount too high. Reduce cashout to extend duration.';
    }
    if (count > maximumCount) {
      return 'Cashout too low. Increase it to keep duration within 18 months.';
    }

    return null;
  }

  int _durationMonthsForSubmission(double totalAmount) {
    if (_withdrawalMode == CreditWithdrawalMode.instant) return 1;

    final months = _estimatedMonths(totalAmount: totalAmount);
    if (months == null || months <= 0) return 1;
    return months.ceil().clamp(1, _maxDurationMonths);
  }

  double _lockedAmountForSubmission() {
    if (_withdrawalMode == CreditWithdrawalMode.instant) {
      return 0;
    }
    return _cashoutValue() ?? 0;
  }

  double _sliderValue({
    required double maxCredit,
    required double creditAmount,
  }) {
    if (maxCredit <= _minimumCreditAmount) {
      return _minimumCreditAmount;
    }
    return creditAmount.clamp(_minimumCreditAmount, maxCredit).toDouble();
  }

  String _durationSummary({
    required int? distributionCount,
    required double? estimatedMonths,
  }) {
    if (distributionCount == null || estimatedMonths == null) {
      return '--';
    }

    final unit = _withdrawalMode == CreditWithdrawalMode.daily
        ? 'days'
        : 'weeks';
    return '$distributionCount $unit';
  }

  double _parseDouble(Object? value, {double fallback = 0}) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? fallback;
  }

  String _statusLabel({
    required List<SavingsPlan> plans,
    required Credit? activeCredit,
    required double maxCredit,
  }) {
    if (plans.isEmpty) {
      return 'Create a savings plan first';
    }
    if (activeCredit != null) {
      return 'You already have an active credit';
    }
    if (maxCredit < _minimumCreditAmount) {
      return 'Not eligible yet';
    }
    return 'You can request credit now';
  }

  Color _statusAccent({
    required List<SavingsPlan> plans,
    required Credit? activeCredit,
    required double maxCredit,
  }) {
    if (plans.isEmpty ||
        activeCredit != null ||
        maxCredit < _minimumCreditAmount) {
      return const Color(0xFFD96069);
    }
    return const Color(0xFF0F9D8A);
  }

  Future<void> _submitRequest(
    BuildContext context,
    SavingsPlan? selectedPlan,
  ) async {
    final credits = context.read<CreditProvider>();
    final plans = context.read<SavingsProvider>().activePlans;
    final plan = selectedPlan ?? _selectedPlan(plans);
    final creditAmount = _effectiveCreditAmount(
      (plan?.currentAmount ?? 0) * 0.4,
    );
    final warning = _cashoutWarning(totalAmount: creditAmount);
    final messenger = ScaffoldMessenger.of(context);

    if (plan == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Select a savings plan first.')),
      );
      return;
    }
    if (credits.activeCredit != null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Finish your outstanding credit before requesting another one.',
          ),
        ),
      );
      return;
    }
    if (creditAmount < _minimumCreditAmount) {
      messenger.showSnackBar(
        const SnackBar(content: Text('You are not eligible for credit yet.')),
      );
      return;
    }
    if (warning != null) {
      messenger.showSnackBar(SnackBar(content: Text(warning)));
      return;
    }

    setState(() => _isProcessing = true);
    final navigator = Navigator.of(context);
    final success = await credits.requestCredit(
      Credit(
        id: '',
        userId: '',
        planId: plan.id,
        amount: creditAmount,
        interestRate: _interestRate,
        durationMonths: _durationMonthsForSubmission(creditAmount),
        status: CreditStatus.pending,
        withdrawalMode: _withdrawalMode,
        lockedAmount: _lockedAmountForSubmission(),
        dueDate: DateTime.now().add(
          Duration(days: _durationMonthsForSubmission(creditAmount) * 30),
        ),
        isTrial: plan.isTrial,
      ),
    );

    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (success) {
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Credit request for ${CurrencyUtil.format(creditAmount)} submitted.',
          ),
        ),
      );
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(credits.error ?? 'Failed to submit credit request.'),
      ),
    );
  }

  String _submitHelperText({
    required List<SavingsPlan> plans,
    required double maxCredit,
    required Credit? activeCredit,
    required String? warning,
  }) {
    if (plans.isEmpty) {
      return 'Create a savings plan before requesting credit.';
    }
    if (activeCredit != null) {
      return 'Repay the current credit first before requesting another one.';
    }
    if (maxCredit < _minimumCreditAmount) {
      return 'Track more savings to unlock at least MK 100 in eligible credit.';
    }
    if (warning != null) {
      return warning;
    }
    return '';
  }

  Widget _buildCashoutCard({
    required double totalAmount,
    required int? distributionCount,
    required double? estimatedMonths,
    required String? warning,
  }) {
    if (_withdrawalMode == CreditWithdrawalMode.instant) {
      return Container(
        key: const ValueKey('instant-cashout'),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF6F4),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFBDE0DB)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.flash_on_rounded,
                color: Color(0xFF0F9D8A),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'All at once',
                    style: GoogleFonts.sora(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF17303B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'You will receive ${CurrencyUtil.format(totalAmount)} immediately.',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      height: 1.4,
                      color: const Color(0xFF48616C),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final payoutLabel = _withdrawalMode == CreditWithdrawalMode.daily
        ? 'Daily cashout'
        : 'Weekly cashout';
    final payoutValue = _cashoutValue();
    final unit = _withdrawalMode == CreditWithdrawalMode.daily ? 'day' : 'week';
    final estimatedUnit = _withdrawalMode == CreditWithdrawalMode.daily
        ? 'days'
        : 'weeks';

    return Container(
      key: ValueKey<String>('${_withdrawalMode.name}-cashout'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFB),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: warning == null
              ? const Color(0xFFD8E8E5)
              : const Color(0xFFF0C7CB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            payoutLabel,
            style: GoogleFonts.sora(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF17303B),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _cashoutController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: GoogleFonts.sora(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF17303B),
            ),
            decoration: _fieldDecoration(payoutLabel).copyWith(
              prefixText: 'MK ',
              suffixIcon: const Icon(
                Icons.edit_outlined,
                color: Color(0xFF6A7C86),
              ),
            ),
            onChanged: (_) {
              setState(() {
                _hasCustomCashout = true;
              });
            },
          ),
          const SizedBox(height: 14),
          Text(
            payoutValue == null || payoutValue <= 0
                ? 'Enter a valid amount to see your payout schedule.'
                : 'You will receive ${CurrencyUtil.formatNoDecimal(payoutValue)} per $unit',
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF17303B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            distributionCount == null || estimatedMonths == null
                ? 'Estimated duration will appear here.'
                : 'Estimated duration: $distributionCount $estimatedUnit (~${_formatMonths(estimatedMonths)} months)',
            style: GoogleFonts.manrope(
              fontSize: 13,
              height: 1.4,
              color: const Color(0xFF48616C),
            ),
          ),
          if (warning != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFCEDEE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Color(0xFFD96069),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      warning,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFB2404C),
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

  String _formatMonths(double value) {
    if ((value - value.roundToDouble()).abs() < 0.05) {
      return value.round().toString();
    }
    return value.toStringAsFixed(1);
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onBack;

  const _Header({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.88),
            fixedSize: const Size(46, 46),
          ),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF17303B),
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nzelu Credit',
                style: GoogleFonts.sora(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: const Color(0xFF0F9D8A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Request Credit',
                style: GoogleFonts.sora(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                  color: const Color(0xFF17303B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final String label;
  final Color accent;

  const _StatusBanner({required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: accent,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE4EEEC)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120D2A35),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.sora(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF17303B),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.manrope(
            fontSize: 13,
            height: 1.4,
            color: const Color(0xFF6A7C86),
          ),
        ),
      ],
    );
  }
}

class _OverviewTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  const _OverviewTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4EEEC)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 18, color: accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6A7C86),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.sora(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF17303B),
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

class _ModeSelector extends StatelessWidget {
  final CreditWithdrawalMode selectedMode;
  final ValueChanged<CreditWithdrawalMode> onSelected;

  const _ModeSelector({required this.selectedMode, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F7F6),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          for (final mode in CreditWithdrawalMode.values)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _ModeChip(
                  label: _modeLabel(mode),
                  selected: selectedMode == mode,
                  onTap: () => onSelected(mode),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static String _modeLabel(CreditWithdrawalMode mode) {
    switch (mode) {
      case CreditWithdrawalMode.instant:
        return 'All at once';
      case CreditWithdrawalMode.daily:
        return 'Daily';
      case CreditWithdrawalMode.weekly:
        return 'Weekly';
    }
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF0F9D8A) : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : const Color(0xFF54738A),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BreakdownTile extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;

  const _BreakdownTile({
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
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6A7C86),
            ),
          ),
          const Spacer(),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.sora(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF17303B),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  final String message;
  final String actionLabel;
  final VoidCallback onTap;

  const _EmptyStateCard({
    required this.message,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4EEEC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: GoogleFonts.manrope(
              fontSize: 13,
              height: 1.4,
              color: const Color(0xFF48616C),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0F9D8A),
              side: const BorderSide(color: Color(0xFFBDE0DB)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              actionLabel,
              style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration _fieldDecoration(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: GoogleFonts.manrope(
      fontWeight: FontWeight.w700,
      color: const Color(0xFF6A7C86),
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Color(0xFFD8E8E5)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Color(0xFF0F9D8A), width: 1.4),
    ),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
  );
}

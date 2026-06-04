import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/savings_plan.dart';
import '../../providers/auth_provider.dart';
import '../../providers/savings_provider.dart';
import '../../utils/currency_util.dart';
import '../../widgets/dashboard_kit.dart';
import '../../widgets/app_button.dart';
import 'deposit_screen.dart';

class CreatePlanScreen extends StatelessWidget {
  const CreatePlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardPage(
      eyebrow: 'Nzelu Savings Planner',
      title: 'Create a plan and fund it first',
      subtitle:
          'Choose the title, target, and first deposit. The app now sends you straight to the deposit step before setup is complete.',
      children: [
        SavingsPlanComposer(),
      ],
    );
  }
}

class SavingsPlanComposer extends StatefulWidget {
  final bool embedded;

  const SavingsPlanComposer({
    super.key,
    this.embedded = false,
  });

  @override
  State<SavingsPlanComposer> createState() => _SavingsPlanComposerState();
}

class _SavingsPlanComposerState extends State<SavingsPlanComposer> {
  final _titleController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _startingAmountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  PenaltyPolicy _penaltyPolicy = PenaltyPolicy.monetaryDeduction;
  PlanFrequency _frequency = PlanFrequency.weekly;
  final DateTime _startDate = DateTime.now();
  DateTime _deadline = DateTime.now().add(const Duration(days: 180));
  bool _goalLockEnabled = false;
  bool _isProcessing = false;

  @override
  void dispose() {
    _titleController.dispose();
    _targetAmountController.dispose();
    _startingAmountController.dispose();
    super.dispose();
  }

  double get _targetAmount => double.tryParse(_targetAmountController.text.trim()) ?? 0;

  double get _startingAmount =>
      double.tryParse(_startingAmountController.text.trim()) ?? 0;

  double get _remainingTarget {
    final remaining = _targetAmount - _startingAmount;
    return remaining <= 0 ? 0 : remaining;
  }

  double get _currentAmount => _startingAmount;

  int get _remainingDays {
    final days = _deadline.difference(DateTime.now()).inDays;
    return days <= 0 ? 1 : days;
  }

  int get _durationMonths {
    final months = (_deadline.difference(_startDate).inDays / 30).ceil();
    return months <= 0 ? 1 : months;
  }

  double get _perDay => _remainingTarget <= 0 ? 0 : _remainingTarget / _remainingDays;

  double get _perWeek {
    if (_remainingTarget <= 0) return 0;
    final weeks = (_remainingDays / 7).ceil();
    return _remainingTarget / (weeks <= 0 ? 1 : weeks);
  }

  double get _perMonth {
    if (_remainingTarget <= 0) return 0;
    final months = (_remainingDays / 30).ceil();
    return _remainingTarget / (months <= 0 ? 1 : months);
  }

  double get _selectedAmount {
    switch (_frequency) {
      case PlanFrequency.daily:
        return _perDay;
      case PlanFrequency.weekly:
      case PlanFrequency.biweekly:
        return _perWeek;
      case PlanFrequency.monthly:
        return _perMonth;
    }
  }

  String get _selectedLabel {
    switch (_frequency) {
      case PlanFrequency.daily:
        return 'Save ${CurrencyUtil.formatNoDecimal(_selectedAmount)} / day';
      case PlanFrequency.weekly:
      case PlanFrequency.biweekly:
        return 'Save ${CurrencyUtil.formatNoDecimal(_selectedAmount)} / week';
      case PlanFrequency.monthly:
        return 'Save ${CurrencyUtil.formatNoDecimal(_selectedAmount)} / month';
    }
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final narrow = width < 760;
    final isDark = false;
    final titleColor = isDark ? Colors.white : const Color(0xFF171412);
    final bodyColor = isDark ? const Color(0xFFD8E0EB) : const Color(0xFF6F665C);
    final fieldFill = isDark
        ? const Color(0xAA131C27)
        : Colors.white.withValues(alpha: 0.7);
    final fieldBorder = isDark ? const Color(0x335F6E80) : const Color(0xFFE6DAC7);

    return DashboardPanel(
      glowColor: _accentForFrequency(_frequency),
      width: double.infinity,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('Plan Setup'),
            const SizedBox(height: 12),
            Text(
              'Set the target, deadline, and frequency in one place. The contribution amount updates instantly below just like the reference cards.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                height: 1.45,
                color: bodyColor,
              ),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _titleController,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => setState(() {}),
              style: GoogleFonts.poppins(color: titleColor),
              decoration: _fieldDecoration(
                'Savings title',
                icon: Icons.bookmark_border_rounded,
                fillColor: fieldFill,
                borderColor: fieldBorder,
                hintColor: isDark
                    ? const Color(0xFF9BA8B7)
                    : const Color(0xFF8B7E6B),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter a plan title';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            _moneyField(
              controller: _targetAmountController,
              hint: 'Target amount',
              onChanged: (_) => setState(() {}),
              validator: (value) {
                final parsed = double.tryParse((value ?? '').trim());
                if (parsed == null || parsed <= 0) return 'Enter target amount';
                return null;
              },
            ),
            const SizedBox(height: 12),
            _moneyField(
              controller: _startingAmountController,
              hint: 'Starting saving amount',
              onChanged: (_) => setState(() {}),
              validator: (value) {
                final parsed = double.tryParse((value ?? '').trim());
                if (parsed == null || parsed <= 0) {
                  return 'Enter starting deposit amount';
                }
                if (_targetAmount > 0 && parsed > _targetAmount) {
                  return 'Starting amount cannot be more than target';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDeadline,
              borderRadius: BorderRadius.circular(18),
              child: Ink(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: fieldFill,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: fieldBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event_outlined, color: Color(0xFF0ABAB5)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('dd MMM yyyy').format(_deadline),
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: titleColor,
                            ),
                          ),
                          Text(
                            '$_remainingDays days remaining',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: bodyColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Deadline',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0ABAB5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _sectionLabel('Saving Frequency'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _FrequencyChip(
                  label: 'Daily',
                  selected: _frequency == PlanFrequency.daily,
                  color: const Color(0xFFD55C4B),
                  onTap: () => setState(() => _frequency = PlanFrequency.daily),
                ),
                _FrequencyChip(
                  label: 'Weekly',
                  selected: _frequency == PlanFrequency.weekly,
                  color: const Color(0xFF3B9D5D),
                  onTap: () => setState(() => _frequency = PlanFrequency.weekly),
                ),
                _FrequencyChip(
                  label: 'Monthly',
                  selected: _frequency == PlanFrequency.monthly,
                  color: const Color(0xFF0ABAB5),
                  onTap: () => setState(() => _frequency = PlanFrequency.monthly),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _sectionLabel('Withdrawal Control Options'),
            const SizedBox(height: 10),
            Text(
              'After you miss your daily, weekly, or monthly target, there is a 3-day grace period before the selected penalty is applied. Goal Lock keeps withdrawals blocked until the target is complete.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                height: 1.45,
                color: bodyColor,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _PolicyChip(
                  label: 'Money Deduction',
                  description: 'Deduct money after grace period',
                  selected: _penaltyPolicy == PenaltyPolicy.monetaryDeduction,
                  color: const Color(0xFFB98A2D),
                  onTap: () => setState(
                    () => _penaltyPolicy = PenaltyPolicy.monetaryDeduction,
                  ),
                ),
                _PolicyChip(
                  label: 'Phone Lock',
                  description: 'Restrict app access after grace period',
                  selected: _penaltyPolicy == PenaltyPolicy.appRestriction,
                  color: const Color(0xFF4C6A78),
                  onTap: () => setState(
                    () => _penaltyPolicy = PenaltyPolicy.appRestriction,
                  ),
                ),
                _PolicyChip(
                  label: 'Goal Lock',
                  description: 'Block withdrawal until target is reached',
                  selected: _goalLockEnabled,
                  color: const Color(0xFFD96069),
                  onTap: () => setState(
                    () => _goalLockEnabled = !_goalLockEnabled,
                  ),
                ),
              ],
            ),
            if (_goalLockEnabled) ...[
              const SizedBox(height: 12),
              _GoalLockPreview(
                progress: _targetAmount <= 0 ? 0 : (_currentAmount / _targetAmount).clamp(0, 1).toDouble(),
                remaining: _remainingTarget,
              ),
            ],
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xCC131C27)
                    : Colors.white.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: fieldBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('Smart Savings Engine'),
                  const SizedBox(height: 10),
                  Text(
                    _selectedLabel,
                    style: GoogleFonts.poppins(
                      fontSize: narrow ? 28 : 32,
                      height: 0.96,
                      color: titleColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your first deposit is required before setup is complete. The remaining contribution updates after that starting amount.',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      height: 1.45,
                      color: bodyColor,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _InsightCard(
                          label: 'Daily',
                          value: CurrencyUtil.formatNoDecimal(_perDay),
                          color: const Color(0xFFD55C4B),
                          darkMode: isDark,
                        ),
                        const SizedBox(width: 8),
                        _InsightCard(
                          label: 'Weekly',
                          value: CurrencyUtil.formatNoDecimal(_perWeek),
                          color: const Color(0xFF3B9D5D),
                          darkMode: isDark,
                        ),
                        const SizedBox(width: 8),
                        _InsightCard(
                          label: 'Monthly',
                          value: CurrencyUtil.formatNoDecimal(_perMonth),
                          color: const Color(0xFFC21A03),
                          darkMode: isDark,
                        ),
                        const SizedBox(width: 8),
                        _InsightCard(
                          label: 'Starting saved',
                          value: CurrencyUtil.formatNoDecimal(_currentAmount),
                          color: const Color(0xFF537A8A),
                          darkMode: isDark,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  DashboardInfoRow(
                    label: 'Target',
                    value: CurrencyUtil.formatNoDecimal(_targetAmount),
                  ),
                  DashboardInfoRow(
                    label: 'Saved amount',
                    value: CurrencyUtil.formatNoDecimal(_currentAmount),
                    valueColor: const Color(0xFF537A8A),
                  ),
                  DashboardInfoRow(
                    label: 'Still needed',
                    value: CurrencyUtil.formatNoDecimal(_remainingTarget),
                  ),
                  DashboardInfoRow(
                    label: 'Deadline',
                    value: DateFormat('dd MMM yyyy').format(_deadline),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            AppButton(
              label: 'CREATE PLAN & GO TO DEPOSIT',
              icon: Icons.rocket_launch_rounded,
              isLoading: _isProcessing,
              width: double.infinity,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(
    String hint, {
    required IconData icon,
    required Color fillColor,
    required Color borderColor,
    required Color hintColor,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: hintColor),
      prefixIcon: Icon(icon, color: hintColor),
      filled: true,
      fillColor: fillColor,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFF0ABAB5)),
      ),
    );
  }

  Widget _moneyField({
    required TextEditingController controller,
    required String hint,
    required ValueChanged<String> onChanged,
    required String? Function(String?) validator,
  }) {
    final isDark = false;

    return TextFormField(
      controller: controller,
      style: GoogleFonts.poppins(
        color: isDark ? Colors.white : const Color(0xFF171412),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
      validator: validator,
      decoration: _fieldDecoration(
        hint,
        icon: Icons.attach_money_rounded,
        fillColor: isDark
            ? const Color(0xAA131C27)
            : Colors.white.withValues(alpha: 0.7),
        borderColor:
            isDark ? const Color(0x335F6E80) : const Color(0xFFE6DAC7),
        hintColor:
            isDark ? const Color(0xFF9BA8B7) : const Color(0xFF8B7E6B),
      ).copyWith(
        prefixText: 'MK ',
        prefixStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0ABAB5),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.poppins(
        fontSize: 14,
        letterSpacing: 1.8,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF0ABAB5),
      ),
    );
  }

  Color _accentForFrequency(PlanFrequency frequency) {
    switch (frequency) {
      case PlanFrequency.daily:
        return const Color(0x66D55C4B);
      case PlanFrequency.weekly:
      case PlanFrequency.biweekly:
        return const Color(0x663B9D5D);
      case PlanFrequency.monthly:
        return const Color(0x66D4AF37);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    final auth = context.read<AuthProvider>();
    final savings = context.read<SavingsProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final createdPlan = await savings.addPlan(
      SavingsPlan(
        id: '',
        userId: auth.user?.id ?? '',
        title: _titleController.text.trim(),
        amountPerPeriod: _selectedAmount,
        frequency: _frequency,
        durationMonths: _durationMonths,
        startDate: _startDate,
        endDate: _deadline,
        penaltyPolicy: _penaltyPolicy,
        goalAmount: _targetAmount,
        currentAmount: 0,
        goalLockEnabled: _goalLockEnabled,
      ),
    );

    if (!mounted) return;

    setState(() => _isProcessing = false);

    if (createdPlan != null) {
      final route = MaterialPageRoute<void>(
        builder: (_) => const DepositScreen(),
        settings: RouteSettings(
          arguments: DepositScreenArgs(
            planId: createdPlan.id,
            initialAmount: _startingAmount,
            lockPlan: true,
            requireDeposit: true,
            planTitle: createdPlan.title,
          ),
        ),
      );
      if (widget.embedded) {
        Navigator.of(context).push(route);
      } else {
        Navigator.of(context).pushReplacement(route);
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Plan created for ${createdPlan.title}. Make the first deposit to continue.',
          ),
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(savings.error ?? 'Failed to create savings plan.')),
      );
    }
  }
}

class _FrequencyChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _FrequencyChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = false;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.12)
              : isDark
                  ? const Color(0xAA131C27)
                  : Colors.white.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? color
                : isDark
                    ? const Color(0x335F6E80)
                    : const Color(0xFFE6DAC7),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected
                ? color
                : isDark
                    ? const Color(0xFFD8E0EB)
                    : const Color(0xFF6F665C),
          ),
        ),
      ),
    );
  }
}

class _PolicyChip extends StatelessWidget {
  final String label;
  final String description;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _PolicyChip({
    required this.label,
    required this.description,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = false;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 170,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.12)
              : isDark
                  ? const Color(0xAA131C27)
                  : Colors.white.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? color
                : isDark
                    ? const Color(0x335F6E80)
                    : const Color(0xFFE6DAC7),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: selected
                    ? color
                    : isDark
                        ? Colors.white
                        : const Color(0xFF171412),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 11,
                height: 1.35,
                color: isDark
                    ? const Color(0xFFD8E0EB)
                    : const Color(0xFF6F665C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalLockPreview extends StatelessWidget {
  final double progress;
  final double remaining;

  const _GoalLockPreview({
    required this.progress,
    required this.remaining,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = false;
    final locked = progress < 1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: locked
            ? const Color(0xFFD96069).withValues(alpha: 0.10)
            : const Color(0xFF0F9D8A).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: locked ? const Color(0xFFF0C7CB) : const Color(0xFF9DD7CB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                locked ? Icons.lock_rounded : Icons.celebration_rounded,
                size: 18,
                color: locked ? const Color(0xFFD96069) : const Color(0xFF0F9D8A),
              ),
              const SizedBox(width: 8),
              Text(
                locked ? 'Withdrawal Locked' : 'Goal Achieved',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: locked ? const Color(0xFFD96069) : const Color(0xFF0F9D8A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: isDark ? const Color(0x335F6E80) : const Color(0xFFE6DAC7),
            valueColor: AlwaysStoppedAnimation<Color>(
              locked ? const Color(0xFFD96069) : const Color(0xFF0F9D8A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            locked
                ? 'Complete your savings target to unlock withdrawals. Remaining: ${CurrencyUtil.formatNoDecimal(remaining)}'
                : 'Withdrawals unlock automatically once the goal is complete.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              height: 1.35,
              color: isDark ? const Color(0xFFD8E0EB) : const Color(0xFF6F665C),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool darkMode;

  const _InsightCard({
    required this.label,
    required this.value,
    required this.color,
    required this.darkMode,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardPanel(
      width: 118,
      glowColor: color,
      padding: const EdgeInsets.all(10),
      child: SizedBox(
        height: 78,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: 10,
                letterSpacing: 1.1,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: darkMode ? Colors.white : const Color(0xFF171412),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

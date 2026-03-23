import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/savings_plan.dart';
import '../../providers/auth_provider.dart';
import '../../providers/savings_provider.dart';
import '../../utils/currency_util.dart';
import '../../widgets/dashboard_kit.dart';
import '../../widgets/gold_button.dart';

class CreatePlanScreen extends StatelessWidget {
  const CreatePlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardPage(
      eyebrow: 'Savings Planner',
      title: 'Create a plan from the target backward',
      subtitle:
          'Choose the goal amount, deadline, and rhythm. The dashboard starts the plan at zero and calculates the saving rate automatically.',
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
  final _formKey = GlobalKey<FormState>();
  PenaltyPolicy _penaltyPolicy = PenaltyPolicy.monetaryDeduction;
  PlanFrequency _frequency = PlanFrequency.weekly;
  final DateTime _startDate = DateTime.now();
  DateTime _deadline = DateTime.now().add(const Duration(days: 180));
  bool _isProcessing = false;

  @override
  void dispose() {
    _titleController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  double get _targetAmount => double.tryParse(_targetAmountController.text.trim()) ?? 0;

  double get _currentAmount => 0;

  int get _remainingDays {
    final days = _deadline.difference(DateTime.now()).inDays;
    return days <= 0 ? 1 : days;
  }

  int get _durationMonths {
    final months = (_deadline.difference(_startDate).inDays / 30).ceil();
    return months <= 0 ? 1 : months;
  }

  double get _perDay => _targetAmount <= 0 ? 0 : _targetAmount / _remainingDays;

  double get _perWeek {
    if (_targetAmount <= 0) return 0;
    final weeks = (_remainingDays / 7).ceil();
    return _targetAmount / (weeks <= 0 ? 1 : weeks);
  }

  double get _perMonth {
    if (_targetAmount <= 0) return 0;
    final months = (_remainingDays / 30).ceil();
    return _targetAmount / (months <= 0 ? 1 : months);
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
    final compact = MediaQuery.sizeOf(context).width < 760;

    final formPanel = DashboardPanel(
      glowColor: _accentForFrequency(_frequency),
      width: widget.embedded ? 420 : (compact ? 320 : 440),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('Plan Setup'),
            const SizedBox(height: 14),
            TextFormField(
              controller: _titleController,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => setState(() {}),
              style: GoogleFonts.inter(color: const Color(0xFF171412)),
              decoration: _fieldDecoration(
                'Savings title',
                icon: Icons.bookmark_border_rounded,
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
            InkWell(
              onTap: _pickDeadline,
              borderRadius: BorderRadius.circular(18),
              child: Ink(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE6DAC7)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event_outlined, color: Color(0xFFB98A2D)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('dd MMM yyyy').format(_deadline),
                            style: GoogleFonts.oswald(
                              fontSize: 20,
                              color: const Color(0xFF171412),
                            ),
                          ),
                          Text(
                            '$_remainingDays days remaining',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: const Color(0xFF6F665C),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Deadline',
                      style: GoogleFonts.oswald(
                        fontSize: 14,
                        color: const Color(0xFFB98A2D),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            _sectionLabel('Saving Frequency'),
            const SizedBox(height: 10),
            DashboardHorizontalRail(
              gap: 10,
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
                  color: const Color(0xFFB98A2D),
                  onTap: () => setState(() => _frequency = PlanFrequency.monthly),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    final intelligencePanel = DashboardPanel(
      glowColor: _accentForFrequency(_frequency),
      width: widget.embedded ? 480 : (compact ? 320 : 560),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Smart Savings Engine'),
          const SizedBox(height: 12),
          Text(
            _selectedLabel,
            style: GoogleFonts.oswald(
              fontSize: compact ? 26 : 30,
              height: 0.96,
              color: const Color(0xFF171412),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Saved amount starts at MK 0. The required contribution updates instantly from your target, deadline, and chosen frequency.',
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.45,
              color: const Color(0xFF6F665C),
            ),
          ),
          const SizedBox(height: 14),
          DashboardHorizontalRail(
            children: [
              _InsightCard(
                label: 'Daily',
                value: CurrencyUtil.formatNoDecimal(_perDay),
                color: const Color(0xFFD55C4B),
              ),
              _InsightCard(
                label: 'Weekly',
                value: CurrencyUtil.formatNoDecimal(_perWeek),
                color: const Color(0xFF3B9D5D),
              ),
              _InsightCard(
                label: 'Monthly',
                value: CurrencyUtil.formatNoDecimal(_perMonth),
                color: const Color(0xFFB98A2D),
              ),
              _InsightCard(
                label: 'Starting saved',
                value: CurrencyUtil.formatNoDecimal(_currentAmount),
                color: const Color(0xFF537A8A),
              ),
            ],
          ),
          const SizedBox(height: 14),
          DashboardInfoRow(
            label: 'Target',
            value: CurrencyUtil.formatNoDecimal(_targetAmount),
          ),
          DashboardInfoRow(
            label: 'Saved amount',
            value: 'MK 0',
            valueColor: const Color(0xFF537A8A),
          ),
          DashboardInfoRow(
            label: 'Deadline',
            value: DateFormat('dd MMM yyyy').format(_deadline),
          ),
          const SizedBox(height: 14),
          GoldButton(
            label: 'CREATE SAVINGS PLAN',
            icon: Icons.rocket_launch_rounded,
            isLoading: _isProcessing,
            width: double.infinity,
            onPressed: _submit,
          ),
        ],
      ),
    );

    return DashboardHorizontalRail(
      children: [
        formPanel,
        intelligencePanel,
      ],
    );
  }

  InputDecoration _fieldDecoration(String hint, {required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: const Color(0xFF8B7E6B)),
      prefixIcon: Icon(icon, color: const Color(0xFF8B7E6B)),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.7),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFE6DAC7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFB98A2D)),
      ),
    );
  }

  Widget _moneyField({
    required TextEditingController controller,
    required String hint,
    required ValueChanged<String> onChanged,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.inter(color: const Color(0xFF171412)),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
      validator: validator,
      decoration: _fieldDecoration(hint, icon: Icons.attach_money_rounded).copyWith(
        prefixText: 'MK ',
        prefixStyle: GoogleFonts.oswald(
          fontSize: 18,
          color: const Color(0xFFB98A2D),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.oswald(
        fontSize: 14,
        letterSpacing: 1.8,
        color: const Color(0xFFB98A2D),
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
        return const Color(0x66B98A2D);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    final auth = context.read<AuthProvider>();
    final savings = context.read<SavingsProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final success = await savings.addPlan(
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
      ),
    );

    if (!mounted) return;

    setState(() => _isProcessing = false);

    if (success) {
      if (!widget.embedded) {
        Navigator.of(context).pop();
      }
      messenger.showSnackBar(
        SnackBar(content: Text('Plan created. $_selectedLabel.')),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? color : const Color(0xFFE6DAC7)),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? color : const Color(0xFF6F665C),
          ),
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InsightCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardPanel(
      width: 150,
      glowColor: color,
      padding: const EdgeInsets.all(14),
      child: SizedBox(
        height: 108,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: GoogleFonts.oswald(
                fontSize: 12,
                letterSpacing: 1.4,
                color: color,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: GoogleFonts.oswald(
                fontSize: 22,
                color: const Color(0xFF171412),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

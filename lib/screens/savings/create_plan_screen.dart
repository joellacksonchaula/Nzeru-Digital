import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../models/savings_plan.dart';
import '../../providers/auth_provider.dart';
import '../../providers/savings_provider.dart';
import '../../utils/currency_util.dart';
import '../../widgets/dashboard_kit.dart';
import '../../widgets/gold_button.dart';

class CreatePlanScreen extends StatefulWidget {
  const CreatePlanScreen({super.key});

  @override
  State<CreatePlanScreen> createState() => _CreatePlanScreenState();
}

class _CreatePlanScreenState extends State<CreatePlanScreen> {
  final _titleController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _currentAmountController = TextEditingController(text: '0');
  final _formKey = GlobalKey<FormState>();
  PenaltyPolicy _penaltyPolicy = PenaltyPolicy.monetaryDeduction;
  DateTime _startDate = DateTime.now();
  DateTime _deadline = DateTime.now().add(const Duration(days: 180));
  bool _isProcessing = false;

  @override
  void dispose() {
    _titleController.dispose();
    _targetAmountController.dispose();
    _currentAmountController.dispose();
    super.dispose();
  }

  double get _targetAmount =>
      double.tryParse(_targetAmountController.text.trim()) ?? 0;

  double get _currentAmount =>
      double.tryParse(_currentAmountController.text.trim()) ?? 0;

  double get _remainingAmount => (_targetAmount - _currentAmount).clamp(0, _targetAmount);

  int get _remainingDays {
    final days = _deadline.difference(DateTime.now()).inDays;
    return days <= 0 ? 1 : days;
  }

  int get _durationMonths {
    final months = (_deadline.difference(_startDate).inDays / 30).ceil();
    return months <= 0 ? 1 : months;
  }

  double get _perDay => _remainingAmount <= 0 ? 0 : _remainingAmount / _remainingDays;

  double get _perWeek {
    if (_remainingAmount <= 0) return 0;
    final weeks = (_remainingDays / 7).ceil();
    return _remainingAmount / (weeks <= 0 ? 1 : weeks);
  }

  double get _perMonth {
    if (_remainingAmount <= 0) return 0;
    final months = (_remainingDays / 30).ceil();
    return _remainingAmount / (months <= 0 ? 1 : months);
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (picked != null) {
      setState(() {
        _deadline = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DashboardPage(
      eyebrow: 'Savings Planner',
      title: 'Create a smarter savings target',
      subtitle:
          'Set the goal, add what you have already saved, and we will calculate the pace you need each day, week, and month.',
      children: [
        DashboardPanel(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel('Plan title'),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Phone, Car, Rent, Vacation...',
                    prefixIcon: Icon(Icons.bookmark_border_rounded),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter a plan title';
                    }
                    if (value.trim().length < 2) {
                      return 'Title must be at least 2 characters';
                    }
                    return null;
                  },
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 20),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final stacked = constraints.maxWidth < 720;
                    final fields = [
                      Expanded(
                        child: _AmountField(
                          controller: _targetAmountController,
                          label: 'Target amount',
                          hint: '0.00',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter target amount';
                            }
                            final parsed = double.tryParse(value);
                            if (parsed == null || parsed <= 0) {
                              return 'Enter a valid amount';
                            }
                            return null;
                          },
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      Expanded(
                        child: _AmountField(
                          controller: _currentAmountController,
                          label: 'Current saved',
                          hint: '0.00',
                          validator: (value) {
                            final parsed = double.tryParse((value ?? '').trim());
                            if (parsed == null || parsed < 0) {
                              return 'Enter a valid amount';
                            }
                            if (parsed > _targetAmount && _targetAmount > 0) {
                              return 'Cannot exceed target';
                            }
                            return null;
                          },
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ];

                    if (stacked) {
                      return Column(
                        children: [
                          fields[0],
                          const SizedBox(height: 14),
                          fields[1],
                        ],
                      );
                    }

                    return Row(
                      children: [
                        fields[0],
                        const SizedBox(width: 14),
                        fields[1],
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                _SectionLabel('Deadline'),
                const SizedBox(height: 10),
                InkWell(
                  onTap: _pickDeadline,
                  borderRadius: BorderRadius.circular(16),
                  child: Ink(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event_outlined, color: Color(0xFF7D6038)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('dd MMM yyyy').format(_deadline),
                                style: GoogleFonts.oswald(
                                  fontSize: 20,
                                  color: const Color(0xFF23211E),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$_remainingDays days remaining',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: const Color(0xFF5E5A56),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Change',
                          style: GoogleFonts.oswald(
                            fontSize: 14,
                            color: const Color(0xFF7D6038),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _SectionLabel('Penalty policy'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _PenaltyChip(
                      label: 'Monetary',
                      icon: Icons.money_off_csred_rounded,
                      selected: _penaltyPolicy == PenaltyPolicy.monetaryDeduction,
                      onTap: () => setState(
                        () => _penaltyPolicy = PenaltyPolicy.monetaryDeduction,
                      ),
                    ),
                    _PenaltyChip(
                      label: 'Restriction',
                      icon: Icons.lock_outline_rounded,
                      selected: _penaltyPolicy == PenaltyPolicy.appRestriction,
                      onTap: () => setState(
                        () => _penaltyPolicy = PenaltyPolicy.appRestriction,
                      ),
                    ),
                    _PenaltyChip(
                      label: 'Both',
                      icon: Icons.shield_outlined,
                      selected: _penaltyPolicy == PenaltyPolicy.both,
                      onTap: () => setState(
                        () => _penaltyPolicy = PenaltyPolicy.both,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        DashboardSectionTitle(title: 'Live Contribution Plan'),
        const SizedBox(height: 10),
        DashboardStatGrid(
          items: [
            DashboardStatItem(
              label: 'Monthly',
              value: CurrencyUtil.formatNoDecimal(_perMonth),
              detail: 'Save this amount each month to stay on pace.',
              icon: Icons.calendar_month_rounded,
              accent: const Color(0xFF876446),
            ),
            DashboardStatItem(
              label: 'Weekly',
              value: CurrencyUtil.formatNoDecimal(_perWeek),
              detail: 'Your weekly target updates instantly with the deadline.',
              icon: Icons.date_range_rounded,
              accent: const Color(0xFF4C6A78),
            ),
            DashboardStatItem(
              label: 'Daily',
              value: CurrencyUtil.formatNoDecimal(_perDay),
              detail: 'Optional daily pace for more granular tracking.',
              icon: Icons.today_rounded,
              accent: const Color(0xFF6E8B5D),
            ),
            DashboardStatItem(
              label: 'Remaining',
              value: CurrencyUtil.formatNoDecimal(_remainingAmount),
              detail: 'Left to save before you hit your target.',
              icon: Icons.flag_circle_rounded,
              accent: const Color(0xFFC2545E),
            ),
          ],
        ),
        const SizedBox(height: 16),
        DashboardPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Preview',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2B2117),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _titleController.text.trim().isEmpty
                    ? 'Savings Plan'
                    : _titleController.text.trim(),
                style: GoogleFonts.oswald(
                  fontSize: 28,
                  height: 0.95,
                  color: const Color(0xFF23211E),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Save ${CurrencyUtil.formatNoDecimal(_perMonth)}/month',
                style: GoogleFonts.oswald(
                  fontSize: 18,
                  color: const Color(0xFF876446),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Save ${CurrencyUtil.formatNoDecimal(_perWeek)}/week',
                style: GoogleFonts.oswald(
                  fontSize: 18,
                  color: const Color(0xFF4C6A78),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Target ${CurrencyUtil.formatNoDecimal(_targetAmount)} by ${DateFormat('dd MMM yyyy').format(_deadline)}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF5C5A57),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        GoldButton(
          label: 'CREATE SAVINGS PLAN',
          icon: Icons.rocket_launch_rounded,
          isLoading: _isProcessing,
          width: double.infinity,
          onPressed: _submit,
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    final auth = context.read<AuthProvider>();
    final savings = context.read<SavingsProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final success = await savings.addPlan(
      SavingsPlan(
        id: '',
        userId: auth.user?.id ?? '',
        title: _titleController.text.trim(),
        amountPerPeriod: _perMonth,
        frequency: PlanFrequency.monthly,
        durationMonths: _durationMonths,
        startDate: _startDate,
        endDate: _deadline,
        penaltyPolicy: _penaltyPolicy,
        goalAmount: _targetAmount,
        currentAmount: _currentAmount,
      ),
    );

    if (!mounted) return;

    setState(() => _isProcessing = false);

    if (success) {
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Plan created. Aim for ${CurrencyUtil.formatNoDecimal(_perMonth)} each month.',
          ),
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(savings.error ?? 'Failed to create savings plan.'),
        ),
      );
    }
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.cormorantGaramond(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.8,
        color: const Color(0xFF6A5336),
      ),
    );
  }
}

class _AmountField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? Function(String?) validator;
  final ValueChanged<String> onChanged;

  const _AmountField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.validator,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: 'MK ',
            prefixStyle: GoogleFonts.oswald(
              fontSize: 18,
              color: const Color(0xFF7D6038),
            ),
          ),
        ),
      ],
    );
  }
}

class _PenaltyChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _PenaltyChip({
    required this.label,
    required this.icon,
    required this.selected,
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
          color: selected
              ? const Color(0xFFB68A25).withValues(alpha: 0.12)
              : AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFFB68A25) : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: selected ? const Color(0xFF7D6038) : AppColors.textMuted),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? const Color(0xFF7D6038) : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

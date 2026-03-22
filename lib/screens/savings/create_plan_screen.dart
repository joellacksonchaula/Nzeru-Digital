import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/app_colors.dart';
import '../../models/savings_plan.dart';
import '../../providers/auth_provider.dart';
import '../../providers/savings_provider.dart';
import '../../widgets/gold_button.dart';
import '../../utils/currency_util.dart';

class CreatePlanScreen extends StatefulWidget {
  const CreatePlanScreen({super.key});

  @override
  State<CreatePlanScreen> createState() => _CreatePlanScreenState();
}

class _CreatePlanScreenState extends State<CreatePlanScreen> {
  final _amountController = TextEditingController();
  PlanFrequency _frequency = PlanFrequency.weekly;
  int _durationMonths = 6;
  PenaltyPolicy _penaltyPolicy = PenaltyPolicy.monetaryDeduction;
  final DateTime _startDate = DateTime.now();
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // Helper method for section labels
  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.playfairDisplay(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        letterSpacing: 2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'CREATE PLAN',
          style: GoogleFonts.playfairDisplay(
            fontSize: 16,
            letterSpacing: 2,
            color: AppColors.gold,
          ),
        ),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.gold),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Savings Amount
                _sectionLabel('Savings Amount'),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    color: AppColors.gold,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: GoogleFonts.playfairDisplay(
                      color: AppColors.textMuted,
                      fontSize: 24,
                    ),
                    prefixText: 'MK ',
                    prefixStyle: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      color: AppColors.gold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter an amount';
                    if (double.tryParse(v) == null) return 'Invalid amount';
                    return null;
                  },
                ).animate().fadeIn(delay: 100.ms),

                const SizedBox(height: 28),
                // Frequency
                _sectionLabel('Frequency'),
                const SizedBox(height: 10),
                Row(
                  children: PlanFrequency.values.map((f) {
                    final isSelected = _frequency == f;
                    final labels = {
                      PlanFrequency.daily: 'Daily',
                      PlanFrequency.weekly: 'Weekly',
                      PlanFrequency.biweekly: 'Bi-Weekly',
                      PlanFrequency.monthly: 'Monthly',
                    };
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _frequency = f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.gold.withAlpha(20)
                                : AppColors.cardBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color:
                                  isSelected ? AppColors.gold : AppColors.border,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              labels[f]!,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color:
                                    isSelected ? AppColors.gold : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 28),
                // Duration
                _sectionLabel('Duration (months)'),
                const SizedBox(height: 10),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppColors.gold,
                    inactiveTrackColor: AppColors.cardBg,
                    thumbColor: AppColors.gold,
                    overlayColor: AppColors.gold.withAlpha(30),
                    valueIndicatorColor: AppColors.gold,
                    valueIndicatorTextStyle:
                        GoogleFonts.playfairDisplay(color: AppColors.background),
                  ),
                  child: Slider(
                    value: _durationMonths.toDouble(),
                    min: 1,
                    max: 24,
                    divisions: 23,
                    label: '$_durationMonths months',
                    onChanged: (v) =>
                        setState(() => _durationMonths = v.round()),
                  ),
                ).animate().fadeIn(delay: 300.ms),
                Center(
                  child: Text(
                    '$_durationMonths months',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gold,
                    ),
                  ),
                ),

                const SizedBox(height: 28),
                // Penalty Policy
                _sectionLabel('Penalty Policy'),
                const SizedBox(height: 10),
                ...[
                  (PenaltyPolicy.monetaryDeduction, 'Monetary Deduction', Icons.money_off),
                  (PenaltyPolicy.appRestriction, 'App Restriction', Icons.lock_outline),
                  (PenaltyPolicy.both, 'Both', Icons.shield_outlined),
                ].map((item) {
                  final isSelected = _penaltyPolicy == item.$1;
                  return GestureDetector(
                    onTap: () => setState(() => _penaltyPolicy = item.$1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.gold.withAlpha(15)
                            : AppColors.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.gold : AppColors.border,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(item.$3,
                              color: isSelected ? AppColors.gold : AppColors.textMuted,
                              size: 20),
                          const SizedBox(width: 14),
                          Text(
                            item.$2,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: isSelected ? AppColors.gold : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                          const Spacer(),
                          if (isSelected)
                            const Icon(Icons.check_circle, color: AppColors.gold, size: 20),
                        ],
                      ),
                    ),
                  );
                }).toList().animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 40),
                // CREATE PLAN Button
                GoldButton(
                  label: 'CREATE SAVINGS PLAN',
                  icon: Icons.rocket_launch_rounded,
                  isLoading: _isProcessing,
                  width: double.infinity,
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() => _isProcessing = true);

                      // Capture all context-dependent objects BEFORE any await
                      final auth = context.read<AuthProvider>();
                      final savings = context.read<SavingsProvider>();
                      final navigator = Navigator.of(context);
                      final messenger = ScaffoldMessenger.of(context);
                      final amount = double.parse(_amountController.text);

                      int periods;
                      switch (_frequency) {
                        case PlanFrequency.daily:
                          periods = _durationMonths * 30;
                          break;
                        case PlanFrequency.weekly:
                          periods = _durationMonths * 4;
                          break;
                        case PlanFrequency.biweekly:
                          periods = _durationMonths * 2;
                          break;
                        case PlanFrequency.monthly:
                          periods = _durationMonths;
                          break;
                      }

                      final endDate = _startDate.add(Duration(days: _durationMonths * 30));

                      final success = await savings.addPlan(
                        SavingsPlan(
                          id: '',
                          userId: auth.user?.id ?? '',
                          amountPerPeriod: amount,
                          frequency: _frequency,
                          durationMonths: _durationMonths,
                          startDate: _startDate,
                          endDate: endDate,
                          penaltyPolicy: _penaltyPolicy,
                          goalAmount: amount * periods,
                        ),
                      );

                      if (mounted) {
                        setState(() => _isProcessing = false);
                        if (success) {
                          navigator.pop();
                          messenger.showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Savings plan for ${CurrencyUtil.format(amount)} created!')),
                          );
                        } else {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                savings.error ?? 'Failed to create savings plan.',
                              ),
                            ),
                          );
                        }
                      }
                    }
                  },
                ).animate().fadeIn(delay: 500.ms),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
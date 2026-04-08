import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../models/savings_plan.dart';
import '../../models/savings_transaction.dart';
import '../../providers/auth_provider.dart';
import '../../providers/savings_provider.dart';
import '../../widgets/dashboard_kit.dart';
import '../../widgets/gold_button.dart';

class DepositScreenArgs {
  final String? planId;
  final double? initialAmount;
  final bool lockPlan;
  final bool requireDeposit;
  final String? planTitle;

  const DepositScreenArgs({
    this.planId,
    this.initialAmount,
    this.lockPlan = false,
    this.requireDeposit = false,
    this.planTitle,
  });
}

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final _amountController = TextEditingController();
  String? _selectedPlanId;
  bool _isProcessing = false;
  bool _initializedFromArgs = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  DepositScreenArgs? _routeArgs(BuildContext context) {
    final raw = ModalRoute.of(context)?.settings.arguments;
    return raw is DepositScreenArgs ? raw : null;
  }

  @override
  Widget build(BuildContext context) {
    final savings = context.watch<SavingsProvider>();
    final args = _routeArgs(context);
    final activePlans = savings.plans.where((p) => p.isActive).toList();

    if (!_initializedFromArgs) {
      _initializedFromArgs = true;
      _selectedPlanId = args?.planId;
      if ((args?.initialAmount ?? 0) > 0) {
        _amountController.text = args!.initialAmount!.toStringAsFixed(2);
      }
    }

    SavingsPlan? lockedPlan;
    if (args?.planId != null) {
      for (final plan in activePlans) {
        if (plan.id == args!.planId) {
          lockedPlan = plan;
          break;
        }
      }
    }

    final displayedPlans =
        args?.lockPlan == true && lockedPlan != null ? [lockedPlan] : activePlans;

    return WillPopScope(
      onWillPop: () async {
        if (args?.requireDeposit == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Make the first deposit to finish setting up this savings plan.',
              ),
            ),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'MAKE DEPOSIT',
            style: GoogleFonts.playfairDisplay(
              fontSize: 16,
              letterSpacing: 2,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.faluRed,
          automaticallyImplyLeading: args?.requireDeposit != true,
          leading: args?.requireDeposit == true
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
        ),
        body: Stack(
          children: [
            const DashboardBackdrop(darkMode: false),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.tiffanyBlue.withAlpha(15),
                          border: Border.all(
                            color: AppColors.tiffanyBlue.withAlpha(40),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.savings_rounded,
                          color: AppColors.tiffanyBlue,
                          size: 40,
                        ),
                      ),
                    ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                    if (args?.requireDeposit == true) ...[
                      const SizedBox(height: 22),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.tiffanyBlue.withAlpha(14),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.tiffanyBlue.withAlpha(40),
                          ),
                        ),
                        child: Text(
                          'Complete the first deposit for ${args?.planTitle ?? 'your new plan'} before leaving this setup.',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 30),
                    Text(
                      'SELECT PLAN',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...displayedPlans.map((plan) {
                      final isSelected = _selectedPlanId == plan.id;
                      return GestureDetector(
                        onTap: args?.lockPlan == true
                            ? null
                            : () => setState(() => _selectedPlanId = plan.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.tiffanyBlue.withAlpha(15)
                                : AppColors.cardBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  isSelected ? AppColors.tiffanyBlue : AppColors.border,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.savings_outlined,
                                color: isSelected
                                    ? AppColors.tiffanyBlue
                                    : AppColors.textMuted,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '${plan.title} - ${plan.frequencyLabel} - MK${plan.amountPerPeriod.toStringAsFixed(2)}/period',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: isSelected
                                        ? AppColors.tiffanyBlue
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: AppColors.tiffanyBlue,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 28),
                    Text(
                      'AMOUNT',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 32,
                        color: AppColors.tiffanyBlue,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        hintStyle: GoogleFonts.playfairDisplay(
                          color: AppColors.textMuted,
                          fontSize: 32,
                        ),
                        prefixText: 'MK ',
                        prefixStyle: GoogleFonts.playfairDisplay(
                          fontSize: 32,
                          color: AppColors.tiffanyBlue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 40),
                    GoldButton(
                      label: args?.requireDeposit == true
                          ? 'MAKE FIRST DEPOSIT'
                          : 'CONFIRM DEPOSIT',
                      icon: Icons.check_circle_outline,
                      isLoading: _isProcessing,
                      width: double.infinity,
                      onPressed: () async {
                        final amount = double.tryParse(_amountController.text);
                        if (amount == null || amount <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Enter a valid amount')),
                          );
                          return;
                        }
                        if (_selectedPlanId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Select a savings plan')),
                          );
                          return;
                        }

                        final auth = context.read<AuthProvider>();
                        setState(() => _isProcessing = true);
                        final navigator = Navigator.of(context);
                        final messenger = ScaffoldMessenger.of(context);

                        final success = await savings.addDeposit(
                          SavingsTransaction(
                            id: '',
                            userId: auth.user?.id ?? '',
                            planId: _selectedPlanId,
                            amount: amount,
                            date: DateTime.now(),
                            type: TransactionType.deposit,
                            description: args?.requireDeposit == true
                                ? 'Initial plan deposit'
                                : 'Manual deposit',
                          ),
                        );

                        if (!mounted) return;

                        setState(() => _isProcessing = false);
                        if (success) {
                          navigator.pop();
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                'Deposited MK${amount.toStringAsFixed(2)} successfully!',
                              ),
                            ),
                          );
                        } else {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Failed to record deposit.'),
                            ),
                          );
                        }
                      },
                    ).animate().fadeIn(delay: 300.ms),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

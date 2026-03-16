import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/app_colors.dart';
import '../../models/savings_transaction.dart';
import '../../providers/auth_provider.dart';
import '../../providers/savings_provider.dart';
import '../../widgets/gold_button.dart';


class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final _amountController = TextEditingController();
  String? _selectedPlanId;
  bool _isProcessing = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final savings = context.watch<SavingsProvider>();
    final activePlans = savings.plans.where((p) => p.isActive).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('MAKE DEPOSIT',
            style: GoogleFonts.orbitron(
                fontSize: 16, letterSpacing: 2, color: AppColors.gold)),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.gold),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Deposit icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.gold.withAlpha(15),
                    border: Border.all(
                        color: AppColors.gold.withAlpha(40), width: 2),
                  ),
                  child: const Icon(Icons.savings_rounded,
                      color: AppColors.gold, size: 40),
                ),
              ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

              const SizedBox(height: 30),

              // Select plan
              Text('SELECT PLAN',
                  style: GoogleFonts.orbitron(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      letterSpacing: 2)),
              const SizedBox(height: 10),
              ...activePlans.map((plan) {
                final isSelected = _selectedPlanId == plan.id;
                return GestureDetector(
                  onTap: () => setState(() => _selectedPlanId = plan.id),
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
                        Icon(Icons.savings_outlined,
                            color: isSelected
                                ? AppColors.gold
                                : AppColors.textMuted,
                            size: 20),
                        const SizedBox(width: 12),
                        Text(
                          '${plan.frequencyLabel} Plan — \$${plan.amountPerPeriod.toStringAsFixed(0)}/period',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: isSelected
                                ? AppColors.gold
                                : AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        if (isSelected)
                          const Icon(Icons.check_circle,
                              color: AppColors.gold, size: 20),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 28),
              Text('AMOUNT',
                  style: GoogleFonts.orbitron(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      letterSpacing: 2)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.orbitron(
                  fontSize: 32,
                  color: AppColors.gold,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  hintText: '0.00',
                  hintStyle: GoogleFonts.orbitron(
                    color: AppColors.textMuted,
                    fontSize: 32,
                  ),
                  prefixText: '\$ ',
                  prefixStyle: GoogleFonts.orbitron(
                    fontSize: 32,
                    color: AppColors.gold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 40),

              GoldButton(
                label: 'CONFIRM DEPOSIT',
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

                  final success = await savings.addDeposit(SavingsTransaction(
                    id: '',
                    userId: auth.user?.id ?? '',
                    planId: _selectedPlanId,
                    amount: amount,
                    date: DateTime.now(),
                    type: TransactionType.deposit,
                    description: 'Manual deposit',
                  ));

                  if (mounted) {
                    setState(() => _isProcessing = false);
                    if (success) {
                      navigator.pop();
                      messenger.showSnackBar(
                        SnackBar(
                            content: Text(
                                'Deposited \$${amount.toStringAsFixed(0)} successfully!')),
                      );
                    } else {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Failed to record deposit.')),
                      );
                    }
                  }
                },
              ).animate().fadeIn(delay: 300.ms),
            ],
          ),
        ),
      ),
    );
  }
}

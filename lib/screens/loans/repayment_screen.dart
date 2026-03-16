import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/app_colors.dart';
import '../../models/loan_payment.dart';
import '../../providers/loan_provider.dart';
import '../../widgets/gold_button.dart';

class RepaymentScreen extends StatefulWidget {
  const RepaymentScreen({super.key});

  @override
  State<RepaymentScreen> createState() => _RepaymentScreenState();
}

class _RepaymentScreenState extends State<RepaymentScreen> {
  final _amountController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loans = context.watch<LoanProvider>();
    final activeLoan = loans.activeLoan;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('MAKE PAYMENT',
            style: GoogleFonts.orbitron(
                fontSize: 16, letterSpacing: 2, color: AppColors.gold)),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.gold),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: activeLoan == null
          ? Center(
              child: Text('No active loan',
                  style: GoogleFonts.inter(color: AppColors.textMuted)))
          : SafeArea(
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
                          color: AppColors.gold.withAlpha(15),
                          border: Border.all(
                              color: AppColors.gold.withAlpha(40), width: 2),
                        ),
                        child: const Icon(Icons.payment_rounded,
                            color: AppColors.gold, size: 40),
                      ),
                    ).animate().scale(
                        duration: 500.ms, curve: Curves.elasticOut),

                    const SizedBox(height: 24),

                    // Remaining balance info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: AppColors.border, width: 0.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Remaining Balance',
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppColors.textMuted)),
                              const SizedBox(height: 4),
                              Text(
                                  '\$ ${activeLoan.remainingBalance.toStringAsFixed(0)}',
                                  style: GoogleFonts.orbitron(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Suggested',
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppColors.textMuted)),
                              const SizedBox(height: 4),
                              Text(
                                  '\$ ${activeLoan.monthlyPayment.toStringAsFixed(0)}',
                                  style: GoogleFonts.orbitron(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.gold)),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 30),

                    Text('PAYMENT AMOUNT',
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
                    ).animate().fadeIn(delay: 300.ms),

                    const SizedBox(height: 40),

                    GoldButton(
                      label: 'CONFIRM PAYMENT',
                      icon: Icons.check_circle_outline,
                      isLoading: _isProcessing,
                      width: double.infinity,
                      onPressed: () async {
                        final amount = double.tryParse(_amountController.text);
                        if (amount == null || amount <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Enter a valid amount')),
                          );
                          return;
                        }
                        if (amount > activeLoan.remainingBalance) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Amount exceeds remaining balance')),
                          );
                          return;
                        }

                        setState(() => _isProcessing = true);
                        final navigator = Navigator.of(context);
                        final messenger = ScaffoldMessenger.of(context);

                        final success = await loans.makePayment(LoanPayment(
                          id: '',
                          loanId: activeLoan.id,
                          amountPaid: amount,
                          paymentDate: DateTime.now(),
                          remainingBalance:
                              activeLoan.remainingBalance - amount,
                        ));

                        if (mounted) {
                          setState(() => _isProcessing = false);
                          if (success) {
                            navigator.pop();
                            messenger.showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Payment of \$${amount.toStringAsFixed(0)} successful!')),
                            );
                          } else {
                            messenger.showSnackBar(
                              const SnackBar(
                                  content: Text('Failed to make payment.')),
                            );
                          }
                        }
                      },
                    ).animate().fadeIn(delay: 400.ms),
                  ],
                ),
              ),
            ),
    );
  }
}

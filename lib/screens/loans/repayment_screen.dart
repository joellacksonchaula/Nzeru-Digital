import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../models/credit_payment.dart';
import '../../providers/credit_provider.dart';
import '../../utils/currency_util.dart';
import '../../widgets/dashboard_kit.dart';
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
    final credits = context.watch<CreditProvider>();
    final activeCredit = credits.activeCredit;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const DashboardBackdrop(darkMode: false),
          SafeArea(
            child: SingleChildScrollView(
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'NZELU CREDIT',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                letterSpacing: 2.1,
                                color: const Color(0xFF0ABAB5),
                              ),
                            ),
                            Text(
                              'Repay Credit',
                              style: GoogleFonts.poppins(
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
                  if (activeCredit == null)
                    DashboardPanel(
                      child: Text(
                        'No active credit right now.',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textMuted,
                        ),
                      ),
                    )
                  else ...[
                    DashboardPanel(
                      child: Row(
                        children: [
                          Expanded(
                            child: _BalanceItem(
                              label: 'Remaining balance',
                              value: CurrencyUtil.format(
                                activeCredit.remainingBalance,
                              ),
                            ),
                          ),
                          Expanded(
                            child: _BalanceItem(
                              label: 'Suggested payment',
                              value: CurrencyUtil.format(
                                activeCredit.suggestedRepayment,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    DashboardPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment amount',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              color: const Color(0xFF171412),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              color: AppColors.tiffanyBlue,
                            ),
                            decoration: InputDecoration(
                              hintText: '0.00',
                              prefixText: 'MK ',
                              prefixStyle: GoogleFonts.poppins(
                                fontSize: 32,
                                color: AppColors.tiffanyBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
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
                              content: Text('Enter a valid amount'),
                            ),
                          );
                          return;
                        }
                        if (amount > activeCredit.remainingBalance) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Amount exceeds remaining balance'),
                            ),
                          );
                          return;
                        }

                        setState(() => _isProcessing = true);
                        final navigator = Navigator.of(context);
                        final messenger = ScaffoldMessenger.of(context);
                        final success = await credits.makePayment(
                          CreditPayment(
                            id: '',
                            creditId: activeCredit.id,
                            amountPaid: amount,
                            paymentDate: DateTime.now(),
                            remainingBalance:
                                activeCredit.remainingBalance - amount,
                          ),
                        );

                        if (!mounted) return;
                        setState(() => _isProcessing = false);
                        if (success) {
                          navigator.pop();
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                'Payment of ${CurrencyUtil.format(amount)} successful.',
                              ),
                            ),
                          );
                        } else {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                credits.error ?? 'Failed to make payment.',
                              ),
                            ),
                          );
                        }
                      },
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
}

class _BalanceItem extends StatelessWidget {
  final String label;
  final String value;

  const _BalanceItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

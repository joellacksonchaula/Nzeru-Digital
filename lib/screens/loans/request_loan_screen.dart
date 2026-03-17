import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../config/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/loan_provider.dart';
import '../../models/loan.dart';
import '../../widgets/gold_button.dart';

class RequestLoanScreen extends StatefulWidget {
  const RequestLoanScreen({super.key});

  @override
  State<RequestLoanScreen> createState() => _RequestLoanScreenState();
}

class _RequestLoanScreenState extends State<RequestLoanScreen> {
  double _loanAmount = 500;
  int _durationMonths = 10;
  final double _interestRate = 10.0;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final loans = context.watch<LoanProvider>();
    final maxLoan =
        loans.getLoanEligibility(auth.user?.savingsBalance ?? 0);
    final totalWithInterest = _loanAmount * (1 + _interestRate / 100);
    final monthlyPayment = totalWithInterest / _durationMonths;
    final currencyFormat = NumberFormat.currency(
      locale: 'en_US',
      symbol: 'MK ',
      decimalDigits: 2,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('REQUEST LOAN',
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
              // Amount slider
              Text('LOAN AMOUNT',
                  style: GoogleFonts.orbitron(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      letterSpacing: 2)),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  currencyFormat.format(_loanAmount),
                  style: GoogleFonts.orbitron(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms),
              const SizedBox(height: 10),
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: AppColors.gold,
                  inactiveTrackColor: AppColors.cardBg,
                  thumbColor: AppColors.gold,
                  overlayColor: AppColors.gold.withAlpha(30),
                ),
                child: Slider(
                  value: _loanAmount,
                  min: 100,
                  max: maxLoan > 0 ? maxLoan : 100,
                  divisions: maxLoan > 100 ? ((maxLoan - 100) / 50).round() : 1,
                  onChanged: (v) =>
                      setState(() => _loanAmount = (v / 50).round() * 50.0),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('MK 100',
                      style: GoogleFonts.inter(
                          fontSize: 11, color: AppColors.textMuted)),
                  Text(currencyFormat.format(maxLoan),
                      style: GoogleFonts.inter(
                          fontSize: 11, color: AppColors.textMuted)),
                ],
              ),

              const SizedBox(height: 30),
              // Duration
              Text('REPAYMENT PERIOD',
                  style: GoogleFonts.orbitron(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      letterSpacing: 2)),
              const SizedBox(height: 10),
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: AppColors.gold,
                  inactiveTrackColor: AppColors.cardBg,
                  thumbColor: AppColors.gold,
                  overlayColor: AppColors.gold.withAlpha(30),
                  valueIndicatorColor: AppColors.gold,
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
              ),
              Center(
                child: Text('$_durationMonths months',
                    style: GoogleFonts.orbitron(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
              ),

              const SizedBox(height: 30),

              // Summary
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.gold.withAlpha(40)),
                ),
                child: Column(
                  children: [
                    _summaryRow('Loan Amount', currencyFormat.format(_loanAmount)),
                    const Divider(color: AppColors.border, height: 24),
                    _summaryRow('Interest Rate', '${_interestRate.toStringAsFixed(0)}%'),
                    const Divider(color: AppColors.border, height: 24),
                    _summaryRow('Total Interest',
                        currencyFormat.format(_loanAmount * _interestRate / 100)),
                    const Divider(color: AppColors.border, height: 24),
                    _summaryRow('Total Repayment',
                        currencyFormat.format(totalWithInterest)),
                    const Divider(color: AppColors.border, height: 24),
                    _summaryRow(
                      'Monthly Payment',
                      currencyFormat.format(monthlyPayment),
                      valueColor: AppColors.gold,
                    ),
                    const Divider(color: AppColors.border, height: 24),
                    // Interest distribution
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Your Interest Share',
                            style: GoogleFonts.inter(
                                fontSize: 12, color: AppColors.textMuted)),
                        Text(
                            currencyFormat.format(
                                _loanAmount * _interestRate / 100 / 2),
                            style: GoogleFonts.orbitron(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success)),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 40),

              GoldButton(
                label: 'SUBMIT REQUEST',
                icon: Icons.send_rounded,
                isLoading: _isProcessing,
                width: double.infinity,
                onPressed: () async {
                  setState(() => _isProcessing = true);
                  final navigator = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);

                  final success = await loans.requestLoan(Loan(
                    id: '',
                    userId: '',
                    amount: _loanAmount,
                    interestRate: _interestRate,
                    durationMonths: _durationMonths,
                    status: LoanStatus.pending,
                    dueDate: DateTime.now()
                        .add(Duration(days: _durationMonths * 30)),
                  ));

                  if (mounted) {
                    setState(() => _isProcessing = false);
                    if (success) {
                      navigator.pop();
                      messenger.showSnackBar(
                        const SnackBar(
                            content: Text('Loan request submitted!')),
                      );
                    } else {
                      messenger.showSnackBar(
                        const SnackBar(
                            content: Text('Failed to submit loan request.')),
                      );
                    }
                  }
                },
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 13, color: AppColors.textMuted)),
        Text(value,
            style: GoogleFonts.orbitron(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textPrimary)),
      ],
    );
  }
}

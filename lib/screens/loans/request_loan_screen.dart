import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../models/loan.dart';
import '../../providers/auth_provider.dart';
import '../../providers/loan_provider.dart';
import '../../utils/currency_util.dart';
import '../../widgets/dashboard_kit.dart';
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
    final maxLoan = loans.getLoanEligibility(auth.user?.savingsBalance ?? 0);
    final totalWithInterest = _loanAmount * (1 + _interestRate / 100);
    final monthlyPayment = totalWithInterest / _durationMonths;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const DashboardBackdrop(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
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
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'NZELU LOANS',
                              style: GoogleFonts.oswald(
                                fontSize: 13,
                                letterSpacing: 2.2,
                                color: const Color(0xFF0ABAB5),
                              ),
                            ),
                            Text(
                              'Request Loan',
                              style: GoogleFonts.oswald(
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
                  DashboardPanel(
                    glowColor: const Color(0x660ABAB5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Choose your amount',
                          style: GoogleFonts.oswald(
                            fontSize: 22,
                            color: const Color(0xFF171412),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            CurrencyUtil.format(_loanAmount),
                            style: GoogleFonts.oswald(
                              fontSize: 34,
                              color: const Color(0xFF0ABAB5),
                            ),
                          ),
                        ),
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: AppColors.loadingRed,
                            inactiveTrackColor: AppColors.tiffanyMist,
                            thumbColor: AppColors.loadingRed,
                            overlayColor: const Color(0x33801818),
                          ),
                          child: Slider(
                            value: _loanAmount,
                            min: 100,
                            max: maxLoan > 100 ? maxLoan : 101,
                            divisions: maxLoan > 100 ? ((maxLoan - 100) / 50).round() : 1,
                            onChanged: (v) =>
                                setState(() => _loanAmount = (v / 50).round() * 50.0),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('MK 100', style: GoogleFonts.inter(fontSize: 11)),
                            Text(
                              CurrencyUtil.formatNoDecimal(maxLoan),
                              style: GoogleFonts.inter(fontSize: 11),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Repayment period',
                          style: GoogleFonts.oswald(
                            fontSize: 18,
                            color: const Color(0xFF171412),
                          ),
                        ),
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: AppColors.loadingGreen,
                            inactiveTrackColor: AppColors.faluMist,
                            thumbColor: AppColors.loadingGreen,
                          ),
                          child: Slider(
                            value: _durationMonths.toDouble(),
                            min: 1,
                            max: 24,
                            divisions: 23,
                            label: '$_durationMonths months',
                            onChanged: (v) => setState(() => _durationMonths = v.round()),
                          ),
                        ),
                        Center(
                          child: Text(
                            '$_durationMonths months',
                            style: GoogleFonts.oswald(
                              fontSize: 20,
                              color: const Color(0xFF4C6A78),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  DashboardPanel(
                    glowColor: const Color(0x664B9957),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Repayment breakdown',
                          style: GoogleFonts.oswald(
                            fontSize: 22,
                            color: const Color(0xFF171412),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DashboardFixedGrid(
                          mainAxisExtent: 112,
                          children: [
                            _RequestMetric(
                              label: 'Interest',
                              value: '${_interestRate.toStringAsFixed(0)}%',
                              accent: const Color(0xFFD4AF37),
                            ),
                            _RequestMetric(
                              label: 'Total interest',
                              value: CurrencyUtil.formatCompact(
                                _loanAmount * _interestRate / 100,
                              ),
                              accent: const Color(0xFFC2545E),
                            ),
                            _RequestMetric(
                              label: 'Total repay',
                              value: CurrencyUtil.formatCompact(totalWithInterest),
                              accent: const Color(0xFF4C6A78),
                            ),
                            _RequestMetric(
                              label: 'Monthly',
                              value: CurrencyUtil.formatCompact(monthlyPayment),
                              accent: const Color(0xFF4B9957),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        DashboardInfoRow(
                          label: 'Your interest share',
                          value: CurrencyUtil.formatNoDecimal(
                            _loanAmount * _interestRate / 100 / 2,
                          ),
                          valueColor: const Color(0xFF4B9957),
                        ),
                        DashboardInfoRow(
                          label: 'Platform share',
                          value: CurrencyUtil.formatNoDecimal(
                            _loanAmount * _interestRate / 100 / 2,
                          ),
                          valueColor: const Color(0xFF4C6A78),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  GoldButton(
                    label: 'SUBMIT REQUEST',
                    icon: Icons.send_rounded,
                    isLoading: _isProcessing,
                    width: double.infinity,
                    onPressed: () async {
                      setState(() => _isProcessing = true);
                      final navigator = Navigator.of(context);
                      final messenger = ScaffoldMessenger.of(context);

                      final success = await loans.requestLoan(
                        Loan(
                          id: '',
                          userId: '',
                          amount: _loanAmount,
                          interestRate: _interestRate,
                          durationMonths: _durationMonths,
                          status: LoanStatus.pending,
                          dueDate: DateTime.now().add(
                            Duration(days: _durationMonths * 30),
                          ),
                        ),
                      );

                      if (!mounted) return;
                      setState(() => _isProcessing = false);
                      if (success) {
                        navigator.pop();
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              'Loan request for ${CurrencyUtil.format(_loanAmount)} submitted!',
                            ),
                          ),
                        );
                      } else {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(loans.error ?? 'Failed to submit loan request.'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;

  const _RequestMetric({
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardPanel(
      glowColor: accent,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.oswald(
              fontSize: 11,
              letterSpacing: 1.2,
              color: accent,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.oswald(
              fontSize: 18,
              color: const Color(0xFF171412),
            ),
          ),
        ],
      ),
    );
  }
}

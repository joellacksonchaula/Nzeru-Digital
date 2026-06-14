import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../models/ijc_group.dart';
import '../../providers/ijc_provider.dart';
import '../../utils/currency_util.dart';

class IjcDepositScreen extends StatefulWidget {
  final IjcGroup group;

  const IjcDepositScreen({required this.group, super.key});

  @override
  State<IjcDepositScreen> createState() => _IjcDepositScreenState();
}

class _IjcDepositScreenState extends State<IjcDepositScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _targetAmountController = TextEditingController();
  final TextEditingController _releaseAmountController = TextEditingController();
  String _policy = 'WEEKLY';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _policy = widget.group.cashOutPolicy.isNotEmpty ? widget.group.cashOutPolicy : 'WEEKLY';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _targetAmountController.dispose();
    _releaseAmountController.dispose();
    super.dispose();
  }

  bool get _needsConfig => widget.group.pocketType == 'SELF' && widget.group.releaseAmount <= 0;

  Future<void> _submitDeposit() async {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid amount.')));
      return;
    }

    double? totalAmount;
    double? releaseAmount;

    if (_needsConfig) {
      totalAmount = double.tryParse(_targetAmountController.text.trim()) ?? 0;
      releaseAmount = double.tryParse(_releaseAmountController.text.trim()) ?? 0;
      if (totalAmount <= 0 || releaseAmount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter target and release amounts.')));
        return;
      }
      if (releaseAmount > totalAmount) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Release amount must be less than target.')));
        return;
      }
    }

    if (!mounted) return;
    setState(() => _isSubmitting = true);
    final provider = context.read<IjcProvider>();
    final success = await provider.deposit(
      groupId: widget.group.id,
      amount: amount,
      description: _noteController.text.trim(),
      totalAmount: totalAmount,
      releaseAmount: releaseAmount,
      cashOutPolicy: _needsConfig ? _policy : null,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Funds added successfully.')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.read<IjcProvider>().error ?? 'Deposit failed.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Funds', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(widget.group.name, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text('Pocket ID ${widget.group.ijcId}', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
                    const SizedBox(height: 16),
                    Text('Current amount', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(CurrencyUtil.format(widget.group.effectiveTotalAmount), style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.primaryTiffanyDark)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: 'MK ',
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Note (optional)'),
            ),
            if (_needsConfig) ...[
              const SizedBox(height: 18),
              Text('Configure release plan', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              TextField(
                controller: _targetAmountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Target pocket amount',
                  prefixText: 'MK ',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _releaseAmountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Release amount per cycle',
                  prefixText: 'MK ',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _policy,
                decoration: const InputDecoration(
                  labelText: 'Release frequency',
                ),
                items: const [
                  DropdownMenuItem(value: 'DAILY', child: Text('Daily')),
                  DropdownMenuItem(value: 'WEEKLY', child: Text('Weekly')),
                  DropdownMenuItem(value: 'MONTHLY', child: Text('Monthly')),
                  DropdownMenuItem(value: 'CUSTOM', child: Text('Custom')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _policy = value);
                  }
                },
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isSubmitting ? null : _submitDeposit,
              style: FilledButton.styleFrom(backgroundColor: AppColors.primaryTiffany),
              child: _isSubmitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                  : const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

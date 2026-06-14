import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../config/app_colors.dart';
import '../../models/ijc_group.dart';
import '../../providers/ijc_provider.dart';
import '../../utils/currency_util.dart';

class IjcDetailScreen extends StatelessWidget {
  final IjcGroup group;

  const IjcDetailScreen({required this.group, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(group.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pocket ID ${group.ijcId}', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Text(
              CurrencyUtil.format(group.effectiveTotalAmount),
              style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.primaryTiffanyDark),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final tileWidth = constraints.maxWidth >= 760 ? (constraints.maxWidth - 20) / 3 : double.infinity;
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    SizedBox(width: tileWidth, child: _StatTile(label: 'Available today', value: CurrencyUtil.format(group.availableBalance))),
                    SizedBox(width: tileWidth, child: _StatTile(label: 'Locked balance', value: CurrencyUtil.format(group.lockedBalance))),
                    SizedBox(width: tileWidth, child: _StatTile(label: 'Next release', value: group.nextReleaseDate != null ? DateFormat('dd MMM').format(group.nextReleaseDate!) : 'Soon')),
                  ],
                );
              },
            ),
            const SizedBox(height: 18),
            Text('Release rules', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 8),
            Card(
              color: AppColors.primaryTiffanyLight.withAlpha(180),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(child: Text('Policy: ${group.cashOutPolicy}')),
                    Expanded(child: Text('Status: ${group.cashOutAvailable? 'Released' : 'Locked'}')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 520;
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.start,
                  children: [
                    SizedBox(
                      width: isWide ? (constraints.maxWidth - 10) / 2 : double.infinity,
                      child: FilledButton(
                        onPressed: () => _openAmountDialog(context, isDeposit: true),
                        style: FilledButton.styleFrom(backgroundColor: AppColors.primaryTiffany),
                        child: const Text('Add funds'),
                      ),
                    ),
                    if (group.canWithdraw)
                      SizedBox(
                        width: isWide ? (constraints.maxWidth - 10) / 2 : double.infinity,
                        child: OutlinedButton(
                          onPressed: () => _openAmountDialog(context, isDeposit: false),
                          child: const Text('Withdraw'),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 18),
            if (group.transactions.isNotEmpty) ...[
              Text('Recent activity', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ...group.transactions.map((t) => ListTile(
                    leading: Icon(t.isDeposit? Icons.arrow_downward: Icons.arrow_upward, color: t.isDeposit? AppColors.success: AppColors.error),
                    title: Text(t.userName),
                    subtitle: Text(DateFormat('dd MMM yyyy').format(t.createdAt)),
                    trailing: Text('${t.isDeposit? '+' : '-'}${CurrencyUtil.format(t.amount)}', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: t.isDeposit? AppColors.success: AppColors.error)),
                  ))
            ]
          ],
        ),
      ),
    );
  }

  void _openAmountDialog(BuildContext context, {required bool isDeposit}) {
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final totalCtrl = TextEditingController();
    final releaseCtrl = TextEditingController();
    var policy = group.cashOutPolicy.isNotEmpty ? group.cashOutPolicy : 'WEEKLY';
    final needsConfig = isDeposit && group.pocketType == 'SELF' && group.releaseAmount <= 0;
    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isDeposit ? 'Add funds' : 'Withdraw'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(labelText: 'Note (optional)'),
                ),
                if (needsConfig) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: totalCtrl,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Target pocket amount',
                      prefixText: 'MK ',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: releaseCtrl,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Release amount per cycle',
                      prefixText: 'MK ',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: policy,
                    decoration: const InputDecoration(
                      labelText: 'Release frequency',
                      prefixIcon: Icon(Icons.event_repeat_rounded),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'DAILY', child: Text('Daily')),
                      DropdownMenuItem(value: 'WEEKLY', child: Text('Weekly')),
                      DropdownMenuItem(value: 'MONTHLY', child: Text('Monthly')),
                      DropdownMenuItem(value: 'CUSTOM', child: Text('Custom')),
                    ],
                    onChanged: (value) {
                      if (value != null) setDialogState(() => policy = value);
                    },
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(onPressed: () async {
              final amount = double.tryParse(amountCtrl.text.trim()) ?? 0;
              if (amount <= 0) return;
              double? totalAmount;
              double? releaseAmount;
              if (needsConfig) {
                totalAmount = double.tryParse(totalCtrl.text.trim()) ?? 0;
                releaseAmount = double.tryParse(releaseCtrl.text.trim()) ?? 0;
                if (totalAmount <= 0 || releaseAmount <= 0) {
                  return;
                }
                if (releaseAmount > totalAmount) {
                  return;
                }
              }
              final provider = context.read<IjcProvider>();
              Navigator.pop(ctx);
              if (isDeposit) {
                await provider.deposit(
                  groupId: group.id,
                  amount: amount,
                  description: noteCtrl.text.trim(),
                  totalAmount: totalAmount,
                  releaseAmount: releaseAmount,
                  cashOutPolicy: needsConfig ? policy : null,
                );
              } else {
                await provider.withdraw(groupId: group.id, amount: amount, description: noteCtrl.text.trim());
              }
            }, child: const Text('Submit')),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}

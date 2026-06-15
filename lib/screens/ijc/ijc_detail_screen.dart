import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

import '../../config/app_colors.dart';
import '../../models/ijc_group.dart';
import '../../providers/ijc_provider.dart';
import '../../screens/ijc/ijc_deposit_screen.dart';
import '../../utils/currency_util.dart';

class IjcDetailScreen extends StatelessWidget {
  final IjcGroup group;

  const IjcDetailScreen({required this.group, super.key});

  @override
  Widget build(BuildContext context) {
    final isLocked = !group.cashOutAvailable;
    final daysLeft = group.daysUntilCashOut;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Text(
          group.name,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 17, color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'share', child: Text('Share Pocket')),
              const PopupMenuItem(value: 'copy', child: Text('Copy Pocket ID')),
            ],
            onSelected: (value) {
              final code = group.joinCode.isNotEmpty ? group.joinCode : group.ijcId;
              if (value == 'share') {
                SharePlus.instance.share(ShareParams(text: 'Join my Nzeru Pocket: $code'));
              } else {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pocket code copied')),
                );
              }
            },
            icon: const Icon(Icons.more_vert_rounded, color: Colors.black),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Summary Card ──────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pocket ID row
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.primaryTiffany.withAlpha(24),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.credit_card_rounded, color: AppColors.primaryTiffany, size: 26),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Pocket ID: ${group.ijcId}',
                                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(text: group.ijcId));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Pocket ID copied')),
                                    );
                                  },
                                  child: Icon(Icons.copy_rounded, size: 14, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Total balance',
                              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    CurrencyUtil.format(group.effectiveTotalAmount),
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryTiffanyDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Release amount: ${CurrencyUtil.format(group.releaseAmount)} ${group.cashOutPolicy.toLowerCase()}',
                    style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 14),
                  // Progress bar
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: group.progressPercent.clamp(0.0, 1.0),
                            minHeight: 8,
                            backgroundColor: AppColors.borderLight,
                            valueColor: AlwaysStoppedAnimation(AppColors.primaryTiffany),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${(group.progressPercent * 100).toStringAsFixed(0)}%',
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Available today badge
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${CurrencyUtil.format(group.availableBalance)} available today',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Stat Tiles ────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    label: 'Available today',
                    value: CurrencyUtil.format(group.availableBalance),
                    valueColor: AppColors.primaryTiffanyDark,
                    icon: Icons.arrow_upward_rounded,
                    iconColor: AppColors.primaryTiffany,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatTile(
                    label: 'Locked balance',
                    value: CurrencyUtil.format(group.lockedBalance),
                    icon: Icons.lock_outline_rounded,
                    iconColor: AppColors.warning,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatTile(
                    label: 'Next release',
                    value: group.nextReleaseDate != null
                        ? DateFormat('dd MMM yyyy').format(group.nextReleaseDate!)
                        : 'Soon',
                    subtitle: daysLeft > 0 ? '$daysLeft days left' : null,
                    icon: Icons.calendar_today_rounded,
                    iconColor: AppColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Release Rules ─────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10, offset: const Offset(0, 3)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTiffany.withAlpha(20),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.verified_user_rounded, color: AppColors.primaryTiffany, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Release rules',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _RuleCell(label: 'Policy', value: group.cashOutPolicy),
                      _VerticalDivider(),
                      _RuleCell(label: 'Release amount', value: CurrencyUtil.format(group.releaseAmount)),
                      _VerticalDivider(),
                      _RuleCell(
                        label: 'Status',
                        valueWidget: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isLocked ? AppColors.warning.withAlpha(20) : AppColors.success.withAlpha(20),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isLocked ? Icons.lock_outline_rounded : Icons.lock_open_rounded,
                                size: 13,
                                color: isLocked ? AppColors.warning : AppColors.success,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isLocked ? 'Locked' : 'Released',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isLocked ? AppColors.warning : AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (group.nextReleaseDate != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _releaseRuleDescription(group),
                      style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Action Button ─────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () {
                  if (group.pocketType == 'SELF') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => IjcDepositScreen(group: group)),
                    );
                  } else {
                    _showSponsoredCodeDialog(context, group);
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryTiffany,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                child: Text(group.pocketType == 'SELF' ? 'Add Funds' : 'Generate Pocket Code'),
              ),
            ),
            if (group.pocketType == 'SPONSORED') ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    final code = group.joinCode.isNotEmpty ? group.joinCode : group.ijcId;
                    SharePlus.instance.share(ShareParams(text: 'Join my Nzeru Pocket: $code'));
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    side: BorderSide(color: AppColors.primaryTiffany),
                  ),
                  child: Text(
                    'Share Pocket Code',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.primaryTiffany),
                  ),
                ),
              ),
            ],
            if (group.canWithdraw) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => _openAmountDialog(context, isDeposit: false),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Withdraw', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
            const SizedBox(height: 20),

            // ── Recent Activity ───────────────────────────────
            if (group.transactions.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent activity', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15)),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10, offset: const Offset(0, 3)),
                  ],
                ),
                child: Column(
                  children: group.transactions.asMap().entries.map((entry) {
                    final i = entry.key;
                    final t = entry.value;
                    final isLast = i == group.transactions.length - 1;
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: (t.isDeposit ? AppColors.success : AppColors.error).withAlpha(20),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  t.isDeposit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                                  color: t.isDeposit ? AppColors.success : AppColors.error,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t.description.isNotEmpty ? t.description : (t.isDeposit ? 'Pocket funding' : 'Release withdrawal'),
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      DateFormat('dd MMM yyyy • hh:mm a').format(t.createdAt),
                                      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${t.isDeposit ? '+' : '-'}${CurrencyUtil.format(t.amount)}',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: t.isDeposit ? AppColors.success : AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isLast)
                          Divider(height: 1, indent: 66, color: AppColors.borderLight),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _releaseRuleDescription(IjcGroup group) {
    final policy = group.cashOutPolicy.toLowerCase();
    final amount = CurrencyUtil.format(group.releaseAmount);
    if (policy == 'weekly') return 'Every week, $amount will be released to your available balance.';
    if (policy == 'daily') return 'Every day, $amount will be released to your available balance.';
    if (policy == 'monthly') return 'Every month, $amount will be released to your available balance.';
    return '$amount will be released per cycle to your available balance.';
  }

  void _showSponsoredCodeDialog(BuildContext context, IjcGroup group) {
    final code = group.joinCode.isNotEmpty ? group.joinCode : group.ijcId;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pocket Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Use this code to share your pocket with sponsors:'),
            const SizedBox(height: 16),
            SelectableText(code, style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 18)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pocket code copied')));
            },
            child: const Text('Copy'),
          ),
          FilledButton(
            onPressed: () {
              SharePlus.instance.share(ShareParams(text: 'Join my Nzeru Pocket: $code'));
              Navigator.pop(ctx);
            },
            child: const Text('Share'),
          ),
        ],
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
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Target pocket amount', prefixText: 'MK '),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: releaseCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Release amount per cycle', prefixText: 'MK '),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: policy,
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
            FilledButton(
              onPressed: () async {
                final amount = double.tryParse(amountCtrl.text.trim()) ?? 0;
                if (amount <= 0) return;
                double? totalAmount;
                double? releaseAmount;
                if (needsConfig) {
                  totalAmount = double.tryParse(totalCtrl.text.trim()) ?? 0;
                  releaseAmount = double.tryParse(releaseCtrl.text.trim()) ?? 0;
                  if (totalAmount <= 0 || releaseAmount <= 0) return;
                  if (releaseAmount > totalAmount) return;
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
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helper Widgets ─────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final Color? valueColor;
  final IconData icon;
  final Color iconColor;

  const _StatTile({
    required this.label,
    required this.value,
    this.subtitle,
    this.valueColor,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: valueColor ?? Colors.black87),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!, style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary)),
          ],
          const SizedBox(height: 8),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: iconColor.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
        ],
      ),
    );
  }
}

class _RuleCell extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;

  const _RuleCell({required this.label, this.value, this.valueWidget});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          valueWidget ??
              Text(value ?? '', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 36, color: AppColors.borderLight, margin: const EdgeInsets.symmetric(horizontal: 8));
  }
}

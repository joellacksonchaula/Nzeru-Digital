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
    final provider = context.watch<IjcProvider>();
    final group = provider.groups.firstWhere(
      (g) => g.id == this.group.id,
      orElse: () => this.group,
    );
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
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'share', child: Text('Share Pocket')),
              const PopupMenuItem(value: 'copy', child: Text('Copy Pocket ID')),
              if (group.isOwner && group.balance <= 0)
                const PopupMenuItem(
                  value: 'delete',
                  child: Text(
                    'Delete Pocket',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                  ),
                ),
            ],
            onSelected: (value) {
              final code = group.joinCode.isNotEmpty ? group.joinCode : group.ijcId;
              if (value == 'share') {
                SharePlus.instance.share(ShareParams(text: 'Join my Nzeru Pocket: $code'));
              } else if (value == 'copy') {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pocket code copied')),
                );
              } else if (value == 'delete') {
                _confirmDeletePocket(context, group);
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
                      // ── Pocket type badge ──
                      _PocketTypeBadge(group.pocketType),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // ── Balance display: "MK 45,000 of 50,000" ──
                  Builder(builder: (context) {
                    final total = group.effectiveTotalAmount;
                    final remaining = group.lockedBalance + group.availableBalance;
                    final isZero = remaining <= 0;

                    // Format number with commas, no decimals for cleaner look
                    String _fmt(double v) {
                      final intPart = v.toInt().toString().replaceAllMapped(
                        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                        (m) => '${m[0]},',
                      );
                      return intPart;
                    }

                    return RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'MK ',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryTiffanyDark,
                            ),
                          ),
                          TextSpan(
                            text: isZero ? '00' : _fmt(remaining),
                            style: GoogleFonts.poppins(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: isZero
                                  ? AppColors.textSecondary
                                  : AppColors.primaryTiffanyDark,
                            ),
                          ),
                          if (!isZero && total > 0) ...<InlineSpan>[
                            TextSpan(
                              text: ' of ',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textSecondary.withAlpha(150),
                              ),
                            ),
                            TextSpan(
                              text: _fmt(total),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary.withAlpha(150),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
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

            // ── Action Buttons (role-aware) ─────────────────────
            // ── SELF pocket: owner adds funds directly ──────────
            if (group.pocketType == 'SELF') ...[
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => IjcDepositScreen(group: group)),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryTiffany,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  child: const Text('Add Funds'),
                ),
              ),
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
            ],

            // ── SPONSORED pocket: role-based buttons ────────────
            if (group.pocketType == 'SPONSORED') ...[
              // SPONSOR (CONTROLLER): can fund the pocket + share/generate code
              if (group.isSponsor) ...[
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => IjcDepositScreen(group: group)),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryTiffany,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    child: const Text('Fund Pocket'),
                  ),
                ),
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

              // OWNER (USER): can only withdraw available funds — cannot fund their own sponsored pocket
              if (group.isOwner) ...[
                // Show pocket code generation only if no sponsor is linked yet
                if (!group.isSponsor && group.controllerName.isEmpty) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: () => _showSponsoredCodeDialog(context, group),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryTiffany,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      child: const Text('Generate Pocket Code'),
                    ),
                  ),
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
                // Withdraw button — shown only when funds are available
                if (group.canWithdraw) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: () => _openAmountDialog(context, isDeposit: false),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.success,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      child: Text('Withdraw ${CurrencyUtil.format(group.availableBalance)}'),
                    ),
                  ),
                ],
                // If no funds are available and sponsor is linked, show a locked info banner
                if (!group.canWithdraw && group.controllerName.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withAlpha(20),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.warning.withAlpha(60)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lock_outline_rounded, color: AppColors.warning, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            group.isPaused
                                ? 'Pocket is paused by your sponsor.'
                                : 'Funds are locked. Next release: ${group.nextReleaseDate != null ? DateFormat('dd MMM yyyy').format(group.nextReleaseDate!) : 'soon'}.',
                            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
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
    final releaseCtrl = TextEditingController();
    var policy = group.cashOutPolicy.isNotEmpty ? group.cashOutPolicy : 'WEEKLY';
    final needsConfig = isDeposit && group.pocketType == 'SELF' && group.releaseAmount <= 0;
    var isSubmitting = false;

    showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevent dismissing while submitting
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isDeposit ? 'Add funds' : 'Withdraw'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  enabled: !isSubmitting,
                  decoration: const InputDecoration(labelText: 'Amount', prefixText: 'MK '),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: noteCtrl,
                  enabled: !isSubmitting,
                  decoration: const InputDecoration(labelText: 'Note (optional)'),
                ),
                if (needsConfig) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: releaseCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    enabled: !isSubmitting,
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
                    onChanged: isSubmitting
                        ? null
                        : (value) {
                            if (value != null) setDialogState(() => policy = value);
                          },
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final amount = double.tryParse(amountCtrl.text.trim()) ?? 0;
                      if (amount <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Enter a valid amount.')),
                        );
                        return;
                      }
                      double? releaseAmount;
                      if (needsConfig) {
                        releaseAmount = double.tryParse(releaseCtrl.text.trim()) ?? 0;
                        if (releaseAmount <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Enter a valid release amount.')),
                          );
                          return;
                        }
                        if (releaseAmount > amount) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Release amount cannot be greater than the deposit amount.')),
                          );
                          return;
                        }
                      }

                      setDialogState(() => isSubmitting = true);
                      final provider = context.read<IjcProvider>();
                      bool success;
                      if (isDeposit) {
                        success = await provider.deposit(
                          groupId: group.id,
                          amount: amount,
                          description: noteCtrl.text.trim(),
                          totalAmount: null,
                          releaseAmount: releaseAmount,
                          cashOutPolicy: needsConfig ? policy : null,
                        );
                      } else {
                        success = await provider.withdraw(
                          groupId: group.id,
                          amount: amount,
                          description: noteCtrl.text.trim(),
                        );
                      }

                      if (success) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(isDeposit ? 'Funds added successfully.' : 'Withdrawal completed.')),
                          );
                          Navigator.pop(ctx);
                        }
                      } else {
                        setDialogState(() => isSubmitting = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(provider.error ?? 'Transaction failed.')),
                          );
                        }
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeletePocket(BuildContext context, IjcGroup group) {
    var isDeleting = false;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(
            'Delete Pocket',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          content: Text(
            'Are you sure you want to delete the pocket "${group.name}"? This action cannot be undone.',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: isDeleting ? null : () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: isDeleting
                  ? null
                  : () async {
                      setDialogState(() => isDeleting = true);
                      final provider = context.read<IjcProvider>();
                      final ok = await provider.deleteGroup(group.id);
                      if (ctx.mounted) {
                        Navigator.pop(ctx); // Close dialog
                      }
                      if (ok) {
                        if (context.mounted) {
                          Navigator.pop(context); // Go back from details page to listing page
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Pocket "${group.name}" deleted successfully.')),
                          );
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(provider.error ?? 'Failed to delete pocket.')),
                          );
                        }
                      }
                    },
              child: isDeleting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.red),
                      ),
                    )
                  : Text(
                      'Delete',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.red),
                    ),
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

// ── Pocket type badge ──────────────────────────────────────────────────────
class _PocketTypeBadge extends StatelessWidget {
  final String pocketType;
  const _PocketTypeBadge(this.pocketType);

  @override
  Widget build(BuildContext context) {
    final isSelf = pocketType == 'SELF';
    final bg = isSelf
        ? const Color(0xFF2EC4B6).withAlpha(28)
        : const Color(0xFF8B5CF6).withAlpha(28);
    final border = isSelf ? const Color(0xFF2EC4B6) : const Color(0xFF8B5CF6);
    final icon = isSelf ? Icons.person_rounded : Icons.handshake_rounded;
    final label = isSelf ? 'Self' : 'Sponsored';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border.withAlpha(120), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: border),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: border,
            ),
          ),
        ],
      ),
    );
  }
}

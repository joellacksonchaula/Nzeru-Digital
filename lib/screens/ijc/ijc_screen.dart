import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../config/design_system.dart';
import '../../models/ijc_group.dart';
import '../../providers/ijc_provider.dart';
import '../../utils/currency_util.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/progress_ring.dart';

class IjcScreen extends StatefulWidget {
  const IjcScreen({super.key});

  @override
  State<IjcScreen> createState() => _IjcScreenState();
}

class _IjcScreenState extends State<IjcScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IjcProvider>().loadGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IjcProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 34, height: 34),
            const SizedBox(width: 12),
            Text(
              'Nzeru Pocket',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _showJoinDialog(context),
            icon: const Icon(Icons.qr_code_rounded),
            tooltip: 'Join Pocket',
          ),
          IconButton(
            onPressed: () => _showCreateDialog(context),
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'Create Pocket',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: provider.loadGroups,
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                children: [
                  _IntroPanel(
                    onCreate: () => _showCreateDialog(context),
                    onJoin: () => _showJoinDialog(context),
                  ),
                  const SizedBox(height: 16),
                  if (provider.error != null)
                    _Notice(message: provider.error!, isError: true),
                  if (provider.groups.isEmpty)
                    const _EmptyState()
                  else
                    ...provider.groups.map((group) => _IjcCreditCard(group)),
                ],
              ),
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final totalController = TextEditingController();
    final releaseController = TextEditingController();
    var pocketType = 'SPONSORED';
    var policy = 'DAILY';
    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Create Nzeru Pocket'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Sponsored Pocket'),
                        value: 'SPONSORED',
                        groupValue: pocketType,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (value) {
                          if (value != null) setDialogState(() => pocketType = value);
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Self Pocket'),
                        value: 'SELF',
                        groupValue: pocketType,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (value) {
                          if (value != null) setDialogState(() => pocketType = value);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Pocket name',
                    prefixIcon: Icon(Icons.credit_score_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                if (pocketType == 'SELF') ...[
                  TextField(
                    controller: totalController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Total pocket amount',
                      prefixText: 'MK ',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: releaseController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
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
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  final total = double.tryParse(totalController.text.trim()) ?? 0;
                  final release = double.tryParse(releaseController.text.trim()) ?? 0;
                  if (name.isEmpty) {
                    _snack(context, 'Enter a pocket name.');
                    return;
                  }
                  if (pocketType == 'SELF' && (total <= 0 || release <= 0)) {
                    _snack(context, 'Enter valid amounts for your self pocket.');
                    return;
                  }
                  if (pocketType == 'SELF' && release > total) {
                    _snack(context, 'Release amount must be less than total pocket amount.');
                    return;
                  }
                  final ok = await context.read<IjcProvider>().createGroup(
                        name: name,
                        pocketType: pocketType,
                        totalAmount: pocketType == 'SELF' ? total : null,
                        releaseAmount: pocketType == 'SELF' ? release : null,
                        cashOutPolicy: pocketType == 'SELF' ? policy : null,
                      );
                  if (!context.mounted) return;
                  Navigator.pop(dialogContext);
                  _snack(
                    context,
                    ok
                        ? 'Pocket created.'
                        : context.read<IjcProvider>().error ?? 'Failed.',
                  );
                },
                child: const Text('Create Pocket'),
              ),
            ],
          ),
        ),
      );
    } finally {
      nameController.dispose();
      totalController.dispose();
      releaseController.dispose();
    }
  }

  Future<void> _showJoinDialog(BuildContext context) async {
    final controller = TextEditingController();
    final totalController = TextEditingController();
    final releaseController = TextEditingController();
    var policy = 'WEEKLY';
    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Join Nzeru Pocket'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Pocket ID or join code',
                    prefixIcon: Icon(Icons.key_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'If you are joining as a sponsor, optionally add funding details below.',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: totalController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Total pocket amount',
                    prefixText: 'MK ',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: releaseController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
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
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  final code = controller.text.trim();
                  final total = double.tryParse(totalController.text.trim()) ?? 0;
                  final release = double.tryParse(releaseController.text.trim()) ?? 0;
                  if (code.isEmpty) {
                    _snack(context, 'Enter a pocket ID or join code.');
                    return;
                  }
                  if ((total > 0 || release > 0) && release > total) {
                    _snack(context, 'Release amount must be less than total pocket amount.');
                    return;
                  }
                  final ok = await context.read<IjcProvider>().joinGroup(
                        code,
                        totalAmount: total > 0 ? total : null,
                        releaseAmount: release > 0 ? release : null,
                        cashOutPolicy: total > 0 || release > 0 ? policy : null,
                      );
                  if (!context.mounted) return;
                  Navigator.pop(dialogContext);
                  _snack(
                    context,
                    ok
                        ? 'Pocket joined.'
                        : context.read<IjcProvider>().error ?? 'Failed.',
                  );
                },
                child: const Text('Join Pocket'),
              ),
            ],
          ),
        ),
      );
    } finally {
      controller.dispose();
      totalController.dispose();
      releaseController.dispose();
    }
  }
}


class _IjcCreditCard extends StatelessWidget {
  final IjcGroup group;

  const _IjcCreditCard(this.group);

  @override
  Widget build(BuildContext context) {
    final pendingMembers =
        group.members.where((member) => member.status == 'PENDING').toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: DesignSystem.creditCardShadows,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pocket ID ${group.ijcId}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryTiffanyLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  group.cashOutPolicy.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryTiffanyDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Total pocket',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            CurrencyUtil.format(group.effectiveTotalAmount),
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryTiffanyDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Release amount: ${CurrencyUtil.format(group.releaseAmount)}',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _CreditStat(
                label: 'Available today',
                value: CurrencyUtil.format(group.availableBalance),
                accentColor: AppColors.success,
              ),
              const SizedBox(width: 10),
              _CreditStat(
                label: 'Locked balance',
                value: CurrencyUtil.format(group.lockedBalance),
                accentColor: AppColors.warning,
              ),
              const SizedBox(width: 10),
              _CreditStat(
                label: 'Next release',
                value: group.nextReleaseDate != null
                    ? DateFormat('dd MMM').format(group.nextReleaseDate!)
                    : 'Soon',
                accentColor: AppColors.primaryTiffany,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryTiffanyLight.withAlpha(180),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryTiffany.withAlpha(40)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Release rules',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryTiffanyDark,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _RuleRow(
                        icon: Icons.timer,
                        title: 'Policy',
                        value: group.cashOutPolicy,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RuleRow(
                        icon: Icons.lock_open_rounded,
                        title: 'Status',
                        value: group.cashOutAvailable ? 'Released' : 'Locked',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () => _amountDialog(
                    context,
                    title: 'Add funds to pocket',
                    actionLabel: 'Deposit',
                    onSubmit: (amount, note) => context.read<IjcProvider>().deposit(
                          groupId: group.id,
                          amount: amount,
                          description: note,
                        ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryTiffany,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Add funds'),
                ),
              ),
              if (group.canWithdraw) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: group.cashOutAvailable
                        ? () => _amountDialog(
                              context,
                              title: 'Withdraw released pocket funds',
                              actionLabel: 'Withdraw',
                              onSubmit: (amount, note) =>
                                  context.read<IjcProvider>().withdraw(
                                        groupId: group.id,
                                        amount: amount,
                                        description: note,
                                      ),
                            )
                        : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: group.cashOutAvailable
                          ? AppColors.primaryTiffanyDark
                          : AppColors.textMuted,
                      side: BorderSide(
                        color: group.cashOutAvailable
                            ? AppColors.primaryTiffanyDark
                            : AppColors.border,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Withdraw'),
                  ),
                ),
              ],
            ],
          ),
          if (!group.isApproved) ...[
            const SizedBox(height: 16),
            const _Notice(message: 'Parent approval required before any funds move.'),
          ],
          if (group.isOwner && pendingMembers.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Pending approvals',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ...pendingMembers.map(
              (member) => Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primaryTiffanyLight.withAlpha(24),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryTiffany.withAlpha(40)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.userName,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Awaiting approval',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton(
                      onPressed: () async {
                        final ok = await context.read<IjcProvider>().approveMember(
                              groupId: group.id,
                              memberId: member.id,
                            );
                        if (context.mounted) {
                          _snack(context, ok ? 'Member approved.' : 'Approval failed.');
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryTiffany,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Approve'),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (group.transactions.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Recent activity',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ...group.transactions.take(4).map(
                  (txn) => _TransactionRow(txn: txn),
                ),
          ],
        ],
      ),
    );
  }
}

class _CreditStat extends StatelessWidget {
  final String label;
  final String value;
  final Color accentColor;

  const _CreditStat({
    required this.label,
    required this.value,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: accentColor.withAlpha(24),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _RuleRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryTiffanyLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: AppColors.primaryTiffanyDark),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryTiffanyDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IntroPanel extends StatelessWidget {
  final VoidCallback onCreate;
  final VoidCallback onJoin;

  const _IntroPanel({required this.onCreate, required this.onJoin});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.abyssalTeal,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nzeru Pocket',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Create a sponsored or self pocket, then fund and release balance on your schedule.',
            style: GoogleFonts.poppins(color: Colors.white.withAlpha(220)),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              FilledButton.icon(
                onPressed: onCreate,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create'),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: onJoin,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                ),
                icon: const Icon(Icons.login_rounded),
                label: const Text('Join'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16, color: AppColors.abyssalTeal),
      label: Text(label),
    );
  }
}

class _RankingRow extends StatelessWidget {
  final IjcMember member;

  const _RankingRow({required this.member});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.emoji_events_outlined),
      title: Text(member.userName),
      subtitle: Text(member.status.toLowerCase()),
      trailing: Text(CurrencyUtil.format(member.totalContributed)),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final IjcTransaction txn;

  const _TransactionRow({required this.txn});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: txn.isDeposit
                ? AppColors.success.withAlpha(24)
                : AppColors.brightCrimson.withAlpha(24),
            child: Icon(
              txn.isDeposit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: txn.isDeposit ? AppColors.success : AppColors.brightCrimson,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.userName,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMM yyyy').format(txn.createdAt),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${txn.isDeposit ? '+' : '-'} ${CurrencyUtil.format(txn.amount)}',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              color: txn.isDeposit ? AppColors.success : AppColors.brightCrimson,
            ),
          ),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  final String message;
  final bool isError;

  const _Notice({required this.message, this.isError = false});

  @override
  Widget build(BuildContext context) {
    final color = isError ? AppColors.brightCrimson : AppColors.warning;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Text(message, style: GoogleFonts.poppins(color: color)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Column(
        children: [
          const Icon(Icons.credit_card_rounded, size: 48, color: AppColors.primaryTiffany),
          const SizedBox(height: 12),
          Text(
            'No pockets yet',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Create a Nzeru pocket or join one using a code.',
            style: GoogleFonts.poppins(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

Future<void> _amountDialog(
  BuildContext context, {
  required String title,
  required String actionLabel,
  required Future<bool> Function(double amount, String note) onSubmit,
}) async {
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  try {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration:
                  const InputDecoration(labelText: 'Amount', prefixText: 'MK '),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'Note'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text.trim()) ?? 0;
              if (amount <= 0) {
                _snack(context, 'Enter a valid amount.');
                return;
              }
              final ok = await onSubmit(amount, noteController.text.trim());
              if (!context.mounted) return;
              Navigator.pop(dialogContext);
              _snack(context, ok ? '$actionLabel recorded.' : 'Action failed.');
            },
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  } finally {
    amountController.dispose();
    noteController.dispose();
  }
}

void _snack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

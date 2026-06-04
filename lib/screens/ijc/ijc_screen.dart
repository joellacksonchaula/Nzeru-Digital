import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../models/ijc_group.dart';
import '../../providers/ijc_provider.dart';
import '../../utils/currency_util.dart';
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
        title: Text(
          'Joint Savings',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () => _showJoinDialog(context),
            icon: const Icon(Icons.group_add_rounded),
            tooltip: 'Join IJC',
          ),
          IconButton(
            onPressed: () => _showCreateDialog(context),
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'Create IJC',
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
                    ...provider.groups.map((group) => _IjcGroupCard(group)),
                ],
              ),
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final goalController = TextEditingController();
    var policy = 'WEEKLY';
    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Create IJC'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Group name',
                    prefixIcon: Icon(Icons.groups_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: goalController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Goal amount',
                    prefixText: 'MK ',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: policy,
                  decoration: const InputDecoration(
                    labelText: 'Cash-out policy',
                    prefixIcon: Icon(Icons.event_repeat_rounded),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'DAILY', child: Text('Daily')),
                    DropdownMenuItem(value: 'WEEKLY', child: Text('Weekly')),
                    DropdownMenuItem(value: 'MONTHLY', child: Text('Monthly')),
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
                  final name = nameController.text.trim();
                  final goal = double.tryParse(goalController.text.trim()) ?? 0;
                  if (name.isEmpty || goal <= 0) {
                    _snack(context, 'Enter a group name and valid goal.');
                    return;
                  }
                  final ok = await context.read<IjcProvider>().createGroup(
                        name: name,
                        goalAmount: goal,
                        cashOutPolicy: policy,
                      );
                  if (!context.mounted) return;
                  Navigator.pop(dialogContext);
                  _snack(
                    context,
                    ok
                        ? 'IJC created.'
                        : context.read<IjcProvider>().error ?? 'Failed.',
                  );
                },
                child: const Text('Create'),
              ),
            ],
          ),
        ),
      );
    } finally {
      nameController.dispose();
      goalController.dispose();
    }
  }

  Future<void> _showJoinDialog(BuildContext context) async {
    final controller = TextEditingController();
    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Join IJC'),
          content: TextField(
            controller: controller,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'IJC ID or join code',
              prefixIcon: Icon(Icons.key_rounded),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final code = controller.text.trim();
                if (code.isEmpty) {
                  _snack(context, 'Enter an IJC ID or join code.');
                  return;
                }
                final ok = await context.read<IjcProvider>().joinGroup(code);
                if (!context.mounted) return;
                Navigator.pop(dialogContext);
                _snack(
                  context,
                  ok
                      ? 'Join request sent.'
                      : context.read<IjcProvider>().error ?? 'Failed.',
                );
              },
              child: const Text('Join'),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
  }
}

class _IjcGroupCard extends StatelessWidget {
  final IjcGroup group;

  const _IjcGroupCard(this.group);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pendingMembers =
        group.members.where((member) => member.status == 'PENDING').toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 60 : 16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProgressRing(
                progress: group.progressPercent,
                size: 88,
                strokeWidth: 9,
                centerText: '${(group.progressPercent * 100).round()}%',
                progressColor: AppColors.brightCrimson,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${group.ijcId}  |  Code ${group.joinCode}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${CurrencyUtil.format(group.balance)} of ${CurrencyUtil.format(group.goalAmount)}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip(icon: Icons.people_rounded, label: '${group.memberCount} members'),
              _Chip(icon: Icons.event_rounded, label: '${group.cashOutPolicy.toLowerCase()} cash-out'),
              _Chip(
                icon: group.cashOutAvailable ? Icons.lock_open_rounded : Icons.lock_rounded,
                label: group.cashOutAvailable
                    ? 'cash-out available'
                    : '${group.daysUntilCashOut} days remaining',
              ),
            ],
          ),
          if (group.nextCashOutDate != null) ...[
            const SizedBox(height: 10),
            Text(
              'Next cash-out: ${DateFormat('dd MMM yyyy').format(group.nextCashOutDate!)}',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
          ],
          if (!group.isApproved) ...[
            const SizedBox(height: 12),
            const _Notice(message: 'Owner approval required before contributing.'),
          ] else ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _amountDialog(
                      context,
                      title: 'Deposit to IJC',
                      actionLabel: 'Deposit',
                      onSubmit: (amount, note) => context.read<IjcProvider>().deposit(
                            groupId: group.id,
                            amount: amount,
                            description: note,
                          ),
                    ),
                    icon: const Icon(Icons.south_west_rounded),
                    label: const Text('Deposit'),
                  ),
                ),
                if (group.isOwner) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: group.cashOutAvailable
                          ? () => _amountDialog(
                                context,
                                title: 'Cash out IJC',
                                actionLabel: 'Withdraw',
                                onSubmit: (amount, note) =>
                                    context.read<IjcProvider>().withdraw(
                                          groupId: group.id,
                                          amount: amount,
                                          description: note,
                                        ),
                              )
                          : null,
                      icon: Icon(group.cashOutAvailable
                          ? Icons.north_east_rounded
                          : Icons.lock_rounded),
                      label: const Text('Cash out'),
                    ),
                  ),
                ],
              ],
            ),
          ],
          if (group.isOwner && pendingMembers.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Pending approvals',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ...pendingMembers.map(
              (member) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(member.userName),
                trailing: FilledButton(
                  onPressed: () async {
                    final ok = await context.read<IjcProvider>().approveMember(
                          groupId: group.id,
                          memberId: member.id,
                        );
                    if (context.mounted) {
                      _snack(context, ok ? 'Member approved.' : 'Approval failed.');
                    }
                  },
                  child: const Text('Approve'),
                ),
              ),
            ),
          ],
          if (group.members.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Contribution ranking',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ...group.members.take(5).map(
                  (member) => _RankingRow(member: member),
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
            'Instant Joint Credit',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Save together with owner approval, member contribution tracking, and scheduled cash-outs.',
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
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        txn.isDeposit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
        color: txn.isDeposit ? AppColors.success : AppColors.brightCrimson,
      ),
      title: Text(txn.userName),
      subtitle: Text(DateFormat('dd MMM yyyy').format(txn.createdAt)),
      trailing: Text(
        '${txn.isDeposit ? '+' : '-'} ${CurrencyUtil.format(txn.amount)}',
        style: TextStyle(
          color: txn.isDeposit ? AppColors.success : AppColors.brightCrimson,
          fontWeight: FontWeight.w700,
        ),
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
          const Icon(Icons.groups_2_rounded, size: 48, color: AppColors.abyssalTeal),
          const SizedBox(height: 12),
          Text(
            'No joint savings yet',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Create an IJC or join one with a code.',
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

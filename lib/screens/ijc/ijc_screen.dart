import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../config/design_system.dart';
import '../../models/ijc_group.dart';
import '../../providers/ijc_provider.dart';
import '../../utils/currency_util.dart';
import 'ijc_detail_screen.dart';

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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 980;
            final cardWidth = isWide ? 360.0 : double.infinity;
            return provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _IntroPanel(
                            onCreate: () => _showCreateDialog(context),
                            onJoin: () => _showJoinDialog(context),
                          ),
                          const SizedBox(height: 16),
                          if (provider.error != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: _Notice(message: provider.error!, isError: true),
                            ),
                          if (provider.groups.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: _EmptyState(),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                alignment: WrapAlignment.start,
                                children: provider.groups
                                    .map((group) => SizedBox(
                                          width: cardWidth,
                                          child: _IjcCreditCard(group),
                                        ))
                                    .toList(),
                              ),
                            ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  );
          },
        ),
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    final nameController = TextEditingController();
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
                  if (name.isEmpty) {
                    _snack(context, 'Enter a pocket name.');
                    return;
                  }
                  final createdGroup = await context.read<IjcProvider>().createGroup(
                    name: name,
                    pocketType: pocketType,
                  );
                  if (!context.mounted) return;
                  Navigator.pop(dialogContext);
                  if (createdGroup != null) {
                    _snack(context, 'Pocket created.');
                    if (pocketType == 'SELF') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => IjcDetailScreen(group: createdGroup),
                        ),
                      );
                    }
                  } else {
                    _snack(context, context.read<IjcProvider>().error ?? 'Failed to create pocket.');
                  }
                },
                child: const Text('Create Pocket'),
              ),
            ],
          ),
        ),
      );
    } finally {
      nameController.dispose();
    }
  }

  Future<void> _showJoinDialog(BuildContext context) async {
    final controller = TextEditingController();
    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
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
                if (code.isEmpty) {
                  _snack(context, 'Enter a pocket ID or join code.');
                  return;
                }
                final ok = await context.read<IjcProvider>().joinGroup(code);
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
      );
    } finally {
      controller.dispose();
    }
  }
}


class _IjcCreditCard extends StatelessWidget {
  final IjcGroup group;

  const _IjcCreditCard(this.group);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => IjcDetailScreen(group: group),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: DesignSystem.creditCardShadows,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              CurrencyUtil.format(group.effectiveTotalAmount),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Release amount',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyUtil.format(group.releaseAmount),
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
                _LockStatus(
                  locked: !group.cashOutAvailable,
                  status: group.cashOutAvailable ? 'Released' : 'Locked',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LockStatus extends StatelessWidget {
  final bool locked;
  final String status;

  const _LockStatus({
    required this.locked,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: locked ? AppColors.error.withAlpha(24) : AppColors.success.withAlpha(24),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: locked ? AppColors.error.withAlpha(60) : AppColors.success.withAlpha(60),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            locked ? Icons.lock_rounded : Icons.lock_open_rounded,
            size: 16,
            color: locked ? AppColors.error : AppColors.success,
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: locked ? AppColors.error : AppColors.success,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isError ? AppColors.error : AppColors.warning).withAlpha(24),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isError ? AppColors.error : AppColors.warning).withAlpha(60),
        ),
      ),
      child: Text(
        message,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: isError ? AppColors.error : AppColors.warning,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.credit_score_rounded, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(
            'No pockets yet',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Create or join a pocket to get started',
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
          ),
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

void _snack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

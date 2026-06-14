import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../config/design_system.dart';
import 'package:intl/intl.dart';
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
    var pocketType = '';
    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (bottomSheetContext) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 24,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary.withAlpha(80),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      pocketType.isEmpty ? 'Create Pocket' : 'Pocket Name',
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    if (pocketType.isEmpty) ...[
                      _PocketTypeOption(
                        label: 'Sponsored Pocket',
                        description: 'Create a pocket for sponsors to fund.',
                        icon: Icons.handshake_rounded,
                        onTap: () => setState(() => pocketType = 'SPONSORED'),
                      ),
                      const SizedBox(height: 12),
                      _PocketTypeOption(
                        label: 'Self Pocket',
                        description: 'Create a personal pocket and add funds now.',
                        icon: Icons.person_rounded,
                        onTap: () => setState(() => pocketType = 'SELF'),
                      ),
                    ] else ...[
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Pocket name',
                          hintText: 'Holiday Savings',
                          prefixIcon: const Icon(Icons.credit_score_rounded),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      const SizedBox(height: 16),
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
                          if (createdGroup == null) {
                            _snack(context, context.read<IjcProvider>().error ?? 'Failed to create pocket.');
                            return;
                          }
                          Navigator.pop(bottomSheetContext);
                          _snack(context, 'Pocket created.');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => IjcDetailScreen(group: createdGroup),
                            ),
                          );
                        },
                        child: const Text('Create Pocket'),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
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
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: DesignSystem.creditCardShadows,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Decorative double lines stretching full width
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Column(
                children: [
                  Container(height: 6, color: AppColors.primaryTiffany),
                  Container(height: 4, color: AppColors.accentRed),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: icon, name, description, menu
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primaryTiffanyLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.credit_card_rounded, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(group.name, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text('Pocket ID ${group.ijcId}', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert_rounded)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Balance label and amount
                  Text('Balance', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Text(CurrencyUtil.format(group.effectiveTotalAmount), style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.primaryTiffany)),
                  const SizedBox(height: 12),

                  // Progress
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Funding Progress', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: group.progressPercent.clamp(0.0, 1.0),
                                minHeight: 10,
                                backgroundColor: AppColors.borderLight,
                                valueColor: AlwaysStoppedAnimation(AppColors.primaryTiffany),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text('${CurrencyUtil.format(group.effectiveTotalAmount)} of ${CurrencyUtil.format(group.goalAmount)}', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('${(group.progressPercent * 100).toStringAsFixed(0)}%', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Stats two columns
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [Icon(Icons.flag_rounded, size: 18, color: AppColors.textSecondary), const SizedBox(width: 8), Text('Target Amount', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary))]),
                              const SizedBox(height: 8),
                              Text(CurrencyUtil.format(group.goalAmount), style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 38, color: AppColors.border),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [Icon(Icons.calendar_today, size: 18, color: AppColors.textSecondary), const SizedBox(width: 8), Text('Release Amount', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary))]),
                              const SizedBox(height: 8),
                              Text('${CurrencyUtil.format(group.releaseAmount)} ${group.cashOutPolicy.toLowerCase()}', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Next release row
                  Row(
                    children: [
                      Icon(Icons.calendar_month_outlined, color: AppColors.primaryTiffany),
                      const SizedBox(width: 8),
                      Expanded(child: Text('Next release: ${group.nextReleaseDate != null ? DateFormat('dd MMM, hh:mm a').format(group.nextReleaseDate!) : 'Soon'}', style: GoogleFonts.poppins())),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PocketTypeOption extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _PocketTypeOption({
    required this.label,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.primaryTiffanyLight,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(icon, color: AppColors.primaryTiffanyDark, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(description, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// _LockStatus removed (unused) — visual lock/status now rendered inline in cards

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

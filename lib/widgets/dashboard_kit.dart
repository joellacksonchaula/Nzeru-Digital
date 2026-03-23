import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/savings_plan.dart';
import '../utils/currency_util.dart';

class DashboardPage extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final List<Widget> children;

  const DashboardPage({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.children,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7E1D5),
      body: Stack(
        children: [
          const _DashboardBackdrop(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DashboardHeader(
                        eyebrow: eyebrow,
                        title: title,
                        subtitle: subtitle,
                        trailing: trailing,
                      ),
                      const SizedBox(height: 18),
                      ...children,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const DashboardHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow.toUpperCase(),
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.2,
                  color: const Color(0xFF6A5336),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: GoogleFonts.oswald(
                  fontSize: 36,
                  height: 0.95,
                  color: const Color(0xFF183B49),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 1.45,
                  color: const Color(0xFF4A4A4A),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 16),
          trailing!,
        ],
      ],
    );
  }
}

class DashboardPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  const DashboardPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.58),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.72),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class DashboardSectionTitle extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const DashboardSectionTitle({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title.toUpperCase(),
          style: GoogleFonts.cormorantGaramond(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
            color: const Color(0xFF2B2117),
          ),
        ),
        const Spacer(),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              actionLabel!,
              style: GoogleFonts.oswald(
                fontSize: 14,
                color: const Color(0xFF7D6038),
              ),
            ),
          ),
      ],
    );
  }
}

class DashboardStatGrid extends StatelessWidget {
  final List<DashboardStatItem> items;

  const DashboardStatGrid({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 900;
        final medium = constraints.maxWidth > 560;
        final crossAxisCount = wide ? 4 : (medium ? 2 : 1);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: wide ? 1.45 : 1.9,
          ),
          itemBuilder: (context, index) => DashboardStatCard(item: items[index]),
        );
      },
    );
  }
}

class DashboardStatItem {
  final String label;
  final String value;
  final String detail;
  final IconData icon;
  final Color accent;

  const DashboardStatItem({
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
    required this.accent,
  });
}

class DashboardStatCard extends StatelessWidget {
  final DashboardStatItem item;

  const DashboardStatCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: item.accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.icon, color: item.accent),
              ),
              const Spacer(),
              Text(
                item.label.toUpperCase(),
                style: GoogleFonts.oswald(
                  fontSize: 12,
                  letterSpacing: 1.2,
                  color: const Color(0xFF6A645C),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            item.value,
            style: GoogleFonts.oswald(
              fontSize: 28,
              height: 0.96,
              color: const Color(0xFF23211E),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.detail,
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.35,
              color: const Color(0xFF5C5A57),
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardPlanCarousel extends StatefulWidget {
  final List<SavingsPlan> plans;
  final void Function(SavingsPlan)? onTap;

  const DashboardPlanCarousel({
    super.key,
    required this.plans,
    this.onTap,
  });

  @override
  State<DashboardPlanCarousel> createState() => _DashboardPlanCarouselState();
}

class _DashboardPlanCarouselState extends State<DashboardPlanCarousel> {
  PageController? _controller;
  double _viewportFraction = 1;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final fraction = width < 600
            ? 0.9
            : width < 980
                ? 0.58
                : 0.38;

        if (_controller == null || _viewportFraction != fraction) {
          _controller?.dispose();
          _viewportFraction = fraction;
          _controller = PageController(viewportFraction: fraction);
        }

        return SizedBox(
          height: 270,
          child: PageView.builder(
            controller: _controller,
            padEnds: false,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.plans.length,
            itemBuilder: (context, index) {
              final plan = widget.plans[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index == widget.plans.length - 1 ? 0 : 14,
                ),
                child: DashboardSavingsPlanCard(
                  plan: plan,
                  onTap: widget.onTap == null ? null : () => widget.onTap!(plan),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class DashboardSavingsPlanCard extends StatelessWidget {
  final SavingsPlan plan;
  final VoidCallback? onTap;

  const DashboardSavingsPlanCard({
    super.key,
    required this.plan,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final healthColor = _healthColor(plan.health);
    final statusLabel = _healthLabel(plan.health);

    return GestureDetector(
      onTap: onTap,
      child: DashboardPanel(
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
                        plan.title,
                        style: GoogleFonts.oswald(
                          fontSize: 24,
                          height: 0.95,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF23211E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Goal ${CurrencyUtil.formatNoDecimal(plan.goalAmount)}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF5B5752),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: healthColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    statusLabel,
                    style: GoogleFonts.oswald(
                      fontSize: 12,
                      color: healthColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                SizedBox(
                  width: 72,
                  height: 72,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: plan.progressPercent,
                        strokeWidth: 8,
                        backgroundColor: const Color(0xFFD8D1C8),
                        valueColor: AlwaysStoppedAnimation<Color>(healthColor),
                      ),
                      Center(
                        child: Text(
                          '${(plan.progressPercent * 100).round()}%',
                          style: GoogleFonts.oswald(
                            fontSize: 18,
                            color: const Color(0xFF2A2724),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _AmountLine(
                        label: 'Saved',
                        value: CurrencyUtil.formatNoDecimal(plan.currentAmount),
                      ),
                      const SizedBox(height: 6),
                      _AmountLine(
                        label: 'Remaining',
                        value: CurrencyUtil.formatNoDecimal(plan.remainingAmount),
                      ),
                      const SizedBox(height: 6),
                      _AmountLine(
                        label: 'Deadline',
                        value: DateFormat('dd MMM yyyy').format(plan.endDate),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: plan.progressPercent,
                minHeight: 10,
                backgroundColor: const Color(0xFFD7D1CB),
                color: healthColor,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _RateChip(
                  label: 'Save ${CurrencyUtil.formatNoDecimal(plan.requiredPerMonth)}/month',
                  color: const Color(0xFF876446),
                ),
                _RateChip(
                  label: 'Save ${CurrencyUtil.formatNoDecimal(plan.requiredPerWeek)}/week',
                  color: const Color(0xFF4C6A78),
                ),
                _RateChip(
                  label: 'Save ${CurrencyUtil.formatNoDecimal(plan.requiredPerDay)}/day',
                  color: const Color(0xFF6E8B5D),
                ),
              ],
            ),
            const Spacer(),
            Text(
              'Estimated completion ${DateFormat('dd MMM yyyy').format(plan.estimatedCompletionDate)}',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: plan.isEstimatedToFinishOnTime
                    ? const Color(0xFF3F6E46)
                    : const Color(0xFF9B4A4A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _healthColor(PlanHealth health) {
    switch (health) {
      case PlanHealth.onTrack:
        return const Color(0xFF4B9957);
      case PlanHealth.watch:
        return const Color(0xFFB7821E);
      case PlanHealth.behind:
        return const Color(0xFFC2545E);
    }
  }

  String _healthLabel(PlanHealth health) {
    switch (health) {
      case PlanHealth.onTrack:
        return 'On Track';
      case PlanHealth.watch:
        return 'Watch';
      case PlanHealth.behind:
        return 'Behind';
    }
  }
}

class _AmountLine extends StatelessWidget {
  final String label;
  final String value;

  const _AmountLine({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 74,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF6A645C),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.oswald(
              fontSize: 16,
              color: const Color(0xFF2A2724),
            ),
          ),
        ),
      ],
    );
  }
}

class _RateChip extends StatelessWidget {
  final String label;
  final Color color;

  const _RateChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class DashboardInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const DashboardInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF6A645C),
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.oswald(
              fontSize: 15,
              color: valueColor ?? const Color(0xFF2A2724),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardBackdrop extends StatelessWidget {
  const _DashboardBackdrop();

  @override
  Widget build(BuildContext context) {
    Widget orb(double size, Color color) => ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
        );

    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFF5EEE3),
                Color(0xFFD7E1E5),
                Color(0xFFE9E0D0),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _BackdropPainter(),
          ),
        ),
        Positioned(top: -30, left: -20, child: orb(160, const Color(0x88F4E6C1))),
        Positioned(top: 220, right: -40, child: orb(220, const Color(0x88D2E8F3))),
        Positioned(bottom: -30, left: 160, child: orb(260, const Color(0x88E8DABB))),
      ],
    );
  }
}

class _BackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strong = Paint()
      ..color = const Color(0x80685846)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    final soft = Paint()
      ..color = const Color(0x33FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final left = Path()
      ..moveTo(0, size.height * 0.12)
      ..quadraticBezierTo(
        size.width * 0.12,
        size.height * 0.18,
        size.width * 0.14,
        size.height * 0.58,
      )
      ..quadraticBezierTo(
        size.width * 0.10,
        size.height * 0.86,
        size.width * 0.02,
        size.height,
      );
    final right = Path()
      ..moveTo(size.width, size.height * 0.12)
      ..quadraticBezierTo(
        size.width * 0.88,
        size.height * 0.18,
        size.width * 0.86,
        size.height * 0.58,
      )
      ..quadraticBezierTo(
        size.width * 0.90,
        size.height * 0.86,
        size.width * 0.98,
        size.height,
      );
    canvas.drawPath(left, strong);
    canvas.drawPath(right, strong);
    canvas.drawPath(left.shift(const Offset(12, 6)), soft);
    canvas.drawPath(right.shift(const Offset(-12, 6)), soft);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.18,
          size.height * 0.83,
          size.width * 0.64,
          size.height * 0.16,
        ),
        const Radius.circular(40),
      ),
      Paint()..color = const Color(0x4D715942),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.22, 0, size.width * 0.56, size.height * 0.08),
        const Radius.circular(20),
      ),
      Paint()..color = const Color(0x4DB29B7B),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

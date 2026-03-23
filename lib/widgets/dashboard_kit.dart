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
      backgroundColor: const Color(0xFF050608),
      body: Stack(
        children: [
          const _DashboardBackdrop(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
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
                style: GoogleFonts.oswald(
                  fontSize: 14,
                  letterSpacing: 2.8,
                  color: const Color(0xFFE0B449),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: GoogleFonts.oswald(
                  fontSize: 34,
                  height: 0.96,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.45,
                    color: Colors.white.withValues(alpha: 0.72),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 12),
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
  final Color glowColor;
  final double? width;

  const DashboardPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin,
    this.glowColor = const Color(0x33E0B449),
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: const Color(0xCC0D1117),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: glowColor.withValues(alpha: 0.45),
              ),
              boxShadow: [
                BoxShadow(
                  color: glowColor.withValues(alpha: 0.2),
                  blurRadius: 24,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 24,
                  offset: const Offset(0, 16),
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

class DashboardHorizontalRail extends StatelessWidget {
  final List<Widget> children;
  final double gap;

  const DashboardHorizontalRail({
    super.key,
    required this.children,
    this.gap = 14,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1) SizedBox(width: gap),
          ],
        ],
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
          style: GoogleFonts.oswald(
            fontSize: 16,
            letterSpacing: 2,
            color: Colors.white,
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
                color: const Color(0xFFE0B449),
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
    return DashboardHorizontalRail(
      children: items
          .map(
            (item) => SizedBox(
              width: 260,
              child: DashboardStatCard(item: item),
            ),
          )
          .toList(),
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
      glowColor: item.accent,
      child: SizedBox(
        height: 174,
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
                    letterSpacing: 1.4,
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              item.value,
              style: GoogleFonts.oswald(
                fontSize: 30,
                height: 0.95,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.detail,
              style: GoogleFonts.inter(
                fontSize: 13,
                height: 1.35,
                color: Colors.white.withValues(alpha: 0.68),
              ),
            ),
          ],
        ),
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
        final fraction = width < 700
            ? 0.92
            : width < 1100
                ? 0.62
                : 0.42;

        if (_controller == null || _viewportFraction != fraction) {
          _controller?.dispose();
          _viewportFraction = fraction;
          _controller = PageController(viewportFraction: fraction);
        }

        return SizedBox(
          height: 292,
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
    final primaryRate = _primaryRateLabel(plan);

    return GestureDetector(
      onTap: onTap,
      child: DashboardPanel(
        glowColor: healthColor,
        child: SizedBox(
          height: 256,
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
                            height: 0.94,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          primaryRate,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: healthColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: healthColor.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: healthColor.withValues(alpha: 0.45)),
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
                    width: 74,
                    height: 74,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: plan.progressPercent,
                          strokeWidth: 7,
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                          valueColor: AlwaysStoppedAnimation<Color>(healthColor),
                        ),
                        Center(
                          child: Text(
                            '${(plan.progressPercent * 100).round()}%',
                            style: GoogleFonts.oswald(
                              fontSize: 18,
                              color: Colors.white,
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
                          label: 'Target',
                          value: CurrencyUtil.formatNoDecimal(plan.goalAmount),
                        ),
                        const SizedBox(height: 6),
                        _AmountLine(
                          label: 'Saved',
                          value: CurrencyUtil.formatNoDecimal(plan.currentAmount),
                        ),
                        const SizedBox(height: 6),
                        _AmountLine(
                          label: 'ETA',
                          value: DateFormat('dd MMM').format(plan.estimatedCompletionDate),
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
                  minHeight: 9,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  color: healthColor,
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _RateChip(
                      label: 'Month ${CurrencyUtil.formatNoDecimal(plan.requiredPerMonth)}',
                      color: const Color(0xFFE0B449),
                    ),
                    const SizedBox(width: 8),
                    _RateChip(
                      label: 'Week ${CurrencyUtil.formatNoDecimal(plan.requiredPerWeek)}',
                      color: const Color(0xFF56D68D),
                    ),
                    const SizedBox(width: 8),
                    _RateChip(
                      label: 'Day ${CurrencyUtil.formatNoDecimal(plan.requiredPerDay)}',
                      color: const Color(0xFFFF5E5E),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'Deadline ${DateFormat('dd MMM yyyy').format(plan.endDate)}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.72),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _primaryRateLabel(SavingsPlan plan) {
    final frequency = plan.frequency;
    switch (frequency) {
      case PlanFrequency.daily:
        return 'Save ${CurrencyUtil.formatNoDecimal(plan.requiredPerDay)} per day';
      case PlanFrequency.weekly:
      case PlanFrequency.biweekly:
        return 'Save ${CurrencyUtil.formatNoDecimal(plan.requiredPerWeek)} per week';
      case PlanFrequency.monthly:
        return 'Save ${CurrencyUtil.formatNoDecimal(plan.requiredPerMonth)} per month';
    }
  }

  Color _healthColor(PlanHealth health) {
    switch (health) {
      case PlanHealth.onTrack:
        return const Color(0xFF56D68D);
      case PlanHealth.watch:
        return const Color(0xFFE0B449);
      case PlanHealth.behind:
        return const Color(0xFFFF5E5E);
    }
  }

  String _healthLabel(PlanHealth health) {
    switch (health) {
      case PlanHealth.onTrack:
        return 'On Track';
      case PlanHealth.watch:
        return 'Slightly Behind';
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
          width: 62,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.56),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.oswald(
              fontSize: 16,
              color: Colors.white,
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
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.26)),
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
                color: Colors.white.withValues(alpha: 0.58),
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.oswald(
              fontSize: 15,
              color: valueColor ?? Colors.white,
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
          imageFilter: ImageFilter.blur(sigmaX: 38, sigmaY: 38),
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
                Color(0xFF020305),
                Color(0xFF090E14),
                Color(0xFF050608),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned.fill(child: CustomPaint(painter: _GridGlowPainter())),
        Positioned(top: -70, left: -40, child: orb(220, const Color(0x2296FF6B))),
        Positioned(top: 120, right: -40, child: orb(220, const Color(0x26E0B449))),
        Positioned(bottom: 10, left: 100, child: orb(240, const Color(0x26FF5E5E))),
      ],
    );
  }
}

class _GridGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1;

    for (var i = 0; i <= 12; i++) {
      final y = size.height * i / 12;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    for (var i = 0; i <= 8; i++) {
      final x = size.width * i / 8;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

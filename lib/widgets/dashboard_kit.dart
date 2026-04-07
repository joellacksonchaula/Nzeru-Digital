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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF091018) : const Color(0xFFF7F4EE),
      body: Stack(
        children: [
          DashboardBackdrop(darkMode: isDark),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  color: const Color(0xFF0ABAB5),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: GoogleFonts.oswald(
                  fontSize: 34,
                  height: 0.96,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF171412),
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
                    color:
                        isDark ? const Color(0xFFD0D5DC) : const Color(0xFF6F665C),
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
    this.glowColor = const Color(0x330ABAB5),
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: width,
      child: Container(
        margin: margin,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xD9111821) : const Color(0xD9FFFFFF),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: isDark
                      ? glowColor.withValues(alpha: 0.35)
                      : glowColor.withValues(alpha: 0.25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withValues(alpha: 0.10),
                    blurRadius: 28,
                    spreadRadius: 1,
                  ),
                  const BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 36,
                    offset: Offset(0, 20),
                  ),
                ],
              ),
              child: child,
            ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Text(
          title.toUpperCase(),
          style: GoogleFonts.oswald(
            fontSize: 16,
            letterSpacing: 2,
            color: isDark ? Colors.white : const Color(0xFF171412),
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
                color: const Color(0xFF0ABAB5),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                    color:
                        isDark ? const Color(0xFFD0D5DC) : const Color(0xFF6F665C),
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
                color: isDark ? Colors.white : const Color(0xFF171412),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.detail,
              style: GoogleFonts.inter(
                fontSize: 13,
                height: 1.35,
                color:
                    isDark ? const Color(0xFFD0D5DC) : const Color(0xFF6F665C),
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
                            color: const Color(0xFF171412),
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
                      color: healthColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: healthColor.withValues(alpha: 0.3)),
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
                          backgroundColor: const Color(0xFFF0EAE0),
                          valueColor: AlwaysStoppedAnimation<Color>(healthColor),
                        ),
                        Center(
                          child: Text(
                            '${(plan.progressPercent * 100).round()}%',
                            style: GoogleFonts.oswald(
                              fontSize: 18,
                              color: const Color(0xFF171412),
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
                  backgroundColor: const Color(0xFFF0EAE0),
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
                      color: const Color(0xFFE36A5B),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'Deadline ${DateFormat('dd MMM yyyy').format(plan.endDate)}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF6F665C),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _primaryRateLabel(SavingsPlan plan) {
    switch (plan.frequency) {
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
        return const Color(0xFF3B9D5D);
      case PlanHealth.watch:
        return const Color(0xFFBF912C);
      case PlanHealth.behind:
        return const Color(0xFFD55C4B);
    }
  }

  String _healthLabel(PlanHealth health) {
    switch (health) {
      case PlanHealth.onTrack:
        return 'On Track';
      case PlanHealth.watch:
        return 'Slight Delay';
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
              color: const Color(0xFF7E756A),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.oswald(
              fontSize: 16,
              color: const Color(0xFF171412),
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
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.20)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color:
                    isDark ? const Color(0xFFD0D5DC) : const Color(0xFF7E756A),
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.oswald(
              fontSize: 15,
              color: valueColor ?? (isDark ? Colors.white : const Color(0xFF171412)),
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardBackdrop extends StatelessWidget {
  final bool? darkMode;

  const DashboardBackdrop({
    super.key,
    this.darkMode,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedDarkMode =
        darkMode ?? Theme.of(context).brightness == Brightness.dark;

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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: resolvedDarkMode
                  ? const [
                      Color(0xFF06080C),
                      Color(0xFF0B1118),
                      Color(0xFF12161F),
                    ]
                  : const [
                      Color(0xFFF9F7F1),
                      Color(0xFFF4F0E6),
                      Color(0xFFF8F5EE),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(painter: _GridGlowPainter(darkMode: resolvedDarkMode)),
        ),
        Positioned(
          top: -70,
          left: -40,
          child: orb(
            220,
            resolvedDarkMode ? const Color(0x140ABAB5) : const Color(0x148FD7A5),
          ),
        ),
        Positioned(
          top: 120,
          right: -40,
          child: orb(
            220,
            resolvedDarkMode ? const Color(0x12D4AF37) : const Color(0x16D4AF37),
          ),
        ),
        Positioned(
          bottom: 10,
          left: 100,
          child: orb(
            240,
            resolvedDarkMode ? const Color(0x12801818) : const Color(0x14801818),
          ),
        ),
      ],
    );
  }
}

class _GridGlowPainter extends CustomPainter {
  final bool darkMode;

  _GridGlowPainter({
    this.darkMode = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = darkMode ? const Color(0x22DDE7F4) : const Color(0xFFE8E1D5)
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

class DashboardFixedGrid extends StatelessWidget {
  final List<Widget> children;
  final double mainAxisExtent;
  final double spacing;

  const DashboardFixedGrid({
    super.key,
    required this.children,
    this.mainAxisExtent = 150,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
      childAspectRatio: 1,
      mainAxisExtent: mainAxisExtent,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../utils/currency_util.dart';

class CandleData {
  final DateTime time;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  CandleData({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  bool get isGreen => close >= open;
}

class CandlestickChart extends StatelessWidget {
  final List<CandleData> candles;
  final String title;
  final String? subtitle;
  final double height;
  final bool showHeader;
  final bool darkMode;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

  const CandlestickChart({
    super.key,
    required this.candles,
    this.title = 'Savings Performance',
    this.subtitle,
    this.height = 320,
    this.showHeader = true,
    this.darkMode = false,
    this.padding = const EdgeInsets.fromLTRB(14, 14, 14, 14),
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
  });

  @override
  Widget build(BuildContext context) {
    if (candles.isEmpty) {
      final theme = _ChartPalette.fromMode(darkMode);
      return ClipRRect(
        borderRadius: borderRadius,
        child: Container(
          height: height,
          color: theme.background,
          child: Center(
            child: Text(
              'No chart data yet',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: theme.body,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    final series = candles;
    final stats = _ChartStats.from(series);
    final theme = _ChartPalette.fromMode(darkMode);

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: theme.background,
            borderRadius: borderRadius,
            border: Border.all(color: theme.border),
            boxShadow: [
              BoxShadow(
                color: theme.shadow,
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            tween: Tween(begin: 0, end: 1),
            builder: (context, value, _) {
              return Padding(
                padding: padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showHeader) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    color: theme.heading,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (subtitle != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    subtitle!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: theme.body,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: theme.chipBackground,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: theme.chipBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Latest',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: theme.axis,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  CurrencyUtil.formatCompact(stats.latest),
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    color: theme.heading,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    Expanded(
                      child: Row(
                        children: [
                          SizedBox(
                            width: 58,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _AxisLabel(CurrencyUtil.formatCompact(stats.max), color: theme.axis),
                                _AxisLabel(CurrencyUtil.formatCompact(stats.mid), color: theme.axis),
                                _AxisLabel(CurrencyUtil.formatCompact(stats.min), color: theme.axis),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: _GridPainter(color: theme.grid),
                                  ),
                                ),
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: _CandlesPainter(
                                      candles: series,
                                      min: stats.min,
                                      max: stats.max,
                                      progress: value,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _AxisLabel(DateFormat('dd MMM').format(series.first.time), color: theme.axis),
                        _AxisLabel(
                          DateFormat('dd MMM').format(series[series.length ~/ 2].time),
                          color: theme.axis,
                        ),
                        _AxisLabel(DateFormat('dd MMM').format(series.last.time), color: theme.axis),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ChartPalette {
  final Color background;
  final Color border;
  final Color heading;
  final Color body;
  final Color axis;
  final Color chipBackground;
  final Color chipBorder;
  final Color grid;
  final Color shadow;

  const _ChartPalette({
    required this.background,
    required this.border,
    required this.heading,
    required this.body,
    required this.axis,
    required this.chipBackground,
    required this.chipBorder,
    required this.grid,
    required this.shadow,
  });

  factory _ChartPalette.fromMode(bool darkMode) {
    if (darkMode) {
      return const _ChartPalette(
        background: Color(0xFF0C1016),
        border: Color(0xFF202833),
        heading: Color(0xFFF9FAFC),
        body: Color(0xB8FFFFFF),
        axis: Color(0x80FFFFFF),
        chipBackground: Color(0xFF141B24),
        chipBorder: Color(0xFF283241),
        grid: Color(0x14FFFFFF),
        shadow: Color(0x33000000),
      );
    }

    return const _ChartPalette(
      background: Color(0xF7FFFEFC),
      border: Color(0xFFE9E0D2),
      heading: Color(0xFF171412),
      body: Color(0xFF6F665C),
      axis: Color(0xFF8B7E6B),
      chipBackground: Color(0xFFF8F3EA),
      chipBorder: Color(0xFFE8DDCA),
      grid: Color(0xFFE8E0D2),
      shadow: Color(0x12000000),
    );
  }
}

class _AxisLabel extends StatelessWidget {
  final String value;
  final Color color;

  const _AxisLabel(this.value, {required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: GoogleFonts.poppins(
        fontSize: 11,
        color: color,
      ),
    );
  }
}

class _ChartStats {
  final double min;
  final double mid;
  final double max;
  final double latest;

  const _ChartStats({
    required this.min,
    required this.mid,
    required this.max,
    required this.latest,
  });

  factory _ChartStats.from(List<CandleData> candles) {
    final max = candles.map((e) => e.high).reduce(math.max);
    final min = candles.map((e) => e.low).reduce(math.min);
    return _ChartStats(
      min: min,
      mid: min + ((max - min) / 2),
      max: max,
      latest: candles.last.close,
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;

  _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    for (var i = 0; i <= 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    for (var i = 0; i <= 9; i++) {
      final x = size.width * i / 9;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) => oldDelegate.color != color;
}

class _CandlesPainter extends CustomPainter {
  final List<CandleData> candles;
  final double min;
  final double max;
  final double progress;

  _CandlesPainter({
    required this.candles,
    required this.min,
    required this.max,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final visibleCount = math.max(1, (candles.length * progress).ceil());
    final range = (max - min).abs() < 0.001 ? 1.0 : max - min;
    final step = size.width / candles.length;
    final wickWidth = math.max(0.7, step * 0.035);
    final bodyWidth = math.max(1.4, step * 0.10);

    double yFor(double value) {
      final normalized = (value - min) / range;
      return size.height - (normalized * (size.height - 8)) - 4;
    }

    for (var i = 0; i < visibleCount; i++) {
      final candle = candles[i];
      final x = i * step + step / 2;
      final openY = yFor(candle.open);
      final closeY = yFor(candle.close);
      final highY = yFor(candle.high);
      final lowY = yFor(candle.low);
      final top = math.min(openY, closeY);
      final bottom = math.max(openY, closeY);
      final color = candle.isGreen ? const Color(0xFF3FA66B) : const Color(0xFFD76354);

      canvas.drawLine(
        Offset(x, highY),
        Offset(x, lowY),
        Paint()
          ..color = color.withValues(alpha: 0.75)
          ..strokeWidth = wickWidth
          ..strokeCap = StrokeCap.round,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            x - bodyWidth / 2,
            top,
            bodyWidth,
            math.max(2.2, bottom - top),
          ),
          const Radius.circular(4),
        ),
        Paint()
          ..color = color.withValues(alpha: 0.92)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CandlesPainter oldDelegate) {
    return oldDelegate.candles != candles ||
        oldDelegate.progress != progress ||
        oldDelegate.min != min ||
        oldDelegate.max != max;
  }
}

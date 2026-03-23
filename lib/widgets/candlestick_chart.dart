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
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

  const CandlestickChart({
    super.key,
    required this.candles,
    this.title = 'Savings Performance',
    this.subtitle,
    this.height = 320,
    this.showHeader = true,
    this.padding = const EdgeInsets.fromLTRB(14, 14, 14, 14),
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
  });

  @override
  Widget build(BuildContext context) {
    final series = candles.isEmpty ? _fallbackCandles : candles;
    final stats = _ChartStats.from(series);

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xF7FFFEFC),
            borderRadius: borderRadius,
            border: Border.all(color: const Color(0xFFE9E0D2)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 24,
                offset: Offset(0, 12),
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
                                  style: GoogleFonts.oswald(
                                    fontSize: 24,
                                    color: const Color(0xFF171412),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (subtitle != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    subtitle!,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: const Color(0xFF6F665C),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F3EA),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE8DDCA),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Latest',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: const Color(0xFF847969),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  CurrencyUtil.formatCompact(stats.latest),
                                  style: GoogleFonts.oswald(
                                    fontSize: 18,
                                    color: const Color(0xFF171412),
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
                                _AxisLabel(CurrencyUtil.formatCompact(stats.max)),
                                _AxisLabel(CurrencyUtil.formatCompact(stats.mid)),
                                _AxisLabel(CurrencyUtil.formatCompact(stats.min)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: _GridPainter(),
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
                        _AxisLabel(DateFormat('dd MMM').format(series.first.time)),
                        _AxisLabel(DateFormat('dd MMM').format(series[series.length ~/ 2].time)),
                        _AxisLabel(DateFormat('dd MMM').format(series.last.time)),
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

class _AxisLabel extends StatelessWidget {
  final String value;

  const _AxisLabel(this.value);

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: GoogleFonts.inter(
        fontSize: 11,
        color: const Color(0xFF8B7E6B),
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
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE8E0D2)
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
      final color = candle.isGreen
          ? const Color(0xFF3FA66B)
          : const Color(0xFFD76354);

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

final _fallbackCandles = List.generate(
  24,
  (index) {
    final open = 1200.0 + (index * 28);
    final drift = index.isEven ? 16.0 : -10.0;
    final close = open + drift;
    return CandleData(
      time: DateTime.now().subtract(Duration(hours: 24 - index)),
      open: open,
      high: math.max(open, close) + 22,
      low: math.min(open, close) - 20,
      close: close,
      volume: 1000,
    );
  },
);

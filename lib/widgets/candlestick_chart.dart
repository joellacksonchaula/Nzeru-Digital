import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  final VoidCallback? onRefresh;
  final Function(String)? onTimeframeChanged;

  const CandlestickChart({
    super.key,
    required this.candles,
    this.title = 'Price Chart',
    this.subtitle,
    this.height = 300,
    this.onRefresh,
    this.onTimeframeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .48),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: .7)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .14),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(child: CustomPaint(painter: _GridPainter())),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.oswald(
                        fontSize: 24,
                        color: Colors.white.withValues(alpha: .9),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: candles.isEmpty
                          ? const Center(child: Text('No data'))
                          : CustomPaint(painter: _CandlesPainter(candles), size: Size.infinite),
                    ),
                  ],
                ),
              ),
              if (subtitle != null)
                Align(
                  alignment: const Alignment(0, -.8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD55660).withValues(alpha: .88),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(color: const Color(0x99E56772), blurRadius: 22, spreadRadius: 4),
                      ],
                    ),
                    child: Text(
                      subtitle!,
                      style: GoogleFonts.oswald(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = const Color(0x55A8C6D8)
      ..strokeWidth = 1;
    final floor = Paint()
      ..color = const Color(0x33A8C6D8)
      ..strokeWidth = 1;

    for (var i = 0; i <= 7; i++) {
      final y = size.height * i / 7;
      canvas.drawLine(Offset.zero.translate(0, y), Offset(size.width, y), grid);
    }
    for (var i = 0; i <= 11; i++) {
      final x = size.width * i / 11;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (var i = 0; i < 12; i++) {
      final x = size.width * i / 11;
      canvas.drawLine(Offset(x, size.height), Offset(size.width / 2, size.height * .74), floor);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CandlesPainter extends CustomPainter {
  final List<CandleData> candles;
  _CandlesPainter(this.candles);

  @override
  void paint(Canvas canvas, Size size) {
    final max = candles.map((e) => e.high).reduce((a, b) => a > b ? a : b);
    final min = candles.map((e) => e.low).reduce((a, b) => a < b ? a : b);
    final range = (max - min) == 0 ? 1.0 : max - min;
    final step = size.width / candles.length;
    final bodyWidth = step * .54;

    double yFor(double value) => size.height - ((value - min) / range) * size.height * .88 - 6;

    for (var i = 0; i < candles.length; i++) {
      final c = candles[i];
      final x = i * step + step / 2;
      final openY = yFor(c.open);
      final closeY = yFor(c.close);
      final highY = yFor(c.high);
      final lowY = yFor(c.low);
      final top = c.isGreen ? closeY : openY;
      final bottom = c.isGreen ? openY : closeY;
      final color = c.isGreen ? const Color(0xFF6BFF9A) : const Color(0xFFFF525A);

      canvas.drawLine(
        Offset(x, highY),
        Offset(x, lowY),
        Paint()..color = color.withValues(alpha: .72)..strokeWidth = 1.4,
      );
      canvas.drawRect(
        Rect.fromLTWH(x - bodyWidth / 2, top, bodyWidth, (bottom - top).abs().clamp(4, size.height)),
        Paint()..color = color.withValues(alpha: .24)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      canvas.drawRect(
        Rect.fromLTWH(x - bodyWidth / 2, top, bodyWidth, (bottom - top).abs().clamp(4, size.height)),
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CandlesPainter oldDelegate) => oldDelegate.candles != candles;
}

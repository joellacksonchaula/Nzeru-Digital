import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

/// OHLC (Open, High, Low, Close) candle data point
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
  double get bodyHeight => (close - open).abs();
  double get wickHeight => high - low;
  double get highestPrice => high;
  double get lowestPrice => low;
}

/// TradingView-style candlestick chart with interactive timeframe selection
class CandlestickChart extends StatefulWidget {
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
  State<CandlestickChart> createState() => _CandlestickChartState();
}

class _CandlestickChartState extends State<CandlestickChart>
    with SingleTickerProviderStateMixin {
  late String selectedTimeframe;
  late AnimationController _animationController;
  final List<String> timeframes = ['1m', '5m', '15m', '1h', '4h', '1d'];

  @override
  void initState() {
    super.initState();
    selectedTimeframe = '1d';
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
            child: Text(
              widget.title,
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w300,
                color: Colors.white70,
                letterSpacing: 0.5,
              ),
            ),
          ),
          // Chart area
          Expanded(
            child: widget.candles.isEmpty
                ? Center(child: Text('No data'))
                : Stack(
                    children: [
                      CustomPaint(
                        painter: _CandlestickPainter(
                          candles: widget.candles,
                        ),
                        size: Size.infinite,
                      ),
                      // Floating Badge (Centered)
                      Positioned(
                        top: 20,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Multiple glow layers
                              Container(
                                width: 140,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.4),
                                      blurRadius: 30,
                                      spreadRadius: 2,
                                    ),
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.2),
                                      blurRadius: 60,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white30, width: 1),
                                ),
                                child: Text(
                                  '- 5.40%',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for candlestick chart
class _CandlestickPainter extends CustomPainter {
  final List<CandleData> candles;

  _CandlestickPainter({required this.candles});

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;

    final maxPrice = candles.map((c) => c.high).reduce((a, b) => a > b ? a : b);
    final minPrice = candles.map((c) => c.low).reduce((a, b) => a < b ? a : b);
    final priceRange = maxPrice - minPrice;

    final candleWidth = size.width / candles.length;
    final bodyWidth = candleWidth * 0.7;

    // Draw Grid
    final gridPaint = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.1)
      ..strokeWidth = 0.5;

    // Horizontal grid lines
    const int hLines = 8;
    for (int i = 0; i <= hLines; i++) {
      final y = (size.height / hLines) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Vertical grid lines
    const int vLines = 20;
    for (int i = 0; i <= vLines; i++) {
      final x = (size.width / vLines) * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Draw candles with GLOW
    for (int i = 0; i < candles.length; i++) {
      final candle = candles[i];
      final x = (i * candleWidth) + candleWidth / 2;

      final highY = _priceToY(candle.high, size.height, maxPrice, minPrice, priceRange);
      final lowY = _priceToY(candle.low, size.height, maxPrice, minPrice, priceRange);
      final openY = _priceToY(candle.open, size.height, maxPrice, minPrice, priceRange);
      final closeY = _priceToY(candle.close, size.height, maxPrice, minPrice, priceRange);

      final isGreen = candle.isGreen;
      final color = isGreen ? const Color(0xFF00C853) : const Color(0xFFFF1744);

      // Draw GLOW first
      final glowPaint = Paint()
        ..color = color.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      
      final bodyTop = isGreen ? closeY : openY;
      final bodyBottom = isGreen ? openY : closeY;
      final bodyHeight = (bodyBottom - bodyTop).clamp(2.0, size.height);
      
      canvas.drawRect(
        Rect.fromLTWH(x - bodyWidth / 2, bodyTop, bodyWidth, bodyHeight),
        glowPaint,
      );

      // Draw WICK
      final wickPaint = Paint()
        ..color = color.withOpacity(0.8)
        ..strokeWidth = 1.5;
      
      canvas.drawLine(Offset(x, highY), Offset(x, lowY), wickPaint);

      // Draw BODY
      final bodyPaint = Paint()..color = color;
      canvas.drawRect(
        Rect.fromLTWH(x - bodyWidth / 2, bodyTop, bodyWidth, bodyHeight),
        bodyPaint,
      );
    }
  }

  double _priceToY(double price, double height, double max, double min, double range) {
    if (range == 0) return height / 2;
    return height - ((price - min) / range) * height;
  }

  @override
  bool shouldRepaint(_CandlestickPainter oldDelegate) {
    return oldDelegate.candles != candles;
  }
}


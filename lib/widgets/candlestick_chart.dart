import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/app_colors.dart';
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
  Offset? _hoveredCandle;
  int? _hoveredIndex;

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
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.black, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              widget.title,
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.black),
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
                      // Floating Badge
                      Positioned(
                        top: 20,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.actionRed,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '- 5.40%',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
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
      ..color = AppColors.black
      ..strokeWidth = 0.5;

    // Horizontal grid lines
    const int hLines = 6;
    for (int i = 0; i <= hLines; i++) {
      final y = (size.height / hLines) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Vertical grid lines
    const int vLines = 10;
    for (int i = 0; i <= vLines; i++) {
      final x = (size.width / vLines) * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Draw candles
    for (int i = 0; i < candles.length; i++) {
      final candle = candles[i];
      final x = (i * candleWidth) + candleWidth / 2;

      final highY = _priceToY(candle.high, size.height, maxPrice, minPrice, priceRange);
      final lowY = _priceToY(candle.low, size.height, maxPrice, minPrice, priceRange);
      final openY = _priceToY(candle.open, size.height, maxPrice, minPrice, priceRange);
      final closeY = _priceToY(candle.close, size.height, maxPrice, minPrice, priceRange);

      final isGreen = candle.isGreen;
      final color = isGreen ? Colors.green : Colors.red;

      final wickPaint = Paint()
        ..color = AppColors.black
        ..strokeWidth = 1;
      
      canvas.drawLine(Offset(x, highY), Offset(x, lowY), wickPaint);

      final bodyPaint = Paint()..color = color;
      final bodyTop = isGreen ? closeY : openY;
      final bodyBottom = isGreen ? openY : closeY;

      canvas.drawRect(
        Rect.fromLTRB(x - bodyWidth / 2, bodyTop, x + bodyWidth / 2, bodyBottom.clamp(bodyTop + 1, size.height)),
        bodyPaint,
      );
    }
  }

  double _priceToY(double price, double height, double max, double min, double range) {
    if (range == 0) return height / 2;
    return height - ((price - min) / range) * height;
  }

  double _priceToY(
    double price,
    double height,
    double maxPrice,
    double minPrice,
    double priceRange,
  ) {
    return height - ((price - minPrice) / priceRange) * height;
  }

  @override
  bool shouldRepaint(_CandlestickPainter oldDelegate) {
    return oldDelegate.candles != candles || oldDelegate.hoveredIndex != hoveredIndex;
  }
}

/// Tooltip showing OHLC data on hover
class _CandleTooltip extends StatelessWidget {
  final CandleData candle;
  final NumberFormat currencyFormat;

  const _CandleTooltip({
    required this.candle,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.black.withAlpha(200),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gold.withAlpha(50), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withAlpha(100),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            DateFormat('HH:mm:ss').format(candle.time),
            style: GoogleFonts.inter(
              color: AppColors.textMuted,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TooltipRow('O', candle.open),
                  _TooltipRow('H', candle.high),
                ],
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TooltipRow('L', candle.low),
                  _TooltipRow('C', candle.close),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TooltipRow extends StatelessWidget {
  final String label;
  final double value;

  const _TooltipRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.inter(
              color: AppColors.textMuted,
              fontSize: 10,
            ),
          ),
          Text(
            'MK ${value.toStringAsFixed(2)}',
            style: GoogleFonts.playfairDisplay(
              color: AppColors.gold,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

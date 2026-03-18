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
    Key? key,
    required this.candles,
    this.title = 'Price Chart',
    this.subtitle,
    this.height = 300,
    this.onRefresh,
    this.onTimeframeChanged,
  }) : super(key: key);

  @override
  State<CandlestickChart> createState() => _CandlestickChartState();
}

class _CandlestickChartState extends State<CandlestickChart>
    with SingleTickerProviderStateMixin {
  late String selectedTimeframe;
  late AnimationController _animationController;
  final List<String> timeframes = ['1m', '5m', '15m', '1h', '4h', '1d'];
  double _scaleLevel = 1.0;
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and controls
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: GoogleFonts.orbitron(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: 1,
                          ),
                        ),
                        if (widget.subtitle != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              widget.subtitle!,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (widget.onRefresh != null)
                      GestureDetector(
                        onTap: widget.onRefresh,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withAlpha(10),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.gold.withAlpha(30),
                              width: 0.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.refresh,
                            color: AppColors.gold,
                            size: 18,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // Timeframe selector
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: timeframes.map((tf) {
                      final isSelected = selectedTimeframe == tf;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedTimeframe = tf;
                              widget.onTimeframeChanged?.call(tf);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.gold
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.gold
                                    : AppColors.border,
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              tf,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? AppColors.black
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 0.5, color: AppColors.border),
          // Chart area
          Expanded(
            child: widget.candles.isEmpty
                ? Center(
                    child: Text(
                      'No data available',
                      style: GoogleFonts.inter(
                        color: AppColors.textMuted,
                        fontSize: 14,
                      ),
                    ),
                  )
                : MouseRegion(
                    onHover: (event) {
                      setState(() {
                        _hoveredCandle = event.localPosition;
                      });
                    },
                    onExit: (_) {
                      setState(() {
                        _hoveredCandle = null;
                        _hoveredIndex = null;
                      });
                    },
                    child: Stack(
                      children: [
                        // Main chart
                        CustomPaint(
                          painter: _CandlestickPainter(
                            candles: widget.candles,
                            hoveredIndex: _hoveredIndex,
                          ),
                          size: Size.infinite,
                        ),
                        // Tooltip on hover
                        if (_hoveredCandle != null && _hoveredIndex != null)
                          Positioned(
                            left: _hoveredCandle!.dx + 10,
                            top: _hoveredCandle!.dy - 60,
                            child: _CandleTooltip(
                              candle: widget.candles[_hoveredIndex!],
                              currencyFormat: NumberFormat.currency(
                                symbol: 'MK ',
                                decimalDigits: 2,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
          // Footer with info
          if (widget.candles.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Current: MK ${widget.candles.last.close.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      _buildStatChip(
                        'High',
                        'MK ${widget.candles.map((c) => c.high).reduce((a, b) => a > b ? a : b).toStringAsFixed(2)}',
                        AppColors.success,
                      ),
                      const SizedBox(width: 8),
                      _buildStatChip(
                        'Low',
                        'MK ${widget.candles.map((c) => c.low).reduce((a, b) => a < b ? a : b).toStringAsFixed(2)}',
                        AppColors.actionRed,
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(30), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9,
              color: AppColors.textMuted,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.orbitron(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
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
  final int? hoveredIndex;

  _CandlestickPainter({
    required this.candles,
    this.hoveredIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;

    // Calculate pricing bounds
    final maxPrice =
        candles.map((c) => c.high).reduce((a, b) => a > b ? a : b);
    final minPrice =
        candles.map((c) => c.low).reduce((a, b) => a < b ? a : b);
    final priceRange = maxPrice - minPrice;

    // Calculate candle width
    final candleWidth = (size.width - 20) / candles.length;
    final spacing = candleWidth * 0.2;
    final bodyWidth = candleWidth - spacing;

    // Draw grid lines and labels
    _drawGridLines(canvas, size, maxPrice, minPrice, priceRange);

    // Draw candles
    for (int i = 0; i < candles.length; i++) {
      final candle = candles[i];
      final x = 10 + (i * candleWidth) + candleWidth / 2;

      _drawCandle(
        canvas,
        size,
        candle,
        x,
        bodyWidth,
        maxPrice,
        minPrice,
        priceRange,
        i == hoveredIndex,
      );
    }
  }

  void _drawGridLines(
    Canvas canvas,
    Size size,
    double maxPrice,
    double minPrice,
    double priceRange,
  ) {
    final paint = Paint()
      ..color = AppColors.gridLine
      ..strokeWidth = 0.5;

    final textPainter = TextPainter(
      textDirection: ui.TextDirection.ltr,
    );

    // Draw 5 horizontal grid lines
    for (int i = 0; i <= 4; i++) {
      final yRatio = i / 4;
      final y = size.height * (1 - yRatio);

      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);

      // Price label
      final price = minPrice + (priceRange * yRatio);
      textPainter.text = TextSpan(
        text: 'MK ${price.toStringAsFixed(0)}',
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(size.width - 60, y - 5),
      );
    }
  }

  void _drawCandle(
    Canvas canvas,
    Size size,
    CandleData candle,
    double x,
    double bodyWidth,
    double maxPrice,
    double minPrice,
    double priceRange,
    bool isHovered,
  ) {
    final highY = _priceToY(candle.high, size.height, maxPrice, minPrice, priceRange);
    final lowY = _priceToY(candle.low, size.height, maxPrice, minPrice, priceRange);
    final openY =
        _priceToY(candle.open, size.height, maxPrice, minPrice, priceRange);
    final closeY =
        _priceToY(candle.close, size.height, maxPrice, minPrice, priceRange);

    // Wick color and body color
    final isGreen = candle.isGreen;
    final color = isGreen ? AppColors.success : AppColors.actionRed;
    final wickPaint = Paint()
      ..color = color
      ..strokeWidth = 1.5;

    final bodyPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final bodyStrokePaint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw wick (high-low line)
    canvas.drawLine(Offset(x, highY), Offset(x, lowY), wickPaint);

    // Draw body (open-close rectangle)
    final bodyTop = isGreen ? closeY : openY;
    final bodyBottom = isGreen ? openY : closeY;
    final bodyHeight = (bodyBottom - bodyTop).abs();

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x - bodyWidth / 2, bodyTop, bodyWidth, bodyHeight),
      const Radius.circular(1),
    );

    canvas.drawRRect(bodyRect, bodyPaint);

    // Highlight on hover
    if (isHovered) {
      final highlightPaint = Paint()
        ..color = color.withAlpha(50)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawRRect(bodyRect, highlightPaint);

      // Draw highlight box around candle
      final highlightRect = Rect.fromLTWH(
        x - bodyWidth / 2 - 2,
        highY - 2,
        bodyWidth + 4,
        lowY - highY + 4,
      );
      canvas.drawRect(highlightRect, highlightPaint);
    }
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
            style: GoogleFonts.orbitron(
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

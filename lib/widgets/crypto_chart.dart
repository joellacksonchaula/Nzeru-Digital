import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../config/app_colors.dart';
import 'glass_card.dart';

class CryptoChart extends StatefulWidget {
  final String title;
  final List<double> data;
  final String symbol;
  final double changePercent;
  final bool isPositive;

  const CryptoChart({
    super.key,
    required this.title,
    required this.data,
    required this.symbol,
    required this.changePercent,
    required this.isPositive,
  });

  @override
  State<CryptoChart> createState() => _CryptoChartState();
}

class _CryptoChartState extends State<CryptoChart> {
  @override
  Widget build(BuildContext context) {
    final spots = widget.data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    return GlassCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      blurAmount: 15,
      borderColor: AppColors.primaryRed.withAlpha(40),
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
                    widget.title.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.symbol,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: widget.isPositive
                      ? const Color(0xFF00D084)
                      : AppColors.actionRed,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.isPositive ? '+' : ''} ${widget.changePercent.toStringAsFixed(2)}%',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.border.withAlpha(80),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                titlesData: const FlTitlesData(
                  show: false,
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                minX: 0,
                maxX: widget.data.length.toDouble() - 1,
                minY: widget.data.reduce((a, b) => a < b ? a : b) * 0.8,
                maxY: widget.data.reduce((a, b) => a > b ? a : b) * 1.2,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: widget.isPositive
                        ? const Color(0xFF00D084)
                        : AppColors.actionRed,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 5,
                          color: widget.isPositive
                              ? const Color(0xFF00D084)
                              : AppColors.actionRed,
                          strokeWidth: 3,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          (widget.isPositive
                                  ? const Color(0xFF00D084)
                                  : AppColors.actionRed)
                              .withAlpha(60),
                          (widget.isPositive
                                  ? const Color(0xFF00D084)
                                  : AppColors.actionRed)
                              .withAlpha(0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../config/app_colors.dart';

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

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.cryptoCardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border.withAlpha(200),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withAlpha(30),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
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
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.symbol,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: widget.isPositive
                        ? const LinearGradient(
                            colors: [
                              Color(0xFF00D084),
                              Color(0xFF00B366),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : AppColors.redCryptoGradient,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: widget.isPositive
                            ? const Color(0xFF00D084).withAlpha(40)
                            : AppColors.actionRed.withAlpha(40),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Text(
                    '${widget.isPositive ? '+' : ''} ${widget.changePercent.toStringAsFixed(2)}%',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.background,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 120,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 20,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppColors.gridLine.withAlpha(100),
                        strokeWidth: 0.5,
                      );
                    },
                  ),
                  titlesData: const FlTitlesData(
                    show: false,
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.border.withAlpha(150),
                        width: 1,
                      ),
                      left: BorderSide(
                        color: AppColors.border.withAlpha(150),
                        width: 1,
                      ),
                    ),
                  ),
                  minX: 0,
                  maxX: widget.data.length.toDouble() - 1,
                  minY: -10,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      gradient: widget.isPositive
                          ? const LinearGradient(
                              colors: [
                                Color(0xFF00D084),
                                Color(0xFF00B366),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : AppColors.redCryptoGradient,
                      barWidth: 2.5,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: widget.isPositive
                                ? const Color(0xFF00D084)
                                : AppColors.actionRed,
                            strokeWidth: 1.5,
                            strokeColor: AppColors.background,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            widget.isPositive
                                ? const Color(0xFF00D084).withAlpha(80)
                                : AppColors.actionRed.withAlpha(80),
                            widget.isPositive
                                ? const Color(0xFF00D084).withAlpha(10)
                                : AppColors.actionRed.withAlpha(10),
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
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';

class CryptoMarketCard extends StatelessWidget {
  final String name;
  final String symbol;
  final double price;
  final double marketCap;
  final double volume24h;
  final double changePercent24h;
  final bool isGold;

  const CryptoMarketCard({
    super.key,
    required this.name,
    required this.symbol,
    required this.price,
    required this.marketCap,
    required this.volume24h,
    required this.changePercent24h,
    this.isGold = false,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = changePercent24h >= 0;

    return Container(
      decoration: BoxDecoration(
        gradient: isGold ? AppColors.cryptoCardGradient : AppColors.cryptoCardGradient,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isGold
              ? AppColors.gold.withAlpha(150)
              : AppColors.border.withAlpha(150),
          width: isGold ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isGold
                ? AppColors.gold.withAlpha(40)
                : AppColors.black.withAlpha(20),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
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
                      name,
                      style: GoogleFonts.orbitron(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isGold ? AppColors.gold : AppColors.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      symbol,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? const Color(0xFF00D084).withAlpha(20)
                        : AppColors.actionRed.withAlpha(20),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isPositive
                          ? const Color(0xFF00D084).withAlpha(100)
                          : AppColors.actionRed.withAlpha(100),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    '${isPositive ? '+' : ''} ${changePercent24h.toStringAsFixed(1)}%',
                    style: GoogleFonts.orbitron(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isPositive
                          ? const Color(0xFF00D084)
                          : AppColors.actionRed,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '\$${price.toStringAsFixed(2)}',
              style: GoogleFonts.orbitron(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _InfoPill(
                  label: 'Vol 24h',
                  value: '\$${(volume24h / 1e9).toStringAsFixed(1)}B',
                ),
                _InfoPill(
                  label: 'Market Cap',
                  value: '\$${(marketCap / 1e9).toStringAsFixed(1)}B',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label;
  final String value;

  const _InfoPill({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.orbitron(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

import 'package:intl/intl.dart';
import '../config/app_colors.dart';
import 'glass_card.dart';

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

    return GlassCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      borderRadius: 16,
      blurAmount: 10,
      borderColor: isGold ? AppColors.gold.withAlpha(120) : AppColors.gold.withAlpha(40),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      symbol,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        letterSpacing: 0.5,
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
                    color: isPositive ? AppColors.gold : AppColors.actionRed,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${isPositive ? '+' : ''}${changePercent24h.toStringAsFixed(1)}%',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'MK ${NumberFormat("#,##0.00").format(price)}',
              style: GoogleFonts.playfairDisplay(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _InfoPill(
                  label: 'Vol 24h',
                  value: 'MK ${(volume24h / 1e9).toStringAsFixed(1)}B',
                ),
                _InfoPill(
                  label: 'Market Cap',
                  value: 'MK ${(marketCap / 1e9).toStringAsFixed(1)}B',
                ),
              ],
            ),
      ],
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
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

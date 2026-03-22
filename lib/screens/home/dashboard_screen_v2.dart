import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/crypto_market_card.dart';
import '../../widgets/crypto_chart.dart';
import '../../widgets/glass_card.dart';
import '../../utils/currency_formatter.dart';
import '../../models/savings_transaction.dart';
import '../../widgets/candlestick_chart.dart';

class DashboardScreenV2 extends StatefulWidget {
  const DashboardScreenV2({super.key});

  @override
  State<DashboardScreenV2> createState() => _DashboardScreenV2State();
}

class _DashboardScreenV2State extends State<DashboardScreenV2> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<DashboardProvider>();
    final user = dashboardProvider.user;
    final dashboardData = dashboardProvider.data;

    if (dashboardProvider.isLoading && dashboardData == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.gold)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black, // Base color for high-tech look
      body: Stack(
        children: [
          // High-tech Background Layer (Gradient stack)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A1C1E), Color(0xFF0D0E10)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Subtle circular 'glows' for spaceship lighting
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.blue.withOpacity(0.05), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(bottom: -200, left: -100, child: Container(width: 600, height: 600, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [Colors.blue.withOpacity(0.03), Colors.transparent])))),

          SafeArea(
            child: RefreshIndicator(
              color: AppColors.gold,
              onRefresh: () async => await context.read<DashboardProvider>().loadDashboard(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Area
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const RadialGradient(
                                colors: [Color(0xFFFDB813), Color(0xFF784B12)],
                              ),
                              border: Border.all(color: Colors.white24, width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFDB813).withOpacity(0.2),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.blur_on_rounded, color: Colors.white, size: 30),
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back,',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: Colors.white60,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              Text(
                                user?.name?.toLowerCase() ?? 'joel chaula',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 24,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Top Savings Cards (Row)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          _buildSavingsCard(
                            title: 'Phone Cash',
                            subtitle: 'Savings Plan',
                            target: 'MK 85,000.00',
                            saved: 'MK 45,000.00',
                            progress: 0.53,
                            trend: 5.4, // Positive in screenshot arrow but text has -5.4 red chart... wait. 
                            // In screenshot first card has red downward chart but says +5.4%? No, it's red.
                            icon: Icons.phone_android_rounded,
                            detail: 'Est. Completion: June 2026\nNext payment: April 1',
                            isTrendPositive: false,
                          ),
                          _buildSavingsCard(
                            title: 'Car Cash',
                            subtitle: 'Savings Plan',
                            target: 'MK 15,000,000.00',
                            saved: 'MK 1,200,000.00',
                            progress: 0.08,
                            trend: 1.2,
                            icon: Icons.directions_car_rounded,
                            detail: 'Est. Completion: 2028\nAutomated deposit: Active',
                            showRing: true,
                            isTrendPositive: true,
                          ),
                          _buildSavingsCard(
                            title: 'Vacation Fund',
                            subtitle: 'Savings Plan',
                            target: 'MK 500,000.00',
                            saved: 'MK 250,000.00',
                            progress: 0.5,
                            trend: 0.8,
                            icon: Icons.beach_access_rounded,
                            detail: 'Est. Completion: Dec 2026\nRecent activity: Manual add',
                            isTrendPositive: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Market Chart (Candlestick)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: CandlestickChart(
                        title: 'Bitcoin Performance',
                        candles: _generateSampleCandles(),
                        height: 320,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Quick Actions
                    Center(
                      child: Text(
                        'QUICK ACTIONS',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white54,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _QuickAction(
                            icon: Icons.file_download_outlined,
                            label: 'Deposit',
                            onTap: () => Navigator.pushNamed(context, AppRoutes.deposit),
                          ),
                          _QuickAction(
                            icon: Icons.assignment_outlined,
                            label: 'New Plan',
                            onTap: () => Navigator.pushNamed(context, AppRoutes.createPlan),
                          ),
                          _QuickAction(
                            icon: Icons.savings_outlined,
                            label: 'Loan',
                            onTap: () => Navigator.pushNamed(context, AppRoutes.requestLoan),
                          ),
                          _QuickAction(
                            icon: Icons.history_outlined,
                            label: 'Repay',
                            onTap: () => Navigator.pushNamed(context, AppRoutes.repayment),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Recent Transactions
                    Center(
                      child: Text(
                        'RECENT TRANSACTIONS',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white54,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2.3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: (dashboardProvider.recentTransactions.length > 4) ? 4 : dashboardProvider.recentTransactions.length,
                        itemBuilder: (context, index) {
                          final txn = dashboardProvider.recentTransactions[index];
                          return GlassCard(
                            margin: EdgeInsets.zero,
                            padding: const EdgeInsets.all(12),
                            borderRadius: 12,
                            blurAmount: 10,
                            borderColor: Colors.white12,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      txn.typeLabel,
                                      style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w400),
                                    ),
                                    Text(
                                      DateFormat('dd MMM yyyy, HH:mm').format(txn.date),
                                      style: GoogleFonts.inter(color: Colors.white30, fontSize: 8),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${txn.isCredit ? '+' : '-'}${CurrencyFormatter.formatMK(txn.amount)}',
                                      style: GoogleFonts.inter(
                                        color: txn.isCredit ? const Color(0xFFFDB813) : Colors.redAccent,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Icon(
                                      txn.isCredit ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                                      color: txn.isCredit ? const Color(0xFFFDB813) : Colors.redAccent,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsCard({
    required String title,
    required String subtitle,
    required String target,
    required String saved,
    required double progress,
    required double trend,
    required IconData icon,
    required String detail,
    bool showRing = false,
    bool isTrendPositive = true,
  }) {
    return GlassCard(
      width: 320,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      padding: const EdgeInsets.all(20),
      borderRadius: 15,
      blurAmount: 15,
      borderColor: Colors.white12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(subtitle, style: GoogleFonts.inter(fontSize: 14, color: Colors.white60)),
                ],
              ),
              Row(
                children: [
                  // Mini Sparkline
                  SizedBox(
                    width: 40,
                    height: 20,
                    child: CustomPaint(
                      painter: _SparklinePainter(
                        color: isTrendPositive ? const Color(0xFF00C853) : const Color(0xFFFF1744),
                        isPositive: isTrendPositive,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isTrendPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                    color: isTrendPositive ? const Color(0xFF00C853) : const Color(0xFFFF1744),
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${isTrendPositive ? '+' : ''}$trend%',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: isTrendPositive ? const Color(0xFF00C853) : const Color(0xFFFF1744),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Target: $target', style: GoogleFonts.inter(fontSize: 14, color: Colors.white70)),
                    Text(
                      'Saved: $saved',
                      style: GoogleFonts.inter(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Icon(icon, color: Colors.white70, size: 36),
            ],
          ),
          const SizedBox(height: 15),
          if (showRing)
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 45,
                    height: 45,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 4,
                      backgroundColor: Colors.white10,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFDB813)),
                    ),
                  ),
                  Text('${(progress * 100).toInt()}%', style: GoogleFonts.inter(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: Colors.white10,
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B5E3C)),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 2,
                        width: double.infinity,
                        color: Colors.white05,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Text('${(progress * 100).toInt()}%', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
              ],
            ),
          const SizedBox(height: 12),
          Text(detail, style: GoogleFonts.inter(fontSize: 12, color: Colors.white24, height: 1.5)),
        ],
      ),
    );
  }

  List<CandleData> _generateSampleCandles() {
    final now = DateTime.now();
    return List.generate(40, (i) {
      final base = 50.0 + (i % 5) * 5;
      return CandleData(time: now.subtract(Duration(minutes: i)), open: base, high: base + 10, low: base - 5, close: base + (i % 2 == 0 ? 5 : -3), volume: 100);
    });
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Halo/Glow
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFDB813).withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              // Glass Disc
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.4),
                  border: Border.all(color: const Color(0xFFFDB813).withOpacity(0.5), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFDB813).withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white70,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final Color color;
  final bool isPositive;

  _SparklinePainter({required this.color, required this.isPositive});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final points = isPositive
        ? [0.8, 0.6, 0.7, 0.4, 0.5, 0.2]
        : [0.2, 0.4, 0.3, 0.6, 0.5, 0.8];

    final dx = size.width / (points.length - 1);
    path.moveTo(0, points[0] * size.height);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(i * dx, points[i] * size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

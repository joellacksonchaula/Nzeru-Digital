import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../models/savings_transaction.dart';
import '../../providers/dashboard_provider.dart';
import '../../utils/currency_formatter.dart';
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
    final provider = context.watch<DashboardProvider>();
    final txns = provider.recentTransactions.isEmpty
        ? _fallbackTransactions
        : provider.recentTransactions.take(4).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFE7E1D5),
      body: Stack(
        children: [
          const _Backdrop(),
          SafeArea(
            child: RefreshIndicator(
              color: AppColors.gold,
              onRefresh: () => context.read<DashboardProvider>().loadDashboard(),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 900;
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1400),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Header(name: provider.user?.name?.toLowerCase() ?? 'joel chaula'),
                            const SizedBox(height: 16),
                            _PlanCards(compact: compact),
                            const SizedBox(height: 16),
                            CandlestickChart(
                              title: 'Bitcoin Performance',
                              subtitle: '-5.40%',
                              candles: _candles,
                              height: compact ? 270 : 360,
                            ),
                            const SizedBox(height: 18),
                            _Actions(compact: compact),
                            const SizedBox(height: 18),
                            _Transactions(compact: compact, txns: txns),
                            if (provider.isLoading) ...[
                              const SizedBox(height: 16),
                              const Center(child: CircularProgressIndicator(color: AppColors.gold)),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop();

  @override
  Widget build(BuildContext context) {
    Widget orb(double size, Color color) => ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
        );

    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF5EEE3), Color(0xFFD7E1E5), Color(0xFFE9E0D0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned.fill(child: CustomPaint(painter: _BackdropPainter())),
        Positioned(top: -30, left: -20, child: orb(160, const Color(0x88F4E6C1))),
        Positioned(top: 220, right: -40, child: orb(220, const Color(0x88D2E8F3))),
        Positioned(bottom: -30, left: 160, child: orb(260, const Color(0x88E8DABB))),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final String name;
  const _Header({required this.name});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [Color(0xFFFFE7AD), Color(0xFFC9A03A), Color(0xFF6C4B17)],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.9), width: 1.5),
            boxShadow: [BoxShadow(color: const Color(0x66D7A93D), blurRadius: 18, spreadRadius: 2)],
          ),
          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome back,', style: GoogleFonts.oswald(fontSize: 22, color: Colors.white)),
            Text(name, style: GoogleFonts.oswald(fontSize: 34, height: .9, color: const Color(0xFF183B49), fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}

class _PlanCards extends StatelessWidget {
  final bool compact;
  const _PlanCards({required this.compact});

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return const Column(
        children: [
          _PlanCard(title: 'Phone Cash', target: 'MK 85,000.00', saved: 'MK 45,000.00', progress: .53, change: '+5.4%', left: 'Est. Completion: June 2026', right: 'Next payment: April 1', icon: Icons.phone_iphone_rounded, positive: false),
          SizedBox(height: 12),
          _PlanCard(title: 'Car Cash', target: 'MK 15,000,000.00', saved: 'MK 1,200,000.00', progress: .08, change: '+1.2%', left: 'Est. Completion: 2028', right: 'Automated deposit: Active', icon: Icons.directions_car_filled_rounded, ring: true),
          SizedBox(height: 12),
          _PlanCard(title: 'Vacation Fund', target: 'MK 500,000.00', saved: 'MK 250,000.00', progress: .50, change: '+0.8%', left: 'Est. Completion: Dec 2026', right: 'Recent activity: Manual add', icon: Icons.beach_access_rounded, gauge: true),
        ],
      );
    }

    return const Row(
      children: [
        Expanded(child: _PlanCard(title: 'Phone Cash', target: 'MK 85,000.00', saved: 'MK 45,000.00', progress: .53, change: '+5.4%', left: 'Est. Completion: June 2026', right: 'Next payment: April 1', icon: Icons.phone_iphone_rounded, positive: false)),
        SizedBox(width: 16),
        Expanded(child: _PlanCard(title: 'Car Cash', target: 'MK 15,000,000.00', saved: 'MK 1,200,000.00', progress: .08, change: '+1.2%', left: 'Est. Completion: 2028', right: 'Automated deposit: Active', icon: Icons.directions_car_filled_rounded, ring: true)),
        SizedBox(width: 16),
        Expanded(child: _PlanCard(title: 'Vacation Fund', target: 'MK 500,000.00', saved: 'MK 250,000.00', progress: .50, change: '+0.8%', left: 'Est. Completion: Dec 2026', right: 'Recent activity: Manual add', icon: Icons.beach_access_rounded, gauge: true)),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String target;
  final String saved;
  final double progress;
  final String change;
  final String left;
  final String right;
  final IconData icon;
  final bool positive;
  final bool ring;
  final bool gauge;

  const _PlanCard({
    required this.title,
    required this.target,
    required this.saved,
    required this.progress,
    required this.change,
    required this.left,
    required this.right,
    required this.icon,
    this.positive = true,
    this.ring = false,
    this.gauge = false,
  });

  @override
  Widget build(BuildContext context) {
    final trend = positive ? const Color(0xFF4B9957) : const Color(0xFFC2545E);
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.62),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(.75)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(.14), blurRadius: 18, offset: const Offset(0, 8))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: GoogleFonts.oswald(fontSize: 24, height: .95, color: const Color(0xFF23211E), fontWeight: FontWeight.w600)),
                Text('Savings Plan', style: GoogleFonts.oswald(fontSize: 13, color: const Color(0xFF3B3631), fontWeight: FontWeight.w300)),
              ])),
              Icon(icon, size: 42, color: const Color(0xFF8D6B4B)),
              const SizedBox(width: 8),
              Row(mainAxisSize: MainAxisSize.min, children: [
                SizedBox(width: 38, height: 20, child: CustomPaint(painter: _SparkPainter(color: trend, up: positive))),
                const SizedBox(width: 4),
                Text(change, style: GoogleFonts.oswald(fontSize: 17, color: trend, fontWeight: FontWeight.w500)),
              ]),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Target: $target', style: GoogleFonts.oswald(fontSize: 16, color: const Color(0xFF302B28))),
                Text('Saved: $saved', style: GoogleFonts.oswald(fontSize: 14, color: const Color(0xFF2A2A2A))),
              ])),
              if (ring) _Ring(progress: progress),
              if (gauge) _Gauge(progress: progress),
            ]),
            const SizedBox(height: 10),
            if (!ring && !gauge)
              Row(children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: const Color(0x80C7B8A9),
                      valueColor: const AlwaysStoppedAnimation(Color(0xFF876446)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('${(progress * 100).round()}%', style: GoogleFonts.oswald(fontSize: 15, color: const Color(0xFF3D3734))),
              ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: Text(left, style: GoogleFonts.oswald(fontSize: 12, color: const Color(0xFF3B3632), fontWeight: FontWeight.w300))),
              Expanded(child: Text(right, textAlign: TextAlign.right, style: GoogleFonts.oswald(fontSize: 12, color: const Color(0xFF3B3632), fontWeight: FontWeight.w300))),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  final double progress;
  const _Ring({required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(fit: StackFit.expand, children: [
        CircularProgressIndicator(value: progress, strokeWidth: 5, backgroundColor: const Color(0xFFD7D1CB), valueColor: const AlwaysStoppedAnimation(Color(0xFF9C8B72))),
        Center(child: Text('${(progress * 100).round()}%', style: GoogleFonts.oswald(fontSize: 14, color: const Color(0xFF35302B)))),
      ]),
    );
  }
}

class _Gauge extends StatelessWidget {
  final double progress;
  const _Gauge({required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 72, height: 38, child: CustomPaint(painter: _GaugePainter(progress)));
  }
}

class _Actions extends StatelessWidget {
  final bool compact;
  const _Actions({required this.compact});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.download_rounded, 'Deposit', AppRoutes.deposit),
      (Icons.note_alt_rounded, 'New Plan', AppRoutes.createPlan),
      (Icons.account_balance_wallet_rounded, 'Loan', AppRoutes.requestLoan),
      (Icons.currency_exchange_rounded, 'Repay', AppRoutes.repayment),
    ];
    return Column(children: [
      Text('QUICK ACTIONS', style: GoogleFonts.cormorantGaramond(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF2B2117))),
      const SizedBox(height: 10),
      Wrap(
        alignment: WrapAlignment.center,
        spacing: compact ? 16 : 28,
        runSpacing: 12,
        children: items.map((e) => _Action(icon: e.$1, label: e.$2, onTap: () => Navigator.pushNamed(context, e.$3))).toList(),
      ),
    ]);
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _Action({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [Color(0xFFFFF7D9), Color(0xFFF2D98D), Color(0xFFB68A25)]),
            ),
            child: Center(
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(.58), border: Border.all(color: Colors.white.withOpacity(.8))),
                child: Icon(icon, color: const Color(0xFF5C482C), size: 24),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: GoogleFonts.oswald(fontSize: 15, color: const Color(0xFF2E261E))),
        ]),
      ),
    );
  }
}

class _Transactions extends StatelessWidget {
  final bool compact;
  final List<SavingsTransaction> txns;
  const _Transactions({required this.compact, required this.txns});

  @override
  Widget build(BuildContext context) {
    final list = txns.length >= 4 ? txns : [...txns, ..._fallbackTransactions].take(4).toList();
    return Column(children: [
      Text('RECENT TRANSACTIONS', style: GoogleFonts.cormorantGaramond(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF2B2117))),
      const SizedBox(height: 10),
      ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.58),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(.7)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(.12), blurRadius: 18, offset: const Offset(0, 8))],
            ),
            child: compact
                ? Column(children: [for (var i = 0; i < list.length; i++) _TxnRow(txn: list[i], divider: i != list.length - 1)])
                : Row(children: [
                    Expanded(child: Column(children: [_TxnRow(txn: list[0], divider: true), _TxnRow(txn: list[1])])),
                    Container(width: 1, height: 168, color: const Color(0xFFD6D0C8)),
                    Expanded(child: Column(children: [_TxnRow(txn: list[2], divider: true), _TxnRow(txn: list[3])])),
                  ]),
          ),
        ),
      ),
    ]);
  }
}

class _TxnRow extends StatelessWidget {
  final SavingsTransaction txn;
  final bool divider;
  const _TxnRow({required this.txn, this.divider = false});

  @override
  Widget build(BuildContext context) {
    final color = txn.isCredit ? const Color(0xFFC59B2B) : const Color(0xFFB74B4F);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(border: divider ? const Border(bottom: BorderSide(color: Color(0xFFD6D0C8))) : null),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(txn.typeLabel, style: GoogleFonts.oswald(fontSize: 18, color: const Color(0xFF23211E))),
            Text(DateFormat('dd MMM yyyy, HH:mm').format(txn.date), style: GoogleFonts.oswald(fontSize: 13, color: const Color(0xFF2E2A28), fontWeight: FontWeight.w300)),
          ]),
        ),
        const SizedBox(width: 16),
        Text('${txn.isCredit ? '+' : '-'}${CurrencyFormatter.formatMK(txn.amount)}', style: GoogleFonts.oswald(fontSize: 18, color: color, fontWeight: FontWeight.w500)),
        Icon(txn.isCredit ? Icons.arrow_upward : Icons.arrow_downward, size: 20, color: color),
      ]),
    );
  }
}

class _BackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strong = Paint()..color = const Color(0x80685846)..style = PaintingStyle.stroke..strokeWidth = 5;
    final soft = Paint()..color = const Color(0x33FFFFFF)..style = PaintingStyle.stroke..strokeWidth = 2;
    final left = Path()..moveTo(0, size.height * .12)..quadraticBezierTo(size.width * .12, size.height * .18, size.width * .14, size.height * .58)..quadraticBezierTo(size.width * .10, size.height * .86, size.width * .02, size.height);
    final right = Path()..moveTo(size.width, size.height * .12)..quadraticBezierTo(size.width * .88, size.height * .18, size.width * .86, size.height * .58)..quadraticBezierTo(size.width * .90, size.height * .86, size.width * .98, size.height);
    canvas.drawPath(left, strong);
    canvas.drawPath(right, strong);
    canvas.drawPath(left.shift(const Offset(12, 6)), soft);
    canvas.drawPath(right.shift(const Offset(-12, 6)), soft);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * .18, size.height * .83, size.width * .64, size.height * .16), const Radius.circular(40)), Paint()..color = const Color(0x4D715942));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * .22, 0, size.width * .56, size.height * .08), const Radius.circular(20)), Paint()..color = const Color(0x4DB29B7B));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GaugePainter extends CustomPainter {
  final double progress;
  _GaugePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 6;
    final track = Paint()..color = const Color(0xFFD0CBC4)..style = PaintingStyle.stroke..strokeWidth = 8..strokeCap = StrokeCap.round;
    final value = Paint()..color = const Color(0xFF9B8460)..style = PaintingStyle.stroke..strokeWidth = 8..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 3.14159, 3.14159, false, track);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 3.14159, 3.14159 * progress, false, value);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) => oldDelegate.progress != progress;
}

class _SparkPainter extends CustomPainter {
  final Color color;
  final bool up;
  _SparkPainter({required this.color, required this.up});

  @override
  void paint(Canvas canvas, Size size) {
    final pts = up ? [0.72, 0.64, 0.66, 0.44, 0.33, 0.22] : [0.24, 0.40, 0.34, 0.58, 0.62, 0.80];
    final gap = size.width / (pts.length - 1);
    final path = Path()..moveTo(0, pts.first * size.height);
    for (var i = 1; i < pts.length; i++) {
      path.lineTo(i * gap, pts[i] * size.height);
    }
    canvas.drawPath(path, Paint()..color = color..strokeWidth = 2.2..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(covariant _SparkPainter oldDelegate) => oldDelegate.color != color || oldDelegate.up != up;
}

final _candles = [
  [98.0, 101.0, 96.0, 97.0], [97.0, 99.0, 92.0, 94.0], [94.0, 95.0, 90.0, 91.0], [91.0, 92.0, 87.0, 88.0], [88.0, 89.0, 85.0, 86.0], [86.0, 88.0, 85.0, 87.0], [87.0, 92.0, 86.0, 90.0], [90.0, 98.0, 89.0, 96.0], [96.0, 97.0, 91.0, 93.0], [93.0, 95.0, 89.0, 90.0], [90.0, 99.0, 88.0, 98.0], [98.0, 100.0, 94.0, 96.0], [96.0, 97.0, 89.0, 91.0], [91.0, 92.0, 84.0, 86.0], [86.0, 87.0, 79.0, 81.0], [81.0, 87.0, 80.0, 85.0], [85.0, 92.0, 84.0, 90.0], [90.0, 91.0, 83.0, 85.0], [85.0, 86.0, 79.0, 81.0], [81.0, 83.0, 78.0, 79.0], [79.0, 85.0, 78.0, 82.0], [82.0, 88.0, 80.0, 86.0], [86.0, 87.0, 79.0, 81.0], [81.0, 82.0, 76.0, 79.0], [79.0, 81.0, 75.0, 77.0], [77.0, 82.0, 76.0, 80.0], [80.0, 85.0, 78.0, 82.0], [82.0, 83.0, 77.0, 79.0], [79.0, 90.0, 78.0, 87.0], [87.0, 89.0, 85.0, 86.0], [86.0, 92.0, 84.0, 89.0], [89.0, 93.0, 88.0, 91.0], [91.0, 92.0, 86.0, 88.0], [88.0, 89.0, 85.0, 87.0], [87.0, 95.0, 86.0, 93.0], [93.0, 96.0, 92.0, 94.0], [94.0, 95.0, 87.0, 89.0], [89.0, 90.0, 83.0, 86.0], [86.0, 87.0, 80.0, 82.0], [82.0, 84.0, 80.0, 81.0],
].asMap().entries.map((e) => CandleData(time: DateTime.now().subtract(Duration(hours: 40 - e.key)), open: e.value[0], high: e.value[1], low: e.value[2], close: e.value[3], volume: 1000 + e.key * 15)).toList();

final _fallbackTransactions = [
  SavingsTransaction(id: '1', userId: 'demo', amount: 3330000, date: DateTime(2026, 3, 16, 21, 40), type: TransactionType.withdrawal),
  SavingsTransaction(id: '2', userId: 'demo', amount: 2000, date: DateTime(2026, 3, 16, 21, 40), type: TransactionType.deposit),
  SavingsTransaction(id: '3', userId: 'demo', amount: 2000, date: DateTime(2026, 3, 16, 21, 40), type: TransactionType.deposit),
  SavingsTransaction(id: '4', userId: 'demo', amount: 3300, date: DateTime(2026, 3, 16, 21, 40), type: TransactionType.deposit),
];

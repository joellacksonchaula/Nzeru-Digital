import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/app_colors.dart';
import '../../widgets/notification_card.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      _NotifData(
        icon: Icons.savings_rounded,
        title: 'Savings Due Tomorrow',
        message: 'Your weekly deposit of MK 100 is due tomorrow. Stay on track!',
        time: '2h ago',
        color: AppColors.gold,
      ),
      _NotifData(
        icon: Icons.payment_rounded,
        title: 'Loan Repayment Reminder',
        message: 'Monthly loan payment of MK 100 is due on March 15th.',
        time: '5h ago',
        color: AppColors.info,
      ),
      _NotifData(
        icon: Icons.warning_amber_rounded,
        title: 'Penalty Warning',
        message: 'You have 2 days left in your grace period. Deposit before penalty applies.',
        time: '1d ago',
        color: AppColors.actionRed,
      ),
      _NotifData(
        icon: Icons.emoji_events_rounded,
        title: 'Loan Eligibility Unlocked!',
        message: 'Congratulations! You are now eligible for a loan up to MK 1,600.',
        time: '2d ago',
        color: AppColors.success,
      ),
      _NotifData(
        icon: Icons.trending_up_rounded,
        title: 'Financial Score Update',
        message: 'Your financial score improved to 87/100. Keep up the great work!',
        time: '3d ago',
        color: AppColors.gold,
      ),
      _NotifData(
        icon: Icons.check_circle_rounded,
        title: 'Deposit Confirmed',
        message: 'Your deposit of MK 100 to Weekly Plan has been processed.',
        time: '4d ago',
        color: AppColors.success,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('NOTIFICATIONS',
            style: GoogleFonts.playfairDisplay(
                fontSize: 16, letterSpacing: 2, color: AppColors.gold)),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.gold),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text('Clear All',
                style: GoogleFonts.inter(
                    color: AppColors.textMuted, fontSize: 12)),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final n = notifications[index];
          return NotificationCard(
            icon: n.icon,
            title: n.title,
            message: n.message,
            time: n.time,
            iconColor: n.color,
          ).animate().fadeIn(
                delay: Duration(milliseconds: 100 * index),
                duration: 400.ms,
              );
        },
      ),
    );
  }
}

class _NotifData {
  final IconData icon;
  final String title;
  final String message;
  final String time;
  final Color color;

  _NotifData({
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
    required this.color,
  });
}

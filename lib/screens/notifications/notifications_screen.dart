import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../config/app_colors.dart';
import '../../services/api_service.dart';
import '../../widgets/dashboard_kit.dart';
import '../../widgets/notification_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService().getNotifications();
  }

  Future<void> _reload() async {
    setState(() {
      _future = ApiService().getNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const DashboardBackdrop(darkMode: false),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'NZELU UPDATES',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                letterSpacing: 2.1,
                                color: const Color(0xFF0ABAB5),
                              ),
                            ),
                            Text(
                              'Notifications',
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                color: const Color(0xFF171412),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          await ApiService().markAllNotificationsRead();
                          await _reload();
                        },
                        child: const Text('Mark all read'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<dynamic>>(
                    future: _future,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(color: AppColors.loadingRed),
                        );
                      }

                      final notifications = snapshot.data!;
                      if (notifications.isEmpty) {
                        return Center(
                          child: Text(
                            'No notifications yet.',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.textMuted,
                            ),
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: _reload,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            final notification = Map<String, dynamic>.from(
                              notifications[index] as Map,
                            );
                            return NotificationCard(
                              icon: _iconFor(notification['type']?.toString()),
                              title: notification['title']?.toString() ?? 'Notification',
                              message: notification['message']?.toString() ?? '',
                              time: _timeLabel(notification['created_at']?.toString()),
                              iconColor: _colorFor(notification['type']?.toString()),
                              onTap: () async {
                                final id = int.tryParse(notification['id'].toString());
                                if (id != null) {
                                  await ApiService().markNotificationRead(id);
                                  await _reload();
                                }
                              },
                            ).animate().fadeIn(
                                  delay: Duration(milliseconds: 90 * index),
                                  duration: 300.ms,
                                );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _timeLabel(String? raw) {
    final date = raw == null ? null : DateTime.tryParse(raw);
    if (date == null) return '--';
    return DateFormat('dd MMM, HH:mm').format(date.toLocal());
  }

  IconData _iconFor(String? type) {
    switch ((type ?? '').toUpperCase()) {
      case 'LOAN_REPAYMENT':
        return Icons.payment_rounded;
      case 'LOAN_APPROVED':
      case 'LOAN_ELIGIBLE':
        return Icons.account_balance_wallet_rounded;
      case 'PENALTY_APPLIED':
      case 'SAVINGS_MISSED':
        return Icons.warning_amber_rounded;
      case 'INTEREST_REWARD':
        return Icons.trending_up_rounded;
      default:
        return Icons.notifications_active_outlined;
    }
  }

  Color _colorFor(String? type) {
    switch ((type ?? '').toUpperCase()) {
      case 'LOAN_REPAYMENT':
        return AppColors.info;
      case 'LOAN_APPROVED':
      case 'LOAN_ELIGIBLE':
        return AppColors.success;
      case 'PENALTY_APPLIED':
      case 'SAVINGS_MISSED':
        return AppColors.actionRed;
      case 'INTEREST_REWARD':
        return AppColors.primaryRed;
      default:
        return AppColors.tiffanyBlue;
    }
  }
}

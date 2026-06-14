import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final double iconSize;
  final bool showText;

  const AppLogo({
    this.size = 48,
    this.iconSize = 24,
    this.showText = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipOval(
          child: Container(
            width: size,
            height: size,
            color: Colors.white,
            child: Center(
              child: Image.asset(
                'assets/images/nzelu_logo.jpeg',
                width: size * 0.8,
                height: size * 0.8,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.account_balance_rounded,
                    color: AppColors.primaryTiffanyDark,
                    size: iconSize,
                  );
                },
              ),
            ),
          ),
        ),
        if (showText) ...[
          const SizedBox(width: 10),
          Text(
            'Nzeru',
            style: TextStyle(
              color: AppColors.primaryTiffanyDark,
              fontWeight: FontWeight.w700,
              fontSize: size * 0.5,
            ),
          ),
        ],
      ],
    );
  }
}


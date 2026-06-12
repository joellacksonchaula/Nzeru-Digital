import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final double iconSize;
  final bool showText;

  const AppLogo({
    this.size = 32,
    this.iconSize = 16,
    this.showText = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.tiffanyGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryTiffany.withAlpha(45),
                blurRadius: 18,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Image.asset(
              'assets/images/nzelu_logo.jpeg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.account_balance_rounded,
                  color: Colors.white,
                  size: iconSize,
                );
              },
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


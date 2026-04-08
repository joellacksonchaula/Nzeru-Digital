import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class GoldButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final double? width;

  const GoldButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.width,
  });

  @override
  State<GoldButton> createState() => _GoldButtonState();
}

class _GoldButtonState extends State<GoldButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          if (!widget.isLoading) widget.onPressed();
        },
        onTapCancel: () => _controller.reverse(),
        child: Container(
          width: widget.width,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            color: widget.isOutlined ? Colors.transparent : AppColors.tiffanyBlue,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.isOutlined
                  ? AppColors.tiffanyBlue
                  : AppColors.faluRed.withValues(alpha: 0.60),
              width: 1.5,
            ),
            boxShadow: widget.isOutlined
                ? null
                : [
                    BoxShadow(
                      color: AppColors.tiffanyBlue.withAlpha(60),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isLoading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: widget.isOutlined
                        ? AppColors.loadingRed
                        : AppColors.loadingGreen,
                  ),
                )
              else ...[
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    size: 20,
                    color: widget.isOutlined
                        ? AppColors.faluRed
                        : Colors.white,
                  ),
                  const SizedBox(width: 10),
                ],
                Text(
                  widget.label,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: widget.isOutlined
                        ? AppColors.faluRed
                        : Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

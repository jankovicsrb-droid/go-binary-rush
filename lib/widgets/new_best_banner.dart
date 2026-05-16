import 'package:flutter/material.dart';
import '../theme.dart';

class NewBestBanner extends StatelessWidget {
  final bool visible;
  final double top;

  const NewBestBanner({super.key, required this.visible, this.top = 64});

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Positioned(
      top: top,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Center(
          child: AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 80),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.bg,
                border: Border.all(color: AppColors.amber),
                boxShadow: AppGlow.amber,
              ),
              child: Text(
                '▲ NEW BEST',
                style: AppText.mono(
                  size: 12,
                  color: AppColors.amber,
                  weight: FontWeight.w700,
                ).copyWith(letterSpacing: 5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

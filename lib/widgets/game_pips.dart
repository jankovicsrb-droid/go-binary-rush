import 'package:flutter/material.dart';
import '../theme.dart';

class GamePips extends StatelessWidget {
  final int lapSolved;
  final bool solved;

  static const lapSize = 10;

  const GamePips({super.key, required this.lapSolved, required this.solved});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(lapSize, (i) {
        final isPast = i < lapSolved;
        final isCurrent = i == lapSolved;
        final Color fillColor;
        final Color borderColor;
        final List<BoxShadow>? glow;

        if (isPast) {
          fillColor = AppColors.g3;
          borderColor = AppColors.g3;
          glow = AppGlow.sm;
        } else if (isCurrent && solved) {
          fillColor = AppColors.g4;
          borderColor = AppColors.g4;
          glow = AppGlow.sm;
        } else if (isCurrent) {
          fillColor = Colors.transparent;
          borderColor = AppColors.g2;
          glow = null;
        } else {
          fillColor = Colors.transparent;
          borderColor = AppColors.g1;
          glow = null;
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: fillColor,
            border: Border.all(color: borderColor, width: 1),
            boxShadow: glow,
          ),
        );
      }),
    );
  }
}

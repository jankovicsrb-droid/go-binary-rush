import 'package:flutter/material.dart';
import '../theme.dart';

class HexWordKeyboard extends StatelessWidget {
  final void Function(String) onTap;
  final bool disabled;
  final double rowPadding;

  const HexWordKeyboard({
    super.key,
    required this.onTap,
    this.disabled = false,
    this.rowPadding = 3,
  });

  static const _keyRows = [
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
    ['Z', 'X', 'C', 'V', 'B', 'N', 'M'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _keyRows
          .map((row) => Padding(
                padding: EdgeInsets.symmetric(vertical: rowPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: row
                      .map((l) => GestureDetector(
                            onTap: () => onTap(l),
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              width: 32,
                              height: 42,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: disabled
                                          ? AppColors.g1
                                          : AppColors.g2)),
                              alignment: Alignment.center,
                              child: Text(l,
                                  style: AppText.mono(
                                      size: 12,
                                      color: disabled
                                          ? AppColors.g1
                                          : AppColors.g3)),
                            ),
                          ))
                      .toList(),
                ),
              ))
          .toList(),
    );
  }
}

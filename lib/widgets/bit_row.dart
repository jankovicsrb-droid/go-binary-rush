import 'package:flutter/material.dart';
import 'bit_tile.dart';

class BitRow extends StatelessWidget {
  final List<int> bits;
  final void Function(int index) onToggle;
  final bool enabled;

  const BitRow({
    super.key,
    required this.bits,
    required this.onToggle,
    this.enabled = true,
  });

  static const _supers = ['⁰', '¹', '²', '³', '⁴', '⁵', '⁶', '⁷'];

  @override
  Widget build(BuildContext context) {
    final int n = bits.length;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            n,
            (i) => BitTile(
              value: bits[i],
              onTap: enabled ? () => onToggle(i) : () {},
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(n, (i) {
            final int power = n - 1 - i;
            return SizedBox(
              width: 76,
              child: Column(
                children: [
                  Text(
                    '${1 << power}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF3A6A3A)),
                  ),
                  Text(
                    '2${_supers[power]}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF2A5A2A)),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}

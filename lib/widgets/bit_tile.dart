import 'package:flutter/material.dart';

const Color _active = Color(0xFF00FF41);
const Color _activeBg = Color(0xFF001800);
const Color _inactiveBorder = Color(0xFF1A3A1A);
const Color _inactiveText = Color(0xFF2E5A2E);

class BitTile extends StatelessWidget {
  final int value;
  final VoidCallback onTap;

  const BitTile({super.key, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool on = value == 1;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        margin: const EdgeInsets.symmetric(horizontal: 6),
        width: 64,
        height: 64,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: on ? _activeBg : Colors.black,
          border: Border.all(
            color: on ? _active : _inactiveBorder,
            width: on ? 2 : 1,
          ),
        ),
        child: Text(
          value.toString(),
          style: TextStyle(
            fontSize: 30,
            color: on ? _active : _inactiveText,
            fontWeight: on ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

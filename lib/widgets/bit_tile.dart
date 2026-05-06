import 'package:flutter/material.dart';

const Color _active = Color(0xFF00FF41);
const Color _activeBg = Color(0xFF001800);
const Color _inactiveBorder = Color(0xFF1A3A1A);
const Color _inactiveText = Color(0xFF2E5A2E);

class BitTile extends StatefulWidget {
  final int value;
  final VoidCallback onTap;
  final bool glowing;
  final double size;

  const BitTile({
    super.key,
    required this.value,
    required this.onTap,
    this.glowing = false,
    this.size = 64,
  });

  @override
  State<BitTile> createState() => _BitTileState();
}

class _BitTileState extends State<BitTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bool on = widget.value == 1;
    final double fontSize = widget.size * 0.47;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.82 : 1.0,
        duration: const Duration(milliseconds: 70),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: widget.size,
          height: widget.size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? _activeBg : Colors.black,
            border: Border.all(
              color: on ? _active : _inactiveBorder,
              width: on ? 2 : 1,
            ),
            boxShadow: (on && widget.glowing)
                ? [
                    const BoxShadow(
                      color: Color(0xCC00FF41),
                      blurRadius: 20,
                      spreadRadius: 3,
                    ),
                  ]
                : null,
          ),
          child: Text(
            widget.value.toString(),
            style: TextStyle(
              fontSize: fontSize,
              color: on ? _active : _inactiveText,
              fontWeight: on ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

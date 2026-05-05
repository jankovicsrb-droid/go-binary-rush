import 'package:flutter/material.dart';
import 'addition_screen.dart';
import 'game_screen.dart';
import 'reverse_screen.dart';
import 'xor_screen.dart';

const Color _green = Color(0xFF00FF41);
const Color _dimGreen = Color(0xFF2E6E2E);
const Color _muteGreen = Color(0xFF1A3A1A);

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(
                'GO BINARY RUSH',
                style: TextStyle(
                    color: _green, fontSize: 20, letterSpacing: 4),
              ),
              const SizedBox(height: 8),
              Container(height: 1, color: _muteGreen),
              const SizedBox(height: 40),
              const Text(
                'SELECT MODE',
                style: TextStyle(
                    fontSize: 10, color: _dimGreen, letterSpacing: 5),
              ),
              const SizedBox(height: 28),
              _ModeItem(
                index: 1,
                name: 'MATCH',
                subtitle: 'decimal  →  binary',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GameScreen()),
                ),
              ),
              const SizedBox(height: 20),
              _ModeItem(
                index: 2,
                name: 'REVERSE',
                subtitle: 'binary  →  decimal',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReverseScreen()),
                ),
              ),
              const SizedBox(height: 20),
              _ModeItem(
                index: 3,
                name: 'ADDITION',
                subtitle: 'row_a + row_b = target',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdditionScreen()),
                ),
              ),
              const SizedBox(height: 20),
              _ModeItem(
                index: 4,
                name: 'XOR',
                subtitle: 'a  ⊕  b  =  ?',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const XorScreen()),
                ),
              ),
              const SizedBox(height: 20),
              const _ModeItem(
                index: 5,
                name: 'SPEED BURST',
                subtitle: '60 second blitz',
                locked: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeItem extends StatelessWidget {
  final int index;
  final String name;
  final String subtitle;
  final bool locked;
  final VoidCallback? onTap;

  const _ModeItem({
    required this.index,
    required this.name,
    required this.subtitle,
    this.locked = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color primary = locked ? _muteGreen : _green;
    final Color sub = locked ? const Color(0xFF0F1F0F) : _dimGreen;

    return GestureDetector(
      onTap: locked ? null : onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '[$index]',
            style: TextStyle(color: primary, fontSize: 13, letterSpacing: 1),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                          color: primary, fontSize: 15, letterSpacing: 3),
                    ),
                    if (locked) ...[
                      const SizedBox(width: 12),
                      Text(
                        '[SOON]',
                        style: TextStyle(
                            color: _muteGreen, fontSize: 9, letterSpacing: 2),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 10, color: sub, letterSpacing: 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

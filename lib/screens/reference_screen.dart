import 'package:flutter/material.dart';
import '../widgets/bit_row.dart';

const Color _green = Color(0xFF00FF41);
const Color _dimGreen = Color(0xFF2E6E2E);
const Color _muteGreen = Color(0xFF1A3A1A);

class ReferenceScreen extends StatelessWidget {
  const ReferenceScreen({super.key});

  List<int> _toBits(int value, int n) =>
      List.generate(n, (i) => (value >> (n - 1 - i)) & 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: _dimGreen),
        title: const Text('REFERENCE',
            style: TextStyle(color: _green, fontSize: 15, letterSpacing: 4)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _muteGreen),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section('PLACE VALUES'),
            const SizedBox(height: 12),
            _placeValues(),
            const SizedBox(height: 32),
            _section('4-BIT TABLE  (0 – 15)'),
            const SizedBox(height: 12),
            _fourBitTable(),
            const SizedBox(height: 32),
            _section('XOR TRUTH TABLE'),
            const SizedBox(height: 12),
            _xorTable(),
          ],
        ),
      ),
    );
  }

  Widget _section(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 10, color: _dimGreen, letterSpacing: 4)),
        const SizedBox(height: 6),
        Container(height: 1, color: _muteGreen),
      ],
    );
  }

  Widget _placeValues() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int bits = 4; bits <= 8; bits += 1) ...[
          Row(
            children: [
              Text('$bits-bit  ',
                  style: const TextStyle(
                      fontSize: 11, color: _dimGreen, letterSpacing: 1)),
              BitRow(
                bits: List.filled(bits, 1),
                onToggle: (_) {},
                enabled: false,
                showLabels: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _fourBitTable() {
    return Wrap(
      spacing: 24,
      runSpacing: 8,
      children: List.generate(16, (i) {
        final bits = _toBits(i, 4);
        final bitStr = bits.join('');
        return SizedBox(
          width: 130,
          child: Row(
            children: [
              Text(bitStr,
                  style: const TextStyle(
                      fontSize: 15, color: _green, letterSpacing: 3)),
              const Text('  =  ',
                  style: TextStyle(fontSize: 13, color: _dimGreen)),
              Text('$i',
                  style: const TextStyle(fontSize: 15, color: _green)),
            ],
          ),
        );
      }),
    );
  }

  Widget _xorTable() {
    const pairs = [
      [0, 0, 0],
      [0, 1, 1],
      [1, 0, 1],
      [1, 1, 0],
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final row in pairs)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '${row[0]}  ⊕  ${row[1]}  =  ${row[2]}',
              style: const TextStyle(
                  fontSize: 18, color: _green, letterSpacing: 4),
            ),
          ),
        const SizedBox(height: 8),
        const Text(
          'XOR = 1 when bits differ,  0 when equal',
          style: TextStyle(fontSize: 10, color: _dimGreen, letterSpacing: 1),
        ),
      ],
    );
  }
}

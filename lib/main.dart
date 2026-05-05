import 'package:flutter/material.dart';

void main() {
  runApp(const BinaryGameApp());
}

class BinaryGameApp extends StatelessWidget {
  const BinaryGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Binary Game',
      theme: ThemeData.dark(),
      home: const BinaryGameScreen(),
    );
  }
}

class BinaryGameScreen extends StatefulWidget {
  const BinaryGameScreen({super.key});

  @override
  State<BinaryGameScreen> createState() => _BinaryGameScreenState();
}

class _BinaryGameScreenState extends State<BinaryGameScreen> {
  final int target = 13;
  final List<int> bits = [0, 0, 0, 0];

  int get currentValue {
    return bits[0] * 8 + bits[1] * 4 + bits[2] * 2 + bits[3] * 1;
  }

  void toggleBit(int index) {
    setState(() {
      bits[index] = bits[index] == 0 ? 1 : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isCorrect = currentValue == target;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Binary Game'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Make number: $target',
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(bits.length, (index) {
                return GestureDetector(
                  onTap: () => toggleBit(index),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      bits[index].toString(),
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 24),

            Text(
              'Current value: $currentValue',
              style: const TextStyle(fontSize: 24),
            ),

            const SizedBox(height: 24),

            Text(
              isCorrect ? 'Correct ✅' : 'Keep trying',
              style: TextStyle(
                fontSize: 28,
                color: isCorrect ? Colors.greenAccent : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
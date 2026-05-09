import 'package:flutter/material.dart';
import 'screens/menu_screen.dart';
import 'theme.dart';
import 'widgets/crt_overlay.dart';

void main() {
  runApp(const BinaryRushApp());
}

class BinaryRushApp extends StatelessWidget {
  const BinaryRushApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Go Binary Rush',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      builder: (context, child) => CrtOverlay(child: child!),
      home: const MenuScreen(),
    );
  }
}

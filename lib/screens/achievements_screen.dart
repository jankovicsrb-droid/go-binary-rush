import 'package:flutter/material.dart';
import '../theme.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('ACHIEVEMENTS', style: AppText.label()),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.g1),
        ),
      ),
      body: Center(
        child: Text('COMING SOON',
            style: AppText.kicker(color: AppColors.g1).copyWith(letterSpacing: 6)),
      ),
    );
  }
}

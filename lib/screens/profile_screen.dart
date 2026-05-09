import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _totalCorrect = 0;
  int _bestStreak = 0;
  int _tier = 1;
  Map<String, int> _bests = {};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalCorrect = prefs.getInt('total_correct') ?? 0;
      _bestStreak   = prefs.getInt('best_streak_ever') ?? 0;
      _tier         = (prefs.getInt('match_current_tier') ?? 0) + 1;
      _bests = {
        'MATCH':       prefs.getInt('match_high_score') ?? 0,
        'REVERSE':     prefs.getInt('reverse_high_score') ?? 0,
        'ADDITION':    prefs.getInt('addition_high_score') ?? 0,
        'XOR':         prefs.getInt('xor_high_score') ?? 0,
        'SPEED BURST': prefs.getInt('speed_match_high_score') ?? 0,
        'HEX MATCH':   prefs.getInt('hex_high_score') ?? 0,
        'HEX WORD':    prefs.getInt('hex_word_high_score') ?? 0,
      };
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('STATS', style: AppText.label()),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.g1),
        ),
      ),
      body: !_loaded
          ? const SizedBox.shrink()
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              children: [
                _coreStats(),
                const SizedBox(height: 28),
                _divider('TIER PROGRESS  ·  MATCH'),
                const SizedBox(height: 14),
                _tierRow(),
                const SizedBox(height: 28),
                _divider('BEST SCORES'),
                const SizedBox(height: 14),
                ..._bests.entries.map((e) => _statRow(e.key, e.value > 0 ? '${e.value}' : '—')),
              ],
            ),
    );
  }

  Widget _coreStats() {
    return Row(
      children: [
        Expanded(child: _bigStat('TOTAL CORRECT', '$_totalCorrect')),
        Container(width: 1, height: 56, color: AppColors.g1),
        Expanded(child: _bigStat('BEST STREAK', '×$_bestStreak')),
      ],
    );
  }

  Widget _bigStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: AppText.kicker()),
        const SizedBox(height: 6),
        Text(value, style: AppText.hudValue(color: AppColors.g4).copyWith(fontSize: 28)),
      ],
    );
  }

  Widget _tierRow() {
    const totalTiers = 6;
    final progress = (_tier - 1) / (totalTiers - 1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('T$_tier', style: AppText.mono(size: 13, color: AppColors.g4)),
            const SizedBox(width: 10),
            Expanded(
              child: ClipRRect(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(border: Border.all(color: AppColors.g1)),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.g3,
                        boxShadow: AppGlow.sm,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text('T$totalTiers', style: AppText.mono(size: 13, color: AppColors.g2)),
          ],
        ),
        if (_tier < totalTiers) ...[
          const SizedBox(height: 6),
          Text('TIER $_tier OF $totalTiers',
              style: AppText.kicker(color: AppColors.g1).copyWith(letterSpacing: 2)),
        ] else ...[
          const SizedBox(height: 6),
          Text('MAX TIER REACHED',
              style: AppText.kicker(color: AppColors.g4).copyWith(letterSpacing: 2)),
        ],
      ],
    );
  }

  Widget _divider(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.kicker()),
        const SizedBox(height: 6),
        Container(height: 1, color: AppColors.g1),
      ],
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppText.mono(size: 12, color: AppColors.g2)),
          Text(value,
              style: AppText.mono(
                  size: 13,
                  color: value == '—' ? AppColors.g1 : AppColors.g3,
                  weight: FontWeight.w600)),
        ],
      ),
    );
  }
}

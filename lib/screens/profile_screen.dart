import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/crt_settings.dart';
import '../services/haptics.dart';
import '../services/notifications.dart';
import '../theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _playerName = 'PLAYER';
  int _totalCorrect = 0;
  int _bestStreak = 0;
  int _tier = 1;
  int _dailyStreak = 0;
  Map<String, int> _bests = {};
  Map<String, int> _speedBests = {};
  Map<String, int> _counts = {};
  Map<String, int> _speedCounts = {};
  bool _loaded = false;
  bool _reminderEnabled = false;
  bool _reminderBusy = false;
  int _reminderHour = Notifications.defaultHour;
  bool _hapticsEnabled = true;
  int _crtLevel = CrtSettings.levelFull;

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
      _playerName   = (prefs.getString('player_name') ?? 'PLAYER').toUpperCase();
      _totalCorrect = prefs.getInt('total_correct') ?? 0;
      _bestStreak   = prefs.getInt('best_streak_ever') ?? 0;
      _tier         = (prefs.getInt('match_current_tier') ?? 0) + 1;
      _dailyStreak  = prefs.getInt('daily_streak') ?? 0;
      _bests = {
        'MATCH':    prefs.getInt('match_high_score') ?? 0,
        'REVERSE':  prefs.getInt('reverse_high_score') ?? 0,
        'ADDITION': prefs.getInt('addition_high_score') ?? 0,
        'XOR':      prefs.getInt('xor_high_score') ?? 0,
        'HEX MATCH':prefs.getInt('hex_high_score') ?? 0,
        'HEX WORD': prefs.getInt('hex_word_high_score') ?? 0,
      };
      _counts = {
        'MATCH':    prefs.getInt('match_correct_count') ?? 0,
        'REVERSE':  prefs.getInt('reverse_correct_count') ?? 0,
        'ADDITION': prefs.getInt('addition_correct_count') ?? 0,
        'XOR':      prefs.getInt('xor_correct_count') ?? 0,
        'HEX MATCH':prefs.getInt('hex_correct_count') ?? 0,
        'HEX WORD': prefs.getInt('hex_word_correct_count') ?? 0,
      };
      _speedBests = {
        'MATCH':    prefs.getInt('speed_match_high_score') ?? 0,
        'REVERSE':  prefs.getInt('speed_reverse_high_score') ?? 0,
        'ADDITION': prefs.getInt('speed_addition_high_score') ?? 0,
        'XOR':      prefs.getInt('speed_xor_high_score') ?? 0,
        'HEX WORD': prefs.getInt('speed_hexWord_high_score') ?? 0,
      };
      _speedCounts = {
        'MATCH':    prefs.getInt('speed_match_correct_count') ?? 0,
        'REVERSE':  prefs.getInt('speed_reverse_correct_count') ?? 0,
        'ADDITION': prefs.getInt('speed_addition_correct_count') ?? 0,
        'XOR':      prefs.getInt('speed_xor_correct_count') ?? 0,
        'HEX WORD': prefs.getInt('speed_hexWord_correct_count') ?? 0,
      };
      _reminderEnabled = prefs.getBool(Notifications.prefsEnabled) ?? false;
      _reminderHour = prefs.getInt(Notifications.prefsHour) ?? Notifications.defaultHour;
      _hapticsEnabled = prefs.getBool(Haptics.prefsEnabled) ?? true;
      _crtLevel = prefs.getInt(CrtSettings.prefsLevel) ?? CrtSettings.levelFull;
      _loaded = true;
    });
  }

  Future<void> _pickHour() async {
    final picked = await showDialog<int>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.bg,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: AppColors.g2),
          borderRadius: BorderRadius.zero,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('REMINDER HOUR', style: AppText.label()),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(24, (h) {
                  final sel = h == _reminderHour;
                  return GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(h),
                    child: Container(
                      width: 48,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: sel ? AppColors.g4 : AppColors.g1,
                        ),
                        color: sel ? AppColors.g1 : Colors.transparent,
                      ),
                      child: Text(
                        '${h.toString().padLeft(2, '0')}:00',
                        style: AppText.mono(
                          size: 11,
                          color: sel ? AppColors.g5 : AppColors.g3,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
    if (picked == null || picked == _reminderHour) return;
    setState(() => _reminderHour = picked);
    await Notifications.setHour(picked, _playerName);
  }

  Future<void> _toggleReminder(bool value) async {
    if (_reminderBusy) return;
    setState(() => _reminderBusy = true);
    if (value) {
      final granted = await Notifications.enable(_playerName);
      if (mounted) {
        setState(() {
          _reminderEnabled = granted;
          _reminderBusy = false;
        });
        if (!granted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: AppColors.bg,
            content: Text(
              'NOTIFICATION PERMISSION DENIED',
              style: AppText.mono(size: 12, color: AppColors.amber),
            ),
          ));
        }
      }
    } else {
      await Notifications.disable();
      if (mounted) {
        setState(() {
          _reminderEnabled = false;
          _reminderBusy = false;
        });
      }
    }
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
                _agentHeader(),
                const SizedBox(height: 24),
                Container(height: 1, color: AppColors.g1),
                const SizedBox(height: 24),
                _coreStats(),
                const SizedBox(height: 28),
                _divider('TIER PROGRESS  ·  MATCH'),
                const SizedBox(height: 14),
                _tierRow(),
                const SizedBox(height: 28),
                _divider('DAILY'),
                const SizedBox(height: 14),
                _statRow('DAILY STREAK', _dailyStreak > 0 ? '×$_dailyStreak' : '—'),
                const SizedBox(height: 28),
                _divider('BEST SCORES'),
                const SizedBox(height: 14),
                ..._bests.entries.map((e) => _statRow(
                      e.key,
                      e.value > 0 ? '${e.value}' : '—',
                      subtitle: _countSubtitle(_counts[e.key] ?? 0),
                    )),
                const SizedBox(height: 28),
                _divider('SPEED BURST'),
                const SizedBox(height: 14),
                ..._speedBests.entries.map((e) => _statRow(
                      e.key,
                      e.value > 0 ? '${e.value}' : '—',
                      subtitle: _countSubtitle(_speedCounts[e.key] ?? 0),
                    )),
                const SizedBox(height: 28),
                _divider('SETTINGS'),
                const SizedBox(height: 14),
                _toggleRow(
                  'HAPTICS',
                  _hapticsEnabled,
                  (v) async {
                    setState(() => _hapticsEnabled = v);
                    await Haptics.setEnabled(v);
                  },
                ),
                _crtRow(),
                if (!kIsWeb) ...[
                  _toggleRow(
                    'DAILY REMINDER',
                    _reminderEnabled,
                    _toggleReminder,
                  ),
                  if (_reminderEnabled) _hourRow(),
                ],
              ],
            ),
    );
  }

  Widget _crtRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CRT INTENSITY',
              style: AppText.mono(size: 12, color: AppColors.g2)),
          const SizedBox(height: 6),
          Row(
            children: List.generate(CrtSettings.labels.length, (i) {
              final sel = i == _crtLevel;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    setState(() => _crtLevel = i);
                    await CrtSettings.setLevel(i);
                  },
                  child: Container(
                    margin: EdgeInsets.only(
                        right: i == CrtSettings.labels.length - 1 ? 0 : 6),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: sel ? AppColors.g4 : AppColors.g1),
                      color: sel ? AppColors.g1 : Colors.transparent,
                    ),
                    child: Text(
                      CrtSettings.labels[i],
                      style: AppText.mono(
                        size: 11,
                        color: sel ? AppColors.g5 : AppColors.g3,
                        weight: sel ? FontWeight.w700 : FontWeight.normal,
                      ).copyWith(letterSpacing: 2),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _hourRow() {
    final hh = '${_reminderHour.toString().padLeft(2, '0')}:00';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('REMINDER TIME',
              style: AppText.mono(size: 12, color: AppColors.g2)),
          GestureDetector(
            onTap: _pickHour,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(border: Border.all(color: AppColors.g2)),
              child: Text(hh,
                  style: AppText.mono(
                      size: 13,
                      color: AppColors.g4,
                      weight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppText.mono(size: 12, color: AppColors.g2)),
          Switch(
            value: value,
            onChanged: _reminderBusy ? null : onChanged,
            activeThumbColor: AppColors.g4,
            activeTrackColor: AppColors.g1,
            inactiveThumbColor: AppColors.g1,
            inactiveTrackColor: AppColors.bg,
          ),
        ],
      ),
    );
  }

  Widget _agentHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text('AGENT', style: AppText.kicker(color: AppColors.g2)),
        const SizedBox(width: 14),
        Text(_playerName,
            style: AppText.mono(
                size: 22, color: AppColors.g4, weight: FontWeight.w700)),
      ],
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

  String? _countSubtitle(int count) {
    if (count <= 0) return null;
    return '$count SOLVED';
  }

  Widget _statRow(String label, String value, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle,
                style: AppText.kicker(color: AppColors.g1)
                    .copyWith(letterSpacing: 2)),
          ],
        ],
      ),
    );
  }
}

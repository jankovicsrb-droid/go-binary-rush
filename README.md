# Go Binary Rush

Fast-paced binary number puzzle game for Android. Eight game modes, all built around binary and hex manipulation. Hacker terminal aesthetic.

## Modes

| # | Mode | Mechanic |
|---|------|----------|
| 1 | **MATCH** | Decimal shown → build its binary representation |
| 2 | **REVERSE** | Binary pre-lit → type the decimal value |
| 3 | **ADDITION** | Fill two rows so A + B = target |
| 4 | **XOR** | Rows A and B fixed → fill C so A ⊕ B = C |
| 5 | **SPEED BURST** | Any mode, 60-second blitz |
| 6 | **HEX MATCH** | Binary shown → enter the hex value |
| 7 | **HEX WORD** | ASCII hex pairs → tap letters to decode the word |
| 8 | **DAILY** | 10 mixed questions, one attempt per day |

## Scoring

- **10 pts** base per correct answer
- **+5 pts** per consecutive correct answer (streak bonus)
- Wrong answers cost 1 pt in HEX WORD; no penalty in other modes

## Difficulty

MATCH uses a tier system (T1–T6). Solve enough questions to advance to wider bit widths:

```
T1–T2  4-bit   0–15
T3     5-bit   16–31
T4     6-bit   32–63
T5     7-bit   64–127
T6     8-bit   128–255
```

## Tech Stack

- Flutter / Dart
- `shared_preferences` — local persistence (scores, streaks, progress)
- `google_fonts` — JetBrains Mono
- No backend, no analytics, no ads

## Build

```bash
# Debug
flutter run

# Release APK (fat, all ABIs)
flutter build apk --release

# Release APK (split per ABI — smaller)
flutter build apk --split-per-abi --release

# App Bundle (Play Store)
flutter build appbundle --release
```

## Project Structure

```
lib/
  main.dart
  theme.dart
  screens/
    menu_screen.dart
    game_screen.dart          # MATCH
    reverse_screen.dart
    addition_screen.dart
    xor_screen.dart
    speed_burst_screen.dart
    hex_screen.dart           # HEX MATCH
    hex_word_screen.dart
    daily_challenge_screen.dart
    how_to_play_screen.dart
    achievements_screen.dart
    profile_screen.dart
    reference_screen.dart
    name_entry_screen.dart
    main_shell.dart
  game/
    question_generator.dart   # Tier-based question generation
    score_engine.dart         # Score, streak, high score
    difficulty.dart           # Tier definitions
    word_list.dart            # 391 words for HEX WORD
  widgets/
    bit_row.dart
    bit_tile.dart
    num_pad.dart
    hex_word_keyboard.dart
    game_hud.dart
    game_pips.dart
    crt_overlay.dart
docs/
  privacy-policy.html         # Hosted via GitHub Pages for Play Store
```

## Privacy

No personal data collected or transmitted. All data stored locally on device.  
Privacy policy: https://gojankovic.github.io/go-binary-rush/privacy-policy.html

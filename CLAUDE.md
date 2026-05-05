# Go Binary Rush

Fast-paced binary number game for mobile (Flutter/Dart). Five game modes, all built around binary bit manipulation. Hacker terminal aesthetic.

## Tech Stack

- Flutter + Dart
- `shared_preferences` for local persistence (score, streak, high score)
- No backend, no database
- Run on Chrome for dev, target Android

## Visual Design

**Hacker / terminal aesthetic — non-negotiable.**

- Background: pure black `#000000`
- Primary text/UI: terminal green (soft, easy on eyes — e.g. `#39FF14` or similar, TBD)
- Font: monospace everywhere (`RobotoMono` or `Courier`)
- Bit tiles: dark bordered squares, green when active (1), dim when inactive (0)
- Animations: subtle CRT flicker or glow on success, no candy/rainbow effects
- No gradients, no rounded pastel buttons — keep it sharp and terminal-like

**Mood: fun arcade game with a hacker skin, not an educational app.**

## Architecture

```
lib/
  main.dart                  # App entry, MaterialApp setup
  screens/
    game_screen.dart         # Main game UI
  game/
    question_generator.dart  # Random target generation, level config
    score_engine.dart        # Score, streak, high score logic
  widgets/
    bit_tile.dart            # Single toggleable bit widget
    bit_row.dart             # Row of bit tiles with labels
```

## Bit Labels

Show both `8 4 2 1` and `2³ 2² 2¹ 2⁰` beneath the bit row — decide later which to keep per level/mode.

## Game Logic

- Bits stored as `List<int>` (values 0 or 1)
- Decimal value: `bits[0]*8 + bits[1]*4 + bits[2]*2 + bits[3]*1` (generalize for n bits)
- Generate random target with `Random().nextInt(max + 1)` — exclude current target to avoid repeat
- Reset all bits to 0 on Next
- SharedPreferences keys: `high_score`, `current_streak`

## Game Modes

### Mode 1 — Match (core, MVP)
Decimal target shown → player constructs binary representation using one row of bit tiles.
One correct answer.

### Mode 2 — Reverse
Binary shown (bits pre-lit) → player types/selects the decimal value.
Opposite of Match. Fast, read-only bits.

### Mode 3 — Addition
Decimal target shown → player fills two independent binary rows whose sum equals target.
Multiple valid solutions. Each row shows its own decimal value but sum is NOT displayed — player must do mental addition.

### Mode 4 — XOR
Two binary rows are pre-filled (fixed, not editable). Player fills a third row.
Goal: `row_a XOR row_b = player_row`. One correct answer.

### Mode 5 — Speed Burst
60-second timed version of any selected mode. Separate high score per mode.
Same game logic, different win condition (maximize solved count).

---

## Difficulty System

Targets progress through tiers by difficulty — not purely random. No-repeat per mode tracked via SharedPreferences `Set<int>`. Exhausted tier auto-advances to next.

| Tier | Bits | Range | Character |
|------|------|-------|-----------|
| 1 | 4-bit | 1–15 | Powers of 2, all-ones — very recognizable |
| 2 | 4-bit | 3–14 | Mixed small values |
| 3 | 5-bit | 16–31 | New bit introduced |
| 4 | 6-bit | 32–63 | Getting harder |
| 5 | 7-bit | 64–127 | Serious |
| 6 | 8-bit | 128–255 | Expert (max) |

---

## Development Phases

### Phase 1 — MVP (current focus)
- [x] Basic bit toggle
- [x] Decimal value display
- [x] Correct/incorrect detection
- [ ] Random target (no repeat)
- [ ] Next button + CORRECT state
- [ ] Bit labels (8 4 2 1 / 2ⁿ)
- [ ] Terminal visual theme
- [ ] App title: Go Binary Rush

### Phase 2 — Core Game Loop
- Difficulty tier progression
- No-repeat target tracking (SharedPreferences)
- Score, streak, high score
- Animated CORRECT feedback (glow/flash)

### Phase 3 — Reverse Mode
Binary pre-lit → player identifies decimal value.

### Phase 4 — Addition Mode
Two editable binary rows, sum must equal target. No live sum display.

### Phase 5 — XOR Mode
Two fixed rows pre-filled, player fills third row so `A XOR B = C`.

### Phase 6 — Speed Burst
Timed overlay (60s) for any mode. Separate leaderboard per mode.

## Conventions

- Stateless widgets where possible; `StatefulWidget` only for interactive screens
- No hardcoded magic numbers — use constants or pass via constructor
- `setState` only; no state management library for MVP
- All strings in English (UI text), no i18n needed
- No comments unless the why is non-obvious

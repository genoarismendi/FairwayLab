# FairwayLab — Code Reference

iOS golf scoring app built in SwiftUI.

---

## Cara e Perro — Zero-Sum Logic

**IMPORTANT:** All bonuses and penalties are now strictly zero-sum (integer only).

### Zero Putts Bonus (per hole)
- Each player with 0 putts receives: +(number of non-zero-putts players)
- Each player without 0 putts pays: -(number of zero-putts players)

Example: 4 players, Alice has 0 putts:
- Alice: +3, Bob/Charlie/Dana: -1 each
- Sum: +3 -3 = 0 ✓

### Nine-Hole Winner Bonus
- Winner receives: +(total players - 1)
- Each loser pays: -1

Example: 4 players, Alice wins front nine:
- Alice: +3, Bob/Charlie/Dana: -1 each
- Sum: +3 -3 = 0 ✓

### Snake Penalty (PER-NINE)
- Calculated separately for front nine (holes 1-9) and back nine (holes 10-18)
- Uses ONLY putts from that specific nine
- Each snake pays: -(number of non-snakes)
- Each non-snake receives: +(number of snakes)

Example: 4 players, Dana is snake on front nine:
- Dana: -3, Alice/Bob/Charlie: +1 each
- Sum: -3 +3 = 0 ✓

**Key Points:**
- Snake is applied TWICE in 18-hole rounds (once per nine)
- Snake is applied ONCE in 9-hole rounds
- All points are integers (no fractions)
- Total points across all players MUST equal zero

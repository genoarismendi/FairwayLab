# FairwayLab — Code Reference

iOS golf scoring app built in SwiftUI.

---

## Cara e Perro — Zero-Sum Logic

**IMPORTANT:** All bonuses and penalties are now strictly zero-sum (integer only).

### Zero Putts Bonus (per hole)
- Each player with 0 putts receives: +(number of non-zero-putts players)
- Each player without 0 putts pays: -(number of zero-putts players)
- **Multiple 0-putt players supported**: each gets from all non-zero-putt players
- **If all players have 0 putts**: no bonus awarded

Example 1: 4 players, Alice has 0 putts:
- Alice: +3, Bob/Charlie/Dana: -1 each
- Sum: +3 -3 = 0 ✓

Example 2: 4 players, Alice AND Bob have 0 putts:
- Alice: +2, Bob: +2, Charlie: -2, Dana: -2
- Sum: +2 +2 -2 -2 = 0 ✓

### Nine-Hole Winner Bonus (Front Nine and Back Nine)
- **Each winner** receives: +(number of non-winners)
- **Each non-winner** pays: -(number of winners)
- **Multiple winners supported**: if players tie for best net score, ALL winners receive bonus
- **If all players tie**: no bonus awarded

Example 1: 4 players, Alice wins front nine alone:
- Alice: +3, Bob/Charlie/Dana: -1 each
- Sum: +3 -3 = 0 ✓

Example 2: 4 players, Alice AND Bob tie for best front nine:
- Alice: +2, Bob: +2, Charlie: -2, Dana: -2
- Sum: +2 +2 -2 -2 = 0 ✓

Example 3: 4 players, Alice/Bob/Charlie all tie for best:
- Alice: +1, Bob: +1, Charlie: +1, Dana: -3
- Sum: +1 +1 +1 -3 = 0 ✓

### Snake Penalty (PER-NINE)
- Calculated separately for front nine (holes 1-9) and back nine (holes 10-18)
- Uses ONLY putts from that specific nine
- Each snake pays: -(number of non-snakes)
- Each non-snake receives: +(number of snakes)
- **Multiple snakes supported**: if players tie for most putts, ALL pay

Example 1: 4 players, Dana is snake on front nine:
- Dana: -3, Alice/Bob/Charlie: +1 each
- Sum: -3 +3 = 0 ✓

Example 2: 4 players, Charlie AND Dana both snakes:
- Charlie: -2, Dana: -2, Alice: +2, Bob: +2
- Sum: -2 -2 +2 +2 = 0 ✓

**Key Points:**
- Snake is applied TWICE in 18-hole rounds (once per nine)
- Snake is applied ONCE in 9-hole rounds
- All points are integers (no fractions)
- Total points across all players MUST equal zero
- **Multiple winners/snakes are fully supported and maintain zero-sum**

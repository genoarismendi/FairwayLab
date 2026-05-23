# Quick Reference: Cara 'e Perro Modifications

## 🎯 New Point Rules

| Event | Points | When Applied | Notes |
|-------|--------|--------------|-------|
| Zero Putts | **+1** | Each hole with 0 putts | Chip-ins, holed from fringe, etc. |
| Front Nine Winner | **+1** | End of round | Lowest NET score on holes 1-9 |
| Back Nine Winner | **+1** | End of round | Lowest NET score on holes 10-18 |
| Snake Penalty | **+1 to others** | End of round | Player with most putts gives 1 pt to all others |

## 📊 Point Calculation Order

1. **Per Hole**: Standard Cara 'e Perro pairwise comparison
2. **Per Hole**: Zero putts bonus added
3. **Accumulate**: Points summed across all holes
4. **End of Round**: Front nine winner bonus
5. **End of Round**: Back nine winner bonus
6. **End of Round**: Snake penalty applied

## 🎨 Visual Indicators

| Emoji | Meaning | When Shown | Location |
|-------|---------|------------|----------|
| 🐍 | Snake holder | Player has most putts (live) | Next to player name during score entry |
| 🐷 | No par on front nine | No score ≤ par on holes 1-9 | Next to player name during score entry |
| 🐷🐷 | No par on either nine | No par on front AND back | Next to player name during score entry |

## 🎮 UI Changes

### Before: Text Fields
```
[Player Name]    [Text: Strokes]  [Text: Putts]
```

### After: Picker Wheels
```
[Player Name] 🐍 🐷

Strokes          Putts
   [Wheel]       [Wheel]
   1-15          0-8
  (80pt)        (60pt)
```

## 📐 Picker Specifications

| Picker | Range | Width | Height | Style | Special |
|--------|-------|-------|--------|-------|---------|
| Strokes | 1-15 | 80pt | 100pt | .wheel | "-" for nil |
| Putts | 0-8 | 60pt | 100pt | .wheel | "-" for nil |

## 🧮 Calculation Examples

### Example 1: Simple Round
```
Player A:
  Base points: +6
  Zero putts (hole 3): +1
  Front nine winner: +1
  Snake penalty (from Player B): +1
  ─────────────────────────────
  Total: +9 points
```

### Example 2: Snake Holder
```
Player B (30 putts - MOST):
  Base points: +4
  Back nine winner: +1
  Snake penalty (GIVES to A & C): -
  ─────────────────────────────
  Total: +5 points
  
(Players A and C each receive +1)
```

### Example 3: Zero Putts Bonus
```
Hole 3:
  Player A: 3 strokes, 0 putts
  Base points: +2
  Zero putt bonus: +1
  ─────────────────────────
  Hole points: +3
```

## 🏌️ Net Score Calculation (Nine Winners)

```
Gross Score - Handicap Strokes = Net Score

Handicap Strokes = Count of holes where:
  hole.strokeIndex ≤ player.handicap

Example (9 handicap player on front 9):
  Holes with stroke index 1-9: 9 strokes
  Gross: 45
  Net: 45 - 9 = 36
```

## 🔍 Tie Handling

| Scenario | Behavior | Points |
|----------|----------|--------|
| Tie for front nine winner | No winner | No bonus |
| Tie for back nine winner | No winner | No bonus |
| Tie for most putts | No snake | No penalty |
| Tie in base Cara 'e Perro | Standard | 0 points |

## 📱 Data Model Changes

### CalculationInput
```swift
let putts: [UUID: [UUID: Int]]  // NEW
```

### RoundState
```swift
func getTotalPutts(for playerID: UUID) -> Int
func getCurrentSnakeHolder() -> UUID?
func madeParOnNine(playerID: UUID, isBackNine: Bool) -> Bool
```

### CaraEPerroResult
```swift
let playerTotalPutts: [UUID: Int]        // NEW
let finalSnakeHolder: UUID?              // NEW
let frontNineWinner: UUID?               // NEW
let backNineWinner: UUID?                // NEW
```

### CaraEPerroHoleResult
```swift
let playerPutts: [UUID: Int]             // NEW
let playerCumulativePutts: [UUID: Int]   // NEW
let snakeHolder: UUID?                   // NEW
```

## 🗂️ Files Modified/Created

### Modified (5 files)
1. `DomainModelsCalculationInput.swift` - Added putts tracking
2. `DomainModelsRoundState.swift` - Added helper methods
3. `DomainServicesCalculationInputMapper.swift` - Maps putts
4. `DomainServicesCaraEPerroCalculator.swift` - New point rules
5. `UIViewsPlayRoundPlayView.swift` - Picker UI & emojis

### Created (3 files)
1. `UIViewsResultsCaraEPerroDetailView.swift` - Enhanced results view
2. `MODIFICATIONS_SUMMARY.md` - Full documentation
3. `TESTING_GUIDE.md` - Testing scenarios

### Persistence Added (3 files modified)
1. `AppState.swift` - Auto-save on data change
2. `GolfXApp.swift` - Save on background
3. `UIViewsPlayRoundPlayView.swift` - Save on commit

## 🎓 Key Algorithms

### Zero Putt Bonus
```swift
for player in players {
    if putts[player.id] == 0 {
        bonusPoints[player.id] += 1
    }
}
```

### Nine Winner
```swift
1. Filter holes (1-9 or 10-18)
2. Calculate net score per player
3. Find minimum net score
4. If tie → return nil
5. Else → return winner ID
```

### Snake Holder
```swift
1. Sum putts per player
2. Find max putt count
3. If tie → return nil
4. Else → return player ID
```

### Pig Status
```swift
for hole in nine {
    if grossScore <= par {
        return true  // Made par
    }
}
return false  // No par made
```

## 🚀 Usage Tips

### For Players
- **Zero putts**: Includes chip-ins and hole-outs from off the green
- **Snake**: Updates live as you enter scores - you can see who has it!
- **Pig**: Encouragement to make at least one par per nine
- **Pickers**: Faster than typing, no keyboard issues

### For Developers
- All calculations are in `CaraEPerroCalculator.calculate()`
- Visual indicators in `HoleEntrySection`
- Results display in `CaraEPerroDetailView`
- Putts flow: RoundState → CalculationInput → Calculator

## ❓ FAQ

**Q: Can a player get multiple zero-putt bonuses?**
A: Yes! One bonus point per hole with 0 putts.

**Q: What if there's a tie for most putts?**
A: No snake holder, no penalty applied.

**Q: Do nine winners get points in 9-hole rounds?**
A: Yes, but only for the nine being played.

**Q: Can someone be snake holder and nine winner?**
A: Yes! They'd get the nine winner bonus but still give points for snake.

**Q: How do pigs work in 9-hole rounds?**
A: Only one 🐷 possible (for the nine being played).

**Q: What's the maximum putts I can enter?**
A: 8 (can be increased if needed in code).

**Q: Will my scores be saved if the app crashes?**
A: Yes! Data is auto-saved continuously to UserDefaults.

**Q: What happens if my phone dies mid-round?**
A: All scores up to the last change are saved and will restore when you reopen the app.

**Q: Can I recover data after force-quitting the app?**
A: Yes! "Continue Round" button will appear when you relaunch.

## 🎯 Point Scenarios

| Scenario | Base | Bonuses | Penalties | Total |
|----------|------|---------|-----------|-------|
| Average player | +3 | +0 | +1 (from snake) | +4 |
| Great putter | +5 | +2 (2 zero putts) | +1 (from snake) | +8 |
| Front nine winner | +4 | +1 (winner) | +1 (from snake) | +6 |
| Snake holder | +3 | +0 | -2 (gives to 2 others) | +3 |
| Perfect round | +8 | +3 (winner+zeros) | +1 (from snake) | +12 |

---

**Version**: 1.0  
**Date**: May 23, 2026  
**Compatibility**: iOS 17.0+

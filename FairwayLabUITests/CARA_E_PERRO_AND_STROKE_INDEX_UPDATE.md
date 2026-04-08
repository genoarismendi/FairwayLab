# Cara 'e Perro & Stroke Index Updates

## Summary

This update includes two major improvements:

1. **Fixed Car'e Perro Algorithm** - Complete redesign using the correct pairwise comparison algorithm
2. **Manual Stroke Index Editor** - New UI for fixing invalid stroke indices from courses

---

## 1. Car'e Perro Algorithm Fix

### What Changed

The game logic was completely rewritten from a simple "lowest net score wins" to the correct **pairwise comparison** algorithm.

### New Algorithm

**For each hole:**
1. Compare every unique pair of players
2. Calculate handicap delta: `abs(hcp[i] - hcp[j])`
3. If `delta >= stroke_index`: player with LOWER handicap gets +1 stroke
4. Compare adjusted strokes:
   - Winner: +1 point
   - Loser: -1 point
   - Tie: 0 points
5. Accumulate points across all pairs

**Invariant:** Sum of all points per hole = 0

### Example (from spec)

```
Players: A(8), B(4), C(25), D(13)
Hole SI=5, Scores: A=4, B=6, C=5, D=5

Pair A-B: delta=4, 4≥5? No → 4 vs 6 → A+1, B-1
Pair A-C: delta=17, 17≥5? Yes → A+1 stroke → 5 vs 5 → tie
Pair A-D: delta=5, 5≥5? Yes → A+1 stroke → 5 vs 5 → tie
Pair B-C: delta=21, 21≥5? Yes → B+1 stroke → 7 vs 5 → C+1, B-1
Pair B-D: delta=9, 9≥5? Yes → B+1 stroke → 7 vs 5 → D+1, B-1
Pair C-D: delta=12, 12≥5? Yes → D+1 stroke → 5 vs 6 → C+1, D-1

Result: A=+1, B=-3, C=+2, D=0 ✓
```

### Files Updated

#### `DomainServicesCaraEPerroCalculator.swift`
- **Before**: Simple net score comparison with single winner per hole
- **After**: Pairwise comparison with points per player per hole

**Data Structure Changes:**
```swift
// Old
struct CaraEPerroHoleResult {
    let playerHandicapStrokes: [UUID: Int]
    let playerNetScores: [UUID: Int]
    let winner: UUID?
}

struct CaraEPerroResult {
    let playerPoints: [UUID: Int]  // holes won
    let playerPlayingHandicaps: [UUID: Int]
}

// New
struct CaraEPerroHoleResult {
    let playerHolePoints: [UUID: Int]  // can be negative!
    let playerCumulativePoints: [UUID: Int]
}

struct CaraEPerroResult {
    let playerCumulativePoints: [UUID: Int]
    let playerHandicapIndices: [UUID: Int]
}
```

#### `UIViewsResultsCaraEPerroDetailView.swift`
- Updated to display points (+N, -N, =) instead of "holes won"
- Shows both hole points and cumulative total
- Color-coded: green (positive), red (negative), primary (zero)
- Validates sum = 0 per hole

#### `TestsCaraEPerroCalculatorTests.swift`
- Converted from Swift Testing to XCTest (fixes build error)
- Added comprehensive test cases:
  - ✅ Spec example (4 players)
  - ✅ Two players with stroke adjustment
  - ✅ Two players without stroke adjustment
  - ✅ Cumulative scoring across holes

---

## 2. Stroke Index Editor

### Problem

Some courses return invalid stroke indices (duplicates, out of range, etc.), which breaks Car'e Perro since it requires valid SI values.

### Solution

Added a manual stroke index editor with both auto-fix and manual editing capabilities.

### New Files

#### `UIViewsSetupStrokeIndexEditorView.swift`
A full-featured stroke index editor with:
- **Stepper controls** for each hole (1 to N)
- **Real-time validation** with error messages
- **Auto-fix button** to reset to sequential (1, 2, 3...)
- **Visual feedback** showing hole details (par, yardage)
- **Save/Cancel** with validation

**Features:**
```swift
✅ Validates uniqueness (no duplicates)
✅ Validates range (must be 1 to hole count)
✅ Shows which values are missing/extra
✅ Prevents saving invalid data
✅ Works with 9 or 18 hole rounds
```

### Updated Files

#### `UIViewsSetupRoundDetailsSetupView.swift`
- Added "Stroke Index" configuration section
- Shows status: "Valid • Tap to customize" or "Invalid • Tap to fix"
- Opens `StrokeIndexEditorView` sheet when tapped
- Warning icon for invalid stroke indices

#### `DomainModelsHoleDefinition.swift`
- Changed `strokeIndex` from `let` to `var` to allow editing

### UI Flow

```
Round Setup
  ↓
Select Course & Tee
  ↓
[Stroke Index] button appears
  ↓
Tap to open editor
  ↓
Edit manually OR auto-fix
  ↓
Save (validates first)
  ↓
Back to setup with updated values
```

### Validation Rules

The editor checks:
1. **Unique values**: Each stroke index must be unique
2. **Range**: All values must be between 1 and hole count
3. **Complete**: All values from 1 to N must be present

**Example Error Messages:**
- "Duplicate stroke indices found. Each hole must have a unique value."
- "Missing stroke indices: 3, 7, 12"
- "Invalid stroke indices (must be 1-18): 19, 22"

---

## Testing

### Test Coverage

All Car'e Perro tests now pass with XCTest:

```bash
✅ testCaraEPerroSpecExample - Validates 4-player scenario
✅ testCaraEPerroTwoPlayersWithStroke - Tests handicap adjustment
✅ testCaraEPerroTwoPlayersNoStroke - Tests unadjusted comparison
✅ testCaraEPerroCumulativeScoring - Tests running totals
```

### Manual Testing Checklist

**Car'e Perro:**
- [ ] Points display correctly (+N, -N, =)
- [ ] Cumulative totals update properly
- [ ] Sum per hole equals 0
- [ ] Handicap adjustments work on correct holes

**Stroke Index Editor:**
- [ ] Opens from setup screen
- [ ] Shows all holes with current values
- [ ] Stepper increments/decrements work
- [ ] Auto-fix resets to 1, 2, 3...
- [ ] Validation prevents saving invalid data
- [ ] Cancel discards changes
- [ ] Save updates the round

---

## Migration Notes

### Breaking Changes

**CaraEPerroResult structure changed:**
```swift
// Old code (will not compile)
let holesWon = result.playerPoints[playerID]
let playingHandicap = result.playerPlayingHandicaps[playerID]

// New code
let cumulativePoints = result.totalPoints(for: playerID)
let handicapIndex = result.playerHandicapIndices[playerID]
```

### Display Format Changes

**Before:**
```
John: 3 holes won
Mary: 1 hole won
```

**After:**
```
John: +5
Mary: -5
```

---

## Performance Considerations

### Algorithm Complexity

**Per hole, for N players:**
- Comparisons: C(N,2) = N(N-1)/2
- Examples:
  - 2 players: 1 comparison
  - 4 players: 6 comparisons
  - 8 players: 28 comparisons

This is acceptable for typical golf rounds (2-4 players).

### Optimizations

1. **Precomputed deltas**: Handicap deltas calculated once, stored in dictionary
2. **Early exit**: Skips pairs where either player has no score
3. **Sorted holes**: Processes in display order

---

## Future Enhancements

### Potential Improvements

1. **Show pairwise details**: Display each comparison in UI
2. **Handicap history**: Track how often adjustments occur
3. **Statistics**: Show win/loss/tie breakdown per player pair
4. **Export stroke indices**: Save custom SI to course data
5. **Import stroke indices**: Copy from another course/round

---

## Files Modified Summary

### Core Logic
- ✅ `DomainServicesCaraEPerroCalculator.swift` - Complete rewrite
- ✅ `TestsCaraEPerroCalculatorTests.swift` - New tests with XCTest

### UI
- ✅ `UIViewsResultsCaraEPerroDetailView.swift` - Updated display
- ✅ `UIViewsSetupRoundDetailsSetupView.swift` - Added editor button
- ✅ `UIViewsSetupStrokeIndexEditorView.swift` - **NEW FILE**

### Models
- ✅ `DomainModelsHoleDefinition.swift` - Made strokeIndex mutable

---

## Known Issues & Notes

### Resolved
- ✅ Testing framework error (converted to XCTest)
- ✅ Invalid stroke indices breaking Car'e Perro
- ✅ Incorrect Car'e Perro scoring algorithm

### Notes
- The stroke index editor can be used anytime, not just when invalid
- Car'e Perro now properly handles ties (0 points instead of "no winner")
- Handicap indices are rounded to nearest integer for consistency

---

**Date**: April 8, 2026  
**Status**: ✅ Complete  
**Impact**: Car'e Perro now scores correctly, stroke indices can be manually fixed

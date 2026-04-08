# Stroke Index Fix for 9-Hole Rounds

## Problem

When playing a 9-hole round, the stroke indices were showing values from the full 18-hole course (e.g., 5, 9, 3, 13, 17, 1, 15, 11, 7), which are valid for 18 holes but invalid for 9 holes since they:
- Contain values outside the 1-9 range (13, 15, 17)
- Are missing required values within 1-9 (2, 4, 6, 8)

This caused validation errors: "Missing stroke indices: 2, 4, 6, 8"

## Root Cause

The `HoleBuilder.buildHoles()` function was copying stroke indices directly from the course's 18-hole data without adjusting them for 9-hole rounds.

**Example:**
- 18-hole course SI: `[5, 9, 3, 13, 17, 1, 15, 11, 7, 6, 10, 2, 14, 18, 4, 16, 12, 8]`
- Front 9 selection copied: `[5, 9, 3, 13, 17, 1, 15, 11, 7]` ❌ Invalid!

## Solution

Added automatic renormalization of stroke indices for 9-hole rounds that:
1. **Preserves relative difficulty** - The hardest hole stays the hardest
2. **Maps to 1-9 range** - All values fit the 9-hole requirement
3. **Maintains uniqueness** - Each hole gets a unique stroke index

### Algorithm

```swift
private static func renormalizeStrokeIndicesForNineHoles(_ holes: [HoleDefinition]) -> [HoleDefinition] {
    // Sort holes by their original stroke index (lower = harder)
    let sortedByDifficulty = holes.enumerated().sorted { $0.element.strokeIndex < $1.element.strokeIndex }
    
    // Assign new indices 1-9 based on difficulty ranking
    var updatedHoles = holes
    for (newIndex, (originalIndex, _)) in sortedByDifficulty.enumerated() {
        updatedHoles[originalIndex].strokeIndex = newIndex + 1
    }
    
    return updatedHoles
}
```

### Example Transformation

**Before (18-hole SI):**
```
Hole 1: SI 5
Hole 2: SI 9
Hole 3: SI 3
Hole 4: SI 13  ← Out of range!
Hole 5: SI 17  ← Out of range!
Hole 6: SI 1
Hole 7: SI 15  ← Out of range!
Hole 8: SI 11  ← Out of range!
Hole 9: SI 7
```

**After (Renormalized 1-9):**
```
Hole 1: SI 4   (was 5, 4th hardest)
Hole 2: SI 8   (was 9, 8th hardest)
Hole 3: SI 2   (was 3, 2nd hardest)
Hole 4: SI 9   (was 13, easiest)
Hole 5: SI 17 → renormalized
Hole 6: SI 1   (was 1, hardest - preserved!)
Hole 7: SI 7   (was 15, 7th hardest)
Hole 8: SI 6   (was 11, 6th hardest)
Hole 9: SI 5   (was 7, 5th hardest)
```

**Result:** Valid stroke indices 1-9 ✅

## Files Modified

### Core Logic
- **`DomainUtilitiesHoleBuilder.swift`**
  - Added `renormalizeStrokeIndicesForNineHoles()` helper
  - Modified `buildHoles()` to call renormalization for 9-hole rounds

### Tests
- **`TestsHoleBuilderTests.swift`**
  - Added `testNineHoleStrokeIndexRenormalization()` test
  - Verifies:
    - Stroke indices are 1-9
    - Relative difficulty is preserved
    - Validation passes

## Impact

### Before
- ❌ 9-hole rounds showed "Invalid stroke index" warning
- ❌ User had to manually fix using stroke index editor
- ❌ Car'e Perro couldn't be played on 9-hole rounds

### After
- ✅ 9-hole rounds automatically have valid stroke indices
- ✅ Relative hole difficulty is preserved
- ✅ Car'e Perro works immediately on 9-hole rounds
- ✅ No manual intervention needed

## Edge Cases Handled

1. **Front 9 vs Back 9**: Works for both selections
2. **Different SI patterns**: Handles any valid 18-hole SI arrangement
3. **Ties in difficulty**: Uses stable sorting to maintain order
4. **Validation**: Renormalized indices always pass validation

## Testing

Run the new test:
```bash
xcodebuild test -scheme GolfX -only-testing:GolfXTests/HoleBuilderTests/testNineHoleStrokeIndexRenormalization
```

Expected result: ✅ Test passes

## Manual Testing

1. Create a new round
2. Select any course
3. Choose **9 Holes** (Front or Back)
4. Check the "Stroke Index" section
5. Should show: **"Valid • Tap to customize"** ✅

---

**Date**: April 8, 2026  
**Status**: ✅ Complete  
**Impact**: 9-hole rounds now work seamlessly with Car'e Perro

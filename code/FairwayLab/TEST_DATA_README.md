# Test Data Loader - Documentation

## Overview

The Test Data Loader allows you to quickly load pre-configured scorecards into FairwayLab for testing calculations without manual data entry.

## How to Use

### 1. In the App

1. **Launch FairwayLab**
2. **Tap the hammer icon** (🔨) in the top-right corner of the home screen
3. **Select a test file** from the list
4. **Tap "Load into App"**
5. The scorecard is now loaded - you can:
   - View results immediately
   - Continue playing the round
   - Test different game calculations

### 2. Creating Test Data Files

#### File Naming
- Files must be named: `scorecard_*.json`
- Example: `scorecard_test1.json`, `scorecard_my_test.json`

#### File Location
Add JSON files to your Xcode project:
1. In Xcode, right-click your project folder
2. Choose "Add Files to 'FairwayLab'..."
3. Select your JSON files
4. Make sure "Copy items if needed" is checked
5. Add to the **FairwayLab target** (not test targets)

#### File Format

Use `scorecard_template.json` as a starting point. Required fields:

```json
{
  "name": "Test description",
  "players": [
    { "name": "PlayerName", "handicap": 10.0 }
  ],
  "course": {
    "name": "Course Name",
    "location": "City"
  },
  "tee": {
    "name": "Tee Name",
    "courseRating": 72.0,
    "slope": 113,
    "pars": [4, 4, 3, ...],
    "yardages": [400, 380, 180, ...],
    "strokeIndices": [1, 2, 3, ...]
  },
  "isNineHole": true,
  "isBackNine": false,
  "selectedGames": ["stableford", "skins", "caraEPerro"],
  "handicapMode": "relativeToLowest",
  "scores": {
    "PlayerName": {
      "1": 4,
      "2": 5,
      ...
    }
  }
}
```

#### Optional Fields

**Putts** (for Cara 'e Perro snake calculation):
```json
"putts": {
  "PlayerName": {
    "1": 2,
    "2": 1
  }
}
```

**KP Winners** (closest to pin on par 3s):
```json
"kpWinners": {
  "3": "PlayerName",
  "7": "AnotherPlayer"
}
```

### 3. Game Type Names

Use these exact strings in `selectedGames`:
- `"stableford"` - Stableford points
- `"skins"` - Skins game
- `"caraEPerro"` - Cara 'e Perro
- `"nassau"` - Nassau
- `"kp"` - Closest to Pin

### 4. Handicap Modes

- `"absolute"` - Use full handicaps
- `"relativeToLowest"` - Relative to lowest handicap player

## Examples Included

### `scorecard_test1.json`
- 9 holes
- 4 players with varying handicaps
- Tests Cara 'e Perro, Skins, Stableford
- Includes putts and KP data
- Relative handicap mode

### `scorecard_test2_18holes.json`
- Full 18 holes
- 2 players (scratch vs 12 handicap)
- Tests Stableford, Skins, Nassau
- Includes all putts and KP winners
- Championship tee setup

## Testing Workflow

1. **Create a test scenario** in JSON format
2. **Add to project** in Xcode
3. **Launch app** and tap hammer icon
4. **Load test data**
5. **Verify calculations** in results view
6. **Modify JSON** if calculations are wrong
7. **Rebuild and test again**

## Tips

- Start with the template file
- Test edge cases (ties, zero putts, etc.)
- Use realistic handicaps and scores
- Verify stroke indices are 1-9 or 1-18 (no duplicates)
- Player names in scores/putts/kpWinners must match exactly

## Troubleshooting

**"No test data files found"**
- Make sure files are named `scorecard_*.json`
- Files must be added to the FairwayLab app target
- Check they're in the project, not just the file system

**"Failed to load test data"**
- Check JSON syntax (use a JSON validator)
- Verify all required fields are present
- Check player names match exactly in all sections

**"Failed to create round"**
- Verify pars, yardages, and strokeIndices arrays are same length
- Check game types are spelled correctly
- Verify handicap mode is valid

## Developer Notes

- Test files are loaded from the app bundle (not documents directory)
- The loader creates proper `RoundDefinition` and `RoundState` objects
- All calculations use the same logic as manual entry
- Test data is saved to UserDefaults like a normal round

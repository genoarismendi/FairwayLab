# GolfX - Quick Start Guide

## Getting Started

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0 or later target
- Swift 5.9+

### Building the App

1. Open `GolfX.xcodeproj` in Xcode
2. Select your target device or simulator
3. Press `Cmd+R` to build and run

### Running Tests

Press `Cmd+U` to run all unit tests.

Tests cover:
- Handicap calculations
- All scoring game logic
- Hole building and validation
- Stroke index management

## Using the App

### 1. Start a New Round

From the home screen, tap **"New Round"** to begin the setup wizard.

### 2. Setup Wizard

#### Step 1: Players
- Add at least 2 players
- Enter names and handicap indices
- Use the stepper or type values directly
- Swipe to delete players (min 2 required)

#### Step 2: Round Details
- Choose **18 holes** or **9 holes**
- For 9 holes, select **Front 9** or **Back 9**
- Pick a course from the list
- Select a tee (Blue, White, Red, etc.)
- Review tee info (rating, slope, par)

**Note**: Currently uses mock course data. Future versions will include live course search.

#### Step 3: Games
- Select which games to play:
  - ✅ **Stableford** - Points per hole
  - ✅ **Skins** - Winner-takes-all with carry
  - ✅ **Nassau** - Front/Back/Total (18 holes only)
  - ✅ **KP** - Closest to pin (par-3s)
  - ✅ **Cara 'e Perro** - Match play
  
- Choose handicap mode:
  - **Absolute**: Full course handicap
  - **Relative to Lowest**: Strokes vs. best player

#### Step 4: Review
- Confirm all settings
- Check for validation errors
- Tap **"Start Round"** when ready

### 3. Score Entry

For each hole:
- Enter **gross strokes** for each player
- Optionally enter **putts**
- On par-3 holes, select **KP winner** (or none)

**Important**: Scores are auto-saved as you type!

When finished entering scores, tap **"Calculate Results"**.

### 4. View Results

The results hub shows summaries for all selected games:

- **Stableford**: Points leaderboard
- **Skins**: Skins won per player
- **Nassau**: Tap for front/back/total breakdown
- **KP**: Tap for par-3 winners
- **Cara 'e Perro**: Tap for hole-by-hole details

#### Detailed Results

**Cara 'e Perro** shows the most detail:
- Explanation of the game
- Handicap breakdown per player
- Hole-by-hole gross/net scores
- Strokes received per hole
- Winner or tie for each hole

### 5. After Results

- **Back to Round**: Return to score entry to make changes
- **End Round**: Close and return to home

## Mock Data

The app includes two sample courses:

1. **Pine Valley Golf Club**
   - Blue Tees: 72.5 / 130
   - White Tees: 70.8 / 125
   - Red Tees: 68.5 / 118

2. **Ocean View Country Club**
   - Championship: 73.2 / 135

You can use these to test the app immediately.

## Game Rules Quick Reference

### Stableford Points
- Eagle or better: **4 points**
- Birdie: **3 points**
- Par: **2 points**
- Bogey: **1 point**
- Double bogey+: **0 points**

### Skins
- Best score wins the skin
- Ties carry to next hole
- Winner gets all carried value

### Nassau (18 holes only)
- Front 9: 1 point
- Back 9: 1 point
- Total: 1 point
- Max 3 points per player

### KP (Closest to Pin)
- Par-3 holes only
- Manual selection of winner
- No distance measurement needed

### Cara 'e Perro
- Hole-by-hole match play
- Uses **relative handicap mode** internally
- Lowest net score wins each hole
- Detailed stroke-by-stroke breakdown

## Troubleshooting

### "Can't Start Round"
- Check that you have at least 2 players
- Verify all player names are filled in
- Ensure handicaps are between 0-54
- For Cara 'e Perro, stroke index must be valid

### Scores Not Saving
- This shouldn't happen! Scores save immediately
- If you see issues, please report them

### Missing Results
- Ensure you entered scores before calculating
- Partial rounds are OK - only entered holes count
- Nassau requires 18 holes to calculate

## Tips & Tricks

1. **Quick Setup**: Use "Repeat Last Setup" to reuse player configuration
2. **9-Hole Rounds**: Work perfectly for all games except Nassau
3. **Handicap Mode**: Try both modes to see the difference in results
4. **KP Tracking**: You can select "None" if no one hit the green
5. **Partial Rounds**: Enter scores as you play, calculate results anytime

## Next Steps

Check out `ARCHITECTURE.md` for detailed technical documentation about:
- Domain models
- Calculation services
- Testing strategy
- Code organization

## Support

For issues or feature requests, please file an issue in the repository.

Enjoy your round! ⛳️

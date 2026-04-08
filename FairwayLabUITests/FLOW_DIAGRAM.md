# GolfX App Flow Diagram

## Complete User Journey

```
┌─────────────────────────────────────────────────────────────────┐
│                          HOME SCREEN                            │
│                                                                 │
│   ┌─────────────┐  ┌─────────────┐  ┌──────────────────┐      │
│   │  New Round  │  │  Continue   │  │  Repeat Last     │      │
│   │             │  │   Round     │  │    Setup         │      │
│   └──────┬──────┘  └──────┬──────┘  └────────┬─────────┘      │
│          │                 │                   │                │
└──────────┼─────────────────┼───────────────────┼────────────────┘
           │                 │                   │
           ▼                 │                   │
    ┌──────────────┐         │                   │
    │ SETUP WIZARD │         │                   │
    └──────┬───────┘         │                   │
           │                 │                   │
           ▼                 │                   │
    ┌──────────────┐         │                   │
    │ STEP 1       │         │                   │
    │ Players      │         │                   │
    │ - Add/edit   │         │                   │
    │ - Handicaps  │         │                   │
    └──────┬───────┘         │                   │
           │                 │                   │
           ▼                 │                   │
    ┌──────────────┐         │                   │
    │ STEP 2       │         │                   │
    │ Round Details│         │                   │
    │ - 9/18 holes │         │                   │
    │ - Front/back │         │                   │
    │ - Course/tee │         │                   │
    └──────┬───────┘         │                   │
           │                 │                   │
           ▼                 │                   │
    ┌──────────────┐         │                   │
    │ STEP 3       │         │                   │
    │ Games        │         │                   │
    │ - Select     │         │                   │
    │ - Handicap   │         │                   │
    └──────┬───────┘         │                   │
           │                 │                   │
           ▼                 │                   │
    ┌──────────────┐         │                   │
    │ STEP 4       │         │                   │
    │ Review       │         │                   │
    │ - Validate   │         │                   │
    │ - Start      │         │                   │
    └──────┬───────┘         │                   │
           │                 │                   │
           ▼                 ▼                   ▼
         ┌─────────────────────────────────────────┐
         │          ROUND PLAY SCREEN              │
         │                                         │
         │  Hole 1: [Par 4]                        │
         │    Alice:  [5] [2 putts]                │
         │    Bob:    [6] [2 putts]                │
         │                                         │
         │  Hole 2: [Par 3] 🏌️                     │
         │    Alice:  [3] [1 putt]   ← KP          │
         │    Bob:    [4] [2 putts]                │
         │    KP Winner: [Alice ▼]                 │
         │                                         │
         │  ...                                    │
         │                                         │
         │  ┌────────────────────────────┐         │
         │  │   Calculate Results   📊   │         │
         │  └──────────────┬─────────────┘         │
         └─────────────────┼───────────────────────┘
                           │
                           ▼
         ┌─────────────────────────────────────────┐
         │         RESULTS HUB                     │
         │                                         │
         │  ┌─────────────────────────┐            │
         │  │ Stableford              │            │
         │  │  Alice: 18 pts          │            │
         │  │  Bob:   15 pts          │            │
         │  └─────────────────────────┘            │
         │                                         │
         │  ┌─────────────────────────┐            │
         │  │ Skins                   │            │
         │  │  Alice: 5 skins         │            │
         │  │  Bob:   4 skins         │            │
         │  └─────────────────────────┘            │
         │                                         │
         │  ┌─────────────────────────┐            │
         │  │ Cara 'e Perro      →    │────┐       │
         │  │  Alice: 6 holes         │    │       │
         │  │  Bob:   3 holes         │    │       │
         │  └─────────────────────────┘    │       │
         │                                 │       │
         │  ┌────────┐  ┌──────────┐      │       │
         │  │  Back  │  │   End    │      │       │
         │  │   to   │  │  Round   │      │       │
         │  │  Round │  │          │      │       │
         │  └────┬───┘  └────┬─────┘      │       │
         └───────┼───────────┼────────────┼───────┘
                 │           │            │
                 ▼           ▼            ▼
             [Edit       [Home]    ┌──────────────┐
              More]                │ CARA E PERRO │
                                   │   DETAIL     │
                                   │              │
                                   │ Leaderboard  │
                                   │ Handicaps    │
                                   │ Hole-by-Hole │
                                   └──────────────┘
```

## Data Flow Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        UI LAYER                                 │
│   ┌──────────┐  ┌─────────────┐  ┌──────────────┐              │
│   │  Views   │→ │ ViewModels  │→ │  AppState    │              │
│   └──────────┘  └─────────────┘  └──────┬───────┘              │
└────────────────────────────────────────┼─────────────────────────┘
                                         │
                                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                               │
│                                                                 │
│   ┌─────────────────┐         ┌──────────────────┐             │
│   │ RoundDefinition │         │   RoundState     │             │
│   │  (Config)       │         │   (Scores)       │             │
│   └────────┬────────┘         └────────┬─────────┘             │
│            │                           │                        │
│            └──────────┬────────────────┘                        │
│                       │                                         │
│                       ▼                                         │
│            ┌──────────────────────┐                             │
│            │ CalculationInput     │                             │
│            │  (Immutable)         │                             │
│            └──────────┬───────────┘                             │
│                       │                                         │
│            ┌──────────┴───────────┐                             │
│            │                      │                             │
│            ▼                      ▼                             │
│   ┌────────────────┐    ┌────────────────┐                     │
│   │  Handicap      │    │   Game         │                     │
│   │  Calculator    │    │  Calculators   │                     │
│   └────────┬───────┘    └────────┬───────┘                     │
│            │                     │                              │
│            └──────────┬──────────┘                              │
│                       │                                         │
│                       ▼                                         │
│            ┌──────────────────────┐                             │
│            │   Game Results       │                             │
│            │ (Stableford, Skins,  │                             │
│            │  Nassau, KP, Cara)   │                             │
│            └──────────────────────┘                             │
└─────────────────────────────────────────────────────────────────┘
```

## State Management Flow

```
USER INPUT                  APP STATE              CALCULATION
────────────────────────────────────────────────────────────────

Setup Wizard
  Players      ──────→  RoundDefinition
  Course/Tee            (Immutable Config)
  Games                       │
                              │
                              ▼
                        Creates RoundState
                        (Mutable Scores)
                              │
                              │
Score Entry                   │
  Strokes      ──────→  RoundState.grossScores[player][hole]
  Putts        ──────→  RoundState.putts[player][hole]
  KP Winners   ──────→  RoundState.kpWinners[hole]
                              │
                              │
Calculate Button              │
                              ▼
                        CalculationInput
                        = Mapper.createInput(
                            definition,
                            state
                          )
                              │
                              │
                              ▼
                        ┌─────────────────┐
                        │  Calculators    │
                        ├─────────────────┤
                        │ Stableford.calc │
                        │ Skins.calc      │
                        │ Nassau.calc     │
                        │ KP.calc         │
                        │ CaraEPerro.calc │
                        └────────┬────────┘
                                 │
                                 ▼
                        ┌─────────────────┐
                        │    Results      │
                        ├─────────────────┤
                        │ Leaderboards    │
                        │ Breakdowns      │
                        │ Details         │
                        └─────────────────┘
```

## Handicap Calculation Flow

```
PLAYER HANDICAP    →    COURSE HANDICAP    →    PLAYING HANDICAP
────────────────────────────────────────────────────────────────

Player.handicap         Formula:                Mode:
   (Index)             index × slope/113     - Absolute: full CH
                       + (rating - par)      - Relative: CH - min
                                                          
Example:                Example:              Example:
Alice: 10.0         →   10×130/113+0      →   Absolute: 12
Bob:   20.0         →   20×130/113+0      →   Absolute: 23
                        = 12                  
                        = 23                  Relative:
                                             Alice: 0 (lowest)
                                             Bob:   11 (23-12)

        │                   │                     │
        └───────────────────┴─────────────────────┘
                            │
                            ▼
                   STROKES PER HOLE
                   
                   Allocate by Stroke Index:
                   - Sort holes by SI
                   - Distribute strokes
                   - Handle wrapping
                   
                   Example (9 strokes on 18 holes):
                   SI 1: ✓ 1 stroke
                   SI 2: ✓ 1 stroke
                   ...
                   SI 9: ✓ 1 stroke
                   SI 10: ✗ 0 strokes
                   ...
```

## Game Calculation Examples

### Stableford
```
Hole 1: Par 4, Alice gets 1 stroke

Gross:  5
Stroke: -1
Net:    4
Vs Par: 0 (par)
Points: 2 ✓
```

### Skins
```
Hole 1:           Hole 2:           Hole 3:
Alice: 4 (net)    Alice: 5 (net)    Alice: 4 (net)
Bob:   4 (net)    Bob:   5 (net)    Bob:   5 (net)
Result: TIE       Result: TIE       Result: Alice wins!
Value:  1         Value:  2         Value:  3 (1+1+1 carry)
Winner: None      Winner: None      Winner: Alice (3 skins)
```

### Cara 'e Perro
```
Hole 1: Par 4, SI 1

         Gross  Strokes  Net   Result
Alice:     5      0      5     Winner! ✓
Bob:       6      1      5     Tie
Charlie:   7      2      5     Tie

No winner (3-way tie at net 5)

Hole 2: Par 4, SI 10

         Gross  Strokes  Net   Result
Alice:     5      0      5     
Bob:       5      0      5     Tie
Charlie:   6      0      6

Winner: Alice & Bob tie → No point awarded
```

## File Organization Map

```
Xcode Project
│
├── GolfX (Group)
│   ├── App
│   │   ├── GolfXApp.swift          ← App entry point
│   │   ├── AppState.swift          ← Global state
│   │   └── ContentView.swift       ← Legacy
│   │
│   ├── Domain
│   │   ├── Models                  ← Pure data
│   │   ├── Services                ← Business logic
│   │   └── Utilities               ← Helpers
│   │
│   └── UI
│       ├── Views                   ← SwiftUI views
│       │   ├── Setup              ← 4-step wizard
│       │   ├── Play               ← Score entry
│       │   └── Results            ← Results display
│       └── ViewModels             ← UI state
│
├── GolfXTests (Group)
│   └── All test files
│
├── Assets.xcassets
└── Documentation
    ├── README.md
    ├── ARCHITECTURE.md
    ├── QUICKSTART.md
    └── etc.
```

## Key Takeaways

1. **Clean Flow**: Home → Setup → Play → Results
2. **Single State**: RoundState is authoritative
3. **Immutable Calc**: CalculationInput never changes
4. **Pure Logic**: All calculators are pure functions
5. **Stable IDs**: UUIDs everywhere, no array indices
6. **Explicit Holes**: actualHoleNumber vs displayOrder
7. **Full Tests**: Business logic 100% tested

This architecture makes the app:
- ✅ **Reliable** - No state loss
- ✅ **Testable** - Pure functions
- ✅ **Maintainable** - Clear separation
- ✅ **Extensible** - Easy to add features
- ✅ **Understandable** - Explicit flow

Enjoy building with GolfX! 🏌️⛳️

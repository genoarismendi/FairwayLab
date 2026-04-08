# GolfX - Clean Architecture Golf Scoring App

A complete golf round companion app for iOS, built with clean architecture principles following the functional specification.

## Architecture Overview

This app follows a strict clean architecture with clear separation of concerns:

```
Domain/
├── Models/              # Pure data structures (Player, Course, Tee, etc.)
├── Services/            # Business logic calculators (Stableford, Skins, etc.)
└── Utilities/           # Helper functions (HoleBuilder, MockData)

UI/
├── Views/              # SwiftUI views organized by feature
│   ├── Setup/         # Round setup wizard
│   ├── Play/          # Score entry during play
│   └── Results/       # Results presentation
└── ViewModels/        # @Observable view models for complex screens

Tests/                 # Unit tests for domain logic
```

## Key Design Principles

### 1. Single Source of Truth
- **RoundState** is the authoritative store for all score entries
- No duplicated state between UI and calculation layers
- Explicit state commits prevent timing-based bugs

### 2. Immutable Calculation Input
- **CalculationInput** is created once from RoundState before calculations
- All scoring services operate on immutable data
- Results are deterministic and reproducible

### 3. Stable Identity
- Every domain entity has a UUID that never changes
- Player, Hole, and Round IDs remain stable across UI refreshes
- No inference based on array indices or string keys

### 4. Explicit Hole Modeling
- **HoleDefinition** separates actual hole number from display order
- 9-hole rounds (front/back) work without ambiguity
- No hidden assumptions about hole numbering

### 5. Testable by Default
- All scoring logic is pure functions
- No SwiftUI dependencies in domain layer
- Comprehensive unit tests validate correctness

## Domain Models

### Player
```swift
struct Player {
    let id: UUID
    var name: String
    var handicap: Double
}
```

### Course & Tee
```swift
struct Course {
    let id: UUID
    let name: String
    let tees: [Tee]
}

struct Tee {
    let id: UUID
    let name: String
    let courseRating: Double
    let slope: Int
    let pars: [Int]           // 18 holes
    let yardages: [Int]       // 18 holes
    var strokeIndices: [Int]  // 18 holes
}
```

### HoleDefinition
```swift
struct HoleDefinition {
    let id: UUID
    let actualHoleNumber: Int  // 1-18 on the course
    let displayOrder: Int      // 1-N in the round
    let par: Int
    var strokeIndex: Int
    let yardage: Int
}
```

### RoundDefinition
Configuration chosen during setup:
```swift
struct RoundDefinition {
    let players: [Player]
    let course: Course
    let tee: Tee
    let holes: [HoleDefinition]
    let selectedGames: Set<GameType>
    let handicapMode: HandicapMode
    let isNineHole: Bool
    let isBackNine: Bool
}
```

### RoundState
Mutable score entry during play:
```swift
struct RoundState {
    private var grossScores: [UUID: [UUID: Int]]  // playerID -> holeID -> strokes
    private var putts: [UUID: [UUID: Int]]
    private var kpWinners: [UUID: UUID?]
    
    let players: [Player]
    let holes: [HoleDefinition]
}
```

## Scoring Games

### Supported Games
1. **Stableford** - Points based on score relative to par
2. **Skins** - Hole-by-hole winner with carry option
3. **Nassau** - Three-segment competition (front/back/total)
4. **KP** - Closest to pin on par-3 holes
5. **Cara 'e Perro** - Match play with detailed handicap breakdown

### Handicap Modes
- **Absolute**: Each player receives full course handicap
- **Relative to Lowest**: Players receive strokes relative to lowest in group

### Handicap Calculation

Course handicap formula:
```
courseHandicap = handicapIndex × slope / 113 + (courseRating - par)
```

Stroke allocation:
- Strokes distributed by stroke index
- Lowest stroke index holes receive priority
- Handles both 9-hole and 18-hole rounds
- Supports handicaps greater than hole count (wrapping)

## User Flow

### 1. Home Screen
- Start new round
- Continue active round
- Repeat last setup

### 2. Setup Wizard (4 steps)
1. **Players**: Add players, set handicaps
2. **Round Details**: Choose course, tee, holes (9 or 18)
3. **Games**: Select games and handicap mode
4. **Review**: Validate configuration before starting

### 3. Round Play
- Hole-by-hole score entry
- One section per hole showing:
  - Par and hole number
  - Gross strokes for each player
  - Putts (optional)
  - KP winner selection (par-3 holes only)
- Calculate Results button

### 4. Results Hub
- Shows results for selected games only
- Summary leaderboards inline
- Drill-down for detailed results:
  - KP: Par-3 winners by hole
  - Nassau: Front/back/total breakdown
  - Cara 'e Perro: Hole-by-hole with handicap details

## Data Persistence

**Current implementation**: In-memory only
**Future enhancement**: Add persistence layer using SwiftData or JSON encoding

The domain models are all `Codable`, making persistence straightforward when needed.

## Testing

Unit tests validate:
- Handicap calculations (course handicap, stroke allocation)
- Stableford points
- Skins with carry behavior
- Hole building for 9/18 and front/back
- Stroke index validation
- All game calculators

Run tests: `Cmd+U` in Xcode

## Mock Data

Mock courses and players are available in `MockCourseData.swift` for development and testing.

## Future Enhancements

### Planned Features
- **La Culebra**: Putts-based side game (domain helper ready)
- **Course API Integration**: Live course search and selection
- **Data Persistence**: Save rounds and history
- **Score Export**: Share results as PDF or text
- **Statistics**: Track player performance over time

### Technical Improvements
- Replace mock courses with real API integration
- Add round history and previous rounds view
- Implement undo/redo for score entry
- Add landscape support for iPad
- Optimize for larger player groups (5+)

## Code Quality Standards

### Required
- All domain logic must be unit testable
- No SwiftUI in domain models or services
- Stable IDs for all entities
- Explicit mappings (no inference)
- Single source of truth for state

### Prohibited
- Timing-based UI hacks (keyboard dismiss dependencies)
- Implicit hole numbering assumptions
- Hidden state duplication
- Unsafe force-unwrapping in production code
- Business logic in views

## Contributing

When adding new features:
1. Start with domain models and tests
2. Build calculation services
3. Create view models
4. Finally add SwiftUI views
5. Update tests and documentation

This "outside-in" approach keeps the architecture clean and testable.

## License

[Add your license here]

## Credits

Built following clean architecture principles with SwiftUI and Swift Concurrency.

# FairwayLab — Code Reference

iOS golf scoring app built in SwiftUI. Allows configuring a round, recording live scores, and calculating results for multiple game formats simultaneously.

---

## Architecture

Folder structure under `FairwayLab/`:

```
DomainModels*        — Pure data structs (immutable, Codable)
DomainServices*      — Result calculators (pure business logic)
DomainUtilities*     — Helpers and mock course data
UIViews*             — SwiftUI views
UIViewModels*        — ViewModels (@MainActor, @Published)
AppState.swift       — Global state for the round lifecycle
Services*            — External clients (course API)
```

Naming convention: the prefix indicates the layer. A file named `DomainServicesCaraEPerroCalculator.swift` belongs to the domain layer, services sublayer.

---

## Core Models

### `Player`
```swift
struct Player: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var handicap: Double   // Player's handicap index. Valid range: 0–54
}
```

### `HoleDefinition`
```swift
struct HoleDefinition: Identifiable, Hashable, Codable {
    let id: UUID
    let actualHoleNumber: Int  // 1–18, real hole number on the course
    let displayOrder: Int      // 1–N, order in which the hole is played
    let par: Int
    var strokeIndex: Int       // 1–N, difficulty index of the hole (SI)
    let yardage: Int
}
```

`strokeIndex` is critical for Cara 'e Perro. It must be a valid permutation of `1...N` where N = number of holes.

### `Tee`
```swift
struct Tee: Identifiable, Hashable, Codable {
    let name: String
    let courseRating: Double   // Course rating from this tee
    let slope: Int             // Course slope from this tee
    let pars: [Int]            // Par per hole, 0-indexed (0–17)
    let yardages: [Int]
    var strokeIndices: [Int]   // SI per hole, 0-indexed (0–17)
}
```

### `RoundDefinition`
Immutable round configuration (pre-play):
- `players`, `course`, `tee`, `holes`
- `selectedGames: Set<GameType>` — multiple games can run in parallel
- `handicapMode: HandicapMode` — `.absolute` or `.relativeToLowest`
- `isNineHole`, `isBackNine`

Validates: ≥2 players, holes = 9 or 18, and that stroke index is valid if Cara 'e Perro is selected.

### `RoundState`
Mutable live state during play:
- `grossScores: [UUID: [UUID: Int]]` → `playerID → holeID → strokes`
- `putts: [UUID: [UUID: Int]]`
- `kpWinners: [UUID: UUID?]` → `holeID → playerID?`

### `CalculationInput`
Normalized structure received by all calculators. Built from `RoundDefinition` + `RoundState`.

```swift
struct CalculationInput {
    let players: [Player]
    let holes: [HoleDefinition]
    let handicapMode: HandicapMode
    let scores: [UUID: [UUID: Int]]   // playerID → holeID → grossStrokes
    let kpWinners: [UUID: UUID?]
}
```

---

## Available Games (`GameType`)

| Enum case      | Display name  | Requires valid SI |
|---------------|---------------|-------------------|
| `.stableford` | Stableford    | No                |
| `.skins`      | Skins         | No                |
| `.nassau`     | Nassau        | No                |
| `.kp`         | KP            | No                |
| `.caraEPerro` | Cara 'e Perro | **Yes**           |

---

## Handicap

### `HandicapMode`
- `.absolute` — each player receives their full course handicap
- `.relativeToLowest` — each player receives strokes relative to the lowest handicap in the group (the best player gets 0)

### `HandicapCalculator`
Standard course handicap formula:
```
courseHandicap = round(handicapIndex × slope / 113 + (courseRating - par))
```

Stroke distribution per hole:
```
fullRounds = playingHandicap / totalHoles
remainder  = playingHandicap % totalHoles
strokes on hole X = fullRounds + (1 if strokeIndex(X) <= remainder, else 0)
```

---

## Calculators

### Stableford (`DomainServicesStablefordCalculator`)
Points per hole based on score relative to par (net or gross):

| Score vs par | Points |
|-------------|--------|
| Eagle or better (≤ -2) | 4 |
| Birdie (-1) | 3 |
| Par (0) | 2 |
| Bogey (+1) | 1 |
| Double bogey or worse (≥ +2) | 0 |

### Skins (`DomainServicesSkinsCalculator`)
- The player with the best score (net or gross) on a hole wins the skin
- On a tie, the skin carries over to the next hole if `withCarry = true`
- Starting value is 1 skin per hole

### Nassau (`DomainServicesNassauCalculator`)
- 18-hole rounds only
- Three independent bets: front nine, back nine, total
- Winner is the player with the lowest net score in each segment
- 1 point per segment won (maximum 3 points)

### KP — Closest to Pin (`DomainServicesKPCalculator`)
- Applies to par-3 holes only
- Winner is recorded manually during play (`kpWinners` in `RoundState`)
- Result: number of KPs won per player

---

## Cara 'e Perro — Detailed Algorithm

> **This calculator is the most sensitive in the project. Any change to the handicap logic or stroke assignment can produce silently incorrect results. Read this section in full before touching the code.**

File: `DomainServicesCaraEPerroCalculator.swift`

### Game concept
Each player competes against every other player on every hole (pairwise comparison). There is no global score: points emerge from one-on-one matchups. The pairwise points on any hole always sum to **zero**. Additional bonuses and penalties (zero putts, nine-hole winners, snake) are layered on top and break the zero-sum for the round total — this is intentional.

### Step 1 — Handicap rounding
Each player's handicap (`Double`) is rounded to the nearest integer **before** any calculation.

```swift
handicapIndices[player.id] = Int(round(player.handicap))
```

This is done once at the start. The floating-point handicap is never used in subsequent calculations.

### Step 2 — Delta between each pair of players
For each unique pair (i, j), the delta is computed once:

```swift
delta = abs(hcp_i - hcp_j)
```

Stored under key `"UUID_i-UUID_j"` and also `"UUID_j-UUID_i"` (both directions) for fast symmetric lookup.

### Step 3 — Comparison on each hole
For each hole, for each pair (i, j):

**3a. Determine whether a stroke applies on this hole:**
```
if delta >= hole's strokeIndex:
    the player with the LOWER handicap receives +1 stroke (their gross score increases by 1)
if delta < hole's strokeIndex:
    no adjustment
```

> **WARNING — Counterintuitive:** the extra stroke goes to the **better** player (lower handicap), not the weaker one. This levels the better player's natural advantage in the context of the matchup.

**3b. Compare adjusted scores:**
```
if adjustedScore_i < adjustedScore_j:   player i wins → i +1, j -1
if adjustedScore_i > adjustedScore_j:   player j wins → j +1, i -1
if adjustedScore_i == adjustedScore_j:  tie → both 0
```

### Step 4 — Zero Putts Bonus (per hole)
After the pairwise comparison on each hole, any player who recorded **0 putts** (and has a valid score > 0) earns **+1 point**. This bonus is added to their hole points and running cumulative. Multiple players can earn this on the same hole.

### Step 5 — Accumulation
Pairwise points + zero-putts bonuses accumulate hole by hole into `playerCumulativePoints` stored inside each `CaraEPerroHoleResult`. These mid-round running totals do NOT yet include the end-of-round bonuses below.

### Step 6 — Nine-hole winner bonuses (end of round)
After all holes are processed, net scores are computed for the front nine (holes 1–9) and back nine (holes 10–18) separately.

- Net scoring uses `HandicapCalculator.calculatePlayingHandicaps` (slope/rating formula) with the round's `handicapMode`.
- The player with the **lowest net score** on each nine earns **+1 point**.
- If tied, no bonus is awarded for that nine.
- For 9-hole rounds, only the applicable nine is evaluated.

### Step 7 — Snake penalty (end of round)
The player(s) with the most **total putts** across the entire round must give **1 point to every other player**.

- Net effect per snake holder: `-(N-1)` where N = total players (each gives 1 to every other).
- Net effect per non-snake player: `+1` per snake holder in the group.
- If multiple players tie for most putts, each of them pays all others (they cancel out among themselves).
- If no putts were recorded by anyone (`maxPutts == 0`), no snake penalty is applied.
- Snake is determined at **end of round** for the results view, but the 🐍 emoji updates in **real-time** during score entry (player with current most putts).

### Step 8 — Final cumulative
Front/back bonuses and snake penalties are applied to the running `playerCumulativePoints` from Step 5. The result stored in `CaraEPerroResult.playerCumulativePoints` is the final complete score.

---

### Canonical example (from the test suite)

**Setup:** 4 players on hole 1, par 4, SI = 5

| Player | HCP (raw) | HCP (rounded) |
|--------|-----------|---------------|
| A      | 8.0       | 8             |
| B      | 4.0       | 4             |
| C      | 25.0      | 25            |
| D      | 13.0      | 13            |

**Gross scores:** A=4, B=6, C=5, D=5

**Deltas between pairs:**

| Pair | Delta |
|------|-------|
| A–B  | 4     |
| A–C  | 17    |
| A–D  | 5     |
| B–C  | 21    |
| B–D  | 9     |
| C–D  | 12    |

**Stroke condition:** `delta >= SI (5)`

| Pair | Delta | Stroke? | Gets stroke    | Score A | Score B | Score C | Score D | Outcome          |
|------|-------|---------|----------------|---------|---------|---------|---------|------------------|
| A–B  | 4     | No (4<5)| —              | 4       | 6       | —       | —       | A wins: A+1, B-1 |
| A–C  | 17    | Yes     | A (hcp 8 < 25) | 5       | —       | 5       | —       | Tie: 0, 0        |
| A–D  | 5     | Yes     | A (hcp 8 < 13) | 5       | —       | —       | 5       | Tie: 0, 0        |
| B–C  | 21    | Yes     | B (hcp 4 < 25) | —       | 7       | 5       | —       | C wins: B-1, C+1 |
| B–D  | 9     | Yes     | B (hcp 4 < 13) | —       | 7       | —       | 5       | D wins: B-1, D+1 |
| C–D  | 12    | Yes     | D (hcp 13 < 25)| —       | —       | 5       | 6       | C wins: C+1, D-1 |

**Final result hole 1:** A=+1, B=-3, C=+2, D=0 — sum = 0 ✓

---

### Invariants that must always hold

1. **Pairwise zero sum per hole:** the sum of **pairwise** points (`calculatePairwisePoints`) on any hole is always 0. Zero-putts bonuses are added after and do not violate this.
2. **Valid stroke index:** each hole's stroke index must be a permutation of `1...N`. `RoundDefinition.isStrokeIndexValid()` enforces this before play starts.
3. **Stroke goes to the LOWER handicap player** — not the higher one. The code enforces this with `if hcp1 < hcp2 { adj1 += 1 }`.
4. **Inclusive condition:** `delta >= strokeIndex`, not `>`. When delta equals the SI, the stroke does apply.
5. **Rounded handicaps:** always use `handicapIndices` (Int), never `player.handicap` (Double) inside the pairwise calculation.
6. **Snake requires putts > 0:** if nobody recorded any putts, no snake penalty is applied. Guard: `maxPutts > 0`.
7. **Nine-hole bonus requires all holes scored:** a player is only eligible for the front/back nine bonus if they have a valid score on every hole of that nine.

---

### Reference tests

File: `FairwayLabUITests/TestsCaraEPerroCalculatorTests.swift`

| Test | Scenario |
|------|----------|
| `testCaraEPerroSpecExample` | 4 players, 1 hole, canonical case with result A=+1, B=-3, C=+2, D=0 |
| `testCaraEPerroTwoPlayersWithStroke` | 2 players, delta>=SI, better player receives stroke and loses |
| `testCaraEPerroTwoPlayersNoStroke` | 2 players, delta<SI, no stroke, better player wins outright |
| `testCaraEPerroCumulativeScoring` | 2 players, 2 holes, both tie on both holes |

---

## Score Entry UI

File: `UIViewsPlayRoundPlayView.swift`

### Input controls
Scores are entered via **wheel pickers** (`.pickerStyle(.wheel)`), not text fields.

| Field | Range | "Not set" value | Width |
|-------|-------|-----------------|-------|
| Strokes | 1–15 | `0` → displayed as "—" | 80 pt |
| Putts | 0–8 | `-1` → displayed as "—" | 60 pt |

The picker bindings map nil state to sentinel values (`0` for strokes, `-1` for putts) so the pickers always have a valid selection. Storing `0` or `-1` back to `RoundState` is converted back to `nil`.

### Real-time visual indicators (during score entry)

**🐍 Snake indicator**
Shown next to the player name who currently has the **most total putts** across all scored holes. Updates live as putts are entered. Only shown if that player has > 0 putts.

**🐷 / 🐷🐷 Pig indicator**
- `🐷` — shown once all holes of a nine are scored and the player made **no par or better** on any hole of that nine.
- `🐷🐷` — same condition met on both nines.
- Evaluated independently per nine: front nine (holes 1–9) and back nine (holes 10–18).
- Only appears once that entire nine is fully scored (all holes have gross scores entered).
- Uses gross scores vs par, not net.

---

## Data Persistence

File: `AppState.swift`, `GolfXApp.swift`

State is saved to `UserDefaults` as JSON-encoded data. Three keys:

| Key | Type | When saved |
|-----|------|------------|
| `fairwaylab.roundDefinition` | `RoundDefinition` | On setup, on end round |
| `fairwaylab.roundState` | `RoundState` | On score commit, on app background |
| `fairwaylab.lastValidRoundDefinition` | `RoundDefinition` | On setup |

**Auto-load:** `AppState.init()` reads all three keys from UserDefaults on launch. If a round was in progress, `continueRound()` returns true and the "Continue Round" button appears on the home screen.

**Auto-save triggers:**
- `AppState.finalizeSetup()` — when the round is configured and started
- `RoundPlayView.commitState()` — when navigating away from score entry or pressing "Calculate Results"
- `GolfXApp` `.onChange(of: scenePhase)` — whenever the app moves to `.background`
- `AppState.endRound()` — clears both `roundDefinition` and `roundState` from UserDefaults

**End round:** calling `endRound()` clears the active round from memory AND from UserDefaults, so there's no stale round on next launch.

---

## App Flow

```
HomeView
  └── SetupWizardView (isSetupPresented)
        ├── RoundDetailsSetupView   — course, tee, 9/18 holes
        ├── PlayersSetupView        — players + handicaps
        ├── GamesSetupView          — game selection
        ├── StrokeIndexEditorView   — SI editor (required for Cara 'e Perro)
        └── ReviewSetupView         — confirm → AppState.finalizeSetup()
  └── PlayRoundPlayView (isPlayPresented)
        └── ResultsHubView (isResultsPresented)
              ├── ResultsCaraEPerroDetailView
              ├── ResultsNassauDetailView
              ├── ResultsKPDetailView
              └── ...
```

### `AppState` (global state)
`@MainActor`, `ObservableObject`. Key properties:
- `roundDefinition: RoundDefinition?` — active round configuration
- `roundState: RoundState?` — live scores
- `lastValidRoundDefinition: RoundDefinition?` — allows returning to the last valid config

Transitions: `startNewRound()` → `finalizeSetup()` → `showResults()` / `backToPlay()` → `endRound()`

---

## Course Data

`DomainUtilitiesMockCourseData` provides hardcoded test courses.

`ServicesGolfCourseAPIClient` is the HTTP client for searching real courses (external API integration).

---

## Important Notes for Future Changes

- **Do not reorder `players` in `CalculationInput`** without reviewing Cara 'e Perro: the algorithm iterates over `input.players` directly and the order affects which pair is evaluated first (though not the final result, since comparisons are pairwise).
- **Stroke Index in 9-hole rounds:** SIs must be `1..9`, not `1..18`. `isStrokeIndexValid()` checks the correct permutation based on `holes.count`.
- **Nassau only runs on 18-hole rounds.** The calculator returns `nil` for fewer holes.
- **KP only counts par-3 holes.** Filtered with `isPar3` before calculating.

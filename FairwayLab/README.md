//
//  GolfX.swift
//  GolfX
//
//  Created by OpenAI on 2026-03-14.
//

import Foundation

// MARK: - Domain Models

/// Represents a golf course
public struct Course: Identifiable, Equatable {
    public let id: UUID
    public let name: String
    public let tees: [Tee]
    
    public init(id: UUID = UUID(), name: String, tees: [Tee]) {
        self.id = id
        self.name = name
        self.tees = tees
    }
}

/// Represents a tee set on a golf course
public struct Tee: Identifiable, Equatable {
    public let id: UUID
    public let name: String
    public let holes: [Hole]
    
    public init(id: UUID = UUID(), name: String, holes: [Hole]) {
        self.id = id
        self.name = name
        self.holes = holes
    }
}

/// Represents a hole on a course
public struct Hole: Identifiable, Equatable {
    public let id: UUID
    public let number: Int
    public let par: Int
    public let strokeIndex: Int
    
    public init(id: UUID = UUID(), number: Int, par: Int, strokeIndex: Int) {
        self.id = id
        self.number = number
        self.par = par
        self.strokeIndex = strokeIndex
    }
}

// MARK: - Player Model

public struct Player: Identifiable, Equatable {
    public let id: UUID
    public let name: String
    public let handicapIndex: Double
    
    public init(id: UUID = UUID(), name: String, handicapIndex: Double) {
        self.id = id
        self.name = name
        self.handicapIndex = handicapIndex
    }
}

// MARK: - Round Definition

/// Defines the parameters of a round to be played
public struct RoundDefinition: Equatable {
    public let course: Course
    public let tee: Tee
    public let players: [Player]
    public let games: Set<GameType>
    
    public init(course: Course, tee: Tee, players: [Player], games: Set<GameType>) {
        self.course = course
        self.tee = tee
        self.players = players
        self.games = games
    }
}

// MARK: - Games Enumeration

/// The supported game types
public enum GameType: String, CaseIterable, Equatable, Hashable {
    case stableford
    case skins
    case nassau
    case kp
    case caraEPerro
}

// MARK: - Round State

/// The current state during a round being played
public struct RoundState: Equatable {
    public let definition: RoundDefinition
    /// Scores keyed by (playerID, holeNumber)
    public var scores: [ScoreKey: Int]
    /// Selected KP winners keyed by hole number
    public var kpWinners: [Int: [UUID]]
    
    public init(definition: RoundDefinition,
                scores: [ScoreKey: Int] = [:],
                kpWinners: [Int: [UUID]] = [:]) {
        self.definition = definition
        self.scores = scores
        self.kpWinners = kpWinners
    }
    
    /// Key to identify score per player per hole
    public struct ScoreKey: Hashable {
        public let playerID: UUID
        public let holeNumber: Int
        
        public init(playerID: UUID, holeNumber: Int) {
            self.playerID = playerID
            self.holeNumber = holeNumber
        }
    }
}

// MARK: - Active Hole

/// Represents the currently active hole during play
public struct ActiveHole: Equatable {
    public let hole: Hole
    public let holeIndex: Int // zero-based index
    
    public init(hole: Hole, holeIndex: Int) {
        self.hole = hole
        self.holeIndex = holeIndex
    }
}

// MARK: - Calculation Input Mapper

/// Input for scoring engines with domain-appropriate types
public struct CalculationInput {
    public let players: [Player]
    public let holes: [Hole]
    /// Scores keyed by (playerID, holeNumber)
    public let scores: [RoundState.ScoreKey: Int]
    
    public init(players: [Player], holes: [Hole], scores: [RoundState.ScoreKey: Int]) {
        self.players = players
        self.holes = holes
        self.scores = scores
    }
    
    /// Factory from RoundState
    public static func from(roundState: RoundState) -> CalculationInput {
        return CalculationInput(players: roundState.definition.players,
                                holes: roundState.definition.tee.holes,
                                scores: roundState.scores)
    }
}

// MARK: - Scoring Engines

// MARK: Stableford Scorer

public struct StablefordScore {
    public let player: Player
    public let pointsPerHole: [Int: Int] // hole number to points
    public let totalPoints: Int
}

/// Stableford scoring engine
public struct Stableford {
    /// Calculate stableford points for each player
    /// Points allocation (example, can be adjusted):
    /// 0 points: 2+ over par
    /// 1 point: 1 over par
    /// 2 points: par
    /// 3 points: 1 under par
    /// 4 points: 2 under par
    /// 5 points: 3 under par or better
    public static func calculate(input: CalculationInput) -> [StablefordScore] {
        var results: [StablefordScore] = []
        
        for player in input.players {
            var pointsByHole: [Int: Int] = [:]
            var total = 0
            for hole in input.holes {
                let key = RoundState.ScoreKey(playerID: player.id, holeNumber: hole.number)
                if let strokes = input.scores[key] {
                    let diff = strokes - hole.par
                    let points = pointsFor(diff: diff)
                    pointsByHole[hole.number] = points
                    total += points
                } else {
                    pointsByHole[hole.number] = 0
                }
            }
            results.append(StablefordScore(player: player, pointsPerHole: pointsByHole, totalPoints: total))
        }
        
        return results
    }
    
    private static func pointsFor(diff: Int) -> Int {
        switch diff {
        case let x where x >= 2: return 0
        case 1: return 1
        case 0: return 2
        case -1: return 3
        case -2: return 4
        case let x where x <= -3: return 5
        default: return 0
        }
    }
}

// MARK: Skins Scorer

public struct SkinResult {
    public let player: Player
    public let skinsWon: Int
}

/// Skins scoring engine with carry-over
public struct Skins {
    /// Calculates skins winners per hole, carrying over if tied
    /// Returns total skins won per player
    public static func calculate(input: CalculationInput) -> [SkinResult] {
        var skinsWon: [UUID: Int] = [:]
        let holes = input.holes.sorted { $0.number < $1.number }
        var carryOver: Int = 0
        
        for hole in holes {
            var bestScore: Int? = nil
            var winners: [UUID] = []
            for player in input.players {
                let key = RoundState.ScoreKey(playerID: player.id, holeNumber: hole.number)
                guard let score = input.scores[key] else { continue }
                if bestScore == nil || score < bestScore! {
                    bestScore = score
                    winners = [player.id]
                } else if score == bestScore {
                    winners.append(player.id)
                }
            }
            
            if let best = bestScore {
                if winners.count == 1 {
                    // Single winner wins skins plus any carry over
                    let totalSkins = 1 + carryOver
                    skinsWon[winners[0], default: 0] += totalSkins
                    carryOver = 0
                } else {
                    // Tie, carry over skins
                    carryOver += 1
                }
            }
        }
        
        return input.players.map { player in
            SkinResult(player: player, skinsWon: skinsWon[player.id] ?? 0)
        }
    }
}

// MARK: Nassau Scorer

public struct NassauResult {
    public let player: Player
    public let frontNinePoints: Int
    public let backNinePoints: Int
    public let overallPoints: Int
}

/// Nassau scoring engine: points for front 9, back 9, and total
public struct Nassau {
    /// Calculates Nassau points for each player vs each other player
    /// Points earned are +1 for winning a 9-hole segment, 0 for tie, -1 for losing.
    ///
    /// Each player is scored against all others; sum of all points is returned.
    public static func calculate(input: CalculationInput) -> [NassauResult] {
        let holes = input.holes
        let frontNineHoles = holes.filter { $0.number >= 1 && $0.number <= 9 }
        let backNineHoles = holes.filter { $0.number >= 10 && $0.number <= 18 }
        
        // Sum of strokes per player per segment
        func sumStrokes(for player: Player, holes: [Hole]) -> Int {
            holes.reduce(0) { partial, hole in
                let key = RoundState.ScoreKey(playerID: player.id, holeNumber: hole.number)
                return partial + (input.scores[key] ?? 0)
            }
        }
        
        var results: [NassauResult] = []
        for player in input.players {
            var frontPoints = 0
            var backPoints = 0
            var overallPoints = 0
            
            for opponent in input.players where opponent.id != player.id {
                let playerFront = sumStrokes(for: player, holes: frontNineHoles)
                let oppFront = sumStrokes(for: opponent, holes: frontNineHoles)
                frontPoints += compareScores(playerScore: playerFront, opponentScore: oppFront)
                
                let playerBack = sumStrokes(for: player, holes: backNineHoles)
                let oppBack = sumStrokes(for: opponent, holes: backNineHoles)
                backPoints += compareScores(playerScore: playerBack, opponentScore: oppBack)
                
                let playerOverall = playerFront + playerBack
                let oppOverall = oppFront + oppBack
                overallPoints += compareScores(playerScore: playerOverall, opponentScore: oppOverall)
            }
            
            results.append(NassauResult(player: player,
                                       frontNinePoints: frontPoints,
                                       backNinePoints: backPoints,
                                       overallPoints: overallPoints))
        }
        
        return results
    }
    
    private static func compareScores(playerScore: Int, opponentScore: Int) -> Int {
        if playerScore < opponentScore { return 1 }
        else if playerScore > opponentScore { return -1 }
        else { return 0 }
    }
}

// MARK: KP (Closest to Pin) Scoring

public struct KPResult {
    public let player: Player
    public let holesWon: [Int]
    public let totalHolesWon: Int
}

/// KP game: player(s) closest to pin per hole win hole
public struct KP {
    /// Calculates KP winners per hole, tallies holes won per player
    /// kpWinners keyed by hole number to player IDs (support ties)
    public static func calculate(roundState: RoundState) -> [KPResult] {
        var winsCount: [UUID: [Int]] = [:]
        
        for (holeNumber, winners) in roundState.kpWinners {
            for winnerID in winners {
                winsCount[winnerID, default: []].append(holeNumber)
            }
        }
        
        return roundState.definition.players.map { player in
            let holes = winsCount[player.id] ?? []
            return KPResult(player: player, holesWon: holes, totalHolesWon: holes.count)
        }
    }
}

// MARK: Cara 'e Perro Scoring

public struct CaraEPerroResult {
    public let player: Player
    public let points: Int
}

/// Cara 'e Perro scoring engine
/// Enforces relative-to-lowest handicap logic internally
public struct CaraEPerro {
    /// Calculates points based on strokes adjusted by relative handicaps
    public static func calculate(input: CalculationInput) -> [CaraEPerroResult] {
        guard !input.players.isEmpty else { return [] }
        
        // Identify lowest handicap index
        guard let lowestHC = input.players.map({ $0.handicapIndex }).min() else {
            return []
        }
        
        var results: [CaraEPerroResult] = []
        
        for player in input.players {
            var totalPoints = 0
            for hole in input.holes {
                let key = RoundState.ScoreKey(playerID: player.id, holeNumber: hole.number)
                guard let strokes = input.scores[key] else { continue }
                
                // Adjust strokes by relative handicap
                let relativeHC = max(0, player.handicapIndex - lowestHC)
                let adjustedStrokes = Double(strokes) - relativeHC * handicapStrokeFactor(for: hole)
                
                // Example scoring: 1 point for adjusted stroke <= par, 0 otherwise
                if adjustedStrokes <= Double(hole.par) {
                    totalPoints += 1
                }
            }
            results.append(CaraEPerroResult(player: player, points: totalPoints))
        }
        
        return results
    }
    
    private static func handicapStrokeFactor(for hole: Hole) -> Double {
        // Example factor: 1 stroke per 18 handicap points, scaled by stroke index
        // More sophisticated models could be applied here
        return Double(hole.strokeIndex) / 18.0
    }
}

// MARK: - DemoCourseService

/// Provides demo data for testing and running without external dependencies
public struct DemoCourseService {
    public static func demoCourse() -> Course {
        let holes = (1...18).map { number in
            Hole(number: number,
                 par: defaultPar(for: number),
                 strokeIndex: defaultStrokeIndex(for: number))
        }
        let tee = Tee(name: "Demo Tee", holes: holes)
        return Course(name: "Demo Course", tees: [tee])
    }
    
    private static func defaultPar(for holeNumber: Int) -> Int {
        // Simple default pars pattern: 4 par 4s, 5 par 3s, 9 par 5s (example)
        switch holeNumber {
        case 1, 3, 5, 7, 9, 11, 13, 15, 17:
            return 4
        case 2, 6, 12, 16:
            return 3
        default:
            return 5
        }
    }
    
    private static func defaultStrokeIndex(for holeNumber: Int) -> Int {
        // Simple default stroke index 1-18 repeating
        return holeNumber
    }
}

// MARK: - Setup Wizard Steps

/// The wizard steps for starting a new round
public enum SetupStep: Int, CaseIterable {
    case players
    case roundDetails
    case games
    case review
}

// MARK: - Unit Tests

#if DEBUG
import XCTest

public final class GolfXTests: XCTestCase {
    let demoCourse = DemoCourseService.demoCourse()
    let player1 = Player(name: "Alice", handicapIndex: 10.0)
    let player2 = Player(name: "Bob", handicapIndex: 15.0)
    
    func testStablefordScoring() {
        let tee = demoCourse.tees[0]
        let definition = RoundDefinition(course: demoCourse, tee: tee, players: [player1, player2], games: [.stableford])
        var state = RoundState(definition: definition)
        // Both players score par on hole 1
        state.scores[RoundState.ScoreKey(playerID: player1.id, holeNumber: 1)] = 4
        state.scores[RoundState.ScoreKey(playerID: player2.id, holeNumber: 1)] = 4
        
        let input = CalculationInput.from(roundState: state)
        let scores = Stableford.calculate(input: input)
        XCTAssertEqual(scores.count, 2)
        XCTAssertEqual(scores[0].pointsPerHole[1], 2)
        XCTAssertEqual(scores[1].pointsPerHole[1], 2)
    }
    
    func testSkinsScoring() {
        let tee = demoCourse.tees[0]
        let definition = RoundDefinition(course: demoCourse, tee: tee, players: [player1, player2], games: [.skins])
        var state = RoundState(definition: definition)
        let keyP1 = RoundState.ScoreKey(playerID: player1.id, holeNumber: 1)
        let keyP2 = RoundState.ScoreKey(playerID: player2.id, holeNumber: 1)
        state.scores[keyP1] = 4
        state.scores[keyP2] = 5
        
        let input = CalculationInput.from(roundState: state)
        let skinsResults = Skins.calculate(input: input)
        
        XCTAssertEqual(skinsResults.first(where: { $0.player.id == player1.id })?.skinsWon, 1)
        XCTAssertEqual(skinsResults.first(where: { $0.player.id == player2.id })?.skinsWon, 0)
    }
    
    func testNassauScoring() {
        let tee = demoCourse.tees[0]
        let definition = RoundDefinition(course: demoCourse, tee: tee, players: [player1, player2], games: [.nassau])
        var state = RoundState(definition: definition)
        
        // Player 1 scores 4 on all front nine holes, Player 2 scores 5
        for hole in tee.holes where hole.number <= 9 {
            state.scores[RoundState.ScoreKey(playerID: player1.id, holeNumber: hole.number)] = 4
            state.scores[RoundState.ScoreKey(playerID: player2.id, holeNumber: hole.number)] = 5
        }
        // Back nine both score 4
        for hole in tee.holes where hole.number > 9 {
            state.scores[RoundState.ScoreKey(playerID: player1.id, holeNumber: hole.number)] = 4
            state.scores[RoundState.ScoreKey(playerID: player2.id, holeNumber: hole.number)] = 4
        }
        
        let input = CalculationInput.from(roundState: state)
        let results = Nassau.calculate(input: input)
        
        let p1Result = results.first(where: { $0.player.id == player1.id })
        let p2Result = results.first(where: { $0.player.id == player2.id })
        
        XCTAssertNotNil(p1Result)
        XCTAssertNotNil(p2Result)
        
        XCTAssertEqual(p1Result?.frontNinePoints, 1)
        XCTAssertEqual(p2Result?.frontNinePoints, -1)
        
        XCTAssertEqual(p1Result?.backNinePoints, 0)
        XCTAssertEqual(p2Result?.backNinePoints, 0)
    }
    
    func testKPCalculation() {
        let tee = demoCourse.tees[0]
        let definition = RoundDefinition(course: demoCourse, tee: tee, players: [player1, player2], games: [.kp])
        var state = RoundState(definition: definition)
        
        state.kpWinners[1] = [player1.id]
        state.kpWinners[2] = [player2.id]
        state.kpWinners[3] = [player1.id, player2.id] // tie hole
        
        let results = KP.calculate(roundState: state)
        
        let aliceResult = results.first(where: { $0.player.id == player1.id })!
        let bobResult = results.first(where: { $0.player.id == player2.id })!
        
        XCTAssertEqual(aliceResult.totalHolesWon, 2)
        XCTAssertEqual(bobResult.totalHolesWon, 2)
    }
    
    func testCaraEPerroCalculation() {
        let tee = demoCourse.tees[0]
        let definition = RoundDefinition(course: demoCourse, tee: tee, players: [player1, player2], games: [.caraEPerro])
        var state = RoundState(definition: definition)
        // Player1 scores 4 on all holes, Player2 scores 6
        for hole in tee.holes {
            state.scores[RoundState.ScoreKey(playerID: player1.id, holeNumber: hole.number)] = 4
            state.scores[RoundState.ScoreKey(playerID: player2.id, holeNumber: hole.number)] = 6
        }
        
        let input = CalculationInput.from(roundState: state)
        let results = CaraEPerro.calculate(input: input)
        
        let p1Points = results.first(where: { $0.player.id == player1.id })?.points ?? 0
        let p2Points = results.first(where: { $0.player.id == player2.id })?.points ?? 0
        
        XCTAssertTrue(p1Points > p2Points)
    }
}

#endif

//
//  TestDataLoader.swift
//  FairwayLab
//
//  Load test scorecard data from JSON files for manual testing
//

import Foundation

struct ScorecardTestData: Codable {
    let name: String
    let description: String
    let players: [PlayerData]
    let course: CourseData
    let tee: TeeData
    let isNineHole: Bool
    let isBackNine: Bool
    let selectedGames: [String]
    let handicapMode: String
    let scores: [String: [Int: Int]]  // playerName -> holeNumber -> score
    let putts: [String: [Int: Int]]?   // playerName -> holeNumber -> putts
    let kpWinners: [Int: String]?      // holeNumber -> playerName
    
    struct PlayerData: Codable {
        let name: String
        let handicap: Double
    }
    
    struct CourseData: Codable {
        let name: String
        let location: String?  // Optional - not used in Course model but kept for documentation
    }
    
    struct TeeData: Codable {
        let name: String
        let courseRating: Double
        let slope: Int
        let pars: [Int]
        let yardages: [Int]
        let strokeIndices: [Int]
    }
}

@MainActor
class TestDataLoader {
    
    /// Load test data from a JSON file in the app bundle
    static func loadTestData(filename: String) -> ScorecardTestData? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("❌ Test data file '\(filename).json' not found in bundle")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let testData = try JSONDecoder().decode(ScorecardTestData.self, from: data)
            print("✅ Loaded test data: \(testData.name)")
            return testData
        } catch {
            print("❌ Failed to decode test data: \(error)")
            return nil
        }
    }
    
    /// Convert test data to RoundDefinition and RoundState
    static func createRound(from testData: ScorecardTestData) -> (RoundDefinition, RoundState)? {
        // Create players
        let players = testData.players.map { Player(name: $0.name, handicap: $0.handicap) }
        
        // Create course (Course doesn't have location field)
        let course = Course(id: UUID(), name: testData.course.name, tees: [])
        
        // Create tee
        let tee = Tee(
            name: testData.tee.name,
            courseRating: testData.tee.courseRating,
            slope: testData.tee.slope,
            pars: testData.tee.pars,
            yardages: testData.tee.yardages,
            strokeIndices: testData.tee.strokeIndices
        )
        
        // Build holes
        let holes = HoleBuilder.buildHoles(
            from: tee,
            isNineHole: testData.isNineHole,
            isBackNine: testData.isBackNine
        )
        
        // Parse selected games
        let gameTypes = Set(testData.selectedGames.compactMap { GameType(rawValue: $0) })
        
        // Parse handicap mode
        guard let handicapMode = HandicapMode(rawValue: testData.handicapMode) else {
            print("❌ Invalid handicap mode: \(testData.handicapMode)")
            return nil
        }
        
        // Create round definition
        let roundDefinition = RoundDefinition(
            players: players,
            course: course,
            tee: tee,
            holes: holes,
            selectedGames: gameTypes,
            handicapMode: handicapMode,
            isNineHole: testData.isNineHole,
            isBackNine: testData.isBackNine
        )
        
        // Create round state
        var roundState = RoundState(players: players, holes: holes)
        
        // Create player name to ID mapping
        let playerMap = Dictionary(uniqueKeysWithValues: players.map { ($0.name, $0.id) })
        
        // Apply scores
        for (playerName, holeScores) in testData.scores {
            guard let playerId = playerMap[playerName] else {
                print("⚠️ Player '\(playerName)' not found")
                continue
            }
            
            for (holeNumber, score) in holeScores {
                if let hole = holes.first(where: { $0.actualHoleNumber == holeNumber }) {
                    roundState.setGrossScore(score, for: playerId, holeID: hole.id)
                }
            }
        }
        
        // Apply putts if provided
        if let puttsData = testData.putts {
            for (playerName, holePutts) in puttsData {
                guard let playerId = playerMap[playerName] else { continue }
                
                for (holeNumber, putts) in holePutts {
                    if let hole = holes.first(where: { $0.actualHoleNumber == holeNumber }) {
                        roundState.setPutts(putts, for: playerId, holeID: hole.id)
                    }
                }
            }
        }
        
        // Apply KP winners if provided
        if let kpData = testData.kpWinners {
            for (holeNumber, playerName) in kpData {
                guard let playerId = playerMap[playerName],
                      let hole = holes.first(where: { $0.actualHoleNumber == holeNumber }) else {
                    continue
                }
                roundState.setKPWinner(playerId, for: hole.id)
            }
        }
        
        print("✅ Created round from test data with \(players.count) players and \(holes.count) holes")
        return (roundDefinition, roundState)
    }
    
    /// List all available test data files
    static func listAvailableTestData() -> [String] {
        guard let bundleURL = Bundle.main.resourceURL else { return [] }
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(
                at: bundleURL,
                includingPropertiesForKeys: nil
            )
            
            return contents
                .filter { $0.pathExtension == "json" && $0.lastPathComponent.hasPrefix("scorecard_") }
                .map { $0.deletingPathExtension().lastPathComponent }
        } catch {
            print("❌ Failed to list test data files: \(error)")
            return []
        }
    }
}

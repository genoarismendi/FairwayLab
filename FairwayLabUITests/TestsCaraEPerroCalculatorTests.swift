//
//  CaraEPerroCalculatorTests.swift
//  GolfXTests
//
//  Unit tests for Cara 'e Perro calculations
//

import XCTest
@testable import GolfX

final class CaraEPerroCalculatorTests: XCTestCase {
    
    func testCaraEPerroSpecExample() async throws {
        // Players: A(hcp 8), B(hcp 4), C(hcp 25), D(hcp 13)
        // Hole 1, SI=5, strokes: A=4, B=6, C=5, D=5
        // Expected result: A=+1, B=-3, C=+2, D=0
        
        let playerA = Player(name: "A", handicap: 8.0)
        let playerB = Player(name: "B", handicap: 4.0)
        let playerC = Player(name: "C", handicap: 25.0)
        let playerD = Player(name: "D", handicap: 13.0)
        
        let players = [playerA, playerB, playerC, playerD]
        
        let hole1 = HoleDefinition(actualHoleNumber: 1, displayOrder: 1, par: 4, strokeIndex: 5, yardage: 400)
        let holes = [hole1]
        
        let scores: [UUID: [UUID: Int]] = [
            playerA.id: [hole1.id: 4],
            playerB.id: [hole1.id: 6],
            playerC.id: [hole1.id: 5],
            playerD.id: [hole1.id: 5]
        ]
        
        let input = CalculationInput(
            players: players,
            holes: holes,
            handicapMode: .relativeToLowest,
            scores: scores,
            kpWinners: [:]
        )
        
        let tee = Tee(
            name: "Test",
            courseRating: 72.0,
            slope: 113,
            pars: [4],
            yardages: [400],
            strokeIndices: [5]
        )
        
        let result = CaraEPerroCalculator.calculate(input: input, tee: tee)
        
        // Verify hole points
        XCTAssertEqual(result.holeResults[0].playerHolePoints[playerA.id], 1, "A should score +1")
        XCTAssertEqual(result.holeResults[0].playerHolePoints[playerB.id], -3, "B should score -3")
        XCTAssertEqual(result.holeResults[0].playerHolePoints[playerC.id], 2, "C should score +2")
        XCTAssertEqual(result.holeResults[0].playerHolePoints[playerD.id], 0, "D should score 0")
        
        // Verify cumulative points (same as hole points since it's the first hole)
        XCTAssertEqual(result.totalPoints(for: playerA.id), 1)
        XCTAssertEqual(result.totalPoints(for: playerB.id), -3)
        XCTAssertEqual(result.totalPoints(for: playerC.id), 2)
        XCTAssertEqual(result.totalPoints(for: playerD.id), 0)
        
        // Verify sum equals 0
        let total = result.playerCumulativePoints.values.reduce(0, +)
        XCTAssertEqual(total, 0, "Sum of all points should be 0")
    }
    
    func testCaraEPerroTwoPlayersWithStroke() async throws {
        let playerLow = Player(name: "Low", handicap: 5.0)
        let playerHigh = Player(name: "High", handicap: 15.0)
        
        let players = [playerLow, playerHigh]
        
        // Handicap delta = 10, stroke index = 5
        // 10 >= 5, so lower handicap player gets +1 stroke
        let hole = HoleDefinition(actualHoleNumber: 1, displayOrder: 1, par: 4, strokeIndex: 5, yardage: 400)
        let holes = [hole]
        
        // Low: 4 gross → 5 adjusted (gets +1 stroke)
        // High: 6 gross → 6 adjusted (no adjustment)
        // High wins: Low gets -1, High gets +1
        let scores: [UUID: [UUID: Int]] = [
            playerLow.id: [hole.id: 4],
            playerHigh.id: [hole.id: 6]
        ]
        
        let input = CalculationInput(
            players: players,
            holes: holes,
            handicapMode: .relativeToLowest,
            scores: scores,
            kpWinners: [:]
        )
        
        let tee = Tee(
            name: "Test",
            courseRating: 72.0,
            slope: 113,
            pars: [4],
            yardages: [400],
            strokeIndices: [5]
        )
        
        let result = CaraEPerroCalculator.calculate(input: input, tee: tee)
        
        XCTAssertEqual(result.holeResults[0].playerHolePoints[playerLow.id], -1, "Low player adjusted to 5, should lose")
        XCTAssertEqual(result.holeResults[0].playerHolePoints[playerHigh.id], 1, "High player stays at 6, should win")
        
        // Verify sum equals 0
        let total = result.holeResults[0].playerHolePoints.values.reduce(0, +)
        XCTAssertEqual(total, 0, "Sum should be 0")
    }
    
    func testCaraEPerroTwoPlayersNoStroke() async throws {
        let playerLow = Player(name: "Low", handicap: 5.0)
        let playerHigh = Player(name: "High", handicap: 15.0)
        
        let players = [playerLow, playerHigh]
        
        // Handicap delta = 10, stroke index = 15
        // 10 < 15, so no stroke adjustment
        let hole = HoleDefinition(actualHoleNumber: 1, displayOrder: 1, par: 4, strokeIndex: 15, yardage: 400)
        let holes = [hole]
        
        // Low: 4 gross → 4 adjusted (no adjustment)
        // High: 6 gross → 6 adjusted (no adjustment)
        // Low wins: Low gets +1, High gets -1
        let scores: [UUID: [UUID: Int]] = [
            playerLow.id: [hole.id: 4],
            playerHigh.id: [hole.id: 6]
        ]
        
        let input = CalculationInput(
            players: players,
            holes: holes,
            handicapMode: .relativeToLowest,
            scores: scores,
            kpWinners: [:]
        )
        
        let tee = Tee(
            name: "Test",
            courseRating: 72.0,
            slope: 113,
            pars: [4],
            yardages: [400],
            strokeIndices: [15]
        )
        
        let result = CaraEPerroCalculator.calculate(input: input, tee: tee)
        
        XCTAssertEqual(result.holeResults[0].playerHolePoints[playerLow.id], 1, "Low player should win")
        XCTAssertEqual(result.holeResults[0].playerHolePoints[playerHigh.id], -1, "High player should lose")
        
        // Verify sum equals 0
        let total = result.holeResults[0].playerHolePoints.values.reduce(0, +)
        XCTAssertEqual(total, 0, "Sum should be 0")
    }
    
    func testCaraEPerroCumulativeScoring() async throws {
        let playerA = Player(name: "A", handicap: 10.0)
        let playerB = Player(name: "B", handicap: 20.0)
        
        let players = [playerA, playerB]
        
        let hole1 = HoleDefinition(actualHoleNumber: 1, displayOrder: 1, par: 4, strokeIndex: 5, yardage: 400)
        let hole2 = HoleDefinition(actualHoleNumber: 2, displayOrder: 2, par: 3, strokeIndex: 10, yardage: 180)
        let holes = [hole1, hole2]
        
        let scores: [UUID: [UUID: Int]] = [
            playerA.id: [hole1.id: 4, hole2.id: 3],
            playerB.id: [hole1.id: 5, hole2.id: 4]
        ]
        
        let input = CalculationInput(
            players: players,
            holes: holes,
            handicapMode: .relativeToLowest,
            scores: scores,
            kpWinners: [:]
        )
        
        let tee = Tee(
            name: "Test",
            courseRating: 72.0,
            slope: 113,
            pars: [4, 3],
            yardages: [400, 180],
            strokeIndices: [5, 10]
        )
        
        let result = CaraEPerroCalculator.calculate(input: input, tee: tee)
        
        // Hole 1: delta=10, SI=5, 10>=5 so A gets +1 stroke → A:5 vs B:5 = tie (0,0)
        XCTAssertEqual(result.holeResults[0].playerHolePoints[playerA.id], 0, "Hole 1 should be a tie")
        XCTAssertEqual(result.holeResults[0].playerHolePoints[playerB.id], 0, "Hole 1 should be a tie")
        
        // Hole 2: delta=10, SI=10, 10>=10 so A gets +1 stroke → A:4 vs B:4 = tie (0,0)
        XCTAssertEqual(result.holeResults[1].playerHolePoints[playerA.id], 0, "Hole 2 should be a tie")
        XCTAssertEqual(result.holeResults[1].playerHolePoints[playerB.id], 0, "Hole 2 should be a tie")
        
        // Verify cumulative equals 0 for both
        XCTAssertEqual(result.totalPoints(for: playerA.id), 0)
        XCTAssertEqual(result.totalPoints(for: playerB.id), 0)
    }
}

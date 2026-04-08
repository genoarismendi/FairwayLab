//
//  HandicapCalculatorTests.swift
//  GolfXTests
//
//  Unit tests for handicap calculations
//

import XCTest
@testable import GolfX

final class HandicapCalculatorTests: XCTestCase {
    
    func testCourseHandicapCalculation() async throws {
        // Test case 1: Standard calculation
        let ch1 = HandicapCalculator.calculateCourseHandicap(
            handicapIndex: 10.0,
            slope: 113,
            courseRating: 72.0,
            par: 72
        )
        XCTAssertEqual(ch1, 10, "10 index on neutral slope/rating should be 10")
        
        // Test case 2: Higher slope
        let ch2 = HandicapCalculator.calculateCourseHandicap(
            handicapIndex: 10.0,
            slope: 130,
            courseRating: 72.0,
            par: 72
        )
        XCTAssertEqual(ch2, 12, "10 index on 130 slope should be about 12")
        
        // Test case 3: Course rating different from par
        let ch3 = HandicapCalculator.calculateCourseHandicap(
            handicapIndex: 10.0,
            slope: 113,
            courseRating: 73.5,
            par: 72
        )
        XCTAssertEqual(ch3, 12, "Should add rating-par difference")
    }
    
    func testAbsoluteHandicapMode() async throws {
        let players = [
            Player(name: "Low", handicap: 5.0),
            Player(name: "Mid", handicap: 15.0),
            Player(name: "High", handicap: 25.0)
        ]
        
        let playingHandicaps = HandicapCalculator.calculatePlayingHandicaps(
            players: players,
            slope: 113,
            courseRating: 72.0,
            par: 72,
            mode: .absolute
        )
        
        XCTAssertEqual(playingHandicaps[players[0].id], 5)
        XCTAssertEqual(playingHandicaps[players[1].id], 15)
        XCTAssertEqual(playingHandicaps[players[2].id], 25)
    }
    
    func testRelativeHandicapMode() async throws {
        let players = [
            Player(name: "Low", handicap: 5.0),
            Player(name: "Mid", handicap: 15.0),
            Player(name: "High", handicap: 25.0)
        ]
        
        let playingHandicaps = HandicapCalculator.calculatePlayingHandicaps(
            players: players,
            slope: 113,
            courseRating: 72.0,
            par: 72,
            mode: .relativeToLowest
        )
        
        XCTAssertEqual(playingHandicaps[players[0].id], 0, "Lowest player gets 0")
        XCTAssertEqual(playingHandicaps[players[1].id], 10, "Mid player gets difference")
        XCTAssertEqual(playingHandicaps[players[2].id], 20, "High player gets difference")
    }
    
    func testStrokeAllocation() async throws {
        // Test with 9 strokes on 18 holes
        let strokes1 = HandicapCalculator.strokesOnHole(
            playingHandicap: 9,
            strokeIndex: 5,
            totalHoles: 18
        )
        XCTAssertEqual(strokes1, 1, "Stroke index 5 should get 1 stroke with 9 handicap")
        
        let strokes2 = HandicapCalculator.strokesOnHole(
            playingHandicap: 9,
            strokeIndex: 10,
            totalHoles: 18
        )
        XCTAssertEqual(strokes2, 0, "Stroke index 10 should get 0 strokes with 9 handicap")
        
        // Test with 20 strokes (more than holes)
        let strokes3 = HandicapCalculator.strokesOnHole(
            playingHandicap: 20,
            strokeIndex: 5,
            totalHoles: 18
        )
        XCTAssertEqual(strokes3, 2, "Should get 2 strokes when handicap > holes")
    }
}

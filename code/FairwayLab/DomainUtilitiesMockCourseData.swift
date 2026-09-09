//
//  MockCourseData.swift
//  GolfX
//
//  Mock course data for development and testing
//

import Foundation

struct MockCourseData {
    
    static let sampleTee1 = Tee(
        name: "Blue Tees",
        courseRating: 72.5,
        slope: 130,
        pars: [4, 4, 3, 5, 4, 4, 3, 5, 4, 4, 4, 3, 5, 4, 4, 3, 5, 4],
        yardages: [380, 420, 175, 520, 400, 390, 165, 545, 410, 395, 425, 180, 530, 405, 415, 170, 550, 425],
        strokeIndices: [7, 3, 17, 1, 11, 9, 15, 5, 13, 8, 4, 18, 2, 12, 6, 16, 10, 14]
    )
    
    static let sampleTee2 = Tee(
        name: "White Tees",
        courseRating: 70.8,
        slope: 125,
        pars: [4, 4, 3, 5, 4, 4, 3, 5, 4, 4, 4, 3, 5, 4, 4, 3, 5, 4],
        yardages: [360, 400, 160, 500, 380, 370, 150, 525, 390, 375, 405, 165, 510, 385, 395, 155, 530, 405],
        strokeIndices: [7, 3, 17, 1, 11, 9, 15, 5, 13, 8, 4, 18, 2, 12, 6, 16, 10, 14]
    )
    
    static let sampleTee3 = Tee(
        name: "Red Tees",
        courseRating: 68.5,
        slope: 118,
        pars: [4, 4, 3, 5, 4, 4, 3, 5, 4, 4, 4, 3, 5, 4, 4, 3, 5, 4],
        yardages: [330, 370, 140, 470, 350, 340, 130, 495, 360, 345, 375, 145, 480, 355, 365, 135, 500, 375],
        strokeIndices: [7, 3, 17, 1, 11, 9, 15, 5, 13, 8, 4, 18, 2, 12, 6, 16, 10, 14]
    )
    
    static let sampleCourse1 = Course(
        name: "Pine Valley Golf Club",
        tees: [sampleTee1, sampleTee2, sampleTee3]
    )
    
    static let sampleCourse2 = Course(
        name: "Ocean View Country Club",
        tees: [
            Tee(
                name: "Championship",
                courseRating: 73.2,
                slope: 135,
                pars: [4, 5, 3, 4, 4, 5, 3, 4, 4, 4, 4, 3, 5, 4, 4, 3, 5, 4],
                yardages: [400, 540, 185, 410, 425, 560, 175, 435, 420, 405, 440, 190, 545, 415, 430, 180, 565, 435],
                strokeIndices: [9, 3, 15, 7, 5, 1, 17, 11, 13, 10, 4, 16, 2, 12, 6, 18, 8, 14]
            )
        ]
    )
    
    static let allCourses = [sampleCourse1, sampleCourse2]
    
    static let samplePlayers = [
        Player(name: "Alice", handicap: 10.5),
        Player(name: "Bob", handicap: 18.2),
        Player(name: "Charlie", handicap: 5.0),
        Player(name: "Diana", handicap: 22.8)
    ]
}

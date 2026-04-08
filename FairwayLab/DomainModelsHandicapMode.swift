//
//  HandicapMode.swift
//  GolfX
//
//  Enum representing handicap application modes
//

import Foundation

enum HandicapMode: String, CaseIterable, Codable {
    case absolute = "Absolute Course Handicap"
    case relativeToLowest = "Relative to Lowest"
    
    var displayName: String { rawValue }
    
    var description: String {
        switch self {
        case .absolute:
            return "Each player receives their full course handicap"
        case .relativeToLowest:
            return "Players receive strokes relative to the lowest handicap in the group"
        }
    }
}

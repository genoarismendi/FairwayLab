//
//  GameType.swift
//  GolfX
//
//  Enum representing available scoring games
//

import Foundation

enum GameType: String, Identifiable, CaseIterable, Codable {
    case stableford = "Stableford"
    case skins = "Skins"
    case nassau = "Nassau"
    case kp = "KP"
    case caraEPerro = "Cara 'e Perro"
    
    var id: String { rawValue }
    
    var displayName: String { rawValue }
    
    var requiresValidStrokeIndex: Bool {
        switch self {
        case .caraEPerro:
            return true
        default:
            return false
        }
    }
}

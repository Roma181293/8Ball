//
//  AnswerType.swift
//  8 Ball
//
//  Created by Roman Topchii on 19.02.2022.
//

import Foundation

enum AnswerType: Int, CaseIterable {
    case unknown = 0
    case neutral = 1
    case contrary = 2
    case affirmative = 3
    
    init(fromString: String) {
        switch fromString {
        case "Affirmative": self = .affirmative
        case "Neutral": self = .neutral
        case "Contrary": self = .contrary
        default: self = .unknown
        }
    }
    
    func toEmoji() -> String {
        switch self {
        case .unknown: return "😳"
        case .neutral: return "😐"
        case .contrary: return "🙁"
        case .affirmative: return "🙂"
        }
    }
    
    func toString() -> String {
        switch self {
        case .affirmative: return "Affirmative"
        case .neutral: return "Neutral"
        case .contrary: return "Contrary"
        default: return "Unknown"
        }
    }
}

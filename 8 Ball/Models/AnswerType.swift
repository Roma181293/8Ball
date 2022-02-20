//
//  AnswerType.swift
//  8 Ball
//
//  Created by Roman Topchii on 19.02.2022.
//

import Foundation

enum AnswerType: Int16, CaseIterable {
    case unknown = 0
    case neutral = 1
    case contrary = 2
    case affirmative = 3
    
    
    init(rawValue value: Int16) {
        switch value {
        case 0: self = .unknown
        case 1: self = .neutral
        case 2: self = .contrary
        case 3: self = .affirmative
        default: self = .unknown
        }
    }
    
    init(fromString: String){
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

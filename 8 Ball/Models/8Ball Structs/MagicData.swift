//
//  MagicData.swift
//  8 Ball
//
//  Created by Roman Topchii on 13.01.2022.
//

import Foundation

struct MagicData: Codable {
    let magic: Magic
    func getType() -> AnswerType {
        switch magic.type {
        case "Contrary": return .contrary //"🙁"
        case "Affirmative": return .affirmative //"🙂"
        case "Neutral": return .neutral //"😐"
        default: return .unknown //"😳"
        }
    }
}


//
//  RemotePredictionData.swift
//  8 Ball
//
//  Created by Roman Topchii on 13.01.2022.
//

import Foundation

struct RemotePredictionData: Decodable {
    let prediction: RemotePrediction
    
    enum CodingKeys: String, CodingKey {
        case prediction = "magic"
    }
}

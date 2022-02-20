//
//  PredictionProvider.swift
//  8 Ball
//
//  Created by Roman Topchii on 19.02.2022.
//

import Foundation

protocol PredictionProvider {
    func getPredictionForQuestion(_ question : String?, completion: @escaping ((Predictible?, Error?) -> Void))
}

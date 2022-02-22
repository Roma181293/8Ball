//
//  PredictionHistoryManager.swift
//  8 Ball
//
//  Created by Roman Topchii on 15.01.2022.
//

import Foundation
import CoreData


class PredictionHistoryManager {
    static func createPrediction(question: String, answer: Answer, context: NSManagedObjectContext) {
        let prediction = PredictionHistory(context: context)
        prediction.answer = answer
        prediction.date = Date()
        prediction.question = question
    }
    
    static func deletePrediction(_ prediction: PredictionHistory, context: NSManagedObjectContext) {
        context.delete(prediction)
    }
}

//
//  DBPredictionProvider.swift
//  8 Ball
//
//  Created by Roman Topchii on 19.02.2022.
//

import Foundation
import CoreData

class DBPredictionService: PredictionProvider {
    
    private var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func getPredictionForQuestion(_ question : String? = nil, completion: @escaping ((Predictible?, Error?) -> Void)) {
        if let randomAnswer = AnswerManager.getRandomAnswer(context: context) {
            completion(Prediction(question: question, answer: randomAnswer), nil)
        }
        else {
            completion (nil, PredictionServiceError.customAnswerNotFound)
        }
    }
}

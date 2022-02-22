//
//  Prediction.swift
//  8 Ball
//
//  Created by Roman Topchii on 19.02.2022.
//

import Foundation

protocol Predictible {
    func getType() -> AnswerType
    func getAnswer() -> String
    func getQuestion() -> String?
}

struct Prediction: Predictible {
    private var question: String?
    private var answer: String
    private var type: AnswerType
    
    init(remotePrediction: RemotePrediction) {
        self.question = remotePrediction.question
        self.answer = remotePrediction.answer
        self.type = AnswerType(fromString: remotePrediction.type)
    }
    
    init(question: String?, answer: Answer) {
        self.question = question
        self.answer = answer.title ?? ""
        self.type = AnswerType(rawValue: answer.type) ?? .unknown
    }
    
    func getType() -> AnswerType {
        return type
    }
    
    func getAnswer() -> String {
        return answer
    }
    
    func getQuestion() -> String? {
        return question == "DefaultQuestion" ? nil : question
    }
}

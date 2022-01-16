//
//  PredictionService.swift
//  8 Ball
//
//  Created by Roman Topchii on 14.01.2022.
//

import Foundation

enum PredictionMode{
    case question
    case blitz
}

enum AnswerType: Int16{
    case affirmative = 0 // "🙂"
    case neutral = 1 // "😐"
    case contrary = 2 // "🙁"
    case unknown = 3 // "😳"
}


protocol PredictionDelegate {
    func setPredictionMode(_ mode: PredictionMode)
    func presentPrediction(answer: String, type: AnswerType)
    func errorHandler(error: Error)
}

class PredictionService {
    
    private let cdm = CoreDataManager.shared
    private var isWaitingForPrediction: Bool = false
    private var isReadyToShow: Bool = false
    private var useCustomAnswers: Bool = false
    private var mode: PredictionMode = .blitz
    
    private var question: String?
    private var answer: String?
    private var answerType: AnswerType?
    
    var delegate:PredictionDelegate?{
        didSet{
            delegate?.setPredictionMode(mode)
        }
    }
    
    init(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.setUseCustomAnswers), name: .useCustomAnswers, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.setDoNotUseCustomAnswers), name: .doNotUseCustomAnswers, object: nil)
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self, name: .useCustomAnswers, object: nil)
        NotificationCenter.default.removeObserver(self, name: .doNotUseCustomAnswers, object: nil)
    }
    
    @objc private func setUseCustomAnswers() {
        useCustomAnswers = true
    }
    
    @objc private func setDoNotUseCustomAnswers() {
        useCustomAnswers = false
    }
    
    
    public func newQuestion(_ question: String) throws {
        guard !isWaitingForPrediction else {throw PredictionServiceError.predictionInProgress}
        guard !question.isEmpty else {throw PredictionServiceError.emptyQuestion}
        guard mode == .question else {return}
        self.question = question
        answer = nil
        answerType = nil
    }
    
    public func changePredictionMode() throws {
        guard !isWaitingForPrediction else {throw PredictionServiceError.predictionInProgress}
        if mode == .question {
            mode = .blitz
        }
        else {
            mode = .question
        }
        isReadyToShow = false
        question = nil
        answer = nil
        answerType = nil
        
        delegate?.setPredictionMode(mode)
    }
    
    public func predict() throws {
        
        if mode == .blitz {
            question = nil
        }
        else if mode == .question && (question == nil || question?.isEmpty==true){
            throw PredictionServiceError.noQuestion
        }
        
        isWaitingForPrediction = true
        
        if useCustomAnswers {
         
           try customPrediction()
            
        }
        else {
           try servicePrediction()
        }
    }
    
    public func showPrediction() {
        self.isReadyToShow = true
        guard !isWaitingForPrediction, let answer = answer, let answerType = answerType else {return}
        self.delegate?.presentPrediction(answer: answer, type: answerType)
        self.isReadyToShow = false
    }
    
    private func servicePrediction() throws {
        EightBallPredictionService.getPredictionForQuestion(question, completion: {(magicData, error) in
            
            self.isWaitingForPrediction = false
            
            if let error = error {
                self.delegate?.errorHandler(error: error)
                self.isReadyToShow = false
            }
            if let magicData = magicData {
                
                let answerNew = magicData.magic.answer
                let typeNew = magicData.getType()
                
                if self.mode == .question {
                    //Add question with answer to the DB
                    do {
                        
                        let context = CoreDataManager.shared.persistentContainer.newBackgroundContext()
                        
                        let storedAnswer = AnswerManager.getOrCreateAnswer(answerNew, type: typeNew, createdByUser: false, context: context)
                        PredictionHistoryManager.createPediction(question: self.question!, answer: storedAnswer, context: context)
                        try self.cdm.saveContext(context)
                    }
                    catch let error {
                        self.delegate?.errorHandler(error: error)
                    }
                }
                
                if self.isReadyToShow {
                    self.delegate?.presentPrediction(answer: magicData.magic.answer, type: magicData.getType())
                    self.isReadyToShow = false
                }
                self.answer = answerNew
                self.answerType = typeNew
                print(#function,"Bot answer", answerNew, typeNew)
            }
        })
    }
    private func customPrediction() throws {
        self.isWaitingForPrediction = false
        let context = CoreDataManager.shared.persistentContainer.viewContext

        if let ans = AnswerManager.getRandomAnswer(context: context) {
            if self.mode == .question {
    
                PredictionHistoryManager.createPediction(question: self.question!, answer: ans, context: context)
                try self.cdm.saveContext(context)
            
            }
            if self.isReadyToShow {
                self.delegate?.presentPrediction(answer: ans.title!, type: answerType ?? .unknown)
                self.isReadyToShow = false
            }
            self.answer = ans.title
            switch ans.type {
            case AnswerType.affirmative.rawValue: self.answerType = .affirmative
            case AnswerType.contrary.rawValue: self.answerType = .contrary
            case AnswerType.neutral.rawValue: self.answerType = .neutral
            case AnswerType.unknown.rawValue: self.answerType = .unknown
            default: self.answerType = nil
            }
            print(#function,"Custom answer", answer, answerType)
            
        }
        else {
            throw PredictionServiceError.customAnswerNotFound
        }
    }
}

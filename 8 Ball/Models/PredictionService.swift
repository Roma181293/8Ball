//
//  PredictionService.swift
//  8 Ball
//
//  Created by Roman Topchii on 14.01.2022.
//

import Foundation

enum PredictionServiceMode{
    case question
    case blitz
}

protocol PredictionServiceDelegate {
    func setPredictionMode(_ mode: PredictionServiceMode)
    func showPrediction(answer: String, type: AnswerType)
    func errorHandler(error: Error)
}

class PredictionService {
    
    private let coreDataManager = CoreDataManager.shared
    private var predictionProvider: PredictionProvider?
    
    private var delegate:PredictionServiceDelegate{
        didSet{
            delegate.setPredictionMode(mode)
        }
    }
    
    private var isWaitingForPrediction: Bool = false
    private var isReadyToShow: Bool = false
    private var useCustomAnswers: Bool = false
    private var mode: PredictionServiceMode = .blitz
    
    private var question: String?
    private var answer: String?
    private var answerType: AnswerType?
    
    init(delegate: PredictionServiceDelegate) {
        self.delegate = delegate
        delegate.setPredictionMode(mode)
        self.predictionProvider = RemotePredictionService(networkDataProvider: NetworkService())
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.setUseCustomAnswers), name: .useCustomAnswers, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.setDoNotUseCustomAnswers), name: .doNotUseCustomAnswers, object: nil)
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self, name: .useCustomAnswers, object: nil)
        NotificationCenter.default.removeObserver(self, name: .doNotUseCustomAnswers, object: nil)
    }
    
    @objc private func setUseCustomAnswers() {
        useCustomAnswers = true
        predictionProvider = DBPredictionService(context: coreDataManager.persistentContainer.viewContext)
    }
    
    @objc private func setDoNotUseCustomAnswers() {
        useCustomAnswers = false
        predictionProvider = RemotePredictionService(networkDataProvider: NetworkService())
    }
    
    //For test purpose only
    public func setPredictionProvider(_ predictionProvider: PredictionProvider) {
        self.predictionProvider = predictionProvider
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
        
        delegate.setPredictionMode(mode)
    }
    
    public func predict() throws {
        
        if mode == .blitz {
            question = nil
        }
        else if mode == .question && (question == nil || question?.isEmpty==true){
            throw PredictionServiceError.noQuestion
        }
        
        isWaitingForPrediction = true
        
        predictionProvider?.getPredictionForQuestion(question, completion: {(prediction, error) in
            
            self.isWaitingForPrediction = false
            
            if let error = error {
                self.delegate.errorHandler(error: error)
                self.isReadyToShow = false
            }
            
            if let prediction = prediction {
                
                let answerNew = prediction.getAnswer()
                let typeNew = prediction.getType()
                
                if self.mode == .question {
                    //Add question with answer to the DB
                    do {
                        
                        let context = CoreDataManager.shared.persistentContainer.newBackgroundContext()
                        
                        let storedAnswer = AnswerManager.getOrCreateAnswer(answerNew, type: typeNew, createdByUser: self.useCustomAnswers, context: context)
                        PredictionHistoryManager.createPrediction(question: self.question!, answer: storedAnswer, context: context)
                        try self.coreDataManager.saveContext(context)
                    }
                    catch let error {
                        self.delegate.errorHandler(error: error)
                    }
                }
                
                if self.isReadyToShow {
                    self.delegate.showPrediction(answer: prediction.getAnswer(), type: prediction.getType())
                    self.isReadyToShow = false
                }
                self.answer = answerNew
                self.answerType = typeNew
            }
        })
    }
    
    public func showPrediction() {
        self.isReadyToShow = true
        guard !isWaitingForPrediction, let answer = answer, let answerType = answerType else {return}
        self.delegate.showPrediction(answer: answer, type: answerType)
        self.isReadyToShow = false
    }
}

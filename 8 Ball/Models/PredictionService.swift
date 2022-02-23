//
//  PredictionService.swift
//  8 Ball
//
//  Created by Roman Topchii on 14.01.2022.
//

import Foundation

enum PredictionServiceMode {
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
    private var predictionProvider: PredictionProvider
    
    private var delegate: PredictionServiceDelegate {
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
    
    init(delegate: PredictionServiceDelegate, predictionProvider: PredictionProvider) {
        self.delegate = delegate
        self.predictionProvider = predictionProvider
        delegate.setPredictionMode(mode)
        NotificationCenter.default.addObserver(self, selector: #selector(self.changePredictionProvider(notification:)), name: .changePredictionProvider, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.getIsUseCustomAnswers), name: .getIsUseCustomAnswers, object: nil)
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self, name: .changePredictionProvider, object: nil)
        NotificationCenter.default.removeObserver(self, name: .getIsUseCustomAnswers, object: nil)
    }
    
    @objc private func getIsUseCustomAnswers() {
        NotificationCenter.default.post(name: .setUseCustomAnswersTo, object: nil, userInfo: ["setUseCustomAnswersTo": useCustomAnswers])
    }
    
    @objc private func changePredictionProvider(notification: NSNotification) {
        if let predictionProvider = notification.userInfo?["predictionProvider"] as? PredictionProvider {
            self.predictionProvider = predictionProvider
            
            if predictionProvider is UserAnswerPredictionProvider {
                useCustomAnswers = true
            }
            else {
                useCustomAnswers = false
            }
        }
        else {
            delegate.errorHandler(error: PredictionServiceError.attributeDoesNotConformPredictionProviderProtocol)
        }
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
        else if mode == .question && (question == nil || question?.isEmpty==true) {
            throw PredictionServiceError.noQuestion
        }
        
        isWaitingForPrediction = true
        
        predictionProvider.getPredictionForQuestion(question, completion: { [weak self] (prediction, error) in
            guard let self = self else {return}
            self.isWaitingForPrediction = false
            
            if let error = error {
                self.delegate.errorHandler(error: error)
                self.isReadyToShow = false
            }
            
            if let prediction = prediction {
                let answerNew = prediction.getAnswer()
                let typeNew = prediction.getType()
                if self.mode == .question {
                    //Add prediction to the DB
                    do {
                        let context = self.coreDataManager.persistentContainer.newBackgroundContext()
                        let storedAnswer = AnswerManager(context: context).getOrCreateAnswer(answerNew, type: typeNew, createdByUser: self.useCustomAnswers)
                        try PredictionHistoryManager(context: context).createPrediction(question: self.question!, answer: storedAnswer)
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
        isReadyToShow = true
        guard !isWaitingForPrediction, let answer = answer, let answerType = answerType else {return}
        delegate.showPrediction(answer: answer, type: answerType)
        isReadyToShow = false
    }
}

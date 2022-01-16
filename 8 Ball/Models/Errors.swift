//
//  Errors.swift
//  8 Ball
//
//  Created by Roman Topchii on 14.01.2022.
//

import Foundation

enum ResponseError: Error {
    case noData
}

extension ResponseError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noData : return NSLocalizedString("There is no data in service response", comment: "")
        }
    }
}

enum URLError: Error {
    case invalidURL(url: String)
}

extension URLError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .invalidURL(url) : return String(format: NSLocalizedString("Invalid URL %@.", comment: ""),url)
        }
    }
}

enum PredictionServiceError: Error {
    case predictionInProgress
    case emptyQuestion
    case noQuestion
    case customAnswerNotFound
}

extension PredictionServiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .predictionInProgress : return NSLocalizedString("I'm thinkig about your question. Please wait", comment: "")
        case .emptyQuestion : return NSLocalizedString("Please enter question", comment: "")
        case .noQuestion: return NSLocalizedString("There is no question. Please add your question", comment: "")
        case .customAnswerNotFound: return NSLocalizedString("Custom answer not found. Please add them", comment: "")
        }
    }
}

enum AnswerError : Error {
    case answerUsedInPrediction
    case emptyAnswer
    case answerAlreadyExists
}
extension AnswerError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .answerUsedInPrediction : return NSLocalizedString("Answer used in prediction", comment: "")
        case .emptyAnswer : return NSLocalizedString("Please enter answer", comment: "")
        case .answerAlreadyExists: return NSLocalizedString("This answer already exists", comment: "")
        }
    }
}

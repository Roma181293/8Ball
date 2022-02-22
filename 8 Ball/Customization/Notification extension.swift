//
//  Notification extension.swift
//  8 Ball
//
//  Created by Roman Topchii on 15.01.2022.
//

import Foundation


extension Notification.Name {
    static let getIsUseCustomAnswers = Notification.Name("getIsUseCustomAnswers")
    static let setUseCustomAnswersTo = Notification.Name("setUseCustomAnswersTo")
    static let changePredictionProvider = Notification.Name("changePredictionProvider")
}

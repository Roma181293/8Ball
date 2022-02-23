//
//  SettingsRouter.swift
//  8 Ball
//
//  Created by Roman Topchii on 20.02.2022.
//

import UIKit

enum SetttingsRoutingDestination: RoutingDestinationBase {
    case answers
    case predictionHistory
}

class SettingsRouter: Router {
    typealias RoutingDestination = SetttingsRoutingDestination
    
    private unowned var viewController: UIViewController!
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func route(to destination: RoutingDestination) {
        switch destination {
        case .answers:
            viewController.navigationController?.pushViewController(AnswerListTableViewController(), animated: true)
        case .predictionHistory:
            viewController.navigationController?.pushViewController(PredictionHistoryListTableViewController(), animated: true)
        }
    }
}

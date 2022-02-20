//
//  PredictionRouter.swift
//  8 Ball
//
//  Created by Roman Topchii on 20.02.2022.
//

import UIKit

enum PredictionDestination: RoutingDestinationBase {
    case addQuestion(delegate: QuestionListener)
    case cancelPredictionChoose(delegate: PredictionPresenter)
}

class PredictionRouter: Router {
    typealias RoutingDestination = PredictionDestination
    
    private unowned var viewController: UIViewController!
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func route(to destination: RoutingDestination) {
        switch destination {
        case .addQuestion(let delegate):
            let alert = CustomAlertController(title: NSLocalizedString("New question",comment: ""), message: NSLocalizedString("Please ask me whatever you want",comment: ""), preferredStyle: .alert)
            
            alert.addTextField { (textField)  in
                textField.tag = 99
                textField.placeholder = NSLocalizedString("40 characters max length", comment: "")
                textField.delegate = alert
            }
            alert.addAction(UIAlertAction(title: NSLocalizedString("Add",comment: ""), style: .default, handler: { [weak alert] (_) in
                guard let alert = alert,
                      let textFields = alert.textFields,
                      let textField = textFields.first
                else {return}
                
                delegate.refreshQuestion(textField.text)
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel",comment: ""), style: .cancel))
            viewController.present(alert, animated: true, completion: nil)
        case .cancelPredictionChoose(let delegate):
            let alert = UIAlertController(title: NSLocalizedString("Oops",comment: ""), message: NSLocalizedString("Do you need this prediction?",comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("No",comment: ""), style: .destructive))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Yes",comment: ""), style: .cancel, handler: {(_) in
                delegate.presentPrediction()
            }))
            viewController.present(alert, animated: true, completion: nil)
        }
    }
}

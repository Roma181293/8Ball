//
//  AnswerListRouter.swift
//  8 Ball
//
//  Created by Roman Topchii on 20.02.2022.
//

import UIKit

enum AnswerListDestination: RoutingDestinationBase {
    case editAnswer(answer: Answer, delegate: AnswerListListener)
    case addAnswer(delegate: AnswerListListener)
}

class AnswerListRouter: Router {
    typealias RoutingDestination = AnswerListDestination
    
    private unowned var viewController: UIViewController!
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func route(to destination: RoutingDestination) {
      switch destination {
      case .editAnswer(let answer, let delegate) :
          let destinationController = AnswerEditorViewController(answerListListener: delegate)
          destinationController.answer = answer
          destinationController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
          destinationController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
          viewController.present(destinationController, animated: true, completion: nil)
      case .addAnswer(let delegate):
          let destinationController = AnswerEditorViewController(answerListListener: delegate)
          destinationController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
          destinationController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
          viewController.present(destinationController, animated: true, completion: nil)
      }
   }
}

//
//  AnswerEditorViewController.swift
//  8 Ball
//
//  Created by Roman Topchii on 15.01.2022.
//

import UIKit

protocol AnswerEditorViewControllerInput {
    func dismissAction()
    func applyAction()
}

class AnswerEditorViewController: UIViewController {
    
    var answer: Answer?
    
    private let answerListListener : AnswerListListener
    
    lazy var answerEditorViewInput: AnswerEditorViewInput  = { return view.subviews.first! as! AnswerEditorViewInput }()
    lazy var answerEditorViewOutput: AnswerEditorViewOutput  = { return view.subviews.first! as! AnswerEditorViewOutput }()
    
    init(answerListListener: AnswerListListener) {
        self.answerListListener = answerListListener
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(AnswerEditorView(frame: view.frame, delegate: self))
        answerEditorViewInput.setTextFieldDelegate(self)
        
        guard let answer = answer else {return}
        answerEditorViewInput.displayAnswer(answer)
    }
}
    
//MARK: - UITextFieldDelegate
extension AnswerEditorViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField : UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: - AnswerEditorViewOutput
extension AnswerEditorViewController: AnswerEditorViewControllerInput {
    func applyAction() {
        do {
            let answerTitle = answerEditorViewOutput.getAnswer()
            if answerTitle.isEmpty == false {
                
                let type: AnswerType = answerEditorViewOutput.getType()
                
                let context = CoreDataManager.shared.persistentContainer.viewContext
                if let answer = answer {
                    try AnswerManager.editAnswer(answer, answerTitle: answerTitle, type: type, context: context)
                }
                else {
                    try  AnswerManager.createAnswer(answerTitle, type: type, createdByUser: true, context: context)
                }
                try CoreDataManager.shared.saveContext(context)
                answerListListener.fetchData()
                dismissAction()
            }
            else {
                throw AnswerError.emptyAnswer
            }
        } catch let error {
            errorHandler(error: error)
        }
    }
    
    func dismissAction() {
        dismiss(animated: true, completion: nil)
    }
}

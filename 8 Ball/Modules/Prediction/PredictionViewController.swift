//
//  ViewController.swift
//  8 Ball
//
//  Created by Roman Topchii on 13.01.2022.
//

import UIKit

protocol QuestionListener {
    func refreshQuestion(_ question: String?)
}

protocol PredictionPresenter {
    func presentPrediction()
}

class PredictionViewController: UIViewController {
    
    var model: PredictionService!
    var router: PredictionRouter!
    
    //MARK: - IBOutlets
    @IBOutlet weak var blitzLabel: UILabel!
    @IBOutlet weak var blitzSwitch: UISwitch!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var newQuestionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionLabel.text = ""
        typeLabel.text = ""
        
        model = PredictionService(delegate: self)
        router = PredictionRouter(viewController: self)
        
        answerLabel.text = NSLocalizedString("Ask me whatever you want to know", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.navigationItem.title = NSLocalizedString("Prediction", comment: "")
    }
    
    
    //MARK: - Motion methods
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionBegan(motion, with: event)
        do{
            answerLabel.text = ""
            typeLabel.text = ""
            try model.predict()
        }
        catch let error {
            errorHandler(error: error)
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        presentPrediction()
    }
    
    override func motionCancelled(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionCancelled(motion, with: event)
        router.route(to: .cancelPredictionChoose(delegate: self))
    }
    
    
    //MARK: - IBAction methods
    @IBAction func changePredictionMode(_ sender: UISwitch) {
        do{
            try model.changePredictionMode()
        }
        catch let error {
            errorHandler(error: error)
        }
    }
    
    @IBAction func newQuestionButtonDidTouch() {
        router.route(to: .addQuestion(delegate: self))
    }
}


//MARK: - PredictionServiceDelegate
extension PredictionViewController: PredictionServiceDelegate {
    func setPredictionMode(_ mode: PredictionServiceMode) {
        switch mode {
        case.question:
            questionLabel.text = ""
            questionLabel.isHidden = false
            newQuestionButton.isHidden = false
            blitzSwitch.isOn = false
        case.blitz:
            questionLabel.isHidden = true
            newQuestionButton.isHidden = true
            blitzSwitch.isOn = true
        }
        answerLabel.text = ""
        typeLabel.text = ""
    }
    
    func showPrediction(answer: String, type: AnswerType) {
        answerLabel.text = answer
        typeLabel.text = type.toEmoji()
    }
}


//MARK: - QuestionListener
extension PredictionViewController: QuestionListener {
    func refreshQuestion(_ question: String?) {
        do{
            try model.newQuestion(question!)
            questionLabel.text = (question ?? "") + "?"
        }
        catch let error {
            self.errorHandler(error: error)
        }
    }
}


//MARK: - PredictionPresenter
extension PredictionViewController: PredictionPresenter {
    func presentPrediction() {
        model.showPrediction()
    }
}

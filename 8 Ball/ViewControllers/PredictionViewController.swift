//
//  ViewController.swift
//  8 Ball
//
//  Created by Roman Topchii on 13.01.2022.
//

import UIKit

class PredictionViewController: UIViewController, PredictionDelegate {
    
    var predictionService: PredictionService!
    
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
        
        predictionService = PredictionService()
        predictionService.delegate = self
        
        answerLabel.text = NSLocalizedString("Ask me whatever you want to know", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.navigationItem.title = NSLocalizedString("Prediction", comment: "")
    }
    
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionBegan(motion, with: event)
        print("----======----")
        do{
            answerLabel.text = ""
            typeLabel.text = ""
            try predictionService.predict()
        }
        catch let error {
            errorHandler(error: error)
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        print(#function)
        predictionService.showPrediction()
    }
    
    override func motionCancelled(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionCancelled(motion, with: event)
        print(#function)
        let alert = UIAlertController(title: NSLocalizedString("Oops",comment: ""), message: NSLocalizedString("Do you need this prediction?",comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("No",comment: ""), style: .destructive))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes",comment: ""), style: .cancel, handler: {(_) in
            self.predictionService.showPrediction()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func setPredictionMode(_ mode: PredictionMode) {
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
    
    func presentPrediction(answer: String, type: AnswerType) {
        print(#function)
        answerLabel.text = answer
        
        switch type {
        case .affirmative: typeLabel.text = "🙂"
        case .neutral: typeLabel.text = "😐"
        case .contrary: typeLabel.text = "🙁"
        case .unknown: typeLabel.text = "😳"
        }
    }
    
    @IBAction func changePredictionMode(_ sender: UISwitch) {
        do{
           try predictionService.changePredictionMode()
        }
        catch let error {
            errorHandler(error: error)
        }
    }
    
    
    @IBAction func askNewQuestion() {
        let alert = CustomUIAlertController(title: NSLocalizedString("New question",comment: ""), message: NSLocalizedString("Please ask me whatever you want",comment: ""), preferredStyle: .alert)
        
        alert.addTextField { (textField)  in
            textField.tag = 99
            textField.placeholder = NSLocalizedString("40 characters max length", comment: "")
            textField.delegate = alert
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("Add",comment: ""), style: .default, handler: { [weak alert] (_) in
            do{
                guard let alert = alert,
                      let textFields = alert.textFields,
                      let textField = textFields.first
                else {return}
                
                try self.predictionService.newQuestion(textField.text!)
                self.questionLabel.text = (textField.text ?? "") + "?"
                
            }
            catch let error {
                self.errorHandler(error: error)
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel",comment: ""), style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }
}

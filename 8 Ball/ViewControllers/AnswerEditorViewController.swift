//
//  AnswerEditorViewController.swift
//  8 Ball
//
//  Created by Roman Topchii on 15.01.2022.
//

import UIKit

class AnswerEditorViewController: UIViewController, UITextFieldDelegate {
    
    var answer: Answer?
    
    var delegate : AnswerListRefreshProtocol!
    
    let bluredView: UIView = {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        return blurEffectView
    }()
    
    let mainView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    
    let typeLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Answer type", comment: "")
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let typeSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["🙂","😐","🙁"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()
    
    let answerTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = NSLocalizedString("Your answer", comment: "")
        textField.autocapitalizationType = .words
        textField.layer.cornerRadius = 5
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 0.5
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.rightViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let discardButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 6
        button.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        button.backgroundColor = .lightGray
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let applyButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 5
        button.setTitle(NSLocalizedString("Add", comment: ""), for: .normal)
        button.backgroundColor = .lightGray
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addMainView()
        
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(self.dismissAction(_:)))
        bluredView.isUserInteractionEnabled = true
        bluredView.addGestureRecognizer(dismissTap)
        
        discardButton.addTarget(self, action: #selector(self.dismissAction(_:)), for: .touchUpInside)
        applyButton.addTarget(self, action: #selector(self.doneAction(_:)), for: .touchUpInside)
        
        answerTextField.delegate = self as UITextFieldDelegate
        
        configureUIForAnswer()
    }
    
    private func configureUIForAnswer() {
        guard let answer = answer else {
            return
        }
        applyButton.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
        
        answerTextField.text = answer.title
        
        if answer.type < 3 {
            typeSegmentedControl.selectedSegmentIndex = Int(answer.type)
        }
    }
    
    private func addMainView() {
        let minSpace: CGFloat = 5
        let maxSpace: CGFloat = 20
        
        
        view.backgroundColor = .clear

        //MARK:- Blured View
        view.addSubview(bluredView)
        bluredView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        bluredView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bluredView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        bluredView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        //MARK:- Main View
        view.addSubview(mainView)
        mainView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
        mainView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
        mainView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        //MARK:- Main Stack View
        mainView.addSubview(mainStackView)
        mainStackView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 10).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -10).isActive = true
        mainStackView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 10).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -13).isActive = true
        
        
        mainStackView.addArrangedSubview(typeLabel)
        mainStackView.setCustomSpacing(minSpace, after: typeLabel)
        mainStackView.addArrangedSubview(typeSegmentedControl)
        mainStackView.setCustomSpacing(maxSpace, after: typeSegmentedControl)
        mainStackView.addArrangedSubview(answerTextField)
        answerTextField.heightAnchor.constraint(equalToConstant: 34).isActive = true
        
        //MARK:- Buttons Stack View
        mainStackView.addArrangedSubview(buttonsStackView)
        buttonsStackView.addArrangedSubview(discardButton)
        buttonsStackView.addArrangedSubview(applyButton)
    }
    
    
    @objc private func doneAction(_ sender: Any) {
        do {
            if answerTextField.text?.isEmpty == false {
                
                var type: AnswerType = .affirmative
                switch typeSegmentedControl.selectedSegmentIndex {
                case 0:
                    type = .affirmative
                case 1:
                    type = .neutral
                case 2:
                    type = .contrary
                default:
                    type = .unknown
                }
                
                let context = CoreDataManager.shared.persistentContainer.viewContext
                if let answer = answer {
                    AnswerManager.editAnswer(answer, answerString: answerTextField.text!, type: type, context: context)
                }
                else {
                   try  AnswerManager.createAnswer(answerTextField.text!, type: type, createdByUser: true, context: context)
                }
                try CoreDataManager.shared.saveContext(context)
                delegate.refreshData()
                dismiss(animated: true, completion: nil)
            }
            else {
                throw AnswerError.emptyAnswer
            }
        }catch let error {
            errorHandler(error: error)
        }
        
    }
    
    @objc private func dismissAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func configureSegmentedControls() {
        guard let answer = answer, answer.type < 3 else {return}
        typeSegmentedControl.selectedSegmentIndex = Int(answer.type)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField : UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

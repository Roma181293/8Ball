//
//  AnswerEditorView.swift
//  8 Ball
//
//  Created by Roman Topchii on 20.02.2022.
//

import UIKit

protocol AnswerEditorViewInput {
    func setTextFieldDelegate(_ delegate: UITextFieldDelegate)
    func displayAnswer(_ answer: Answer)
}

protocol AnswerEditorViewOutput {
    func getAnswer() -> String
    func getType() -> AnswerType
}

class AnswerEditorView: UIView {
    
   private let answerEditorViewControllerInput: AnswerEditorViewControllerInput
    
    //MARK: - Views declaration
    private let bluredView: UIView = {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        return blurEffectView
    }()
    
    private let mainView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Answer type", comment: "")
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let typeSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["😳","😐","🙁","🙂"])//AnswerType.allCases)//
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()
    
    private let answerTextField: UITextField = {
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
    
    private let buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let discardButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 6
        button.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        button.backgroundColor = .lightGray
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let applyButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 5
        button.setTitle(NSLocalizedString("Add", comment: ""), for: .normal)
        button.backgroundColor = .lightGray
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(frame: CGRect, delegate: AnswerEditorViewControllerInput) {
        answerEditorViewControllerInput = delegate
        
        super.init(frame: frame)
        
        addCustomView()
        
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(self.dismissAction))
        bluredView.isUserInteractionEnabled = true
        bluredView.addGestureRecognizer(dismissTap)
        
        discardButton.addTarget(self, action:  #selector(self.dismissAction), for: .touchUpInside)
        
        applyButton.addTarget(self, action:  #selector(self.applyAction), for: .touchUpInside)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addCustomView() {
        let minSpace: CGFloat = 5
        let maxSpace: CGFloat = 20
        
        self.backgroundColor = .clear
        
        //Blured View
        self.addSubview(bluredView)
        bluredView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        bluredView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        bluredView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bluredView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        //Main View
        self.addSubview(mainView)
        mainView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8).isActive = true
        mainView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
        mainView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        //Main Stack View
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
        
        //Buttons Stack View
        mainStackView.addArrangedSubview(buttonsStackView)
        buttonsStackView.addArrangedSubview(discardButton)
        buttonsStackView.addArrangedSubview(applyButton)
    }
    
    @objc private func applyAction() {
        answerEditorViewControllerInput.applyAction()
    }
    
    @objc private func dismissAction() {
        answerEditorViewControllerInput.dismissAction()
    }
}


//MARK: - AnswerEditorViewInput
extension AnswerEditorView: AnswerEditorViewInput {
    
    func setTextFieldDelegate(_ delegate: UITextFieldDelegate) {
        answerTextField.delegate = delegate
    }
    
    func displayAnswer(_ answer: Answer) {
        applyButton.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
        
        answerTextField.text = answer.title
        
        if answer.type >= 0 && answer.type <= 3 {
            typeSegmentedControl.selectedSegmentIndex = Int(answer.type)
        }
    }
}


//MARK: - AnswerEditorViewOutput
extension AnswerEditorView: AnswerEditorViewOutput {
    func getAnswer() -> String {
        return answerTextField.text!
    }
    
    func getType() -> AnswerType {
        return AnswerType(rawValue: Int16(typeSegmentedControl.selectedSegmentIndex)) ?? .unknown
    }
}

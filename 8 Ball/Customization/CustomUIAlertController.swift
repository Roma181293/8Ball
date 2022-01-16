//
//  CustomUIAlertController.swift
//  8 Ball
//
//  Created by Roman Topchii on 15.01.2022.
//

import Foundation
import UIKit


class CustomUIAlertController: UIAlertController, UITextFieldDelegate {
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = (textField.text ?? "") as NSString
        let newText = text.replacingCharacters(in: range, with: string)
       // print("textField.tag", textField.tag)
        
        switch textField.tag {
      
        case 98...100:  // questions
            if let regex = try? NSRegularExpression(pattern: "^[a-zA-Zа-яА-Я0-9ґҐєЄіІїЇ ]{0,40}+$" , options: .caseInsensitive) {
                return regex.numberOfMatches(in: newText, options: .reportProgress, range: NSRange(location: 0, length: (newText as NSString).length)) > 0
            }
            return false
        default:
            return true
        }
    }
}

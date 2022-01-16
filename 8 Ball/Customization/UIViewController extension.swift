//
//  UIViewController extension.swift
//  8 Ball
//
//  Created by Roman Topchii on 15.01.2022.
//

import UIKit


extension UIViewController {
    func errorHandler(error: Error) {
        let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

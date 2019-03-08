//
//  UIViewController+Extension.swift
//  PPLN 2019
//
//  Created by Robihamanto on 07/03/19.
//  Copyright © 2019 Robihamanto. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showAlertController(withTitle title: String, andDescription description: String) {
        let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        //alert.addAction(UIAlertAction(title: "", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    func getCurrentTime() -> String {
        let date = Date()
        let formatter = DateFormatter()
        
        formatter.dateFormat = "EEEE d-MMMM-yyyy HH:mm"
        formatter.locale = Locale(identifier: "id_ID")

        let result = formatter.string(from: date)

        return result
    }
    
}

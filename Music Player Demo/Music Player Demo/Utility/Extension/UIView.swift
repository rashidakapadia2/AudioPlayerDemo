//
//  UIView.swift
//  Neostore_Chaitanya
//
//  Created by neosoft on 05/05/22.
//

import UIKit

extension UIViewController{
    
    func AlertResponseMessage (_ title:String,_ message : String){
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
    }
    
}

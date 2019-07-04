//
//  AlertController.swift
//  Travel Retail
//
//  Created by Anis Mizi on 3/28/19.
//  Copyright © 2019 AL HARAMAIN. All rights reserved.
//

import UIKit

class AlertController{
    static func showAlert(_ inViewController: UIViewController,title: String, message: String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(action)
        inViewController.present(alert,animated: true,completion: nil)
    }
}

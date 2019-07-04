//
//  AddItemVC.swift
//  Travel Retail
//
//  Created by Anis Mizi on 5/6/19.
//  Copyright © 2019 AL HARAMAIN. All rights reserved.
//

import Foundation
import UIKit

class AddItemVC: UIViewController{
    
    @IBOutlet weak var searchItem: UITextField!
    
    @IBOutlet weak var enterQuantity: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    var delegate: AddItemDelegate?
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    let alertViewGrayColor = UIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
    }
    
    func setupView() {
        alertView.layer.cornerRadius = 15
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }
    
    func animateView() {
        alertView.alpha = 0;
        self.alertView.frame.origin.y = self.alertView.frame.origin.y + 50
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.alertView.alpha = 1.0;
            self.alertView.frame.origin.y = self.alertView.frame.origin.y - 50
        })
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        delegate?.okButtonTapped(msg: "")
    }
    
    @IBAction func add(_ sender: UIButton) {
        delegate?.cancelButtonTapped()
    }
}

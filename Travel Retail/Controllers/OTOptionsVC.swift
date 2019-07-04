//
//  OTOptionsVC.swift
//  Travel Retail
//
//  Created by Anis Mizi on 5/19/19.
//  Copyright © 2019 AL HARAMAIN. All rights reserved.
//

import UIKit

class OTOptionsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        Utils.dailySales = false
        Utils.otsales = true
    }
    
    @IBAction func otRequestPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "setOTLocation", sender: nil)
    }
    
    @IBAction func submitOtPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "OTSalesDetails", sender: nil)
    }
    
}

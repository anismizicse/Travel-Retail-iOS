//
//  PriceListDetailsVC.swift
//  Travel Retail
//
//  Created by Anis Mizi on 5/19/19.
//  Copyright © 2019 AL HARAMAIN. All rights reserved.
//

import UIKit

class PriceListDetailsVC: UIViewController {

    @IBOutlet weak var itemCode: UILabel!
    @IBOutlet weak var itemType: UILabel!
    @IBOutlet weak var itemDesc: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var topNotes: UILabel!
    @IBOutlet weak var middleNotes: UILabel!
    @IBOutlet weak var baseNotes: UILabel!
    
    var productInfo: ProductInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        itemCode.text = productInfo?.itemcode
        itemType.text = productInfo?.item_type
        itemDesc.text = productInfo?.item_description
        price.text = productInfo?.price
        topNotes.text = productInfo?.top_note
        middleNotes.text = productInfo?.middle_notes
        baseNotes.text = productInfo?.base_notes
    }
    
    @IBAction func backPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
}

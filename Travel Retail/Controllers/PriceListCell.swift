//
//  PriceListCell.swift
//  Travel Retail
//
//  Created by Anis Mizi on 3/28/19.
//  Copyright © 2019 AL HARAMAIN. All rights reserved.
//

import UIKit

class PriceListCell: UITableViewCell {

    @IBOutlet weak var sl: UILabel!
    @IBOutlet weak var itemcode: UILabel!
    @IBOutlet weak var item_type: UILabel!
    @IBOutlet weak var item_desc: UILabel!
    @IBOutlet weak var item_price: UILabel!
    
    func setPriceListCell(product: ProductInfo){
        
        self.sl.text = product.sl
        self.itemcode.text = product.itemcode
        self.item_type.text = product.item_type
        self.item_desc.text = product.item_description
        self.item_price.text = product.price
        
    }
}

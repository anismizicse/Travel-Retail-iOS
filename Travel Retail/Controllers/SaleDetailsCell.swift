//
//  SaleDetailsCell.swift
//  Travel Retail
//
//  Created by Anis Mizi on 5/14/19.
//  Copyright © 2019 AL HARAMAIN. All rights reserved.
//

import Foundation
import UIKit

class SaleDetailsCell: UITableViewCell{
    
    @IBOutlet weak var sn: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var itemCode: UILabel!
    @IBOutlet weak var quantity: UILabel!
    @IBOutlet weak var amount: UILabel!
    
    func setSaleDetailsCell(saleInfo: SalesInfo){
        
        if saleInfo.sale_id == 0{
            sn.text = ""
        }else{
            sn.text = "\(saleInfo.sale_id)"
        }
        
        location.text = saleInfo.location
        itemCode.text = saleInfo.itemcode
        quantity.text = saleInfo.quantity
        amount.text = saleInfo.total_price
    }
    
    func setOtSaleDetailsCell(saleInfo: OTSalesInfo){
        
        if saleInfo.sale_id == 0{
            sn.text = ""
        }else{
            sn.text = "\(saleInfo.sale_id)"
        }
        
        location.text = saleInfo.location
        itemCode.text = saleInfo.itemcode
        quantity.text = saleInfo.quantity
        amount.text = saleInfo.total_price
        
    }
}

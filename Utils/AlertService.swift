//
//  AlertService.swift
//  Travel Retail
//
//  Created by Anis Mizi on 5/6/19.
//  Copyright © 2019 AL HARAMAIN. All rights reserved.
//

import Foundation
import UIKit

class AlertService {
    
    func alert() -> AddItemAlertVC {
        let storyBoard = UIStoryboard(name: "CustomAlert", bundle: .main)
        
        let alertVc = storyBoard.instantiateViewController(withIdentifier: "AddItem") as! AddItemAlertVC
        
        return alertVc
    }
    
    func editSalesAlert() -> EditSalesDetailsVC{
        
        let storyBoard = UIStoryboard(name: "CustomAlert", bundle: .main)
        let alertVc = storyBoard.instantiateViewController(withIdentifier: "EditSalesDetails") as! EditSalesDetailsVC
        
        return alertVc
    }
    
    func priceListDetailsAlert() -> PriceListDetailsVC{
        
        let storyBoard = UIStoryboard(name: "CustomAlert", bundle: .main)
        let alertVc = storyBoard.instantiateViewController(withIdentifier: "PriceListDetails") as! PriceListDetailsVC
        
        return alertVc
    }
    
    func otOptionsAlert() -> OTOptionsVC{
        
        let storyBoard = UIStoryboard(name: "Main", bundle: .main)
        let alertVc = storyBoard.instantiateViewController(withIdentifier: "OTOptions") as! OTOptionsVC
        
        return alertVc
    }
}

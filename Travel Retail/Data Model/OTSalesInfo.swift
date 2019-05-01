//
//  OTSalesInfo.swift
//  Travel Retail
//
//  Created by Anis Mizi on 4/30/19.
//  Copyright © 2019 AL HARAMAIN. All rights reserved.
//

import Foundation
import RealmSwift

//OTSalesInfo table
class OTSalesInfo: Object {
    @objc dynamic var sale_id: Int = 0
    @objc dynamic var transaction_id: String = ""
    @objc dynamic var salesman: String = ""
    @objc dynamic var salesman_name: String = ""
    @objc dynamic var location: String = ""
    @objc dynamic var area: String = ""
    @objc dynamic var organization: String = ""
    @objc dynamic var itemcode: String = ""
    @objc dynamic var item_description: String = ""
    @objc dynamic var quantity: String = ""
    @objc dynamic var unit_price: String = ""
    @objc dynamic var total_price: String = ""
    @objc dynamic var date: String = ""
    @objc dynamic var location_area: String = ""
}

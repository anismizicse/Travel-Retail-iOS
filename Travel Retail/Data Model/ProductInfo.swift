//
//  ProductInfo.swift
//  Travel Retail
//
//  Created by Anis Mizi on 4/7/19.
//  Copyright © 2019 AL HARAMAIN. All rights reserved.
//

import Foundation
import RealmSwift

class ProductInfo: Object{
    @objc dynamic var sl: String = ""
    @objc dynamic var itemcode: String = ""
    @objc dynamic var item_type: String = ""
    @objc dynamic var item_description: String = ""
    @objc dynamic var price: String = ""
    @objc dynamic var location: String = ""
    @objc dynamic var top_note: String = ""
    @objc dynamic var middle_notes: String = ""
    @objc dynamic var base_notes: String = ""
}

//
//  DeletedSalesInfo.swift
//  Travel Retail
//
//  Created by Anis Mizi on 5/17/19.
//  Copyright © 2019 AL HARAMAIN. All rights reserved.
//

import Foundation
import RealmSwift

//Sales_Info table
class DeletedSalesInfo: Object {
    @objc dynamic var sale_id: Int = 0
    @objc dynamic var transaction_id: String = ""
    @objc dynamic var salesman: String = ""
}

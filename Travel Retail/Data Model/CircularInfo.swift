//
//  CircularInfo.swift
//  Travel Retail
//
//  Created by Anis Mizi on 4/30/19.
//  Copyright © 2019 AL HARAMAIN. All rights reserved.
//

import Foundation
import RealmSwift

//CircularInfo table
class CircularInfo: Object {
    @objc dynamic var circular_id: Int = 0
    @objc dynamic var created_from: String = ""
    @objc dynamic var created_to: String = ""
    @objc dynamic var ref: String = ""
    @objc dynamic var subject: String = ""
    @objc dynamic var message: String = ""
    @objc dynamic var date: String = ""
}

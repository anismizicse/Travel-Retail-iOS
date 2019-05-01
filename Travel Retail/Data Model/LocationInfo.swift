//
//  LocationInfo.swift
//  Travel Retail
//
//  Created by Anis Mizi on 4/30/19.
//  Copyright © 2019 AL HARAMAIN. All rights reserved.
//

import Foundation
import RealmSwift

//LocationInfo table
class LocationInfo: Object {
    @objc dynamic var main_location: String = ""
    @objc dynamic var sub_location: String = ""
    @objc dynamic var organization: String = ""
}

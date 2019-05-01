//
//  UserInfo.swift
//  Travel Retail
//
//  Created by Anis Mizi on 4/7/19.
//  Copyright © 2019 AL HARAMAIN. All rights reserved.
//

import Foundation
import RealmSwift

class UserInfo: Object{
    @objc dynamic var fname: String = ""
    @objc dynamic var lname: String = ""
    @objc dynamic var usercode: String = ""
    @objc dynamic var email: String = ""
    @objc dynamic var phone: String = ""
    @objc dynamic var pass: String = ""
    @objc dynamic var user_type: String = ""
    @objc dynamic var location: String = ""
    @objc dynamic var logged_in: String = ""
}

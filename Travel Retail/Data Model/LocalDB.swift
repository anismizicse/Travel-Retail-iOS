//
//  LocalDB.swift
//  Travel Retail
//
//  Created by Anis Mizi on 4/26/19.
//  Copyright © 2019 AL HARAMAIN. All rights reserved.
//

import Foundation
import RealmSwift

class LocalDB{
    
    static func fetchUser() -> UserInfo?{
        let realm = try! Realm()
        let scope = realm.objects(UserInfo.self)
        return scope.first
    }
    
}

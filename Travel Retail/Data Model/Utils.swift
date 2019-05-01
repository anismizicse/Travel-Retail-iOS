//
//  Utils.swift
//  Travel Retail
//
//  Created by Anis Mizi on 3/28/19.
//  Copyright © 2019 AL HARAMAIN. All rights reserved.
//

import Foundation
import SystemConfiguration
import Firebase

class Utils{
    static let server_url: String = "http://mizianis.com/sm/imchat/TravelRetail/"
   
    static let PRODUCT_UPDATE = "product_update"
    static let LOCATION_UPDATE = "location_update"
    static let CIRCULAR_UPDATE = "circular_update"
    static let GUIDELINE_UPDATE = "guideline_update"
    static let OTEMAIL_UPDATE = "otemail_update"
    static let UPDATE_AVAILABLE = "update_available"
    
    static let DB_READY = "DB_READY"
    static let ACCOUNT_SUSPENDED = "account_suspended"
    static let LOGGED_IN = "logged_in"
    static let CHAT_GROUP = "chat_group"
    static let CHAT_EMAIL = "chat_email"
    static let CHAT_PASSWORD = "chat_password"
    static let EMAIL_ADDRESSES = "email_addresses"
    static let NOTIFICATIONID = "notificationid"
    static let FIREBASE_TOKEN = "firebaseToken"
    
    //Sales Executive static variables
    static var salesmanName = "", loginName = "", loginPass = "", location = "";
    
    static func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        /* Only Working for WIFI
         let isReachable = flags == .reachable
         let needsConnection = flags == .connectionRequired
         
         return isReachable && !needsConnection
         */
        
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
        
    }
    
    static func saveToken(ref: DatabaseReference, currentUserId: String) {

        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
                UserDefaults.standard.set(result.token, forKey: FIREBASE_TOKEN)
                ref.child("userState").child(currentUserId).child("device_token").setValue(result.token)
            }else{
                ref.setValue("na")
            }
        }
        
    }
}


//
//  HomeVC.swift
//  Travel Retail
//
//  Created by Anis Mizi on 3/28/19.
//  Copyright © 2019 AL HARAMAIN. All rights reserved.
//

import UIKit
import Alamofire
import Toast_Swift
import RealmSwift
import SwiftyJSON
import Firebase

enum HomeButtons: Int{
    case DailySales = 1
    case PriceList
    case SalesDetails
    case Report
    case Circular
    case GuideLine
    case OTRequest
    case LiveChat
    case Update
}

class HomeVC: UIViewController {
    
    var realm = try! Realm()
    let alertService = AlertService()
    var ref: DatabaseReference!
    
    var insertUpdate = false
    var otinsertUpdate = false
    
    var saleDetilsString = ""
    var editedSaleDetils = ""
    var deletedSaleDetils = ""
    var otsaleDetilsString = ""
    var oteditedSaleDetils = ""
    var otdeletedSaleDetils = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        title = "Home"
        ref = Database.database().reference()
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func ButtonClicked(_ sender: UIButton) {
        
        switch sender.tag {
            
        case HomeButtons.DailySales.rawValue:
            
            Utils.dailySales = true
            Utils.otsales = false
            
            if Utils.location != "DUFRY"{
                performSegue(withIdentifier: "setLocation", sender: nil)
            }else{
                DailySalesVC.mainArea = "DUFRY"
                DailySalesVC.subArea = "DUFRY"
                self.performSegue(withIdentifier: "dailySales", sender: nil)
            }
            
            
        case HomeButtons.PriceList.rawValue:
            print("")
        case HomeButtons.SalesDetails.rawValue:
            Utils.dailySales = true
            Utils.otsales = false
            performSegue(withIdentifier: "saleDetails", sender: nil)
            
        case HomeButtons.Report.rawValue:
            
            //Utils.createPDF()
            
            if !Utils.isConnectedToNetwork() {
                AlertController.showAlert(self, title: "Internet Error", message: "Please connect to Internet to update new Sales updates.")
            }else{
                
                self.view.makeToastActivity(.center)
                
                let userDetails = self.realm.objects(UserInfo.self)
                var loginName = ""
                var loginPass = ""
                
                if let detail = userDetails.first{
                    loginName = detail.usercode
                    loginPass = detail.pass
                }
                
                //creating parameters for the post request
                let parameters: Parameters=[
                    "usercode": loginName,
                    "password": loginPass
                ]
                
                //Sending http post request
                Alamofire.request(Utils.server_url+"get_new_userinfo.php", method: .post, parameters: parameters).responseString
                    {
                        response in
                        
                        //print(response.result.value ?? "nil value")
                        
                        if let res = response.result.value {
                            
                            if res == "na"{
                                
                                DispatchQueue.main.async {
                                    self.view.hideAllToasts(includeActivity: true, clearQueue: true)
                                }
                                
                                UserDefaults.standard.set(1, forKey: Utils.ACCOUNT_SUSPENDED)
                                UserDefaults.standard.set(0, forKey: Utils.LOGGED_IN)
                                self.view.makeToast("Your account has been suspended. Please contact admin.")
                            }else{
                                self.submitSalesUpdates()
                            }
                        }
                }
            }
            
        case HomeButtons.Circular.rawValue:
            Utils.circular = true
            Utils.guideline = false
            performSegue(withIdentifier: "CircularGuideline", sender: nil)
        case HomeButtons.GuideLine.rawValue:
            Utils.circular = false
            Utils.guideline = true
            performSegue(withIdentifier: "CircularGuideline", sender: nil)
        case HomeButtons.OTRequest.rawValue:
            //            let alertVc = alertService.otOptionsAlert()
            //            present(alertVc,animated: true)
            performSegue(withIdentifier: "OTOptions", sender: nil)
        case HomeButtons.LiveChat.rawValue:
            
            let user = Auth.auth().currentUser
            let chatLogin = UserDefaults.standard.integer(forKey: Utils.CHAT_LOGGED_IN)
            
            let email = UserDefaults.standard.string(forKey: Utils.CHAT_EMAIL) ?? ""
            let pass = UserDefaults.standard.string(forKey: Utils.CHAT_PASSWORD) ?? ""
            
            if user == nil && chatLogin == 0{
                loginLiveChat(email: email, password: pass)
            }else{
                self.performSegue(withIdentifier: "LiveChat", sender: nil)
            }
            
        case HomeButtons.Update.rawValue:
            print("")
        default:
            print("")
            
        }
    }
    
    func loginLiveChat(email: String,password: String){
        
    
        Auth.auth().signIn(withEmail: email, password: password) {  authResult, error in
            
            if let user = authResult?.user{
                //self.view.hideAllToasts(includeActivity: true, clearQueue: true)
                Utils.saveToken(ref: self.ref, currentUserId: user.uid)
                UserDefaults.standard.set(1, forKey: Utils.CHAT_LOGGED_IN)
                self.view.makeToast("Logged In Successfully....")
                self.performSegue(withIdentifier: "LiveChat", sender: nil)
            }
            
            if(error != nil){
                AlertController.showAlert(self, title: "Error!", message: error!.localizedDescription)
            }
        }
    }
    
    func submitSalesUpdates(){
        
        let fetchSaleDetails = {self.realm.objects(TempSalesInfo.self)}()
        let fetchOtSaleDetails = {self.realm.objects(OTTempSalesInfo.self)}()
        let fetchEditedSales = {self.realm.objects(EditedSalesInfo.self)}()
        let fetchOTEditedSales = {self.realm.objects(OTEditedSalesInfo.self)}()
        let fetchDeletedSales = {self.realm.objects(DeletedSalesInfo.self)}()
        let fetchOTDeletedSales = {self.realm.objects(OTDeletedSalesInfo.self)}()
        
        //        print("\(fetchSaleDetails.count) \(fetchOtSaleDetails.count) \(fetchEditedSales.count) \(fetchOTEditedSales.count) \(fetchDeletedSales.count) \(fetchOTDeletedSales.count)")
        
        //Sales entries are up to date if all sales tables size is 0
        if fetchSaleDetails.count == 0 && fetchOtSaleDetails.count == 0 && fetchEditedSales.count == 0 &&
            fetchOTEditedSales.count == 0 && fetchDeletedSales.count == 0 && fetchOTDeletedSales.count == 0 {
            
            self.view.hideAllToasts(includeActivity: true, clearQueue: true)
            
            //Show "Up to Date" status
            AlertController.showAlert(self, title: "Up to Date", message: "All Sales Entries Are Up to Date.")
            
        }else{
            
            
            if fetchSaleDetails.count != 0{
                
                //var sales: [TempSalesInfo] = []
                var i = 1
                let total = fetchSaleDetails.count
                
                saleDetilsString += "["
                
                for sale in fetchSaleDetails{
                    //sales.append(sale)
                    saleDetilsString += "{"
                    
                    saleDetilsString += "\"sale_id\":\"\(sale.sale_id)\","
                    saleDetilsString += "\"transaction_id\":\"\(sale.transaction_id)\","
                    saleDetilsString += "\"salesman\":\"\(sale.salesman)\","
                    saleDetilsString += "\"salesman_name\":\"\(sale.salesman_name)\","
                    saleDetilsString += "\"location\":\"\(sale.location)\","
                    saleDetilsString += "\"area\":\"\(sale.area)\","
                    
                    saleDetilsString += "\"organization\":\"\(sale.organization)\","
                    saleDetilsString += "\"itemcode\":\"\(sale.itemcode)\","
                    saleDetilsString += "\"item_description\":\"\(sale.item_description)\","
                    saleDetilsString += "\"quantity\":\"\(sale.quantity)\","
                    saleDetilsString += "\"unit_price\":\"\(sale.unit_price)\","
                    saleDetilsString += "\"total_price\":\"\(sale.total_price)\","
                    saleDetilsString += "\"date\":\"\(sale.date)\""
                    
                    saleDetilsString += "}"
                    
                    if i != total {
                        saleDetilsString += ","
                    }
                    
                    i += 1
                    
                }
                saleDetilsString += "]"
            }
            
            
            //print(saleDetilsString)
            
            
            //Edited Sales
            
            
            if fetchEditedSales.count != 0{
                
                //var sales: [TempSalesInfo] = []
                var i = 1
                let total = fetchEditedSales.count
                
                editedSaleDetils += "["
                
                for sale in fetchEditedSales{
                    //sales.append(sale)
                    editedSaleDetils += "{"
                    
                    editedSaleDetils += "\"sale_id\":\"\(sale.sale_id)\","
                    editedSaleDetils += "\"transaction_id\":\"\(sale.transaction_id)\","
                    editedSaleDetils += "\"salesman\":\"\(sale.salesman)\","
                    editedSaleDetils += "\"salesman_name\":\"\(sale.salesman_name)\","
                    editedSaleDetils += "\"location\":\"\(sale.location)\","
                    editedSaleDetils += "\"area\":\"\(sale.area)\","
                    
                    editedSaleDetils += "\"organization\":\"\(sale.organization)\","
                    editedSaleDetils += "\"itemcode\":\"\(sale.itemcode)\","
                    editedSaleDetils += "\"item_description\":\"\(sale.item_description)\","
                    editedSaleDetils += "\"quantity\":\"\(sale.quantity)\","
                    editedSaleDetils += "\"unit_price\":\"\(sale.unit_price)\","
                    editedSaleDetils += "\"total_price\":\"\(sale.total_price)\","
                    editedSaleDetils += "\"date\":\"\(sale.date)\""
                    
                    editedSaleDetils += "}"
                    
                    if i != total {
                        editedSaleDetils += ","
                    }
                    
                    i += 1
                    
                }
                editedSaleDetils += "]"
            }
            
            
            //print(editedSaleDetils)
            
            
            //Deleted Sales
            
            
            if fetchDeletedSales.count != 0{
                
                //var sales: [TempSalesInfo] = []
                var i = 1
                let total = fetchDeletedSales.count
                
                deletedSaleDetils += "["
                
                for sale in fetchDeletedSales{
                    //sales.append(sale)
                    deletedSaleDetils += "{"
                    
                    deletedSaleDetils += "\"sale_id\":\"\(sale.sale_id)\","
                    deletedSaleDetils += "\"transaction_id\":\"\(sale.transaction_id)\","
                    deletedSaleDetils += "\"salesman\":\"\(sale.salesman)\""
                    
                    deletedSaleDetils += "}"
                    
                    if i != total {
                        deletedSaleDetils += ","
                    }
                    
                    i += 1
                    
                }
                deletedSaleDetils += "]"
            }
            
            
            print("String Created: \(deletedSaleDetils)")
            
            
            //OtDetails Sales
            
            
            if fetchOtSaleDetails.count != 0{
                
                //var sales: [TempSalesInfo] = []
                var i = 1
                let total = fetchOtSaleDetails.count
                
                otsaleDetilsString += "["
                
                for sale in fetchOtSaleDetails{
                    //sales.append(sale)
                    otsaleDetilsString += "{"
                    
                    otsaleDetilsString += "\"sale_id\":\"\(sale.sale_id)\","
                    otsaleDetilsString += "\"transaction_id\":\"\(sale.transaction_id)\","
                    otsaleDetilsString += "\"salesman\":\"\(sale.salesman)\","
                    otsaleDetilsString += "\"salesman_name\":\"\(sale.salesman_name)\","
                    otsaleDetilsString += "\"location\":\"\(sale.location)\","
                    otsaleDetilsString += "\"area\":\"\(sale.area)\","
                    
                    otsaleDetilsString += "\"organization\":\"\(sale.organization)\","
                    otsaleDetilsString += "\"itemcode\":\"\(sale.itemcode)\","
                    otsaleDetilsString += "\"item_description\":\"\(sale.item_description)\","
                    otsaleDetilsString += "\"quantity\":\"\(sale.quantity)\","
                    otsaleDetilsString += "\"unit_price\":\"\(sale.unit_price)\","
                    otsaleDetilsString += "\"total_price\":\"\(sale.total_price)\","
                    otsaleDetilsString += "\"date\":\"\(sale.date)\""
                    
                    otsaleDetilsString += "}"
                    
                    if i != total {
                        otsaleDetilsString += ","
                    }
                    
                    i += 1
                    
                }
                otsaleDetilsString += "]"
            }
            
            
            //print(otsaleDetilsString)
            
            
            //OtEditedDetails Sales
            
            
            if fetchOTEditedSales.count != 0{
                
                //var sales: [TempSalesInfo] = []
                var i = 1
                let total = fetchOTEditedSales.count
                
                oteditedSaleDetils += "["
                
                for sale in fetchOTEditedSales{
                    //sales.append(sale)
                    oteditedSaleDetils += "{"
                    
                    oteditedSaleDetils += "\"sale_id\":\"\(sale.sale_id)\","
                    oteditedSaleDetils += "\"transaction_id\":\"\(sale.transaction_id)\","
                    oteditedSaleDetils += "\"salesman\":\"\(sale.salesman)\","
                    oteditedSaleDetils += "\"salesman_name\":\"\(sale.salesman_name)\","
                    oteditedSaleDetils += "\"location\":\"\(sale.location)\","
                    oteditedSaleDetils += "\"area\":\"\(sale.area)\","
                    
                    oteditedSaleDetils += "\"organization\":\"\(sale.organization)\","
                    oteditedSaleDetils += "\"itemcode\":\"\(sale.itemcode)\","
                    oteditedSaleDetils += "\"item_description\":\"\(sale.item_description)\","
                    oteditedSaleDetils += "\"quantity\":\"\(sale.quantity)\","
                    oteditedSaleDetils += "\"unit_price\":\"\(sale.unit_price)\","
                    oteditedSaleDetils += "\"total_price\":\"\(sale.total_price)\","
                    oteditedSaleDetils += "\"date\":\"\(sale.date)\""
                    
                    oteditedSaleDetils += "}"
                    
                    if i != total {
                        oteditedSaleDetils += ","
                    }
                    
                    i += 1
                    
                }
                
                oteditedSaleDetils += "]"
            }
            
            
            //print(oteditedSaleDetils)
            
            //OtDeletedDetails Sales
            
            
            if fetchOTDeletedSales.count != 0{
                
                //var sales: [TempSalesInfo] = []
                var i = 1
                let total = fetchOTDeletedSales.count
                
                otdeletedSaleDetils += "["
                
                for sale in fetchOTDeletedSales{
                    //sales.append(sale)
                    otdeletedSaleDetils += "{"
                    
                    otdeletedSaleDetils += "\"sale_id\":\"\(sale.sale_id)\","
                    otdeletedSaleDetils += "\"transaction_id\":\"\(sale.transaction_id)\","
                    otdeletedSaleDetils += "\"salesman\":\"\(sale.salesman)\""
                    
                    
                    otdeletedSaleDetils += "}"
                    
                    if i != total {
                        otdeletedSaleDetils += ","
                    }
                    
                    i += 1
                    
                }
                otdeletedSaleDetils += "]"
            }
            
            
            //print(otdeletedSaleDetils)
            
            self.view.hideToastActivity()
            
            
            //Only those Sales Tables entries will be updated to remote server whose size is greater than 0
            if (fetchSaleDetails.count > 0 && fetchEditedSales.count == 0) {
                updateNewSales()
            } else if (fetchEditedSales.count > 0 && fetchSaleDetails.count == 0) {
                updateEditedSales()
            } else if (fetchSaleDetails.count > 0 && fetchEditedSales.count > 0) {
                
                /*
                 Here we put insertUpdate = true. If this condition passes, it means we have new sales entries and
                 edited sales entries due to update on server. So we want to create a chain of method calls. Example,
                 updateNewSales() -> updateEditedSales() -> updateDeletedSales(). After completing New Sales update
                 program will check if insertUpdate is true or not inside updateNewSales(). If true then it will follow
                 the chain. If false the chain will be like this updateNewSales() -> updateDeletedSales(). Please note
                 that if there is no deleted salses update, no deleted sales will be updated on server.
                 */
                insertUpdate = true
                updateNewSales()
            } else {
                updateDeletedSales()
            }
            
            //Only those OT Sales Tables entries will be updated to remote server whose size is greater than 0
            if (fetchOtSaleDetails.count > 0 && fetchOTEditedSales.count == 0) {
                otupdateNewSales()
            } else if (fetchOTEditedSales.count > 0 && fetchOtSaleDetails.count == 0) {
                otupdateEditedSales()
            } else if (fetchOtSaleDetails.count > 0 && fetchOTEditedSales.count > 0) {
                
                //Works same as sales update. Difference is it will work on OT Sales
                otinsertUpdate = true
                otupdateNewSales()
            } else {
                otupdateDeletedSales()
            }
            
            
        }
        
        
        
    }
    
    //Fetch product, location, circular, guideline update status from server and insert current update number
    func insertAppUpdate(){
        
        //Sending http post request
        Alamofire.request(Utils.server_url+"get_app_update.php", method: .post, parameters: nil).responseJSON
            {
                response in
                
                //getting the json value from the server
                if let result = response.result.value {
                    
                    //converting it as NSDictionary
                    if let jsonData = result as? NSArray{
                        
                        
                        for entry in jsonData {
                            
                            if let entry = entry as? NSDictionary{
                                //displaying the message in label
                                
                                
                                
                                
                                let product_update = Int(entry.value(forKey: "product_update") as? String ?? "") ?? 0
                                let location_update = Int(entry.value(forKey: "location_update") as? String ?? "") ?? 0
                                let circular_update = Int(entry.value(forKey: "circular_update") as? String ?? "") ?? 0
                                let guideline_update = Int(entry.value(forKey: "guideline_update") as? String ?? "") ?? 0
                                let otemailaddress_update = Int(entry.value(forKey: "otemail_update") as? String ?? "") ?? 0
                                
                                let pro_update = Int(UserDefaults.standard.string(forKey: Utils.PRODUCT_UPDATE) ?? "0")
                                let loc_update = Int(UserDefaults.standard.string(forKey: Utils.LOCATION_UPDATE) ?? "0")
                                let cir_update = Int(UserDefaults.standard.string(forKey: Utils.CIRCULAR_UPDATE) ?? "0")
                                let guide_update = Int(UserDefaults.standard.string(forKey: Utils.GUIDELINE_UPDATE) ?? "0")
                                let otemail_update = Int(UserDefaults.standard.string(forKey: Utils.OTEMAIL_UPDATE) ?? "0")
                                
                                if (pro_update != product_update) || (loc_update != location_update) || (cir_update != circular_update) || (guide_update != guideline_update) || (otemail_update != otemailaddress_update){
                                    UserDefaults.standard.set(1, forKey: Utils.UPDATE_AVAILABLE)
                                    //sendNotification()
                                }
                                
                                
                                
                                
                                
                            }
                        }
                        
                        
                        
                    }
                }
                
                
        }
    }
    
    func updateNewSales(){
        
        self.view.makeToastActivity(.center)
        
        //creating parameters for the post request
        let parameters: Parameters=[
            "saleDetilsString": saleDetilsString
        ]
        
        //Sending http post request
        Alamofire.request(Utils.server_url+"update_new_sales.php", method: .post, parameters: parameters).responseString
            {
                response in
                
                if let res = response.result.value {
                    
                    if res == "updated"{
                        
                        self.insertAppUpdate()
                        self.view.makeToast("Successfully updated new sales entries to server")
                        
                        let tempSales = self.realm.objects(TempSalesInfo.self)
                        
                        do{
                            try self.realm.write {
                                self.realm.delete(tempSales)
                            }
                        }catch{
                            print("Error deleting tempSales \(error)")
                        }
                        
                        if self.insertUpdate {
                            self.updateEditedSales()
                        } else if self.deletedSaleDetils != "" {
                            self.updateDeletedSales()
                        }
                        
                    }
                }
                
                DispatchQueue.main.async {
                    self.view.hideToastActivity()
                }
        }
    }
    
    
    func updateDeletedSales(){
        
        self.view.makeToastActivity(.center)
        
        //creating parameters for the post request
        let parameters: Parameters=[
            "deletedSaleDetils": deletedSaleDetils
        ]
        
        //Sending http post request
        Alamofire.request(Utils.server_url+"update_deleted_sales.php", method: .post, parameters: parameters).responseString
            {
                response in
                
                print("\(response) \(self.deletedSaleDetils)")
                
                if self.deletedSaleDetils != ""{
                    
                    self.view.makeToast("Successfully updated deleted sales entries to server")
                    
                    let deletedSales = self.realm.objects(DeletedSalesInfo.self)
                    
                    do{
                        try self.realm.write {
                            self.realm.delete(deletedSales)
                        }
                    }catch{
                        print("Error deleting DeletedSalesInfo \(error)")
                    }
                    
                    
                }
                
                DispatchQueue.main.async {
                    self.view.hideToastActivity()
                }
                
        }
    }
    
    func updateEditedSales(){
        
        self.view.makeToastActivity(.center)
        
        //creating parameters for the post request
        let parameters: Parameters=[
            "editedSaleDetils": editedSaleDetils
        ]
        
        //Sending http post request
        Alamofire.request(Utils.server_url+"update_edited_sales.php", method: .post, parameters: parameters).responseString
            {
                response in
                
                self.view.makeToast("Successfully updated edited sales to server")
                
                let editedSales = self.realm.objects(EditedSalesInfo.self)
                
                do{
                    try self.realm.write {
                        self.realm.delete(editedSales)
                    }
                }catch{
                    print("Error deleting tempSales \(error)")
                }
                
                DispatchQueue.main.async {
                    self.view.hideToastActivity()
                }
                
                
        }
    }
    
    func otupdateNewSales(){
        
        self.view.makeToastActivity(.center)
        
        //creating parameters for the post request
        let parameters: Parameters=[
            "otsaleDetilsString": otsaleDetilsString
        ]
        
        //Sending http post request
        Alamofire.request(Utils.server_url+"update_new_otsales.php", method: .post, parameters: parameters).responseString
            {
                response in
                
                if let res = response.result.value {
                    
                    if res == "updated"{
                        
                        self.insertAppUpdate()
                        self.view.makeToast("Successfully updated new ot sales entries to server")
                        
                        let oTTempSales = self.realm.objects(OTTempSalesInfo.self)
                        
                        do{
                            try self.realm.write {
                                self.realm.delete(oTTempSales)
                            }
                        }catch{
                            print("Error deleting tempSales \(error)")
                        }
                        
                        if self.otinsertUpdate {
                            self.otupdateEditedSales()
                        } else if self.otdeletedSaleDetils != "" {
                            self.otupdateDeletedSales()
                        }
                        
                    }
                }
                
                DispatchQueue.main.async {
                    self.view.hideToastActivity()
                }
        }
    }
    
    func otupdateDeletedSales(){
        
        self.view.makeToastActivity(.center)
        
        //creating parameters for the post request
        let parameters: Parameters=[
            "otdeletedSaleDetils": otdeletedSaleDetils
        ]
        
        //Sending http post request
        Alamofire.request(Utils.server_url+"update_otdeleted_sales.php", method: .post, parameters: parameters).responseString
            {
                response in
                
                if self.otdeletedSaleDetils != ""{
                    
                    self.view.makeToast("Successfully updated ot deleted sales entries to server")
                    
                    let oTDeletedSales = self.realm.objects(OTDeletedSalesInfo.self)
                    
                    do{
                        try self.realm.write {
                            self.realm.delete(oTDeletedSales)
                        }
                    }catch{
                        print("Error deleting OTDeletedSalesInfo \(error)")
                    }
                    
                    
                }
                
                DispatchQueue.main.async {
                    self.view.hideToastActivity()
                }
                
        }
    }
    
    func otupdateEditedSales(){
        
        self.view.makeToastActivity(.center)
        
        //creating parameters for the post request
        let parameters: Parameters=[
            "oteditedSaleDetils": oteditedSaleDetils
        ]
        
        //Sending http post request
        Alamofire.request(Utils.server_url+"update_otedited_sales.php", method: .post, parameters: parameters).responseString
            {
                response in
                
                self.view.makeToast("Successfully updated ot edited sales to server")
                
                let oTEditedSales = self.realm.objects(OTEditedSalesInfo.self)
                
                do{
                    try self.realm.write {
                        self.realm.delete(oTEditedSales)
                    }
                }catch{
                    print("Error deleting tempSales \(error)")
                }
                
                if self.otinsertUpdate {
                    self.otupdateDeletedSales()
                    self.otinsertUpdate = false;
                } else if self.otdeletedSaleDetils != "" {
                    self.otupdateDeletedSales()
                }
                
                DispatchQueue.main.async {
                    self.view.hideToastActivity()
                }
                
        }
        
    }
    
    
}



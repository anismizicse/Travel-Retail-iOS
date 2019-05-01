//
//  LoginVC.swift
//  Travel Retail
//
//  Created by Anis Mizi on 3/28/19.
//  Copyright © 2019 AL HARAMAIN. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import RealmSwift
import Toast_Swift

class LoginVC: UIViewController {
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    
    
    let realm = try! Realm()
    lazy var userInfo: Results<UserInfo> = { self.realm.objects(UserInfo.self) }()
    //lazy var appInfo: Results<AppInfo> = { self.realm.objects(AppInfo.self) }()
    var db_ready = false
    var suspended = false
    
    var userEmail = ""
    var userCode = ""
    var userPass = ""
    var userLocation = ""
    
    var fname = "", lname = "",  phone = "", email = "", user_type = "", logged_in = "";
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        /*if appInfo.count == 0{
         let appInfo = AppInfo()
         appInfo.db_ready = false
         appInfo.suspended = false
         appInfo.logged_in = false
         
         do{
         try self.realm.write {
         self.realm.add(appInfo)
         }
         
         checkInfo = appInfo
         }catch{
         print("Error inserting data \(error)")
         }
         }else{
         checkInfo = appInfo[0]
         }*/
        
        // Do any additional setup after loading the view.
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func loginPressed(_ sender: Any) {
        
        
        guard
            let usercode = userName.text,
            usercode != "",
            let password = userPassword.text,
            password != ""
            else {
                AlertController.showAlert(self, title: "Alert", message: "Please Fill all the fields")
                
                return
        }
        
        
        userCode = usercode
        userPass = password
        userEmail = "\(userCode)@tr.com"
        
        //if let appInfo = checkInfo {
        db_ready = UserDefaults.standard.bool(forKey: Utils.DB_READY)
        suspended = UserDefaults.standard.bool(forKey: Utils.ACCOUNT_SUSPENDED)
        //}
        
        
        if (userInfo.count != 0) {
            if (userInfo[0].usercode != usercode || userInfo[0].pass != password) {
                
                AlertController.showAlert(self, title: "Invalid", message: "Invalid Username or Password.")
                
                return
            }else if (userInfo[0].usercode == usercode || userInfo[0].pass == password){
                
                Utils.location = userInfo[0].location
                
                //This method resets all data loader variables
                //DataLoader.resetAllData();
                
                UserDefaults.standard.set(true, forKey: Utils.LOGGED_IN)
                
                /*if let appInfo = checkInfo{
                 do{
                 try self.realm.write {
                 appInfo.logged_in = true
                 }
                 }catch{
                 
                 }
                 }*/
                
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
                
            }
        }else if(!db_ready && !suspended){
            
            //if let appInfo = checkInfo{
            if !db_ready{
                
                do{
                    try realm.write {
                        realm.deleteAll()
                    }
                }catch{
                    print("Error emptying database")
                }
                
            }
            //}
            
            setUpLocalDB()
            
            
        }else if(suspended){
            
            AlertController.showAlert(self, title: "Account Suspended", message: "Your Account has been suspened. Please contact Admin. Thanks.")
            
        }
        
        
        
        //loginToFirebase(email: email, password: password)
        
    }
    
    func setUpLocalDB(){
        
        //creating parameters for the post request
        let parameters: Parameters=[
            "usercode": userCode,
            "password": userPass
        ]
        
        //Sending http post request
        Alamofire.request(Utils.server_url+"get_new_userinfo.php", method: .post, parameters: parameters).responseJSON
            {
                response in
                //printing response
                //print(response)
                
                //getting the json value from the server
                if let result = response.result.value {
                    
                    if let value = result as? String{
                        print(value)
                    }
                    
                    //converting it as NSDictionary
                    if let jsonData = result as? NSArray{
                        
                        
                        for entry in jsonData {
                            
                            if let entry = entry as? NSDictionary{
                                //displaying the message in label
                                
                                let userinfo = UserInfo()
                                
                                userinfo.fname = entry.value(forKey: "fname") as? String ?? ""
                                userinfo.lname = entry.value(forKey: "lname") as? String ?? ""
                                userinfo.usercode = entry.value(forKey: "usercode") as? String ?? ""
                                userinfo.email = entry.value(forKey: "email") as? String ?? ""
                                userinfo.phone = entry.value(forKey: "phone") as? String ?? ""
                                userinfo.pass = entry.value(forKey: "password") as? String ?? ""
                                userinfo.user_type = entry.value(forKey: "user_type") as? String ?? ""
                                userinfo.location = entry.value(forKey: "location") as? String ?? ""
                                userinfo.logged_in = entry.value(forKey: "logged_in") as? String ?? ""
                                //print(fname! + lname!)
                                
                                self.fname = userinfo.fname
                                self.lname = userinfo.lname
                                self.email = userinfo.email
                                self.phone = userinfo.phone
                                self.user_type = userinfo.user_type
                                self.logged_in = userinfo.logged_in
                                
                                UserDefaults.standard.set(self.userEmail, forKey: Utils.CHAT_EMAIL)
                                UserDefaults.standard.set(self.userPass, forKey: Utils.CHAT_PASSWORD)
                                UserDefaults.standard.set(userinfo.location, forKey: Utils.CHAT_GROUP)
                                
                                if userinfo.logged_in == "1"{
                                    AlertController.showAlert(self, title: "Logged In", message: "Please contact admin to logout your account.")
                                }else{
                                    
                                    /*All checks are satisfied. Actual local db creation starts from here.
                                     We are setting this static variables for later use.
                                     */
                                    self.userLocation = userinfo.location;
                                    Utils.loginName = userinfo.usercode;
                                    Utils.location = userinfo.location;
                                    Utils.salesmanName = "\(userinfo.fname) \(userinfo.lname)";
                                    
                                    UserDefaults.standard.set(Utils.salesmanName, forKey: LiveChatUtil.CHAT_NAME)
                                    UserDefaults.standard.set("na", forKey: LiveChatUtil.PHOTO_URL)
                                    
                                    do{
                                        try self.realm.write {
                                            self.realm.add(userinfo)
                                        }
                                        
                                        //Start inserting products info if user data is inserted successfully
                                        self.insertProducts();
                                        
                                        
                                        // basic usage
                                        self.view.makeToast("Sales Executive Info Inserted Successfully")
                                        
                                    }catch{
                                        print("Error inserting data \(error)")
                                    }
                                    
                                    /*Boolean success = localDbOperations.insertUser_Info(fname, lname, usercode, email, phone, pass, user_type, location, db);
                                     if (success) {
                                     //Start inserting products info if user data is inserted successfully
                                     insertProducts();
                                     showToast("Sales Executive Info Inserted Successfully");
                                     } else {
                                     //Toast.makeText(MainActivity.this, "Insertion Error", Toast.LENGTH_SHORT).show();
                                     }*/
                                    
                                    
                                }
                                
                                
                                
                                
                            }
                        }
                    }else if let jsonData = result as? String{
                        
                        if jsonData == "na"{
                            
                            AlertController.showAlert(self, title: "Invalid", message: "Invalid Username or Password.")
                            
                        }
                    }
                }
        }
    }
    
    //Fetch all the products info of company from remote server and insert into local database
    func insertProducts(){
        //creating parameters for the post request
        let parameters: Parameters=[
            "location": userLocation
        ]
        
        //Sending http post request
        Alamofire.request(Utils.server_url+"get_all_products.php", method: .post, parameters: parameters).responseJSON
            {
                response in
                //printing response
                //print(response)
                
                //getting the json value from the server
                if let result = response.result.value {
                    
                    //converting it as NSDictionary
                    if let jsonData = result as? NSArray{
                        
                        let totalProducts = jsonData.count
                        var i = 1
                        
                        let alertController = UIAlertController(title: "Inserting Products.", message: "\(i)/\(totalProducts) inserted", preferredStyle: .alert)
                        
                        /*let progressDownload : UIProgressView = UIProgressView(progressViewStyle: .default)
                         
                         progressDownload.setProgress(Float(i)/Float(totalProducts), animated: true)
                         progressDownload.frame = CGRect(x: 10, y: 70, width: 250, height: 0)
                         
                         alertController.view.addSubview(progressDownload)*/
                        self.present(alertController, animated: true, completion: nil)
                        
                        
                        for entry in jsonData {
                            
                            if let entry = entry as? NSDictionary{
                                //displaying the message in label
                                
                                let productInfo = ProductInfo()
                                
                                productInfo.itemcode = entry.value(forKey: "itemcode") as? String ?? ""
                                productInfo.item_type = entry.value(forKey: "item_type") as? String ?? ""
                                productInfo.item_description = entry.value(forKey: "item_description") as? String ?? ""
                                productInfo.price = entry.value(forKey: "price") as? String ?? ""
                                productInfo.location = entry.value(forKey: "location") as? String ?? ""
                                productInfo.top_note = entry.value(forKey: "top_note") as? String ?? ""
                                productInfo.middle_notes = entry.value(forKey: "middle_notes") as? String ?? ""
                                productInfo.base_notes = entry.value(forKey: "base_notes") as? String ?? ""
                                
                                
                                do{
                                    try self.realm.write {
                                        self.realm.add(productInfo)
                                    }
                                    
                                    //progressDownload.setProgress(Float(i)/Float(totalProducts), animated: true)
                                    alertController.message = "\(i)/\(totalProducts) inserted"
                                    i += 1
                                    
                                }catch{
                                    print("Error inserting data \(error)")
                                }
                                
                            }
                        }
                        
                        if (i - 1) == totalProducts {
                            alertController.dismiss(animated: true, completion: nil)
                            self.insertSales()
                        }
                    }
                }
        }
    }
    
    //Fetch all previous sales entries from remote server created by that sales executive and insert into local db
    func insertSales(){
        //creating parameters for the post request
        let parameters: Parameters=[
            "usercode": userCode
        ]
        
        //Sending http post request
        Alamofire.request(Utils.server_url+"get_salesman_sales.php", method: .post, parameters: parameters).responseJSON
            {
                response in
                //printing response
                //print(response)
                
                self.view.makeToast("Inserting Sales Data. Pelase wait....")
                self.view.makeToastActivity(.center)
                
                var totalData = 0
                var i = 0
                
                DispatchQueue(label: "SalesInfo", qos: .background).async {
                    
                    
                    //getting the json value from the server
                    if let result = response.result.value {
                    
                        
                        //converting it as NSDictionary
                        if let jsonData = result as? NSArray{
                            
                            totalData = jsonData.count
                            i = 1
                            let realm = try! Realm()
                            
                            /*let alertController = UIAlertController(title: "Inserting Sales Data.", message: "\(i)/\(totalData) inserted", preferredStyle: .alert)
                             
                             let progressDownload : UIProgressView = UIProgressView(progressViewStyle: .default)
                             
                             progressDownload.setProgress(Float(i)/Float(totalData), animated: true)
                             progressDownload.frame = CGRect(x: 10, y: 70, width: 250, height: 0)
                             
                             alertController.view.addSubview(progressDownload)
                             self.present(alertController, animated: true, completion: nil)*/
                            
                            
                            for entry in jsonData {
                                
                                if let entry = entry as? NSDictionary{
                                    //displaying the message in label
                                    
                                    let saleInfo = SalesInfo()
                                    
                                    saleInfo.sale_id = Int(entry.value(forKey: "sale_id") as? String ?? "0") ?? 0
                                    saleInfo.transaction_id = entry.value(forKey: "transaction_id") as? String ?? ""
                                    saleInfo.salesman = entry.value(forKey: "salesman") as? String ?? ""
                                    saleInfo.salesman_name = entry.value(forKey: "salesman_name") as? String ?? ""
                                    saleInfo.location = entry.value(forKey: "location") as? String ?? ""
                                    saleInfo.area = entry.value(forKey: "area") as? String ?? ""
                                    saleInfo.organization = entry.value(forKey: "organization") as? String ?? ""
                                    saleInfo.itemcode = entry.value(forKey: "itemcode") as? String ?? ""
                                    saleInfo.item_description = entry.value(forKey: "item_description") as? String ?? ""
                                    saleInfo.quantity = entry.value(forKey: "quantity") as? String ?? ""
                                    saleInfo.unit_price = entry.value(forKey: "unit_price") as? String ?? ""
                                    saleInfo.total_price = entry.value(forKey: "total_price") as? String ?? ""
                                    saleInfo.date = entry.value(forKey: "date") as? String ?? ""
                                    
                                    
                                    do{
                                        try realm.write {
                                            realm.add(saleInfo)
                                        }
                                        
                                        //progressDownload.setProgress(Float(i)/Float(totalData), animated: true)
                                        //alertController.message = "\(i)/\(totalData) inserted"
                                        i += 1
                                        
                                    }catch{
                                        print("Error inserting data \(error)")
                                    }
                                    
                                }
                            }
                            
                            print("\(i) \(totalData)")
                            if (i - 1) == totalData {
                                
                                DispatchQueue.main.async {
                                    self.view.hideAllToasts(includeActivity: true, clearQueue: true)
                                    self.insertOTSales();
                                }
                                
                            }
                        }
                    }else{
                       
                        DispatchQueue.main.async {
                            self.view.hideAllToasts(includeActivity: true, clearQueue: true)
                            self.insertOTSales();
                        }
                        
                    }
                }
                
                
        }
    }
    
    //Fetch all previous OT(open tester) sales entries from remote server created by that sales executive and insert into local db
    func insertOTSales(){
        //creating parameters for the post request
        let parameters: Parameters=[
            "usercode": userCode
        ]
        
        //Sending http post request
        Alamofire.request(Utils.server_url+"get_salesman_otsales.php", method: .post, parameters: parameters).responseJSON
            {
                response in
                //printing response
                //print(response)
                
                self.view.makeToast("Inserting OT Sales Data. Pelase wait....")
                self.view.makeToastActivity(.center)
                
                var totalData = 0
                var i = 0
                
                DispatchQueue(label: "OTSales", qos: .background).async {
                    
                    
                    //getting the json value from the server
                    if let result = response.result.value {
                        
                        if let value = result as? String{
                            print(value)
                        }
                        
                        //converting it as NSDictionary
                        if let jsonData = result as? NSArray{
                            
                            totalData = jsonData.count
                            i = 1
                            let realm = try! Realm()
                            
                            for entry in jsonData {
                                
                                if let entry = entry as? NSDictionary{
                                    //displaying the message in label
                                    
                                    let saleInfo = OTSalesInfo()
                                    
                                    saleInfo.sale_id = Int(entry.value(forKey: "sale_id") as? String ?? "0") ?? 0
                                    saleInfo.transaction_id = entry.value(forKey: "transaction_id") as? String ?? ""
                                    saleInfo.salesman = entry.value(forKey: "salesman") as? String ?? ""
                                    saleInfo.salesman_name = entry.value(forKey: "salesman_name") as? String ?? ""
                                    saleInfo.location = entry.value(forKey: "location") as? String ?? ""
                                    saleInfo.area = entry.value(forKey: "area") as? String ?? ""
                                    saleInfo.organization = entry.value(forKey: "organization") as? String ?? ""
                                    saleInfo.itemcode = entry.value(forKey: "itemcode") as? String ?? ""
                                    saleInfo.item_description = entry.value(forKey: "item_description") as? String ?? ""
                                    saleInfo.quantity = entry.value(forKey: "quantity") as? String ?? ""
                                    saleInfo.unit_price = entry.value(forKey: "unit_price") as? String ?? ""
                                    saleInfo.total_price = entry.value(forKey: "total_price") as? String ?? ""
                                    saleInfo.date = entry.value(forKey: "date") as? String ?? ""
                                    
                                    
                                    do{
                                        try realm.write {
                                            realm.add(saleInfo)
                                        }
                                        
                                        i += 1
                                        
                                    }catch{
                                        print("Error inserting data \(error)")
                                    }
                                    
                                }
                            }
                            
                            print("\(i) \(totalData)")
                            if (i - 1) == totalData {
                                //alertController.dismiss(animated: true, completion: nil)
                                DispatchQueue.main.async {
                                    self.view.hideAllToasts(includeActivity: true, clearQueue: true)
                                    self.insertLocations()
                                }
                                
                            }
                        }
                    }else {
                        
                        DispatchQueue.main.async {
                            self.view.hideToastActivity()
                            self.insertLocations()
                        }
                    
                    }
                }
                
                
        }
    }
    
    //Fetch all locations from remote server and insert into local database
    func insertLocations(){
        //creating parameters for the post request
        let parameters: Parameters=[
            "organization": userLocation
        ]
        
        //Sending http post request
        Alamofire.request(Utils.server_url+"get_all_locations.php", method: .post, parameters: parameters).responseJSON
            {
                response in
                //printing response
                //print(response)
                
                self.view.makeToast("Inserting Locations Data. Pelase wait....")
                self.view.makeToastActivity(.center)
                
                var totalData = 0
                var i = 0
                
                DispatchQueue(label: "Locations", qos: .background).async {
                    
                    
                    //getting the json value from the server
                    if let result = response.result.value {
                        
                        //converting it as NSDictionary
                        if let jsonData = result as? NSArray{
                            
                            totalData = jsonData.count
                            i = 1
                            let realm = try! Realm()
                            
                            for entry in jsonData {
                                
                                if let entry = entry as? NSDictionary{
                                    //displaying the message in label
                                    
                                    let location = LocationInfo()
                                    
                                    
                                    location.main_location = entry.value(forKey: "main_location") as? String ?? ""
                                    location.sub_location = entry.value(forKey: "sub_location") as? String ?? ""
                                    location.organization = entry.value(forKey: "organization") as? String ?? ""
                                    
                                    
                                    
                                    do{
                                        try realm.write {
                                            realm.add(location)
                                        }
                                        
                                        i += 1
                                        
                                    }catch{
                                        print("Error inserting data \(error)")
                                    }
                                    
                                }
                            }
                            
                            //print("\(i) \(totalData)")
                            if (i - 1) == totalData {
                                //alertController.dismiss(animated: true, completion: nil)
                                DispatchQueue.main.async {
                                    self.view.hideAllToasts(includeActivity: true, clearQueue: true)
                                    self.insertCircular()
                                }
                                
                            }
                        }
                    }
                }
                
                
        }
    }
    
    //Fetch job circulars and notices from remote server and insert into local database
    func insertCircular(){
        
        //Sending http post request
        Alamofire.request(Utils.server_url+"get_all_circulars.php", method: .post, parameters: nil).responseJSON
            {
                response in
                //printing response
                //print(response)
                
                self.view.makeToast("Inserting Circular Data. Pelase wait....")
                self.view.makeToastActivity(.center)
                
                var totalData = 0
                var i = 0
                
                DispatchQueue(label: "Circulars", qos: .background).async {
                    
                    
                    //getting the json value from the server
                    if let result = response.result.value {
                        
                        //converting it as NSDictionary
                        if let jsonData = result as? NSArray{
                            
                            totalData = jsonData.count
                            i = 1
                            let realm = try! Realm()
                            
                            for entry in jsonData {
                                
                                if let entry = entry as? NSDictionary{
                                    //displaying the message in label
                                    
                                    let circularInfo = CircularInfo()
                                    
                                    circularInfo.circular_id = Int(entry.value(forKey: "circular_id") as? String ?? "0") ?? 0
                                    circularInfo.created_from = entry.value(forKey: "created_from") as? String ?? ""
                                    circularInfo.created_to = entry.value(forKey: "created_to") as? String ?? ""
                                    circularInfo.ref = entry.value(forKey: "ref") as? String ?? ""
                                    circularInfo.subject = entry.value(forKey: "subject") as? String ?? ""
                                    circularInfo.message = entry.value(forKey: "message") as? String ?? ""
                                    circularInfo.date = entry.value(forKey: "date") as? String ?? ""
                                    
                                    
                                    do{
                                        try realm.write {
                                            realm.add(circularInfo)
                                        }
                                        
                                        i += 1
                                        
                                    }catch{
                                        print("Error inserting data \(error)")
                                    }
                                    
                                }
                            }
                            
                            //print("\(i) \(totalData)")
                            if (i - 1) == totalData {
                                //alertController.dismiss(animated: true, completion: nil)
                                DispatchQueue.main.async {
                                    self.view.hideAllToasts(includeActivity: true, clearQueue: true)
                                    self.insertGuideline()
                                }
                                
                            }
                        }
                    }else{
                        
                        DispatchQueue.main.async {
                            self.view.hideAllToasts(includeActivity: true, clearQueue: true)
                            self.insertGuideline()
                        }
                        
                    }
                }
                
                
        }
    }
    
    //Fetch company guidelines from remote server and insert into local database
    func insertGuideline(){
        
        //Sending http post request
        Alamofire.request(Utils.server_url+"get_all_guidelines.php", method: .post, parameters: nil).responseJSON
            {
                response in
                //printing response
                //print(response)
                
                self.view.makeToast("Inserting Guideline Data. Pelase wait....")
                self.view.makeToastActivity(.center)
                
                var totalData = 0
                var i = 0
                
                DispatchQueue(label: "Guidelines", qos: .background).async {
                    
                    
                    //getting the json value from the server
                    if let result = response.result.value {
                        
                        //converting it as NSDictionary
                        if let jsonData = result as? NSArray{
                            
                            totalData = jsonData.count
                            i = 1
                            let realm = try! Realm()
                            
                            for entry in jsonData {
                                
                                if let entry = entry as? NSDictionary{
                                    //displaying the message in label
                                    
                                    let guidelineInfo = GuidelineInfo()
                                    
                                    guidelineInfo.guideline_id = Int(entry.value(forKey: "guideline_id") as? String ?? "0") ?? 0
                                    guidelineInfo.created_from = entry.value(forKey: "created_from") as? String ?? ""
                                    guidelineInfo.created_to = entry.value(forKey: "created_to") as? String ?? ""
                                    guidelineInfo.ref = entry.value(forKey: "ref") as? String ?? ""
                                    guidelineInfo.subject = entry.value(forKey: "subject") as? String ?? ""
                                    guidelineInfo.message = entry.value(forKey: "message") as? String ?? ""
                                    guidelineInfo.date = entry.value(forKey: "date") as? String ?? ""
                                    
                                    
                                    do{
                                        try realm.write {
                                            realm.add(guidelineInfo)
                                        }
                                        
                                        i += 1
                                        
                                    }catch{
                                        print("Error inserting data \(error)")
                                    }
                                    
                                }
                            }
                            
                            print("\(i) \(totalData)")
                            if (i - 1) == totalData {
                                //alertController.dismiss(animated: true, completion: nil)
                                DispatchQueue.main.async {
                                    self.view.hideAllToasts(includeActivity: true, clearQueue: true)
                                    self.insertAppSettings()
                                }
                                
                            }
                        }
                    }else{
                        
                        DispatchQueue.main.async {
                            self.view.hideAllToasts(includeActivity: true, clearQueue: true)
                            self.insertGuideline()
                        }
                        
                    }
                }
                
                
        }
    }
    
    //Fetch App Settings from remote server and insert into local database
    func insertAppSettings(){
        
        //Sending http post request
        Alamofire.request(Utils.server_url+"get_app_settings.php", method: .post, parameters: nil).responseJSON
            {
                response in
                //printing response
                //print(response)
                
                
                self.view.makeToastActivity(.center)
                
                
                DispatchQueue(label: "Guidelines", qos: .background).async {
                    
                    
                    //getting the json value from the server
                    if let result = response.result.value {
                        
                        //converting it as NSDictionary
                        if let jsonData = result as? NSArray{
                            
                            
                            
                            for entry in jsonData {
                                
                                if let entry = entry as? NSDictionary{
                                    //displaying the message in label
                                    
                                    let email_addresses = entry.value(forKey: "email_addresses") as? String ?? ""
                                    
                                    UserDefaults.standard.set(email_addresses, forKey: Utils.EMAIL_ADDRESSES)
                                    
                                }
                            }
                            
                            
                            DispatchQueue.main.async {
                                self.view.hideAllToasts(includeActivity: true, clearQueue: true)
                                self.insertAppUpdate()
                            }
                            
                            
                        }
                    }
                }
                
                
        }
    }
    
    //Fetch product, location, circular, guideline update status from server and insert current update number
    func insertAppUpdate(){
        
        //Sending http post request
        Alamofire.request(Utils.server_url+"get_app_update.php", method: .post, parameters: nil).responseJSON
            {
                response in
                //printing response
                //print(response)
                
                
                self.view.makeToastActivity(.center)
                
                
                DispatchQueue(label: "App Updates", qos: .background).async {
                    
                    
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
                                    let otemail_update = Int(entry.value(forKey: "otemail_update") as? String ?? "") ?? 0
                                    
                                    UserDefaults.standard.set(product_update, forKey: Utils.PRODUCT_UPDATE)
                                    UserDefaults.standard.set(location_update, forKey: Utils.LOCATION_UPDATE)
                                    UserDefaults.standard.set(circular_update, forKey: Utils.CIRCULAR_UPDATE)
                                    UserDefaults.standard.set(guideline_update, forKey: Utils.GUIDELINE_UPDATE)
                                    UserDefaults.standard.set(otemail_update, forKey: Utils.OTEMAIL_UPDATE)
                                    
                                    UserDefaults.standard.set(0, forKey: Utils.UPDATE_AVAILABLE)
                                    UserDefaults.standard.set(1, forKey: Utils.LOGGED_IN)
                                    UserDefaults.standard.set(0, forKey: Utils.ACCOUNT_SUSPENDED)
                                    UserDefaults.standard.set(true, forKey: Utils.DB_READY)
                                    UserDefaults.standard.set(0, forKey: Utils.NOTIFICATIONID)
                                    
                                    
                                    
                                }
                            }
                            
                            
                            DispatchQueue.main.async {
                                
                                self.view.hideAllToasts(includeActivity: true, clearQueue: true)
                                self.updateLogged()
                            }
                            
                            
                        }
                    }
                }
                
                
        }
    }
    
    /*
     Update Successfully Logged in status in remote server. This prevents user to use the app on different devices
     at the same time.
     */
    func updateLogged(){
        
        //creating parameters for the post request
        let parameters: Parameters=[
            "usercode": userCode
        ]
        
        //Sending http post request
        Alamofire.request(Utils.server_url+"update_logged.php", method: .post, parameters: parameters).responseJSON
            {
                response in
                
                self.startLiveChatLogin()
        }
    }
    
    
    func startLiveChatLogin(){
        Auth.auth().fetchSignInMethods(forEmail: userEmail){ signInMethods, error in
            
            if let err = error {
                AlertController.showAlert(self, title: "Error!", message: err.localizedDescription)
                return
            }
            
            if signInMethods != nil{
                self.loginLiveChat(email: self.userEmail,password: self.userPass)
            }else{
                self.createLiveChatUser()
            }
            
        }
    }
    
    
    func loginLiveChat(email: String,password: String){
        
        Auth.auth().signIn(withEmail: email, password: password) {  authResult, error in
            
            if let user = authResult?.user{
                Utils.saveToken(ref: self.ref, currentUserId: user.uid)
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
            
            if(error != nil){
                AlertController.showAlert(self, title: "Error!", message: error!.localizedDescription)
            }
        }
    }
    
    func createLiveChatUser(){
        Auth.auth().createUser(withEmail: userEmail, password: userPass) { authResult, error in
            
            
            if let user = authResult?.user{
                
                Utils.saveToken(ref: self.ref, currentUserId: user.uid)
                self.createChatUserInfo(currentUserId: user.uid)
            }
            
            if error != nil{
                AlertController.showAlert(self, title: "Error!", message: error!.localizedDescription)
            }
        }
    }
    
    func createChatUserInfo(currentUserId: String){
        
        let userInfo = ["name": "\(fname) \(lname)",
                    "status": "\(userLocation) user",
                    "uid": currentUserId,
                    "usercode": userCode,
                    "email": email,
                    "phone": phone,
                    "password": userPass,
                    "user_type": user_type,
                    "location": userLocation]
        
        let childUpdates = ["/Users/\(currentUserId)": userInfo]
        
        ref.updateChildValues(childUpdates){
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("Data could not be saved: \(error).")
            } else {
                print("Data saved successfully!")
                
                ref.child("GroupMembers").child(self.userLocation).child(currentUserId).child("saved").setValue(true){
                    (error:Error?, ref:DatabaseReference) in
                    if let error = error {
                        print("Data could not be saved: \(error).")
                    } else {
                        print("Data saved successfully!")
                        self.performSegue(withIdentifier: "loginSegue", sender: nil)
                    }
                }
            }
        }
        

    }
    

}

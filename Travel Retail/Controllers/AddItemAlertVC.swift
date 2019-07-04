//
//  AddItemAlertVC.swift
//  Travel Retail
//
//  Created by Anis Mizi on 5/6/19.
//  Copyright © 2019 AL HARAMAIN. All rights reserved.
//

import UIKit
import SearchTextField
import RealmSwift
import Toast_Swift

class AddItemAlertVC: UIViewController {
    
    @IBOutlet weak var searchItem: SearchTextField!
    @IBOutlet weak var enterQuantity: UITextField!
    
    let realm = try! Realm()
    var itemCodes: [String] = []
    
    var delegate: AddItemDelegate?
    var editDelegate: EditItemDelegate?
    
    var itemCode: String?
    var quantity: String?
    
//    lazy var productCodes: Results<ProductInfo> = { self.realm.objects(ProductInfo.self).filter("item_type = '\(DailySalesVC.subArea ?? "")'") } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if delegate != nil {
            
            let productCodes = self.realm.objects(ProductInfo.self).filter("item_type = '\(DailySalesVC.subArea ?? "")'")
            
            if(productCodes.count != 0){
                for item in productCodes{
                    itemCodes.append(item.itemcode)
                }
            }
            
        }else if editDelegate != nil {
            
            searchItem.text = itemCode
            enterQuantity.text = quantity            
            
            let productCodes = self.realm.objects(ProductInfo.self).filter("item_type = '\(EditSalesDetailsVC.subArea ?? "")'")
            
            if(productCodes.count != 0){
                for item in productCodes{
                    itemCodes.append(item.itemcode)
                }
            }
            
        }
        
        // Do any additional setup after loading the view.
        searchItem.filterStrings(itemCodes)
        
        // Handle what happens when the user picks an item. By default the title is set to the text field
        searchItem.itemSelectionHandler = {filteredResults, itemPosition in
            
            // Just in case you need the item position
            let item = filteredResults[itemPosition]
            print("Item at position \(itemPosition): \(item.title)")
            
            // Do whatever you want with the picked item
            self.searchItem.text = item.title
            
        }
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true)
        print("Dismiss Clicked")
    }
    
    @IBAction func addItem(_ sender: UIButton) {
        print("Ok Clicked")
        
        if delegate != nil{
            addItemOperation()
        }else if editDelegate != nil{
            let selectedItem = self.searchItem.text
            let quan = self.enterQuantity.text
            let quantity = Double(quan ?? "0") ?? 0
            let productInfo = self.realm.objects(ProductInfo.self).filter("itemcode = '\(selectedItem ?? "")'")
            if productInfo.count != 0{
                let product = productInfo[0]
                editDelegate?.okButtonTapped(product: product, quantity: quantity)
            }
            dismiss(animated: true)
        }
        
    }
    
    func addItemOperation(){
        let selectedItem = self.searchItem.text
        let quantity = Int(self.enterQuantity.text ?? "0")
        
        if(selectedItem == nil || quantity! <= 0){
            self.view.makeToast("Invalid ItemCode or Quantity.")
        }else if(itemCodes.contains(selectedItem ?? "")){
            
            //Fetch product details of user selected product code
            let fetchProduct = { self.realm.objects(ProductInfo.self).filter("itemcode = '\(selectedItem ?? "")'")}()
            
            var productDetails: ProductInfo?
            
            if fetchProduct.count != 0{
                productDetails = fetchProduct[0]
            }
            
            let tranNumber = UserDefaults.standard.string(forKey: Utils.TRANSACTION_ID) ?? ""
            let newTransaction = "\(Utils.loginName)_\(tranNumber)"
            
            let saleInfo = SalesInfo()
            saleInfo.sale_id = Int(tranNumber) ?? 0
            saleInfo.transaction_id = newTransaction
            saleInfo.salesman = Utils.loginName
            saleInfo.salesman_name = Utils.salesmanName
            saleInfo.location = DailySalesVC.mainArea ?? ""
            saleInfo.area = DailySalesVC.subArea ?? ""
            saleInfo.organization = Utils.location
            saleInfo.itemcode = productDetails?.itemcode ?? ""
            saleInfo.item_description = productDetails?.item_description ?? ""
            saleInfo.quantity = self.enterQuantity.text ?? "0"
            saleInfo.unit_price = productDetails?.price ?? ""
            
            let quantityInDouble = Double(self.enterQuantity.text ?? "0") ?? 0
            let priceInDouble = Double(productDetails?.price ?? "0") ?? 0
            
            saleInfo.total_price = "\( quantityInDouble * priceInDouble)"
            saleInfo.date = DailySalesVC.transDate ?? ""
            
            let tempSaleInfo = TempSalesInfo()
            tempSaleInfo.sale_id = saleInfo.sale_id
            tempSaleInfo.transaction_id = newTransaction
            tempSaleInfo.salesman = Utils.loginName
            tempSaleInfo.salesman_name = Utils.salesmanName
            tempSaleInfo.location = DailySalesVC.mainArea ?? ""
            tempSaleInfo.area = DailySalesVC.subArea ?? ""
            tempSaleInfo.organization = Utils.location
            tempSaleInfo.itemcode = productDetails?.itemcode ?? ""
            tempSaleInfo.item_description = productDetails?.item_description ?? ""
            tempSaleInfo.quantity = self.enterQuantity.text ?? "0"
            tempSaleInfo.unit_price = productDetails?.price ?? ""
            tempSaleInfo.total_price = "\( quantityInDouble * priceInDouble)"
            tempSaleInfo.date = saleInfo.date
            
            DailySalesVC.productCode = saleInfo.itemcode
            DailySalesVC.productDesc = saleInfo.item_description
            DailySalesVC.totalProduct = saleInfo.quantity
            DailySalesVC.totalCost = saleInfo.total_price
            DailySalesVC.transDate = saleInfo.date
            
            var successMsg = ""
            
            if Utils.dailySales {
                
                do{
                    try realm.write {
                        realm.add(saleInfo)
                    }
                    
                    try realm.write {
                        realm.add(tempSaleInfo)
                    }
                    
                    UserDefaults.standard.set( saleInfo.sale_id + 1 , forKey: Utils.TRANSACTION_ID)
                    
                    DailySalesVC.newTransaction = newTransaction
                    
                    successMsg = "Successfully Inserted."
                    //self.view.makeToast("Successfully Inserted.")
                    
                    
                }catch{
                    //self.view.makeToast("Error inserting data \(error)")
                    successMsg = "Error inserting data \(error)"
                    print("Error inserting data \(error)")
                    
                }
                
                self.delegate?.okButtonTapped(msg: successMsg)
                dismiss(animated: true)
                
            }else if Utils.otsales {
                
                let otTranNumber = UserDefaults.standard.string(forKey: Utils.OTTRANSACTION_ID) ?? ""
                let otNewTransaction = "\(Utils.loginName)_\(otTranNumber)"
                
                let otSaleInfo = OTSalesInfo()
                otSaleInfo.sale_id = Int(otTranNumber) ?? 0
                otSaleInfo.transaction_id = otNewTransaction
                otSaleInfo.salesman = Utils.loginName
                otSaleInfo.salesman_name = Utils.salesmanName
                otSaleInfo.location = DailySalesVC.mainArea ?? ""
                otSaleInfo.area = DailySalesVC.subArea ?? ""
                otSaleInfo.organization = Utils.location
                otSaleInfo.itemcode = productDetails?.itemcode ?? ""
                otSaleInfo.item_description = productDetails?.item_description ?? ""
                otSaleInfo.quantity = self.enterQuantity.text ?? "0"
                otSaleInfo.unit_price = productDetails?.price ?? ""
                otSaleInfo.total_price = "\( quantityInDouble * priceInDouble)"
                otSaleInfo.date = DailySalesVC.transDate ?? ""
                
                let otTempSaleInfo = OTTempSalesInfo()
                otTempSaleInfo.sale_id = Int(otTranNumber) ?? 0
                otTempSaleInfo.transaction_id = otNewTransaction
                otTempSaleInfo.salesman = Utils.loginName
                otTempSaleInfo.salesman_name = Utils.salesmanName
                otTempSaleInfo.location = DailySalesVC.mainArea ?? ""
                otTempSaleInfo.area = DailySalesVC.subArea ?? ""
                otTempSaleInfo.organization = Utils.location
                otTempSaleInfo.itemcode = productDetails?.itemcode ?? ""
                otTempSaleInfo.item_description = productDetails?.item_description ?? ""
                otTempSaleInfo.quantity = self.enterQuantity.text ?? "0"
                otTempSaleInfo.unit_price = productDetails?.price ?? ""
                otTempSaleInfo.total_price = "\( quantityInDouble * priceInDouble)"
                otTempSaleInfo.date = DailySalesVC.transDate ?? ""
                
                do{
                    try realm.write {
                        realm.add(otSaleInfo)
                    }
                    
                    try realm.write {
                        realm.add(otTempSaleInfo)
                    }
                    
                    UserDefaults.standard.set( otSaleInfo.sale_id + 1 , forKey: Utils.OTTRANSACTION_ID)
                    
                    DailySalesVC.otNewTransaction = otNewTransaction
                    
                    //self.view.makeToast("OT inserted Successfully.")
                    
                    successMsg = "OT inserted Successfully."
                    //dismiss(animated: true)
                    
                }catch{
                    //self.view.makeToast("Error inserting OT data \(error)")
                    print("Error inserting OT data \(error)")
                    successMsg = "Error inserting OT data \(error)"
                    //dismiss(animated: true)
                }
                
                self.delegate?.okButtonTapped(msg: successMsg)
                dismiss(animated: true)
                
            }
        }
    }
    
}

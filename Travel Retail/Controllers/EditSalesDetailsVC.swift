//
//  EditSalesDetailsVC.swift
//  Travel Retail
//
//  Created by Anis Mizi on 5/16/19.
//  Copyright © 2019 AL HARAMAIN. All rights reserved.
//

import UIKit
import RealmSwift
import Toast_Swift

class EditSalesDetailsVC: UIViewController {
    
    let alertService = AlertService()
    var delegate: AddItemDelegate?
    var saleInfo: SalesInfo?
    var otsaleInfo: OTSalesInfo?
    let realm = try! Realm()
    
    static var subArea: String?
    
    @IBOutlet weak var locValue: UILabel!
    @IBOutlet weak var areaValue: UILabel!
    @IBOutlet weak var itemCode: UILabel!
    @IBOutlet weak var itemDescription: UILabel!
    @IBOutlet weak var quantity: UILabel!
    @IBOutlet weak var totalPrice: UILabel!
    @IBOutlet weak var salesExe: UILabel!
    @IBOutlet weak var saleDate: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        if Utils.dailySales{
            locValue.text = saleInfo?.location
            areaValue.text = saleInfo?.area
            itemCode.text = saleInfo?.itemcode
            itemDescription.text = saleInfo?.item_description
            quantity.text = saleInfo?.quantity
            totalPrice.text = saleInfo?.total_price
            salesExe.text = Utils.salesmanName
            saleDate.text = saleInfo?.date
            
            EditSalesDetailsVC.subArea = saleInfo?.area
            
        }else if Utils.otsales{
            locValue.text = otsaleInfo?.location
            areaValue.text = otsaleInfo?.area
            itemCode.text = otsaleInfo?.itemcode
            itemDescription.text = otsaleInfo?.item_description
            quantity.text = otsaleInfo?.quantity
            totalPrice.text = otsaleInfo?.total_price
            salesExe.text = Utils.salesmanName
            saleDate.text = otsaleInfo?.date
            
            EditSalesDetailsVC.subArea = otsaleInfo?.area
        }
        
        
    }
    
    
    @IBAction func editItem(_ sender: UIButton) {
        
        let alertVc = alertService.alert()
        alertVc.editDelegate = self
        
        if Utils.dailySales {
            alertVc.itemCode = saleInfo?.itemcode
            alertVc.quantity = saleInfo?.quantity
        }else if Utils.otsales {
            alertVc.itemCode = otsaleInfo?.itemcode
            alertVc.quantity = otsaleInfo?.quantity
        }
        
        present(alertVc,animated: true)
        
    }
    @IBAction func deleteItem(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "Delete Entry", message: "Are you sure to delete this entry?", preferredStyle: .alert)
        
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler:
            { action -> Void in
                // Put your code here
               print("\(Utils.dailySales) \(Utils.otsales)")
                if Utils.dailySales{
                    
                    if let sale = self.saleInfo{
                        
                        do{
                            try self.realm.write {
                                self.realm.delete(self.realm.objects(SalesInfo.self).filter("transaction_id = '\(sale.transaction_id)'"))
                            }
                            
                            
                            let deletedSale = DeletedSalesInfo()
                            deletedSale.sale_id = sale.sale_id
                            deletedSale.transaction_id = sale.transaction_id
                            deletedSale.salesman = sale.salesman
                            
                            try self.realm.write {
                                self.realm.add(deletedSale)
                            }
                            
                            
                            try self.realm.write {
                                self.realm.delete(self.realm.objects(TempSalesInfo.self).filter("transaction_id = '\(sale.transaction_id)'"))
                            }
                            
                            
                            try self.realm.write {
                                self.realm.delete(self.realm.objects(EditedSalesInfo.self).filter("transaction_id = '\(sale.transaction_id)'"))
                            }
                            
                            self.delegate?.okButtonTapped(msg: "Sales entry was deleted Successfully")
                            
                            self.dismiss(animated: true)
                            
                        }catch{
                            print("Error deleting data \(error)")
                        }
                    }else{
                        print("salesDetails empty")
                    }
                    
                }else if Utils.otsales{
                    
                    if let sale = self.otsaleInfo{
                        
                        do{

                
                            
                            let deletedSale = OTDeletedSalesInfo()
                            deletedSale.sale_id = sale.sale_id
                            deletedSale.transaction_id = sale.transaction_id
                            deletedSale.salesman = sale.salesman
                            
                            try self.realm.write {
                                self.realm.add(deletedSale)
                            }
                            
                            
                            try self.realm.write {
                                self.realm.delete(self.realm.objects(OTTempSalesInfo.self).filter("transaction_id = '\(sale.transaction_id)'"))
                            }
                            
                            
                            
                            
                            try self.realm.write {
                                self.realm.delete(self.realm.objects(OTEditedSalesInfo.self).filter("transaction_id = '\(sale.transaction_id)'"))
                            }
                            
                            try self.realm.write {
                                self.realm.delete(self.realm.objects(OTSalesInfo.self).filter("transaction_id = '\(sale.transaction_id)'"))
                            }
                            
                            self.delegate?.okButtonTapped(msg: "OT sales entry was deleted Successfully")
                            
                            self.dismiss(animated: true)
                            
                        }catch{
                            print("Error deleting data \(error)")
                        }
                    }else{
                        print("salesDetails empty")
                    }
                    
                }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        
    }
    @IBAction func updateSale(_ sender: UIButton) {
        
        if let sale = self.saleInfo{
            
            let fetchSale = self.realm.objects(SalesInfo.self).filter("transaction_id = '\(sale.transaction_id)'")
            var tempSale: SalesInfo?
            if let saleInfo = fetchSale.first{
                
                tempSale = saleInfo
                
                do{
                    try self.realm.write {
                        //saleInfo.location = locValue.text ?? ""
                        //saleInfo.area = areaValue.text ?? ""
                        //saleInfo.organization = Utils.location
                        saleInfo.itemcode = itemCode.text ?? ""
                        saleInfo.item_description = itemDescription.text ?? ""
                        saleInfo.quantity = quantity.text ?? ""
                        saleInfo.total_price = totalPrice.text ?? ""
                        saleInfo.date = saleDate.text ?? ""
                    }
                    print("Editing SaleInfo \(sale.transaction_id)")
                }catch{
                    print("Error deleting data \(error)")
                }
            }
            
            let fetchEditedSale = self.realm.objects(EditedSalesInfo.self).filter("transaction_id = '\(sale.transaction_id)'")
            if let saleInfo = fetchEditedSale.first{
                do{
                    try self.realm.write {
                        saleInfo.location = locValue.text ?? ""
                        saleInfo.area = areaValue.text ?? ""
//                        saleInfo.organization = UserDefaults.standard.string(forKey: Utils.location) ?? ""
                        saleInfo.itemcode = itemCode.text ?? ""
                        saleInfo.item_description = itemDescription.text ?? ""
                        saleInfo.quantity = quantity.text ?? ""
                        saleInfo.total_price = totalPrice.text ?? ""
                        saleInfo.date = saleDate.text ?? ""
                    }
                }catch{
                    print("Error deleting data \(error)")
                }
            }else{
                //if let newEditedSale = fetchSale.first{
                    do{
                    
                        let saleInfo = EditedSalesInfo()
                        saleInfo.sale_id = tempSale?.sale_id ?? 0
                        saleInfo.transaction_id = tempSale?.transaction_id ?? ""
                        saleInfo.salesman = tempSale?.salesman ?? ""
                        saleInfo.salesman_name = tempSale?.salesman_name ?? ""
                        saleInfo.location = tempSale?.location ?? ""
                        saleInfo.area = areaValue.text ?? ""
                        saleInfo.organization = Utils.location
                        saleInfo.itemcode = itemCode.text ?? ""
                        saleInfo.item_description = itemDescription.text ?? ""
                        saleInfo.quantity = quantity.text ?? ""
                        saleInfo.unit_price = tempSale?.unit_price ?? ""
                        saleInfo.total_price = totalPrice.text ?? ""
                        saleInfo.date = saleDate.text ?? ""
                        
                        
                        /*saleInfo.location = locValue.text ?? ""
                        saleInfo.area = areaValue.text ?? ""
//                        saleInfo.organization = UserDefaults.standard.string(forKey: Utils.location) ?? ""
                        saleInfo.itemcode = itemCode.text ?? ""
                        saleInfo.item_description = itemDescription.text ?? ""
                        saleInfo.quantity = quantity.text ?? ""
                        saleInfo.total_price = totalPrice.text ?? ""
                        saleInfo.date = saleDate.text ?? ""*/
                        
                        try self.realm.write {
                            self.realm.add(saleInfo)
                            
                        }
                    }catch{
                        print("Error deleting data \(error)")
                    }
                //}
            }
            
            self.delegate?.okButtonTapped(msg: "Successfully Updated")
            dismiss(animated: true)
            
        }else if let sale = self.otsaleInfo{
            
            let fetchSale = self.realm.objects(OTSalesInfo.self).filter("transaction_id = '\(sale.transaction_id)'")
            //let saleInfo = fetchSale[0]
            var tempOtSale: OTSalesInfo?
            if let otSaleInfo = fetchSale.first{
                
                tempOtSale = otSaleInfo
                
                do{
                    try self.realm.write {
                        //saleInfo.location = locValue.text ?? ""
                        //saleInfo.area = areaValue.text ?? ""
//                        otSaleInfo.organization = UserDefaults.standard.string(forKey: Utils.location) ?? ""
                        otSaleInfo.itemcode = itemCode.text ?? ""
                        otSaleInfo.item_description = itemDescription.text ?? ""
                        otSaleInfo.quantity = quantity.text ?? ""
                        otSaleInfo.total_price = totalPrice.text ?? ""
                        otSaleInfo.date = saleDate.text ?? ""
                    }
                    print("Editing SaleInfo \(sale.transaction_id)")
                }catch{
                    print("Error deleting data \(error)")
                }
            }
            
            let fetchEditedSale = self.realm.objects(OTEditedSalesInfo.self).filter("transaction_id = '\(sale.transaction_id)'")
            if let saleInfo = fetchEditedSale.first{
                do{
                    try self.realm.write {
                        //saleInfo.location = locValue.text ?? ""
                        //saleInfo.area = areaValue.text ?? ""
//                        saleInfo.organization = UserDefaults.standard.string(forKey: Utils.location) ?? ""
                        saleInfo.itemcode = itemCode.text ?? ""
                        saleInfo.item_description = itemDescription.text ?? ""
                        saleInfo.quantity = quantity.text ?? ""
                        saleInfo.total_price = totalPrice.text ?? ""
                        saleInfo.date = saleDate.text ?? ""
                    }
                }catch{
                    print("Error deleting data \(error)")
                }
            }else{
                do{
                    let saleInfo = OTEditedSalesInfo()
                    saleInfo.sale_id = tempOtSale?.sale_id ?? 0
                    saleInfo.transaction_id = tempOtSale?.transaction_id ?? ""
                    saleInfo.salesman = tempOtSale?.salesman ?? ""
                    saleInfo.salesman_name = tempOtSale?.salesman_name ?? ""
                    saleInfo.location = tempOtSale?.location ?? ""
                    saleInfo.area = areaValue.text ?? ""
                    saleInfo.organization = Utils.location
                    saleInfo.itemcode = itemCode.text ?? ""
                    saleInfo.item_description = itemDescription.text ?? ""
                    saleInfo.quantity = quantity.text ?? ""
                    saleInfo.unit_price = tempOtSale?.unit_price ?? ""
                    saleInfo.total_price = totalPrice.text ?? ""
                    saleInfo.date = saleDate.text ?? ""
                    
                    try self.realm.write {
                        self.realm.add(saleInfo)
                        
                    }
                }catch{
                    print("Error deleting data \(error)")
                }
            }
            
            self.delegate?.okButtonTapped(msg: "Successfully Updated")
            dismiss(animated: true)
            
        }
    }
    @IBAction func cancelSale(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
}

extension EditSalesDetailsVC: EditItemDelegate{
    
    func okButtonTapped(product: ProductInfo, quantity: Double) {
        
        itemCode.text = product.itemcode
        itemDescription.text = product.item_description
        self.quantity.text = "\(Int(quantity))"
        totalPrice.text = "\(quantity * (Double(product.price) ?? 0))"
        
    }
    
    func cancelButtonTapped() {
        
    }
}

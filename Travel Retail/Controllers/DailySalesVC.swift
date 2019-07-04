//
//  DailySalesVC.swift
//  Travel Retail
//
//  Created by Anis Mizi on 5/6/19.
//  Copyright © 2019 AL HARAMAIN. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import Toast_Swift

class DailySalesVC: UIViewController{
    
    //var addItemDialog: AddItemVC?
    let alertService = AlertService()
    let realm = try! Realm()
    
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var area: UILabel!
    @IBOutlet weak var itemCode: UILabel!
    @IBOutlet weak var productDescription: UILabel!
    @IBOutlet weak var quantity: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var salesExe: UILabel!
    @IBOutlet weak var saleDate: UILabel!
    
    static var mainArea: String?
    static var subArea: String?
    static var transDate: String?
    static var newTransaction: String?
    static var otNewTransaction: String?
    
    static var productCode: String?
    static var productDesc: String?
    static var totalProduct: String?
    static var totalCost: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Insert New Sales"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let now = Date()
        let dateString = formatter.string(from:now)
        
        self.saleDate.text = dateString
        self.location.text = DailySalesVC.mainArea
        self.area.text = DailySalesVC.subArea
        self.salesExe.text = Utils.salesmanName
        
        DailySalesVC.transDate = dateString
        
        
        /*addItemDialog = self.storyboard?.instantiateViewController(withIdentifier: "addItemdialog") as? AddItemVC
         addItemDialog?.providesPresentationContextTransitionStyle = true
         addItemDialog?.definesPresentationContext = true
         addItemDialog?.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
         addItemDialog?.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
         addItemDialog?.delegate = self*/
        
    }
    
    @IBAction func addItem(_ sender: UIButton) {
        /*if let addItem = addItemDialog{
         self.present(addItem, animated: true, completion: nil)
         }*/
        let alertVc = alertService.alert()
        alertVc.delegate = self
        present(alertVc,animated: true)
    }
    
    @IBAction func deleteItem(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "Delete Entry", message: "Are you sure to delete this entry?", preferredStyle: .alert)
        
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler:
            { action -> Void in
                do{
                    try self.realm.write {
                        self.realm.delete(self.realm.objects(SalesInfo.self).filter("transaction_id = '\(DailySalesVC.newTransaction ?? "")'"))
                    }
                    
                    try self.realm.write {
                        self.realm.delete(self.realm.objects(TempSalesInfo.self).filter("transaction_id = '\(DailySalesVC.newTransaction ?? "")'"))
                    }
                    
                    self.view.makeToast("Entry was deleted Successfully")
                    self.itemCode.text = ""
                    self.productDescription.text = ""
                    self.quantity.text = ""
                    self.price.text = ""
                    
                }catch{
                    print("Error deleting data \(error)")
                }
                
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}

extension DailySalesVC: AddItemDelegate{
    
    func okButtonTapped(msg: String) {
        self.itemCode.text = DailySalesVC.productCode
        self.productDescription.text = DailySalesVC.productDesc
        self.quantity.text = DailySalesVC.totalProduct
        self.price.text = DailySalesVC.totalCost
        self.saleDate.text = DailySalesVC.transDate
        self.view.makeToast(msg)
    }
    
    func cancelButtonTapped() {
        print("Cancel Button Pressed")
    }
    
    
}

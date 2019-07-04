//
//  PriceListVC.swift
//  Travel Retail
//
//  Created by Anis Mizi on 3/28/19.
//  Copyright © 2019 AL HARAMAIN. All rights reserved.
//

import UIKit
import RealmSwift
import SearchTextField
import Toast_Swift

class PriceListVC: UIViewController {
    
    @IBOutlet weak var searchProduct: SearchTextField!
    @IBOutlet weak var tableView: UITableView!
    let realm = try! Realm()
    
    lazy var productsInfo: Results<ProductInfo> = {self.realm.objects(ProductInfo.self)}()
    
    var allProducts: [ProductInfo] = []
    var itemCodes: [String] = []
    
    let alertService = AlertService()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "PriceList"
        navigationItem.largeTitleDisplayMode = .never
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        if(productsInfo.count != 0){

            var i = 0
            for product in productsInfo{
                i += 1
                let singleProduct = ProductInfo(value: product)
                singleProduct.sl = "\(i)"
                allProducts.append(singleProduct)
                itemCodes.append(product.itemcode)
            }
            
        }
        
        setProductSearch()
        
    }
    
    func setProductSearch(){
        searchProduct.filterStrings(itemCodes)
        
        searchProduct.itemSelectionHandler = {filteredResults, itemPosition in
            
            // Just in case you need the item position
            let item = filteredResults[itemPosition]
            
            
            // Do whatever you want with the picked item
            self.searchProduct.text = item.title
        }
    }
    

    @IBAction func searchPressed(_ sender: UIButton) {
        let code = searchProduct.text ?? ""
        
        if itemCodes.contains(code){
            
            //Fetch product details of user selected product code
            let fetchProduct = { self.realm.objects(ProductInfo.self).filter("itemcode = '\(code)'")}()
            
            var productDetails: ProductInfo?
            
            if fetchProduct.count != 0{
                productDetails = fetchProduct[0]
            }
            
            allProducts = []
            
            if let product = productDetails{
                allProducts.append(product)
            }
            
            tableView.reloadData()
            
        }else{
            self.view.makeToast("Invalid Product Code")
        }
    }
    
}

extension PriceListVC: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let product = allProducts[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PriceListCell") as! PriceListCell
        
        cell.setPriceListCell(product: product)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let product = allProducts[indexPath.row]
        
        let alertVc = alertService.priceListDetailsAlert()
        alertVc.productInfo = product
        present(alertVc,animated: true)
        
    }
    
}

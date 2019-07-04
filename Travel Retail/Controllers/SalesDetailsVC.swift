//
//  SalesDetails.swift
//  Travel Retail
//
//  Created by Anis Mizi on 5/14/19.
//  Copyright © 2019 AL HARAMAIN. All rights reserved.
//

import UIKit
import RealmSwift
import TPPDF
import MessageUI

class SalesDetailsVC: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var salesman: UILabel!
    @IBOutlet weak var showDate: UITextField!
    @IBOutlet weak var saleDetailsTable: UITableView!
    
    @IBOutlet weak var otSendButton: UIButton!
    var realm = try! Realm()
    //lazy var fetchSalesDetails: Results<SalesInfo> = {self.realm.objects(SalesInfo.self)}()
    var allSales: [SalesInfo] = []
    var tempSales: [SalesInfo] = []
    
    var allOtSales: [OTSalesInfo] = []
    //var tempOtSales: [OTSalesInfo] = []
    
    //UIDate Picker
    let datePicker = UIDatePicker()
    
    let alertService = AlertService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        title = "Sales Details"
        saleDetailsTable.delegate = self
        saleDetailsTable.dataSource = self
        showDatePicker()
        
        self.salesman.text = Utils.salesmanName
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let now = Date()
        let dateString = formatter.string(from:now)
        showDate.text = dateString
        
        refReshList(salesDate: dateString)
    }
    
    func refReshList(salesDate: String){
        
        print("\(Utils.dailySales) \(Utils.otsales)")
        if(Utils.dailySales){
            
            fetchSaleDetails(salesDate: salesDate)
            otSendButton.isHidden = true
            
        }else if Utils.otsales{
            
            let fetchOtSalesDetails: Results<OTSalesInfo> = self.realm.objects(OTSalesInfo.self)
                .filter("date = '\(salesDate)'")
                .sorted(byKeyPath: "location", ascending: true)
                .sorted(byKeyPath: "area", ascending: true)
            
            allOtSales = []
            //tempOtSales = []
            
            if fetchOtSalesDetails.count != 0 {
                
                var i = 1
                for otSaleInfo in fetchOtSalesDetails{
                    
                    let otSale = OTSalesInfo(value: otSaleInfo)
                    otSale.sale_id = i
                    allOtSales.append(otSale)
                    
                    i += 1
                }
                
            }else{
                print("OT sales is empty")
            }
            
            saleDetailsTable.reloadData()
            
        }
        
    }
    
    func fetchSaleDetails(salesDate: String){
        //let fetchSalesDetails = realm.objects(SalesInfo.self).filter("date = '\(salesDate)'")
        //        let sortProperties = [SortDescriptor(keyPath: "location", ascending: true), SortDescriptor(keyPath: "area", ascending: true)]
        let fetchSalesDetails: Results<SalesInfo> = self.realm.objects(SalesInfo.self)
            .filter("date = '\(salesDate)'")
            .sorted(byKeyPath: "location", ascending: true)
            .sorted(byKeyPath: "area", ascending: true)
        
        allSales = []
        tempSales = []
        
        if fetchSalesDetails.count != 0 {
            
            for saleInfo in fetchSalesDetails{
                allSales.append(saleInfo)
            }
            
            print("\(allSales.count) \(allSales[0].transaction_id)")
            
            var netprice = 0.0
            var location = "\(allSales[0].location)-\(allSales[0].area)"
            var gross_total = 0.0
            
            
            for i in 0..<allSales.count {
                
                //print("Inside if \(location) : \(allSales[i].location)-\(allSales[i].area)")
                if location == "\(allSales[i].location)-\(allSales[i].area)" {
                    
                    let tempSale = SalesInfo(value: allSales[i])
                    
                    
                    gross_total = gross_total + (Double(allSales[i].total_price) ?? 0 )
                    tempSale.sale_id = (i + 1)
                    tempSale.location = location
                    
                    tempSales.append(tempSale)
                    
                    //print("Inside if \(allSales.count - 1) == \(i)")
                    if (allSales.count - 1) == i {
                        
                        let tempSale = SalesInfo()
                        
                        //tempSale.sale_id = (i + 1)
                        tempSale.transaction_id = "gross"
                        tempSale.salesman = ""
                        tempSale.salesman_name = ""
                        tempSale.location = ""
                        tempSale.area = ""
                        tempSale.organization = ""
                        tempSale.itemcode = "GROSS"
                        tempSale.item_description = ""
                        tempSale.quantity = "TOTAL"
                        tempSale.unit_price = ""
                        
                        let price = gross_total.truncatingRemainder(dividingBy: 1);
                        var pro_price = "";
                        
                        if (price == 0.0){
                            pro_price = "\(Int(gross_total)) "
                        }
                        else{
                            pro_price = "\(gross_total)";
                        }
                        
                        tempSale.total_price = pro_price
                        tempSale.date = ""
                        tempSale.location = ""
                        
                        netprice = netprice + gross_total;
                        
                        //allSales[i] = tempSale
                        tempSales.append(tempSale)
                    }
                    
                }else{
                    print("Inside else \(location) : \(allSales[i].location)-\(allSales[i].area)")
                    
                    var tempSale = SalesInfo()
                    
                    //tempSale.sale_id = (i + 1)
                    tempSale.transaction_id = "gross"
                    tempSale.salesman = ""
                    tempSale.salesman_name = ""
                    tempSale.location = ""
                    tempSale.area = ""
                    tempSale.organization = ""
                    tempSale.itemcode = "GROSS"
                    tempSale.item_description = ""
                    tempSale.quantity = "TOTAL"
                    tempSale.unit_price = ""
                    
                    let price = gross_total.truncatingRemainder(dividingBy: 1)
                    var pro_price = ""
                    
                    if (price == 0.0){
                        pro_price = "\(Int(gross_total)) "
                    }
                    else{
                        pro_price = "\(gross_total)"
                    }
                    
                    tempSale.total_price = pro_price
                    tempSale.date = ""
                    tempSale.location = ""
                    
                    
                    
                    netprice = netprice + gross_total
                    
                    gross_total = Double(allSales[i].total_price) ?? 0
                    
                    
                    location = "\(allSales[i].location)-\(allSales[i].area)"
                    
                    //allSales[i] = tempSale
                    tempSales.append(tempSale)
                    tempSale = SalesInfo(value: allSales[i])
                    tempSale.location = location
                    tempSales.append(tempSale)
                    
                    print("Inside else \(allSales.count - 1) == \(i)")
                    if (allSales.count - 1) == i {
                        
                        let tempSale = SalesInfo()
                        
                        //tempSale.sale_id = (i + 1)
                        tempSale.transaction_id = "gross"
                        tempSale.salesman = ""
                        tempSale.salesman_name = ""
                        tempSale.location = ""
                        tempSale.area = ""
                        tempSale.organization = ""
                        tempSale.itemcode = "GROSS"
                        tempSale.item_description = ""
                        tempSale.quantity = "TOTAL"
                        tempSale.unit_price = ""
                        
                        let price = gross_total.truncatingRemainder(dividingBy: 1);
                        var pro_price = "";
                        
                        if (price == 0.0){
                            pro_price = "\(Int(gross_total)) "
                        }
                        else{
                            pro_price = "\(gross_total)"
                        }
                        
                        tempSale.total_price = pro_price
                        tempSale.date = ""
                        tempSale.location = ""
                        
                        netprice = netprice + gross_total;
                        
                        //allSales[i] = tempSale
                        tempSales.append(tempSale)
                        
                    }
                    
                }
                
            }
            
            
            let tempSale = SalesInfo()
            //tempSale.sale_id = (allSales.count + 1)
            tempSale.transaction_id = "gross"
            tempSale.salesman = ""
            tempSale.salesman_name = ""
            tempSale.location = ""
            tempSale.area = ""
            tempSale.organization = ""
            tempSale.itemcode = "NET"
            tempSale.item_description = ""
            tempSale.quantity = "TOTAL"
            tempSale.unit_price = ""
            
            let price = netprice.truncatingRemainder(dividingBy: 1)
            var pro_price = ""
            
            if (price == 0.0){
                pro_price = "\(Int(netprice)) "
            }else{
                pro_price = "\(netprice)"
            }
            
            tempSale.total_price = pro_price;
            tempSale.date = "";
            
            //allSales.append(sales_info)
            tempSales.append(tempSale)
            
            
        }else{
            print("SaleDetails is empty.")
        }
        
        //print("Total Data: \(allSales.count)")
        saleDetailsTable.reloadData()
    }
    
    
    @IBAction func sendOTSales(_ sender: Any) {
        
        let document = PDFDocument(format: .a4)
        let attributedTitle = NSMutableAttributedString(string: "AL HARAMAIN GROUP OF COMPANIES", attributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 22.0),
            NSAttributedString.Key.foregroundColor : UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            ])
        document.addAttributedText(.headerCenter, text: attributedTitle)
        let subTitle = NSMutableAttributedString(string: "OT Sales Report", attributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20.0)])
        document.addAttributedText(.headerCenter, text: subTitle)
        document.addText(text: "Sales Executive: \(Utils.salesmanName)")
        document.addText(text: "Date: \(showDate.text ?? "")")
        
        let table = PDFTable()
        let totalRows = allOtSales.count + 1
        table.widths = [0.1, 0.2, 0.1, 0.5, 0.2]
        
        
        var cellDatas = Array(repeating: Array(repeating: "", count: 5), count: totalRows)
        var cellAligns: [[PDFTableCellAlignment]] = Array(repeating: Array(repeating: PDFTableCellAlignment.center, count: 5), count: totalRows)
        
        let colors = (fill: UIColor.white, text: UIColor.orange)
        let lineStyle = PDFLineStyle(type: .full, color: UIColor.black, width: 2)
        let borders = PDFTableCellBorders(left: lineStyle, top: lineStyle, right: lineStyle, bottom: lineStyle)
        let font = UIFont.systemFont(ofSize: 18)
        let topCellStyle = PDFTableCellStyle(colors: colors, borders: borders, font: font)
        
        cellDatas[0] = ["S.N.", "Item Code", "Quantity", "Description", "Location"]
        cellAligns[0] = [.center, .center, .center, .center, .center]
        
        
    
        
        do {
            try table.setCellStyle(row: 0, column: 0, style: topCellStyle)
            try table.setCellStyle(row: 0, column: 1, style: topCellStyle)
            try table.setCellStyle(row: 0, column: 2, style: topCellStyle)
            try table.setCellStyle(row: 0, column: 3, style: topCellStyle)
            try table.setCellStyle(row: 0, column: 4, style: topCellStyle)
        } catch PDFError.tableIndexOutOfBounds(let index, let length){
            // In case the index is out of bounds
            
            print("Requested cell is out of bounds! \(index) / \(length)")
        } catch {
            // General error handling in case something goes wrong.
            
            print("Error while setting cell style: " + error.localizedDescription)
        }
        
        
        
        let cellColors = (fill: UIColor.white, text: UIColor.black)
        let cellStyle = PDFTableCellStyle(colors: cellColors, borders: borders, font: font)
        
        var i = 1
        for sale in allOtSales{
            //print(sale.description)
            
            var data: [String] = []
            data.append("\(i)")
            data.append("\(sale.itemcode)")
            data.append("\(sale.quantity)")
            data.append("\(sale.item_description)")
            data.append("\(sale.location)")
            
            cellDatas[i] = data
            cellAligns[i] = [.center, .center, .center, .center, .center]
            
            
            
            for j in 0...4{
                do {
                    
                    try table.setCellStyle(row: i, column: j, style: cellStyle)
                    
                } catch PDFError.tableIndexOutOfBounds(let index, let length){
                    // In case the index is out of bounds
                    
                    print("Requested cell is out of bounds! \(index) / \(length)")
                } catch {
                    // General error handling in case something goes wrong.
                    
                    print("Error while setting cell style: " + error.localizedDescription)
                }
            }
            
            i += 1
            
        }
        
        
        do {
            try table.generateCells(data: cellDatas, alignments: cellAligns)
        } catch PDFError.tableContentInvalid(let value) {
            // In case invalid input is provided, this error will be thrown.
            
            print("This type of object is not supported as table content: " + String(describing: (type(of: value))))
        } catch {
            // General error handling in case something goes wrong.
            
            print("Error while creating table: " + error.localizedDescription)
        }
        
        
        document.addTable(table: table)
        
        do{
            let filePath = try PDFGenerator.generateURL(document: document, filename: "Sales_Manager_OT_request.pdf")
            
            TestVC.path = filePath.absoluteString
            performSegue(withIdentifier: "Test", sender: nil)
            
            if MFMailComposeViewController.canSendMail() {
                let mailComposer = MFMailComposeViewController()
                mailComposer.setSubject("Update about ios tutorials")
                mailComposer.setMessageBody("What is the update about ios tutorials on youtube", isHTML: false)
                mailComposer.setToRecipients(["abc@test.com"])
                self.present(mailComposer, animated: true
                    , completion: nil)
                
                do {
                    let attachmentData = try Data(contentsOf: filePath)
                    mailComposer.addAttachmentData(attachmentData, mimeType: "application/pdf", fileName: "Sales_Manager_OT_request")
                    mailComposer.mailComposeDelegate = self
                    self.present(mailComposer, animated: true
                        , completion: nil)
                } catch let error {
                    print("We have encountered error \(error.localizedDescription)")
                }
                
            } else {
                print("Email is not configured in settings app or we are not able to send an email")
            }
            
        }catch{
            print("Error Creating PDF \(error)")
        }
        
    }
    
    func showDatePicker(){
        //Formate Date
        datePicker.datePickerMode = .date
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        showDate.inputAccessoryView = toolbar
        showDate.inputView = datePicker
        
    }
    
    @objc func donedatePicker(){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: datePicker.date)
        showDate.text = dateString
        self.view.endEditing(true)
        refReshList(salesDate: dateString)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
}


extension SalesDetailsVC: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Utils.dailySales ? tempSales.count : allOtSales.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let sale = Utils.dailySales ? tempSales[indexPath.row] : allOtSales[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SaleDetailsCell") as! SaleDetailsCell
        
        Utils.dailySales ? cell.setSaleDetailsCell(saleInfo: tempSales[indexPath.row]) : cell.setOtSaleDetailsCell(saleInfo: allOtSales[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let alertVc = alertService.editSalesAlert()
        
        if Utils.dailySales && tempSales[indexPath.row].transaction_id != "gross" {
            
            alertVc.saleInfo = tempSales[indexPath.row]
            
        }else if Utils.otsales{
            
            alertVc.otsaleInfo = allOtSales[indexPath.row]
            
        }
        
        alertVc.delegate = self
        present(alertVc,animated: true)
    }
    
}

extension SalesDetailsVC: AddItemDelegate{
    
    func okButtonTapped(msg: String) {
        self.view.makeToast(msg)
        refReshList(salesDate: (showDate.text ?? ""))
    }
    
    func cancelButtonTapped() {
        
    }
    
}

//
//  SetLocation.swift
//  Travel Retail
//
//  Created by Anis Mizi on 5/2/19.
//  Copyright © 2019 AL HARAMAIN. All rights reserved.
//

import UIKit
import SearchTextField
import RealmSwift

class SetLocationVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    
    @IBOutlet weak var selectArea: UIPickerView!
    @IBOutlet weak var searchLocation: SearchTextField!
    
    let realm = try! Realm()
    lazy var mainLocations: Results<LocationInfo> = { self.realm.objects(LocationInfo.self).sorted(byKeyPath: "main_location", ascending: true) }()
    
    var areas: [String] = [String]()
    var locations: [String] = [String]()
    
    var locationSelected: String?
    var areaSelected: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Set Location"
        
        if mainLocations.count != 0{
            for location in mainLocations{
                locations.append(location.main_location)
            }
            
            locations = Array(Set(locations))
        }else{
            locations = []
        }
        
        self.selectArea.delegate = self
        self.selectArea.dataSource = self
        
        areas = []
        searchLocation.filterStrings(locations)
        
        // Handle what happens when the user picks an item. By default the title is set to the text field
        searchLocation.itemSelectionHandler = {filteredResults, itemPosition in
            
            // Just in case you need the item position
            let item = filteredResults[itemPosition]
            print("Item at position \(itemPosition): \(item.title)")
            
            // Do whatever you want with the picked item
            self.searchLocation.text = item.title
            
            self.locationSelected = item.title
        
            let sublocations: Results<LocationInfo> = self.realm.objects(LocationInfo.self).filter("main_location = '\(item.title)'")
            
            if sublocations.count != 0 {
                self.areas = []
                for subLoc in sublocations{
                    self.areas.append(subLoc.sub_location)
                }
                self.areas = Array(Set(self.areas))
            }
            
            self.selectArea.reloadAllComponents()
            
            //print("\(item) \(itemPosition) \(self.locations[itemPosition])")
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return areas.count
    }
    
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return areas[row]
    }
    
    // Capture the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        self.areaSelected = areas[row]
        print(areas[row])
    }
    

    @IBAction func goToSales(_ sender: Any) {
        if locationSelected != nil && areaSelected != nil{
            
            DailySalesVC.mainArea = self.locationSelected
            DailySalesVC.subArea = self.areaSelected
            
            self.performSegue(withIdentifier: "dailySales", sender: nil)
        }
    }
    
}

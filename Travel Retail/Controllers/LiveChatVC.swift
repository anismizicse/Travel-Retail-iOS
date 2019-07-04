//
//  LiveChatVC.swift
//  Travel Retail
//
//  Created by Anis Mizi on 5/25/19.
//  Copyright © 2019 AL HARAMAIN. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class LiveChatVC: ButtonBarPagerTabStripViewController {


    
    let purpleInspireColor = UIColor(red:0.13, green:0.03, blue:0.25, alpha:1.0)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        title = "Live Chat"
        
        let logoutBarButtonItem = UIBarButtonItem(title: "Menu", style: .plain, target: self, action: #selector(openMenu))
        self.navigationItem.rightBarButtonItem  = logoutBarButtonItem
        
        // change selected bar color
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.selectedBarBackgroundColor = purpleInspireColor
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 14)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .black
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .black
            newCell?.label.textColor = self?.purpleInspireColor
        }
        
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let child_1 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Members")
        let child_2 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UnseenMessages")
        return [child_1, child_2]
    }
    
    @IBAction func openGroupChat(_ sender: UIButton) {
        
        //self.performSegue(withIdentifier: "GroupChatSegue", sender: nil)
    }
    @objc func openMenu(){
        
        let alert = UIAlertController(title: "Choose Option",
                                      message: "",
                                      preferredStyle: .alert)
        
        let action1 = UIAlertAction(title: "Settings", style: .default, handler: { (action) -> Void in
            
            self.performSegue(withIdentifier: "ChatSettings", sender: nil)
            //print("ACTION 1 selected!")
        })
        
        let action2 = UIAlertAction(title: "Logout", style: .default, handler: { (action) -> Void in
            //print("ACTION 2 selected!")
        })
        
        
        // Cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
        
        /*// Restyle the view of the Alert
        alert.view.tintColor = UIColor.brown  // change text color of the buttons
        alert.view.backgroundColor = UIColor.cyan  // change background color
        alert.view.layer.cornerRadius = 25   // change corner radius*/
        
        // Add action buttons and present the Alert
        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
}


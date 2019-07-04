//
//  TestVC.swift
//  Travel Retail
//
//  Created by Anis Mizi on 5/22/19.
//  Copyright © 2019 AL HARAMAIN. All rights reserved.
//

import UIKit

class TestVC: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    static var path: String?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let url : NSURL! = NSURL(string: TestVC.path ?? "")
        webView.loadRequest(NSURLRequest(url: url as URL) as URLRequest)
    }
    

}

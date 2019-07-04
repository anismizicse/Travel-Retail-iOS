//
//  AddItemDelegate.swift
//  Travel Retail
//
//  Created by Anis Mizi on 5/6/19.
//  Copyright © 2019 AL HARAMAIN. All rights reserved.
//

import Foundation

protocol AddItemDelegate: class {
    func okButtonTapped(msg: String)
    func cancelButtonTapped()
}

protocol EditItemDelegate: class {
    func okButtonTapped(product: ProductInfo, quantity: Double)
    func cancelButtonTapped()
}

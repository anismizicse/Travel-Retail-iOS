//
//  CustomMessages.swift
//  Travel Retail
//
//  Created by Anis Mizi on 6/26/19.
//  Copyright © 2019 AL HARAMAIN. All rights reserved.
//

import UIKit

class CustomMessages: UITableViewCell {
    @IBOutlet weak var receiverBox: UIView!
    @IBOutlet weak var receiverImage: UIImageView!
    
    @IBOutlet weak var receiverName: UILabel!
    @IBOutlet weak var receiverMessage: UILabel!
    @IBOutlet weak var receiverMessageDate: UILabel!
    @IBOutlet weak var senderBox: UIView!
    @IBOutlet weak var senderMessage: UILabel!
    @IBOutlet weak var senderMessageDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

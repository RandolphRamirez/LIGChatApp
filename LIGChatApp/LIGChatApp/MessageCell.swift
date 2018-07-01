//
//  MessageCell.swift
//  LIGChatApp
//
//  Created by Vivian on 7/1/18.
//  Copyright © 2018 Randolph. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {

    @IBOutlet var lblMessage: UILabel!
    @IBOutlet var lblSender: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

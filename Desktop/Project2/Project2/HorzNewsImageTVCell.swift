//
//  HorzNewsImageTVCell.swift
//  Project2
//
//  Created by Robert Whitehead on 10/16/17.
//  Copyright © 2017 Robert Whitehead. All rights reserved.
//

import UIKit

class HorzNewsImageTVCell: UITableViewCell {


    @IBOutlet var newsImage: UIImageView!
    @IBOutlet var titleText: UITextView!
    @IBOutlet var sourceLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

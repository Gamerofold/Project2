//
//  NewsImageTVCell.swift
//  Project2
//
//  Created by Robert Whitehead on 10/14/17.
//  Copyright © 2017 Robert Whitehead. All rights reserved.
//

import UIKit

class NewsImageTVCell: UITableViewCell {

    @IBOutlet var titleText: UITextView!
    @IBOutlet var sourceLabel: UILabel!
    @IBOutlet var newsImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

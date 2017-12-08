//
//  SaveTVCell.swift
//  Project2
//
//  Created by Robert Whitehead on 10/19/17.
//  Copyright © 2017 Robert Whitehead. All rights reserved.
//

import UIKit


class SaveTVCell: UITableViewCell {

    @IBOutlet var photoImage: UIImageView!
    @IBOutlet var titleText: UITextView!
    @IBOutlet var sourceLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var descriptionText: UITextView!
    @IBOutlet var urlLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

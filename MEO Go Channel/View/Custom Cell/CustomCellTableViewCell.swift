//
//  CustomCellTableViewCell.swift
//  MEO Go Channel
//
//  Created by Clovis Magenta da Cunha on 04/03/19.
//  Copyright © 2019 CMC. All rights reserved.
//

import UIKit

class CustomCellTableViewCell: UITableViewCell {

    @IBOutlet weak var programImage: UIImageView!
    @IBOutlet weak var channelLabel: UILabel!
    @IBOutlet weak var programNameLabel: UILabel!
    @IBOutlet weak var descriptonLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        channelLabel.text = ""
        programNameLabel.text = ""
        descriptonLabel.text = ""
        
        
        // Initialization code
    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }

}

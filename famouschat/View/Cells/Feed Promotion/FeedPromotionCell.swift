//
//  FeedPromotionCell.swift
//  famouschat
//
//  Created by angel oni on 2019/5/28.
//  Copyright © 2019 Oni Angel. All rights reserved.
//

import UIKit

class FeedPromotionCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var promotion_txt: UILabel!
    @IBOutlet weak var promotion_img: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

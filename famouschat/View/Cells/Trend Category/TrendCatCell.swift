//
//  TrendCatCell.swift
//  famouschat
//
//  Created by T-Tech Solutions LLC on 10/01/2019.
//  Copyright © 2019 Oni Angel. All rights reserved.
//

import UIKit

class TrendCatCell: UICollectionViewCell {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var name_height: NSLayoutConstraint!
    @IBOutlet weak var mask_view: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        mask_view.backgroundColor = Utility.color(withHexString: "A3A3A3")
        mask_view.alpha = 0.5
    }

}

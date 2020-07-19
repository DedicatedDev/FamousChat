//
//  TrendSearchCell.swift
//  famouschat
//
//  Created by T-Tech Solutions LLC on 08/11/2018.
//  Copyright © 2018 T-Tech Solutions LLC. All rights reserved.
//

import UIKit

class TrendSearchCell: UITableViewCell {

    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var job: UILabel!
    @IBOutlet weak var under_line: UIImageView!
    @IBOutlet weak var status: UIView!
    
    @IBOutlet weak var like_0: UIImageView!
    @IBOutlet weak var like_1: UIImageView!
    @IBOutlet weak var like_2: UIImageView!
    @IBOutlet weak var like_3: UIImageView!
    @IBOutlet weak var like_4: UIImageView!
    
    var like_stars = [UIImageView]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        like_stars = [like_0,like_1,like_2,like_3,like_4]
    }

    override func prepareForReuse() {
        
        photo.image = UIImage.init(named: "non_profile")
        super.prepareForReuse()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

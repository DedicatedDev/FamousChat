//
//  ChatMsgCell.swift
//  famouschat
//
//  Created by T-Tech Solutions LLC on 08/11/2018.
//  Copyright © 2018 T-Tech Solutions LLC. All rights reserved.
//

import UIKit

class ChatMsgCell: UICollectionViewCell {
    
    @IBOutlet weak var msg: UILabel!
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var msg_img: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        msg_img.layer.cornerRadius = 8
        msg_img.clipsToBounds = true
        
    }
    
    override func prepareForReuse() {
        
        image.image = UIImage.init(named: "non_profile")
        msg_img.image = nil
        super.prepareForReuse()
        
    }
    
    
}


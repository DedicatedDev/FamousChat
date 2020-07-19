//
//  ChatListCell.swift
//  famouschat
//
//  Created by T-Tech Solutions LLC on 08/11/2018.
//  Copyright © 2018 T-Tech Solutions LLC. All rights reserved.
//

import UIKit

class ChatListCell: UITableViewCell {

    @IBOutlet weak var select_bar: UIView!
    @IBOutlet weak var main_frame: UIView!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var status: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var unread_frame: UIView!
    @IBOutlet weak var unread_num: UILabel!
    @IBOutlet weak var last_msg: UILabel!
    @IBOutlet weak var last_time: UILabel!
    @IBOutlet weak var under_line: UIImageView!
    @IBOutlet weak var camera_img: UIImageView!
    @IBOutlet weak var last_msg_left_constrain: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        
        photo.image = UIImage.init(named: "non_profile")
        super.prepareForReuse()
        
    }
    
}

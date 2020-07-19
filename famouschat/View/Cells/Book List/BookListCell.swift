//
//  BookListCell.swift
//  famouschat
//
//  Created by T-Tech Solutions LLC on 08/11/2018.
//  Copyright © 2018 T-Tech Solutions LLC. All rights reserved.
//

import UIKit

class BookListCell: UICollectionViewCell {

    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var question: UILabel!
    @IBOutlet weak var image_frame: UIView!
    @IBOutlet weak var image_height: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft], cornerRadii: CGSize(width: 12, height: 12))
//        let mask = CAShapeLayer()
//        mask.path = path.cgPath
//        photo.layer.mask = mask
//        photo.layer.masksToBounds = true
        
       
    }
    
    override func prepareForReuse() {
        
        photo.image = UIImage.init(named: "non_profile")
        super.prepareForReuse()
        
    }

}

//
//  RateCell.swift
//  famouschat
//
//  Created by angel oni on 2019/2/8.
//  Copyright © 2019 Oni Angel. All rights reserved.
//

import UIKit

class RateCell: UICollectionViewCell {

   
    @IBOutlet weak var first_frame: UIView!
    @IBOutlet weak var second_frame: UIView!
    @IBOutlet weak var third_frame: UIView!
    @IBOutlet weak var rate: UILabel!
    @IBOutlet weak var category: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.first_frame.addGrdient(mainColor: [Utility.color(withHexString: "205786")!.cgColor, Utility.color(withHexString: "90cffd")!.cgColor])
        self.first_frame.layer.cornerRadius = self.first_frame.frame.height / 2
        self.first_frame.clipsToBounds = true
        self.first_frame.dropShadow(color: .gray, opacity: 0.5, offSet: CGSize.zero, radius: 3, scale: true)
        
        self.second_frame.layer.cornerRadius = self.second_frame.frame.height / 2
        self.second_frame.clipsToBounds = true
        
        self.third_frame.layer.cornerRadius = self.third_frame.frame.height / 2
        self.third_frame.clipsToBounds = true
        self.third_frame.dropShadow(color: .gray, opacity: 0.5, offSet: CGSize.zero, radius: 3, scale: true)
    }

}

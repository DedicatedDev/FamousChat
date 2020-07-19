//
//  ImagePickerAlert.swift
//  famouschat
//
//  Created by angel oni on 2019/2/13.
//  Copyright © 2019 Oni Angel. All rights reserved.
//

import UIKit

class ImagePickerAlert: UIView {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var top_frame: UIView!
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var photo_btn: UIButton!
    
    @IBOutlet weak var cancel_btn: UIButton!
    @IBOutlet weak var add_btn: UIButton!
    
    class func instanceFromNib(title: String) -> UIView {
        
        let alert = Bundle.main.loadNibNamed("ImagePickerAlert", owner: self, options: nil)?.last as! ImagePickerAlert
        let windows = UIApplication.shared.windows
        let lastWindow = windows.last
        
        let widhth: CGFloat = UIScreen.main.bounds.width - 80
        let height = CGFloat(350)
        let orgX = (UIScreen.main.bounds.width - widhth) / 2
        let orgY = (UIScreen.main.bounds.height - height) / 2
        alert.frame = CGRect(x: orgX, y: orgY, width: widhth, height: height)
        
        alert.layer.cornerRadius = 12
        alert.clipsToBounds = true
        
        alert.top_frame.layer.cornerRadius = alert.top_frame.frame.height / 2
        alert.top_frame.clipsToBounds = true
        
        
        alert.dropShadow(color: Utility.color(withHexString: ShareData.btn_color), opacity: 1, offSet: CGSize.zero, radius: 8, scale: true)
        
        alert.cancel_btn.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        alert.cancel_btn.clipsToBounds = true
        alert.cancel_btn.dropShadow(color: .gray, opacity: 0.8, offSet: CGSize.zero, radius: 5, scale: true)
        
        alert.add_btn.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        alert.add_btn.clipsToBounds = true
        alert.add_btn.dropShadow(color: .gray, opacity: 0.8, offSet: CGSize.zero, radius: 5, scale: true)
        
        alert.title.text = title
        
        lastWindow?.addSubview(alert)
        
        return alert
    }
}

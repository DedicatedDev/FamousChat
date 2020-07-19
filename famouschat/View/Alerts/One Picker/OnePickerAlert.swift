//
//  OnePickerAlert.swift
//  famouschat
//
//  Created by angel oni on 2019/2/8.
//  Copyright © 2019 Oni Angel. All rights reserved.
//

import UIKit

class OnePickerAlert: UIView {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var top_frame: UIView!
    @IBOutlet weak var picker: UIPickerView!
    
    @IBOutlet weak var apply_frame: UIView!
    @IBOutlet weak var apply_btn: UIButton!
    
    
    class func instanceFromNib(title: String) -> UIView {
        
        let alert = Bundle.main.loadNibNamed("OnePickerAlert", owner: self, options: nil)?.last as! OnePickerAlert
        let windows = UIApplication.shared.windows
        let lastWindow = windows.last
        
        let widhth: CGFloat = UIScreen.main.bounds.width - 80
        let height = CGFloat(300)
        let orgX = (UIScreen.main.bounds.width - widhth) / 2
        let orgY = (UIScreen.main.bounds.height - height) / 2
        alert.frame = CGRect(x: orgX, y: orgY, width: widhth, height: height)
        
        alert.layer.cornerRadius = 12
        alert.clipsToBounds = true
        
        alert.top_frame.layer.cornerRadius = alert.top_frame.frame.height / 2
        alert.top_frame.clipsToBounds = true
        
        alert.dropShadow(color: Utility.color(withHexString: ShareData.btn_color), opacity: 1, offSet: CGSize.zero, radius: 8, scale: true)
        alert.apply_frame.dropShadow(color: .gray, opacity: 1, offSet: CGSize.zero, radius: 5, scale: true)
        
        alert.title.text = title
       
        lastWindow?.addSubview(alert)
        
        return alert
    }
}

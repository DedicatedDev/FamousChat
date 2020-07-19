//
//  SixPickerAlert.swift
//  famouschat
//
//  Created by T-Tech Solutions LLC on 10/01/2019.
//  Copyright © 2019 Oni Angel. All rights reserved.
//

import UIKit

class SixPickerAlert: UIView {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var top_frame: UIView!
    @IBOutlet weak var picker_11: UIPickerView!
    @IBOutlet weak var picker_12: UIPickerView!
    @IBOutlet weak var picker_13: UIPickerView!
    @IBOutlet weak var picker_21: UIPickerView!
    @IBOutlet weak var picker_22: UIPickerView!
    @IBOutlet weak var picker_23: UIPickerView!
    
    @IBOutlet weak var btn_frame: UIView!
    @IBOutlet weak var apply_btn: UIButton!
    
    
    class func instanceFromNib(_ title: String) -> UIView
    {
        let alert = Bundle.main.loadNibNamed("SixPickerAlert", owner: self, options: nil)?.last as! SixPickerAlert
        let windows = UIApplication.shared.windows
        let lastWindow = windows.last
        
        let widhth: CGFloat = UIScreen.main.bounds.width - 80
        let height = CGFloat(300)
        let orgX = (UIScreen.main.bounds.width - widhth) / 2
        let orgY = (UIScreen.main.bounds.height - height) / 2
        alert.frame = CGRect(x: orgX, y: orgY, width: widhth, height: height)
        
        alert.top_frame.layer.cornerRadius = alert.top_frame.frame.height / 2
        alert.top_frame.clipsToBounds = true
        
        alert.title.text = title
        
        
        alert.layer.cornerRadius = 12
        alert.clipsToBounds = true
        
        alert.dropShadow(color: Utility.color(withHexString: ShareData.btn_color), opacity: 1, offSet: CGSize.zero, radius: 8, scale: true)
        alert.btn_frame.dropShadow(color: .gray, opacity: 1, offSet: CGSize.zero, radius: 5, scale: true)
        
        lastWindow?.addSubview(alert)
        return alert
        
        return alert
    }

}

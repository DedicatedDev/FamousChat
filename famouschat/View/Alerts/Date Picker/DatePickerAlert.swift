//
//  DatePickerAlert.swift
//  famouschat
//
//  Created by T-Tech Solutions LLC on 12/01/2019.
//  Copyright © 2019 Oni Angel. All rights reserved.
//

import UIKit

class DatePickerAlert: UIView {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var top_frame: UIView!
    
    @IBOutlet weak var time_picker: UIDatePicker!
    @IBOutlet weak var apply_frame: UIView!
    @IBOutlet weak var apply_btn: UIButton!
    
    var status = false
    var time_str = "2019:01:20"
    
    class func instanceFromNib(_ title: String, _ stauts: Bool) -> UIView
    {
        let alert = Bundle.main.loadNibNamed("DatePickerAlert", owner: self, options: nil)?.last as! DatePickerAlert
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
        alert.status = stauts
        if stauts
        {
            alert.time_picker.datePickerMode = .date
            let array = CommonFuncs().splitString(CommonFuncs().currentTime())
            alert.time_str = "\(array[0])-\(array[1])-\(array[2])"
        }
        else
        {
            alert.time_picker.datePickerMode = .time
            alert.time_str = "07:00:am"
        }
        
        lastWindow?.addSubview(alert)
        
        return alert
    }
    
    @IBAction func timeChanged(_ sender: Any) {
        
        let formatter = DateFormatter()
        if status
        {
            formatter.dateFormat = "yyyy-MM-dd"
        }
        else
        {
            formatter.dateFormat = "hh:mm:a"
        }
        
        time_str = formatter.string(from: self.time_picker.date)        
        
    }
    
}

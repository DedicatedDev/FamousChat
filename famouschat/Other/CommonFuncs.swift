//
//  CommonFuncs.swift
//  famouschat
//
//  Created by angel oni on 2019/5/16.
//  Copyright © 2019 Oni Angel. All rights reserved.
//

import Foundation
import SCLAlertView


class CommonFuncs: UIViewController
{
    func likeStars(_ like: Double, _ stars: [UIImageView])
    {
        
        let image = UIImage(named: "menu_star")?.withRenderingMode(.alwaysTemplate)
        for i in 0..<stars.count
        {
            stars[i].image = image
            stars[i].tintColor = Utility.color(withHexString: ShareData.star_non_color)
        }
        var fullLike: Int = Int(like)
        var semiLike: Double = like - Double(fullLike)
        
        for i in 0..<fullLike
        {
            stars[i].tintColor = Utility.color(withHexString: ShareData.star_color)
        }
        if semiLike >= 0.5
        {
            stars[fullLike].tintColor = Utility.color(withHexString: ShareData.star_color)
        }
    }
    
    
    func getStringHeight(_ str: String, _ font_size: Int, _ base_width: CGFloat, _ side_constrain: CGFloat, _ additional_height: CGFloat) -> CGFloat
    {
        let font = UIFont.systemFont(ofSize: CGFloat(font_size))
        let fontAttributes = [NSAttributedStringKey.font: font_size]
        
        let txt_width = base_width - side_constrain
        var verseTxt = UILabel()
        verseTxt.text = str
        verseTxt.font = UIFont.systemFont(ofSize: CGFloat(font_size))
        verseTxt.numberOfLines = 0
        verseTxt.sizeThatFits(CGSize(width: txt_width, height: CGFloat.greatestFiniteMagnitude))
        let newSize = verseTxt.sizeThatFits(CGSize(width: txt_width, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = verseTxt.frame
        var newHeight = newSize.height + additional_height
        
        return newHeight
    }
    
    
    func attributeString(_ fonts: [UIFont], _ colors: [UIColor], _ strs: [String]) -> NSMutableAttributedString
    {
        var attributedString = NSMutableAttributedString(string:"")
        
        for i in 0..<strs.count
        {
            var attrs = [NSAttributedStringKey.font : fonts[i], NSAttributedStringKey.foregroundColor : colors[i]]
            var str = NSMutableAttributedString(string: strs[i], attributes: attrs)
            attributedString.append(str)
        }
        
        return attributedString
    }
    
    
    func createRequest(_ status: Bool, _ path: String, _ method: String, _ parameters: [String: Any], completionHandler: @escaping (_ result: Dictionary<String, AnyObject>) -> Void) {
        
        var url: URL!
        
        if status
        {
            url = URL(string: "\(ShareData.main_url)\(path)/")!
        }
        else
        {
            url = URL(string: "\(ShareData.main_url)\(path).php")!
        }
        
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            guard error == nil else {
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                
                if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, AnyObject> {
                    
                    let result = completionHandler(json)
                }
            } catch let error {
                
            }
        })
        task.resume()
    }
    
    
    func splitString(_ str: String) -> [String]
    {
        if str.contains("|")
        {
            return str.characters.split(separator: "|").map(String.init)
        }
        else if str.contains("-")
        {
            return str.characters.split(separator: "-").map(String.init)
        }
        else if str.contains(",")
        {
            return str.characters.split(separator: ",").map(String.init)
        }
        else if str.contains(":")
        {
            return str.characters.split(separator: ":").map(String.init)
        }
        else
        {
            return [str]
        }
        
    }
    
    func currentTime() -> String
    {
        let date = Date()
        let calendar = Calendar.current
        let year = "\(calendar.component(.year, from: date) as! Int)" as! String
        let month = String(format: "%02d", calendar.component(.month, from: date) as! Int)
        
        let day = String(format: "%02d", calendar.component(.day, from: date) as! Int)
        let hour = String(format: "%02d", calendar.component(.hour, from: date) as! Int)
        let minute = String(format: "%02d", calendar.component(.minute, from: date) as! Int)
        
        return "\(year)-\(month)-\(day)-\(hour)-\(minute)"
    }
    
    
    func timeString(_ time: String, _ duration: String, _ status: Int) -> String
    {
        var formater = DateFormatter()
        formater.dateFormat = "yyyy-MM-dd-HH-mm"
        let start_time = formater.date(from: time)!
        
        if status == 0
        {
            formater.dateFormat = "E dd MMM, hh:mm a"
            return formater.string(from: start_time)
            
        }
        else if status == 1
        {
            formater.dateFormat = "MMMM dd'th',  yyyy"
            return formater.string(from: start_time)
        }
        else
        {
            formater.dateFormat = "E dd MMM, hh:mm a"
            let str1 = formater.string(from: start_time)
            
            let end_time = start_time.addingTimeInterval(TimeInterval(Double(duration)! * 60))
            formater.dateFormat = "hh:mm a"
            let str2 = formater.string(from: end_time)
            return "\(str1) - \(str2)"
        }
    }
    
    func time24To12(_ time: String) -> [String]
    {
        
        var hour = time
        var am_str = "am"
        
        if Int(hour)! < 12
        {
            am_str = "AM"
        }
        else if Int(hour)! == 12
        {
            am_str = "PM"
        }
        else
        {
            am_str = "PM"
            hour = String(format: "%02d", Int(hour)! - 12)
        }
        
        return [hour, am_str]
        
    }
    
    func time12To24(_ hour: String, _ am: String) -> String
    {
        var str = ""
        
        if am == "AM"
        {
            str = hour
        }
        else
        {
            if hour == "12"
            {
                str = hour
            }
            else
            {
                str = "\(Int(hour)! + 12)"
            }
        }
        
        return str
        
    }
    
    func kiloData(num: String) -> String {
        
        var str = ""
        if Int(num)! < 1000
        {
            str = num
        }
        else if Int(num)! >= 1000 && Int(num)! < 1000000
        {
            str = String(format: "%.001f", Double(Double(num)! / 1000)) + "K"
        }
        else
        {
            str = String(format: "%.001f", Double(Double(num)! / 1000000)) + "M"
        }
        
        return str
        
    }
    
    
    func strArrayTostr(_ strArray: [String], _ mark: String) -> String
    {
        var str = ""
        for i in 0..<strArray.count - 1
        {
            str += "\(strArray[i])\(mark)"
        }
        str += strArray[strArray.count - 1]
        
        return str
    }
    
    func historyTime(_ time: String, _ time_zone: String) -> String
    {
        let array = CommonFuncs().splitString(time)
        
        let currentTime = self.currentTime()
        let time_zone_div = Int(ShareData.time_zones[Int(ShareData.user_info.time_zone!)!])! - Int(ShareData.time_zones[Int(time_zone)!])!
        
        let formater = DateFormatter()
        formater.dateFormat = "yyyy-MM-dd-HH-mm"
        let start_time = formater.date(from: time)!.addingTimeInterval(TimeInterval(time_zone_div * 3600))
        let end_time = formater.date(from: currentTime)        
        
        let currentDate = Date()
        let components = Set<Calendar.Component>([.minute, .hour, .day, .month, .year])
        let diff_time = Calendar.current.dateComponents(components, from: start_time, to: end_time!)
        
        var remain_str = ""
        if diff_time.year! == 0
        {
            if diff_time.month! == 0
            {
                if diff_time.day! == 0
                {
                    
                    formater.dateFormat = "hh:mm a"
                    remain_str =  formater.string(from: start_time)
                }
                else
                {
                    formater.dateFormat = "MMM dd"
                    remain_str =  formater.string(from: start_time)
                    
                }
            }
            else
            {
                formater.dateFormat = "MMM dd"
                remain_str =  formater.string(from: start_time)
            }
        }
        else
        {
            formater.dateFormat = "yyyy MMM"
            remain_str =  formater.string(from: start_time)
        }
        
        
        return remain_str
        
    }
    
    func historyTime1(_ time: String, _ time_zone: String) -> String
    {
        let currentTime = self.currentTime()
        let time_zone_div = Int(ShareData.time_zones[Int(ShareData.user_info.time_zone!)!])! - Int(ShareData.time_zones[Int(time_zone)!])!
        
        let formater = DateFormatter()
        formater.dateFormat = "yyyy-MM-dd-HH-mm"
        let start_time = formater.date(from: time)!.addingTimeInterval(TimeInterval(time_zone_div * 3600))
        let end_time = formater.date(from: currentTime)
        
        let currentDate = Date()
        let components = Set<Calendar.Component>([.minute, .hour, .day, .month, .year])
        let diff_time = Calendar.current.dateComponents(components, from: start_time, to: end_time!)
        
        var remain_str = ""
        if diff_time.year! == 0
        {
            if diff_time.month! == 0
            {
                if diff_time.day! == 0
                {
                    
                    
                    if diff_time.hour! == 0
                    {
                        if diff_time.minute! == 0
                        {
                            remain_str = "Just ago"
                        }
                        else
                        {
                            remain_str = (diff_time.minute! == 1) ? "\(diff_time.minute!) minute ago" : "\(diff_time.minute!) minutes ago"
                        }
                        
                    }
                    else
                    {
                        remain_str = (diff_time.hour! == 1) ? "\(diff_time.hour!) hour ago" : "\(diff_time.hour!) hours ago"
                    }
                }
                else
                {
                    remain_str = (diff_time.day! == 1) ? "\(diff_time.day!) day ago" : "\(diff_time.day!) days ago"
                }
            }
            else
            {
                remain_str = (diff_time.month! == 1) ? "\(diff_time.month!) month ago" : "\(diff_time.month!) months ago"
            }
        }
        else
        {
            remain_str = (diff_time.year! == 1) ? "\(diff_time.year!) year ago" : "\(diff_time.year!) years ago"
        }
        
        
        return remain_str
        
    }
    
    func doneAlert(_ title: String, _ subtitle: String, _ btn_title: String, _ completionHandler: @escaping () -> Void) -> SCLAlertView
    {
        let appearance = SCLAlertView.SCLAppearance(
    
        kDefaultShadowOpacity: 0.6,
        kCircleIconHeight: 60,
        showCloseButton: false,
        showCircularIcon: true
    
        )
    
        let alertView = SCLAlertView(appearance: appearance)
        let alertViewIcon = UIImage(named: "mark1")
    
        alertView.addButton(btn_title, backgroundColor: Utility.color(withHexString: ShareData.btn_color), textColor: UIColor.white, action: completionHandler)
    
        alertView.showInfo(title, subTitle: subtitle, circleIconImage: alertViewIcon, animationStyle: .noAnimation)
        return alertView
    }
    
    func selectAlert(_ title: String, _ subtitle: String, _ btn_num: Int, _ btn_titles: [String], _ btn_colors: [UIColor], _ btn_txt_colors: [UIColor], _ target: AnyObject, _ btn_actions: [Selector]) -> SCLAlertView
    {
        let appearance = SCLAlertView.SCLAppearance(
            
            kDefaultShadowOpacity: 0.6,
            kCircleIconHeight: 60,
            showCloseButton: false,
            showCircularIcon: true,
            hideWhenBackgroundViewIsTapped: false
            
        )
        
        let alertView = SCLAlertView(appearance: appearance)
        let alertViewIcon = UIImage(named: "mark1")
        
        for i in 0..<btn_num
        {
            alertView.addButton(btn_titles[i], backgroundColor: btn_colors[i], textColor: btn_txt_colors[i], target: target, selector: btn_actions[i])
        }
        
        alertView.showInfo(title, subTitle: subtitle, circleIconImage: alertViewIcon, animationStyle: .noAnimation)
        
        return alertView
    }
    
    func inputAlert(_ title: String, _ subtitle: String, _ default_txt: String, _ btn_num: Int, _ btn_titles: [String], _ btn_colors: [UIColor], _ btn_txt_colors: [UIColor], _ target: AnyObject, _ btn_actions: [Selector]) -> UITextField
    {
        let appearance = SCLAlertView.SCLAppearance(
            
            kDefaultShadowOpacity: 0.6,
            kCircleIconHeight: 60,
            showCloseButton: false,
            showCircularIcon: true
            
        )
        
        let alertView = SCLAlertView(appearance: appearance)
        let alertViewIcon = UIImage(named: "mark1")
        let txt = alertView.addTextField(default_txt)
        for i in 0..<btn_num
        {
            alertView.addButton(btn_titles[i], backgroundColor: btn_colors[i], textColor: btn_txt_colors[i], target: target, selector: btn_actions[i])
        }
        
        alertView.showInfo(title, subTitle: subtitle, circleIconImage: alertViewIcon, animationStyle: .noAnimation)
        
        return txt
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

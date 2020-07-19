

//
//  SwiftHelper.swift
//  Answer
//
//  Created by Deepak Singh on 13/02/17.
//  Copyright © 2017 Prodge. All rights reserved.
//

import UIKit
import SystemConfiguration
//import SVProgressHUD
import MobileCoreServices

class SwiftHelper: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    var imagePickerHanler: ((_ info: [String : AnyObject]?, _ imagePickerHanler: UIImage?)-> Void)?
    var currentViewController: UIViewController?
    var currentChatUser : String?
    
    static let sharedInstance: SwiftHelper = {
        
        let instance = SwiftHelper()
        return instance
    }()
    
    class func convertToString(obj : Any?) -> String
    {
        if obj == nil
        {
            return ""
        }
        
        let strBlank = ""
        
        if let _ = obj as? String
        {
            let aString = self.validateString(aString: obj as? String)
            return aString
        }
        else
        {
            if obj is String == true || obj is NSNumber == true || obj is Bool == true ||  obj is Int == true
                
            {
                let aString = String(describing: obj!)
                return aString
            }
        }
        
        return strBlank
    }
    
    class func removeZeroFromTheLeading(strNumber:String) -> String
    {
        if strNumber.first == "0"
        {
            let numberString = strNumber
            let numberAsInt = Int(numberString)
            let backToString = "\(numberAsInt!)"
            
            return backToString
        }
        
        return strNumber
    }
    
    class func isEnglishMode () -> Bool
    {
        return false
//        let code = Locale.current.languageCode
//        if code == "en"
//        {
//            return true
//        }
//        else
//        {
//            return false
//        }
    }
    class func showLoader(message: String?)
    {
//        DispatchQueue.main.async {
//            kSharedAppDelegate.window?.isUserInteractionEnabled = false
//            SVProgressHUD.setDefaultMaskType(.gradient)
//            SVProgressHUD.show()
//        }
    }
    
    class func dismissLoader()
    {
//        DispatchQueue.main.async {
//            kSharedAppDelegate.window?.isUserInteractionEnabled = true
////            SVProgressHUD.dismiss()
//        }
    }
    
    class func toString(object:Any?) -> String
    {
        if let str = object as? String
        {
            return String(format: "%@", str)
        }
        
        if let num = object as? NSNumber
        {
            return String(format: "%@", num)
        }
        
        return ""
    }
    
    class func validateString(aString : String?) -> String
    {
        let strBlank = ""
        
        if aString == nil
        {
            return strBlank
        }
        
        if let _ = aString
        {
            if (SwiftHelper.isStringValid(string: aString!) && SwiftHelper.isStringValid(string: aString!))
            {
                return aString!
            }
        }
        
        return strBlank
    }
    
    class func isStringValid(string: String?) -> Bool
    {
        var str: String?;
        
        if string != nil
        {
            str = string!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        else         {
            return false;
        }
        
        if str!.isEmpty
        {
            return false;
        }
        return true;
    }
    
    
    class func getViewControllerFromStoryBoard(stoName:String , identifier:String)-> UIViewController
    {
        let storyBoard = UIStoryboard(name: stoName, bundle: nil);
        let viewController:UIViewController = storyBoard.instantiateViewController(withIdentifier: identifier);
        return viewController;
    }
    
    class func delayInMainQueue(delay:Double, closure:(()->())?)
    {
        
    }
    class func getMainQueue(closure:(()->())?)
    {
        DispatchQueue.main.async {
            
        }
    }
    
    class func isHeightGreater568()-> Bool
    {
        if UIScreen.main.bounds.size.height > 568
        {
            return true
        }
        return false
    }
    
    class func  getColor(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat) -> UIColor
    {
        let color =  UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: alpha)
        return color
    }
    
    class func isConnectedToNetwork() -> Bool
    {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress)
        {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false
        {
            return false
        }
        
        /* Only Working for WIFI
         let isReachable = flags == .reachable
         let needsConnection = flags == .connectionRequired
         
         return isReachable && !needsConnection
         */
        
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
    }
    
    
    class func isValidEmail(candidate: String) -> Bool
    {
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        var valid = NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
        if valid {
            valid = !candidate.contains("..")
        }
        print(valid)
        return valid
    }
    
    class func isValidPhone(phone: String) -> Bool
    {
        
        let phoneRegex = "^((\\+)|(00))[0-9]{6,14}$";
        let valid = NSPredicate(format: "SELF MATCHES %@", phoneRegex).evaluate(with: phone)
        print(valid)
        return valid
    }

 
    
//    class func showOkAlert(title: String, message: String)
//    {
//        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        
//        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//        alertController.addAction(cancelAction)
//        
//        let topViewController: UIViewController = self.topMostViewController(rootViewController: self.rootViewController())!
//        
//        topViewController.present(alertController, animated: true, completion: nil)
//        
//    }
    
    
   
    
    
    
    
    class func topMostController() -> UIViewController? {
        
        let topController =  UIApplication.shared.keyWindow?.rootViewController
        if let navigationController = topController as? UINavigationController,
            let activeViewC = navigationController.visibleViewController {
            
            return activeViewC
        }
        if let viewC = topController {
            
            return viewC
        }
        return nil
    }
    
    class func makeImageViewCircular(imageView: UIImageView)
    {
        imageView.layer.cornerRadius = imageView.frame.size.width/2
        imageView.clipsToBounds = true
        
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 5.0
    }
    
    class func makeViewCircular(view: AnyObject)
    {
        
//        if #available(iOS 12.0, *) {
//            
//            var newView = view
//            newView.cornerRadius = view.frame.size.height/2
//            newView.layer.borderColor = UIColor.clear.cgColor
//            newView.layer.borderWidth = 1.0
//            newView.layer.masksToBounds = true
//        } else {
//            // Fallback on earlier versions
//        }
        
        
        
    }
    
    class func makeShadowToView(arrview:[Any?], shadowColor:UIColor, shadowOffset:CGSize, shadowOpacity:Float, shadowRadius:CGFloat , cornerRadius:CGFloat)
    {
        for view in arrview
        {
            let views = view as? UIView
            views?.layer.shadowColor = shadowColor.cgColor
            views?.layer.shadowOffset = shadowOffset
            views?.layer.shadowOpacity = shadowOpacity
            views?.layer.shadowRadius = shadowRadius
            //views?.layer.shadowPath = UIBezierPath(roundedRect: (views?.bounds)!, cornerRadius:cornerRadius).cgPath
            views?.layer.masksToBounds = true
        }
        
    }
    
   class func downloadedFrom(strUrl: String, completionBlock:@escaping (_ image: UIImage?)->Void)
    {
        
        if !self.isStringValid(string: strUrl)
        {
              completionBlock(nil)
        }
        
        
        let url = URL(string: strUrl)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else
            {
                DispatchQueue.main.async() { () -> Void in
                    
                    completionBlock(nil)
                }
                return
            }
            DispatchQueue.main.async() { () -> Void in
                completionBlock(image)
            }
            }.resume()
    }
    
   class func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    class func getUserAgent()-> String
    {
        
        let model = UIDevice.current.localizedModel
        let osVersion = UIDevice.current.systemVersion
        let userAgent = String(format:"%@:%@",model,osVersion)
        return userAgent
    }
    
    public func showActionSheetFromViewController(viewController: UIViewController, options: [String],title: String, message: String ,onSelect:@escaping (_ selectedIndex: Int, _ selectedTitle: String)-> Void)
    {
        let optionMenu = UIAlertController(title: NSLocalizedString(title, comment: ""), message: NSLocalizedString(message, comment: ""), preferredStyle: .actionSheet)
        
        
        for option in options {
            
            let action = UIAlertAction(title: option, style: .default, handler:
            {
                (alert: UIAlertAction!) -> Void in
                
                if let index = options.index(of: option), index > -1, index < options.count
                {
                     onSelect(index, option)
                }
                else
                {
                     onSelect(-1, "")
                }
            })
            
             optionMenu.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler:
        {
            (alert: UIAlertAction!) -> Void in
        })

        optionMenu.addAction(cancelAction)
        viewController.present(optionMenu, animated: true, completion: nil)
    }
    
    
    func getImageFromGalleryFromViewController(viewController: UIViewController?, callBack:@escaping (_ info: [String : AnyObject]?, _ selectedImage: UIImage?)-> Void)->Void
    {
        self.currentViewController = viewController
        self.imagePickerHanler = callBack
        let imagePicker: UIImagePickerController = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.mediaTypes = [kUTTypeImage as String]
        
        if viewController != nil {
            self.currentViewController = viewController;
            self.currentViewController!.present(imagePicker, animated: true, completion: nil);
            
        } else {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            if ((appDelegate.window?.rootViewController) != nil) {
                
                self.currentViewController = appDelegate.window?.rootViewController!;
                (self.currentViewController)!.present(imagePicker, animated: true, completion: nil);
                
            } else {
                
                self.imagePickerHanler!(nil, nil);
            }
        }
    }
    
    
    func getImageFromCameraFromViewController(viewController: UIViewController?, callBack:@escaping (_ info: [String : AnyObject]?, _ selectedImage: UIImage?)-> Void)->Void
    {
        if UIImagePickerController.isSourceTypeAvailable(.camera)
        {
            self.currentViewController = viewController
            self.imagePickerHanler = callBack
            let imagePicker: UIImagePickerController = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .camera
            imagePicker.mediaTypes = [kUTTypeImage as String]
            
            if viewController != nil
            {
                self.currentViewController = viewController;
                self.currentViewController!.present(imagePicker, animated: true, completion: nil);
            }
            else
            {
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                
                if ((appDelegate.window?.rootViewController) != nil)
                {
                    self.currentViewController = appDelegate.window?.rootViewController!;
                    (self.currentViewController)!.present(imagePicker, animated: true, completion: nil);
                }
                else
                {
                    self.imagePickerHanler!(nil, nil);
                }
            }
        }
    }
    
    class func convertStringToDate(dateString:String, fromFormat :String) -> Date
    {
        if (dateString == "" || dateString == "0000-00-00" || dateString == "0000-00-00 00:00:00")
        {
            return Date()
        }
        //Create Date Formatter
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        //Specify Format of String to Parse
        dateFormatter.dateFormat = fromFormat
        
        //Parse into NSDate
        if let dateFromString : Date = dateFormatter.date(from: dateString)
        {
            return dateFromString
        }
        else
        {
            return Date()
        }
    }
    
    class func convertStringToUTCDate(dateString:String, fromFormat :String) -> Date
    {
        if (dateString == "" || dateString == "0000-00-00" || dateString == "0000-00-00 00:00:00" || fromFormat != "" )
        {
            return Date()
        }
        //Create Date Formatter
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.init(abbreviation: "UTC")
        //Specify Format of String to Parse
        dateFormatter.dateFormat = fromFormat
        
        //Parse into NSDate
        let dateFromString : Date = dateFormatter.date(from: dateString)!
        
        //Return Parsed Date
        return dateFromString
    }
    
    class func convertDateToString(date: Date, toFormat : String)->String
    {
        if toFormat != ""
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = toFormat
            return dateFormatter.string(from: date)
        }
        
        return ""
    }
    
    class func convertDateToPersiaDateString(date: Date, toFormat : String)->String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.calendar = Calendar.init(identifier: .persian)
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = toFormat
        dateFormatter.locale = Locale.init(identifier: "fa_IR")
        return dateFormatter.string(from: date)
    }
    

    
    class func timeAgoSinceDate(date:Date, numericDates:Bool) -> String
    {
        let calendar = NSCalendar.current
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        let now = NSDate()
        let earliest = now.earlierDate(date as Date)
        let latest = (earliest == now as Date) ? date : now as Date
        let components = calendar.dateComponents(unitFlags, from: earliest as Date,  to: latest as Date)
        
        if (components.year! >= 2) {
            return "\(components.year!) سال پیش"
        } else if (components.year! >= 1){
            if (numericDates){
                return "1 سال پیش"
            } else {
                return "سال گذشته"
            }
        } else if (components.month! >= 2) {
            return "\(components.month!) ماه ها قبل"
        } else if (components.month! >= 1){
            if (numericDates){
                return "1 ماه پیش"
            } else {
                return "ماه گذشته"
            }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!) چند هفته پیش"
        } else if (components.weekOfYear! >= 1){
            if (numericDates){
                return "1 هفته قبل"
            } else {
                return "هفته گذشته"
            }
        } else if (components.day! >= 2) {
            return "\(components.day!) چند روز قبل"
        } else if (components.day! >= 1){
            if (numericDates){
                return "1 روز پیش"
            } else {
                return "دیروز"
            }
        } else if (components.hour! >= 2) {
            return "\(components.hour!) ساعت پیش"
        } else if (components.hour! >= 1){
            if (numericDates){
                return "1 ساعت پیش"
            } else {
                return "یک ساعت پیش"
            }
        } else if (components.minute! >= 2) {
            return "\(components.minute!) دقیقه قبل"
        } else if (components.minute! >= 1){
            if (numericDates){
                return "1 دقیقه پیش"
            } else {
                return "یک دقیقه پیش"
            }
        }
        else if (components.second! >= 3)
        {
            return "همین الان"
        }
        else
        {
            return "همین الان"
        }
    }
    
    class func getBankNameFromCode(code:NSString) -> NSString
    {
        switch code {
        case "010":
            return "بانک مرکزی جمھوری اس می ايران"
        case "011":
            return "بانک صنعت و معدن"
        case "012":
            return "بانک ملت"
        case "013":
            return "بانک رفاه کارگران"
        case "014":
            return "بانک مسکن"
        case "015":
            return "بانک سپه"
        case "016":
            return "بانک کشاورزی"
        case "017":
            return "بانک ملی ايران"
        case "018":
            return "بانک تجارت"
        case "019":
            return "بانک صادرات ايران"
        case "020":
            return "بانک توسعه صادرات"
        case "021":
            return "پست بانک ايران"
        case "022":
            return "بانک توسعه تعاون"
            
        case "051":
            return "موسسه اعتباری توسعه"
        case "053":
            return "بانک کارآفرين"
        case "054":
            return "بانک پارسيان"
        case "055":
            return "بانک اقتصاد نوين"
        case "056":
            return "بانک سامان"
        case "057":
            return "بانک پاسارگاد"
        case "058":
            return "بانک سرمايه"
        case "059":
            return "بانک سينا"
        case "060":
            return "قرض الحسنه مھر"
        case "061":
            return "بانک شھر"
        case "062":
            return "بانک آينده"
        case "063":
            return "بانک انصار"
        case "064":
            return "بانک گردشگری"
        case "065":
            return "بانک حکمت ايرانيان"
        case "066":
            return "بانک دی"
        case "069":
            return "بانک ايران زمين"
            
        default:
            return ""
        }
    }
    
    class func getCurrentTimeStamp()->UInt64
    {
        let currentTimeinterval = UInt64(floor(Date().timeIntervalSince1970 * 1000))
        
        return currentTimeinterval
    }
    
    class func verifyUrl (urlString: String?) -> Bool
    {
        //Check for nil
        if let urlString = urlString
        {
            // create NSURL instance
            if let url = URL(string: urlString)
            {
                // check if your application can open the NSURL instance
                return UIApplication.shared.canOpenURL(url)
            }
        }
        return false
    }
    
    class func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress)
        {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    class func stringSectionDate(timeStamp: TimeInterval) -> String
    {
        let date = Date(timeIntervalSince1970: timeStamp)
        if NSCalendar.current.isDateInToday(date)
        {
            return "Today"
        }
        else if NSCalendar.current.isDateInYesterday(date)
        {
            return "Yesterday"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM, yyyy"
        formatter.locale = Locale(identifier: "en_US")
        
        let strDate: String = formatter.string(from: date)
        return strDate
    }
    
    class func getDayOfWeek()->Int
    {
        let todayDate = Date()
        let weekday = Calendar.current.component(.weekday, from: todayDate)
        
        return weekday
    }
    
    class func getEncodedText(_ text: String) -> String
    {
        let data: Data? = text.data(using: String.Encoding.nonLossyASCII)
        let goodValue = String(data: data!, encoding: String.Encoding.utf8)
        return goodValue!
    }
    class func getDecodedText(_ text: String) -> String
    {
        var encodedText = text
        if encodedText.contains("\\n")
        {
            encodedText = encodedText.replacingOccurrences(of: "\\n", with: "")
        }
        let wI = NSMutableString( string: encodedText )
        CFStringTransform(wI, nil, "Any-Hex/Java" as NSString, true )
        
//        var decodedString = wI as String
//        if decodedString.contains("\\n")
//        {
//            decodedString = decodedString.replacingOccurrences(of: "\\n", with: "")
//        }
        return wI as String
    }
}

//MARK: TADebug

let isDebugModeOn = true

class TADebug {
    
    class func Log<T>(message: T, functionName:  String = #function, fileNameWithPath: String = #file, lineNumber: Int = #line ) {
        
        if isDebugModeOn {
            
            let fileNameWithoutPath:String = NSURL(fileURLWithPath: fileNameWithPath).lastPathComponent ?? ""
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss.SSS"
            let output = "\r\n\(fileNameWithoutPath) => \(functionName) (line \(lineNumber), at \(dateFormatter.string(from: NSDate() as Date)))\r\n => \(message)\r\n"
            print(output)
        }
    }
}

extension Int {
    var abbreviated: String {
        let abbrev = "KMBTPE"
        return abbrev.characters.enumerated().reversed().reduce(nil as String?) { accum, tuple in
            let factor = Double(self) / pow(10, Double(tuple.0 + 1) * 3)
            let format = (factor.truncatingRemainder(dividingBy: 1)  == 0 ? "%.0f%@" : "%.1f%@")
            return accum ?? (factor > 1 ? String(format: format, factor, String(tuple.1)) : nil)
            } ?? String(self)
    }
}

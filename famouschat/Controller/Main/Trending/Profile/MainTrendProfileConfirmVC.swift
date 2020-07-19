//
//  MainTrendProfileConfirmVC.swift
//  famouschat
//
//  Created by angel oni on 2019/2/11.
//  Copyright © 2019 Oni Angel. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class MainTrendProfileConfirmVC: UIViewController, NVActivityIndicatorViewable {

    
    @IBOutlet weak var back_img: UIImageView!
    @IBOutlet weak var back_btn: UIButton!
    @IBOutlet weak var menu_img: UIImageView!
    @IBOutlet weak var menu_btn: UIButton!
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var photo_height: NSLayoutConstraint!
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var fee: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var confirm_btn: UIButton!
    
    let progressDlg = ShareData.progressDlgs[ShareData.progress_index]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        init_UI()
    }
    
    func init_UI()
    {
        
        self.navigationController?.isNavigationBarHidden = true
        
        photo_height.constant = photo.frame.width * 0.7
        photo.load(url: ShareData.selected_influencer.photo!)
        
        name.text = ShareData.selected_influencer.name!
        
        let back_image = UIImage.init(named: "back")!.withRenderingMode(.alwaysTemplate)
        back_img.image = back_image
        back_img.tintColor = UIColor.white
        
        let menu_image = UIImage.init(named: "menu")!.withRenderingMode(.alwaysTemplate)
        menu_img.image = menu_image
        menu_img.tintColor = UIColor.white
        menu_img.isHidden = true
        
        back_btn.addTarget(self, action: #selector(self.backAction(_:)), for: .touchUpInside)
        
        
        let array = CommonFuncs().splitString(ShareData.booking_time)
        time.text = "\(CommonFuncs().timeString("\(array[0])-\(array[1])-\(array[2])-\(array[3])-\(array[4])", "", 0)) EST \(ShareData.time_zones[Int(ShareData.selected_influencer.time_zone!)!])"
        duration.text = "\(ShareData.booking_duration) minutes"
        
        var formater_0 = DateFormatter()
        formater_0.dateFormat = "yyyy-MM-dd"
        let time_str_0 = formater_0.date(from: "\(array[0])-\(array[1])-\(array[2])")!
        
        let calendar_0 = Calendar.current
        let weekDay_0 = calendar_0.component(.weekday, from: time_str_0) as! Int - 1
        
        let array2 = CommonFuncs().splitString(ShareData.selected_influencer.chat_rate!.characters.split(separator: ",").map(String.init)[weekDay_0])
        let rate = (Double(array2[2])! + Double(array2[3])! / 100) / (Double(array2[0])! * 60 + Double(array2[1])!)
        
        fee.text = "$\(String(format: "%.02f", rate * Double(ShareData.booking_duration)!))"
        
        confirm_btn.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        confirm_btn.clipsToBounds = true
        confirm_btn.dropShadow(color: .gray, opacity: 0.8, offSet: CGSize.zero, radius: 5, scale: true)
        
        
    }


    @IBAction func confirmAction(_ sender: Any) {
        
        self.confirm_btn.isUserInteractionEnabled = false
        
        let send_time = CommonFuncs().currentTime()
        
        let parmeters = ["influencer_id": ShareData.selected_influencer.id!, "normal_id": ShareData.user_info.id!, "book_time": ShareData.booking_time, "duration": ShareData.booking_duration, "question": ShareData.booking_question, "time": send_time, "time_zone": ShareData.user_info.time_zone!, "popcoin": ShareData.booking_popcoin] as [String: Any]
        
        self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: progressDlg, color: .darkGray, fadeInAnimation: nil)
        
        CommonFuncs().createRequest(false, "book/request", "POST", parmeters, completionHandler: {data in
            
            let status = data["status"] as! Bool
            let message = data["message"] as! String
            
            DispatchQueue.main.async {
                
                self.confirm_btn.isUserInteractionEnabled = true
                self.stopAnimating(nil)
                
                
               CommonFuncs().doneAlert(ShareData.appTitle, message, "CLOSE", {self.navigationController?.popToRootViewController(animated: true)})
            }
        })
    }
    
    @objc func backAction(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
}

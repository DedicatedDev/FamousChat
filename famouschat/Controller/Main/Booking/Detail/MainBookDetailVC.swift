//
//  MainBookDetailVC.swift
//  famouschat
//
//  Created by angel oni on 2019/2/10.
//  Copyright © 2019 Oni Angel. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import ObjectMapper

class MainBookDetailVC: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet weak var back_img: UIImageView!
    @IBOutlet weak var back_btn: UIButton!
    @IBOutlet weak var menu_img: UIImageView!
    @IBOutlet weak var menu_btn: UIButton!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var photo_height: NSLayoutConstraint!
    @IBOutlet weak var name_btn: UIButton!
    @IBOutlet weak var day_label: UILabel!
    
    @IBOutlet weak var like_0: UIImageView!
    @IBOutlet weak var like_1: UIImageView!
    @IBOutlet weak var like_2: UIImageView!
    @IBOutlet weak var like_3: UIImageView!
    @IBOutlet weak var like_4: UIImageView!
    
    @IBOutlet weak var main_frame: UIView!
    @IBOutlet weak var main_frame_height: NSLayoutConstraint!
    @IBOutlet weak var scroll_height: NSLayoutConstraint!
    @IBOutlet weak var call_reason: UILabel!
    @IBOutlet weak var call_reason_height: NSLayoutConstraint!
    @IBOutlet weak var call_time: UILabel!
    @IBOutlet weak var call_rate: UILabel!
    
    @IBOutlet weak var btn_frame_width: NSLayoutConstraint!
    @IBOutlet weak var start_btn: UIButton!
    @IBOutlet weak var cancel_btn: UIButton!
    
    let progressDlg = ShareData.progressDlgs[ShareData.progress_index]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        init_UI()
        
    }
    
    func init_UI()
    {
        self.navigationController?.isNavigationBarHidden = true
        
        main_frame.dropShadow(color: .gray, opacity: 0.5, offSet: CGSize(width: 0, height: 2
        ), radius: 1, scale: true)
        
        let back_image = UIImage.init(named: "back")!.withRenderingMode(.alwaysTemplate)
        back_img.image = back_image
        back_img.tintColor = UIColor.white
        
        let menu_image = UIImage.init(named: "menu")!.withRenderingMode(.alwaysTemplate)
        menu_img.image = menu_image
        menu_img.tintColor = UIColor.white
        menu_img.isHidden = true
        
        back_btn.addTarget(self, action: #selector(self.backAction(_:)), for: .touchUpInside)
        
        photo_height.constant = photo.frame.width * 0.7
        photo.load(url: ShareData.selected_book.profile.photo!)
        
        CommonFuncs().likeStars(Double(ShareData.selected_book.profile.rate!)!, [like_0, like_1, like_2, like_3, like_4])
        
        day_label.text = CommonFuncs().timeString(ShareData.selected_book.book.time!, "", 1)
        day_label.isHidden = false
        
        name_btn.setTitle(ShareData.selected_book.profile.name!, for: .normal)
        
        let reason_height = CommonFuncs().getStringHeight(ShareData.selected_book.book.question!, 13, main_frame.frame.width, 30, 10)
        
        call_reason.text = ShareData.selected_book.book.question!
        
        call_reason_height.constant = reason_height
        main_frame_height.constant = reason_height + 220
        scroll_height.constant = reason_height + 700
        
        let time_zone_div = Int(ShareData.time_zones[Int(ShareData.user_info.time_zone!)!])! - Int(ShareData.time_zones[Int(ShareData.selected_book.profile.time_zone!)!])!
        
        let formater = DateFormatter()
        formater.dateFormat = "yyyy-MM-dd-HH-mm"
        let start_time = formater.date(from: ShareData.selected_book.book.time!)!.addingTimeInterval(TimeInterval(time_zone_div * 3600))
        let week_num = Calendar.current.component(.weekday, from: start_time)
        
        let array1 = ["\(Calendar.current.component(.year, from: start_time) as! Int)", String(format: "%02d", Calendar.current.component(.month, from: start_time) as! Int), String(format: "%02d", Calendar.current.component(.day, from: start_time) as! Int), String(format: "%02d", Calendar.current.component(.hour, from: start_time) as! Int), String(format: "%02d", Calendar.current.component(.minute, from: start_time) as! Int)]
        
        let start_time_str = "\(CommonFuncs().time24To12(array1[3])[0]):\(array1[4]) \(CommonFuncs().time24To12(array1[3])[1])"
        
        var end_hour = Int(array1[3])!
        var end_min = Int(array1[4])! + Int(ShareData.selected_book.book.duration)!
        if end_min / 60 >= 1
        {
            end_hour += (end_min / 60)
            end_min = end_min % 60
        }
        
        let array2 = [String(format: "%02d", end_hour), String(format: "%02d", end_min)]
        let end_time_str = "\(CommonFuncs().time24To12(array2[0])[0]):\(array2[1]) \(CommonFuncs().time24To12(array2[0])[1])"
        
        
        call_time.attributedText = CommonFuncs().attributeString([UIFont.boldSystemFont(ofSize: 13), UIFont.systemFont(ofSize: 13)], [UIColor.gray, UIColor.gray],  ["\(ShareData.selected_book.book.duration!) minutes", "  \(start_time_str) - \(end_time_str)"])
        
        let array3_rate = ShareData.selected_book.profile.chat_rate!.split(separator: ",").map(String.init)
        let array3_book_time = CommonFuncs().splitString(ShareData.selected_book.book.time!)
        
        let array3 = CommonFuncs().splitString(array3_rate[week_num])
        let rate = (Double(array3[2])! + Double(array3[3])! / 100) / (Double(array3[0])! * 60 + Double(array3[1])!)
        
        call_rate.attributedText = CommonFuncs().attributeString([UIFont.boldSystemFont(ofSize: 13), UIFont.systemFont(ofSize: 13)], [UIColor.gray, UIColor.gray], ["$\(String(format: "%.02f", rate * Double(ShareData.selected_book.book.duration!)!))", "    for \(ShareData.selected_book.book.duration!) minutes"])
        
        start_btn.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        start_btn.clipsToBounds = true
        start_btn.dropShadow(color: .gray, opacity: 0.8, offSet: CGSize.zero, radius: 5, scale: true)
        
        cancel_btn.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        cancel_btn.clipsToBounds = true
        cancel_btn.dropShadow(color: .gray, opacity: 0.8, offSet: CGSize.zero, radius: 5, scale: true)
        
        if ShareData.book_detail_from_status
        {
            if ShareData.selected_book.book.normal_id! == ShareData.user_info.id!
            {
                start_btn.isHidden = true
                btn_frame_width.constant = 140
            }
        }
        else
        {
            start_btn.setTitle("Cancel", for: .normal)
            cancel_btn.setTitle("Accept", for: .normal)
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        start_btn.isUserInteractionEnabled = true
    }

    @IBAction func startAction(_ sender: Any) {
        
        if ShareData.book_detail_from_status
        {
            start_btn.isUserInteractionEnabled = false
            
            var id = ""
            id = ShareData.selected_book.book.normal_id!
            QuickBloxHelper.sharedInstance.getUserByExterNalId(id) { (isSucess, oponentId) in
                if isSucess {
                    
                    QuickBloxHelper.sharedInstance.sendPushToOponent("\(oponentId)")
                    QuickBloxHelper.sharedInstance.makeCall(toQBId: oponentId, hintText: "video chat \(ShareData.selected_book.profile.name!)", tutorId: "1234", videoCallId: ShareData.selected_book.book.id!)
                    
                    
                    let parmeters = ["book_id": ShareData.selected_book.book.id!] as [String: Any]
                    
                    CommonFuncs().createRequest(false, "book/start", "POST", parmeters, completionHandler: {data in
                        
                        DispatchQueue.main.async {
                            
                            self.start_btn.isUserInteractionEnabled = true
                            ShareData.video_chat_start_status = true
                            self.navigationController?.pushViewController(MainVideoCallingVC(), animated: true)
                            
                        }
                    })
                    
                    
                } else {
                    
                    self.start_btn.isUserInteractionEnabled = true
                    
                    CommonFuncs().doneAlert(ShareData.appTitle, "You can not call \(ShareData.selected_book.profile.name!) right Now", "CLOSE", {})
                }
            }
        }
        else
        {
            let send_time = CommonFuncs().currentTime()
            
            let parmeters = ["book_id": ShareData.selected_book.book.id!, "time": send_time, "time_zone": ShareData.user_info.time_zone!] as [String: Any]
            
            self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: self.progressDlg, color: .darkGray, fadeInAnimation: nil)
            
            CommonFuncs().createRequest(false, "book/cancel", "POST", parmeters, completionHandler: {data in
                
                let status = data["status"] as! Bool
                let message = data["message"] as! String
                
                DispatchQueue.main.async {
                    
                    CommonFuncs().doneAlert(ShareData.appTitle, message, "CLOSE", {
                        self.stopAnimating()
                        self.navigationController?.popViewController(animated: true)})
                }
            })
        }
        
        
        
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        
        if ShareData.book_detail_from_status
        {
            let send_time = CommonFuncs().currentTime()
            let time_array = CommonFuncs().splitString(send_time)
            let booked_time = CommonFuncs().splitString(ShareData.selected_book.book.time!)
            
            if (time_array[0] == booked_time[0]) && (time_array[1] == booked_time[1])
            {
                if (time_array[2] == booked_time[2]) || ((Int(booked_time[2])! - Int(time_array[2])!) == 1 && Int(time_array[3])! >= Int(booked_time[3])!)
                {
                    CommonFuncs().doneAlert(ShareData.appTitle, "You can`t cancel this book in 24 hours", "CLOSE", {})
                    return
                }
                
            }
            
            let parmeters = ["book_id": ShareData.selected_book.book.id!, "time": send_time, "time_zone": ShareData.user_info.time_zone!] as [String: Any]
            
            self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: self.progressDlg, color: .darkGray, fadeInAnimation: nil)
            
            CommonFuncs().createRequest(false, "book/cancel", "POST", parmeters, completionHandler: {data in
                
                let status = data["status"] as! Bool
                let message = data["message"] as! String
                
                self.stopAnimating(nil)
                
                DispatchQueue.main.async {
                    
                    self.stopAnimating(nil)
                    
                    if status
                    {
                        ShareData.books = ShareData.books.filter { $0.book.id != ShareData.selected_book.book.id! }
                        
                    }
                    CommonFuncs().doneAlert(ShareData.appTitle, message, "CLOSE", {
                        self.stopAnimating()
                        self.navigationController?.popToRootViewController(animated: true)})
                    
                }
            })
        }
        else
        {
            let send_time = CommonFuncs().currentTime()
            let parmeters = ["book_id": ShareData.selected_book.book.id!, "time": send_time, "time_zone": ShareData.user_info.time_zone!] as [String: Any]
            
            self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: self.progressDlg, color: .darkGray, fadeInAnimation: nil)
            
            CommonFuncs().createRequest(false, "book/accept", "POST", parmeters, completionHandler: {data in
                
                let status = data["status"] as! Bool
                let message = data["message"] as! String
                
                DispatchQueue.main.async {
                    
                    if let temp = Mapper<BookMDL>().map(JSONObject: data["data"])
                    {
                        ShareData.books.append(temp)
                        ShareData.selected_book = temp
                        
                    }
                    CommonFuncs().doneAlert(ShareData.appTitle, message, "CLOSE",  {
                        self.stopAnimating()
                        self.navigationController?.popViewController(animated: true)})
                    
                }
            })
        }
        
        
    }
    
    @IBAction func detailAction(_ sender: Any) {
        
        var parameters: [String: Any]!
        
        if ShareData.selected_book.book.normal_id! == ShareData.user_info.id!
        {
            parameters = ["user_id": ShareData.selected_book.book.influencer_id!, "type": "0"]
        }
        else
        {
            parameters = ["user_id": ShareData.selected_book.book.normal_id!, "type": "1"]
        }
        
        self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: progressDlg, color: .darkGray, fadeInAnimation: nil)
        
        CommonFuncs().createRequest(false, "review/request", "POST", parameters, completionHandler: {data in
            
            let status = data["status"] as! Bool
            let message = data["message"] as! String
            
            DispatchQueue.main.async {
                
                self.stopAnimating(nil)
                
                if status
                {
                    ShareData.reviews = [ReviewMDL]()
                    
                    if let detail = data["data"] as? [String:Any]
                    {
                        if let profile = detail["profile"] as? [String:Any], let temp = Mapper<UserMDL>().map(JSONObject: profile)
                        {
                            ShareData.user_detail_profile = temp
                        }
                        
                        if let reviews = detail["reviews"] as? [String:Any], let temp = Mapper<ReviewMDL>().mapArray(JSONObject: reviews)
                        {
                            ShareData.user_detail_reviews = temp
                        }
                        
                    }
                    self.navigationController?.pushViewController(MainBookDetailProfileVC(), animated: true)
                }
                else
                {
                    CommonFuncs().doneAlert(ShareData.appTitle, message, "CLOSE", {})
                }
                
            }
            
        })
        
    }
    
    @objc func backAction(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
}



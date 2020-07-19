//
//  MoreInfluencerAuctionNewVC.swift
//  famouschat
//
//  Created by T-Tech Solutions LLC on 11/11/2018.
//  Copyright © 2018 T-Tech Solutions LLC. All rights reserved.
//

import UIKit
import Alamofire
import NVActivityIndicatorView
import ObjectMapper


class MoreInfluencerAuctionNewVC: UIViewController, NVActivityIndicatorViewable {
   
    @IBOutlet weak var title_label: UILabel!
    
    @IBOutlet weak var header_frame: UIView!
    @IBOutlet weak var back_img: UIImageView!
    @IBOutlet weak var back_btn: UIButton!
    @IBOutlet weak var menu_img: UIImageView!
    @IBOutlet weak var menu_btn: UIButton!
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var scroll_height: NSLayoutConstraint!
    @IBOutlet weak var duration_btn: UIButton!
    
    @IBOutlet weak var start_frame: UIView!
    @IBOutlet weak var start_time_mon: UILabel!
    @IBOutlet weak var start_time_day: UILabel!
    @IBOutlet weak var start_time_year: UILabel!
    
    @IBOutlet weak var chat_day_frame: UIView!
    @IBOutlet weak var chat_day_mon: UILabel!
    @IBOutlet weak var chat_day_day: UILabel!
    @IBOutlet weak var chat_day_year: UILabel!

    @IBOutlet weak var chat_time_frame: UIView!
    @IBOutlet weak var chat_start_time_label: UILabel!
    @IBOutlet weak var chat_end_time_label: UILabel!
    
    @IBOutlet weak var charity_btn: UIButton!
    
    @IBOutlet weak var charity_frame: UIView!
    @IBOutlet weak var charity_in: UITextView!
    @IBOutlet weak var goal_cost_frame: UIView!
    @IBOutlet weak var goal_cost_in: UITextField!
    @IBOutlet weak var out_cost_frame: UIView!
    @IBOutlet weak var out_cost_in: UITextField!
    @IBOutlet weak var create_btn: UIButton!
    
    
    
    let progressDlg = ShareData.progressDlgs[ShareData.progress_index]
    
    var start_time = ""
    var chat_day = ""
    
    let time_am_array = ["AM", "PM"]
    let time_hour_array = ["00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
    let time_min_array = ["00", "15", "30", "45"]
    
    var chat_time_array = ["09", "00", "AM", "05", "00", "PM"]
    
    let month_names : [String] = ["January","Febrary","March","April","May","June","July","August","September","October","November","December"]
    
    var alert: DatePickerAlert!
    var picker_alert: SixPickerAlert!
    var duration_alert: OnePickerAlert!
    var charity_alert: SearchPickerAlert!
    var new_charity_alert: ImagePickerAlert!
    var alert_index = 0
    
    var charity_name = ""
    var charity_id = ""
    
    var filterd_charity_array = [CharityMDL]()
    
    let duration_array = ["1", "2", "3", "5", "7", "10", "15", "20", "25", "30", "45", "60", "90"]
    var duration = "10"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let array = CommonFuncs().splitString(CommonFuncs().currentTime())
        
        if !ShareData.auciton_create_edit
        {
            start_time = "\(array[0])-\(array[1])-\(array[2])"
            chat_day = "\(array[0])-\(array[1])-\(array[2])"
        }
        else
        {
            start_time = ShareData.selected_auction.start_time!
            duration = ShareData.selected_auction.duration!
            chat_day = ShareData.selected_auction.chat_day!
            charity_id = ShareData.selected_auction.charity_id!
            
            let array1 = CommonFuncs().splitString(ShareData.selected_auction.chat_time!)
            let array2 =  CommonFuncs().time24To12(array1[0])
            let array3 = CommonFuncs().time24To12(array1[2])
            
            chat_time_array = [array2[0], array1[1], array2[1], array3[0], array1[3], array3[1]]
            
        }
        
        filterd_charity_array = ShareData.charity_list
        
        init_UI()
    }
    
    func init_UI()
    {
        self.navigationController?.isNavigationBarHidden = true
        
        header_frame.dropShadow(color: .gray, opacity: 0.5, offSet: CGSize.zero, radius: 8, scale: true)
        
        let back_image = UIImage.init(named: "back")!.withRenderingMode(.alwaysTemplate)
        back_img.image = back_image
        back_img.tintColor = Utility.color(withHexString: ShareData.btn_color)
        
        let menu_image = UIImage.init(named: "menu")!.withRenderingMode(.alwaysTemplate)
        menu_img.image = menu_image
        menu_img.tintColor = Utility.color(withHexString: ShareData.btn_color)
        menu_img.isHidden = true
        
        back_btn.addTarget(self, action: #selector(self.backAction(_:)), for: .touchUpInside)
        
        scroll_height.constant = 950
        scroll.scrollsToTop = false
        
        start_frame.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        start_frame.clipsToBounds = true
        start_frame.dropShadow(color: .gray, opacity: 0.8, offSet: CGSize.zero, radius: 5, scale: true)
        
        var array = [String]()
        var array1 = [String]()
        
        if !ShareData.auciton_create_edit
        {
            title_label.text = "Create an Auction"
            array = CommonFuncs().splitString(CommonFuncs().currentTime())
            array1 = CommonFuncs().splitString(CommonFuncs().currentTime())
            duration_btn.setTitle("Select Duration", for: .normal)
            charity_btn.setTitle("Select Charity", for: .normal)
            charity_in.text = "Write about chaity..."
            goal_cost_in.placeholder = "Write goal cost..."
            out_cost_in.placeholder = "Write out cost..."
            create_btn.setTitle("CREAT AUCTION", for: .normal)
        }
        else
        {
            let data = ShareData.selected_auction!
            
            title_label.text = "Edit an Auction"
            array = CommonFuncs().splitString(data.start_time!)
            array1 = CommonFuncs().splitString(data.chat_day!)
            duration_btn.setTitle(duration, for: .normal)
            
            let index = ShareData.charity_list.index { $0.id == data.charity_id! }
            charity_name = ShareData.charity_list[index!].name!
            charity_btn.setTitle(ShareData.charity_list[index!].name!, for: .normal)
            charity_in.text = data.charity_info!
            goal_cost_in.text = data.goal_cost!
            out_cost_in.text = data.out_cost!
            create_btn.setTitle("UPDATE AUCTION", for: .normal)
        }
        
        start_time_mon.text = month_names[Int(array[1])! - 1]
        start_time_day.text = array[2]
        start_time_year.text = array[0]
        
        duration_btn.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        duration_btn.clipsToBounds = true
        duration_btn.dropShadow(color: .gray, opacity: 0.5, offSet: CGSize.zero, radius: 5, scale: true)
        
        chat_day_frame.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        chat_day_frame.clipsToBounds = true
        chat_day_frame.dropShadow(color: .gray, opacity: 0.5, offSet: CGSize.zero, radius: 5, scale: true)
        
        chat_day_mon.text = month_names[Int(array1[1])! - 1]
        chat_day_day.text = array1[2]
        chat_day_year.text = array1[0]
        
        chat_time_frame.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        chat_time_frame.clipsToBounds = true
        chat_time_frame.dropShadow(color: .gray, opacity: 0.5, offSet: CGSize.zero, radius: 5, scale: true)
        
        chat_start_time_label.attributedText = CommonFuncs().attributeString([UIFont.boldSystemFont(ofSize: 15), UIFont.boldSystemFont(ofSize: 15),UIFont.boldSystemFont(ofSize: 15), UIFont.boldSystemFont(ofSize: 12)], [UIColor.darkGray, Utility.color(withHexString: ShareData.btn_color), UIColor.darkGray, UIColor.darkGray], [chat_time_array[0], "  :  ", chat_time_array[1], "  \(chat_time_array[2])"])
        chat_end_time_label.attributedText = CommonFuncs().attributeString([UIFont.boldSystemFont(ofSize: 15), UIFont.boldSystemFont(ofSize: 15),UIFont.boldSystemFont(ofSize: 15), UIFont.boldSystemFont(ofSize: 12)], [UIColor.darkGray, Utility.color(withHexString: ShareData.btn_color), UIColor.darkGray, UIColor.darkGray], [chat_time_array[3], "  :  ", chat_time_array[4], "  \(chat_time_array[5])"])
        
        
        charity_btn.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        charity_btn.clipsToBounds = true
        charity_btn.dropShadow(color: .gray, opacity: 0.5, offSet: CGSize.zero, radius: 5, scale: true)
        
        charity_frame.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        charity_frame.layer.borderColor = UIColor.gray.cgColor
        charity_frame.layer.borderWidth = 1
        charity_frame.clipsToBounds = true
        
        goal_cost_frame.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        goal_cost_frame.layer.borderColor = UIColor.gray.cgColor
        goal_cost_frame.layer.borderWidth = 1
        goal_cost_frame.clipsToBounds = true
        
        out_cost_frame.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        out_cost_frame.layer.borderColor = UIColor.gray.cgColor
        out_cost_frame.layer.borderWidth = 1
        out_cost_frame.clipsToBounds = true
        
        
        create_btn.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        create_btn.dropShadow(color: .gray, opacity: 0.8, offSet: CGSize.zero, radius: 5, scale: true)
        
        charity_in.delegate = self
        out_cost_in.delegate = self
        goal_cost_in.delegate = self
        
    }
    
    @IBAction func startTimeAction(_ sender: Any) {
        
        self.alert = DatePickerAlert.instanceFromNib("Start Time", true) as? DatePickerAlert
        self.scroll.isHidden = true
        
        alert_index = 0
        alert.apply_btn.addTarget(self, action: #selector(self.pickerDone(_:)), for: .touchUpInside)
    }
    
    @IBAction func durationAction(_ sender: Any) {
        
        alert_index = 3
        self.duration_alert = OnePickerAlert.instanceFromNib(title: "Duration") as? OnePickerAlert
        
        self.scroll.isHidden = true
        
        self.duration_alert.picker.delegate = self
        self.duration_alert.picker.dataSource = self
        
        let index = duration_array.index(where: { $0 == duration })
        self.duration_alert.picker.selectRow(index!, inComponent: 0, animated: true)
        
        duration_alert.apply_btn.addTarget(self, action: #selector(self.durationPickerDone(_:)), for: .touchUpInside)
    }
    
    @IBAction func chatDayAction(_ sender: Any) {
        
        self.alert = DatePickerAlert.instanceFromNib("Day of Chat", true) as? DatePickerAlert
        self.scroll.isHidden = true
        
        alert_index = 1
        alert.apply_btn.addTarget(self, action: #selector(self.pickerDone(_:)), for: .touchUpInside)
    }
    
    @IBAction func chatTimeAction(_ sender: Any) {
        
        alert_index = 2
        self.picker_alert = SixPickerAlert.instanceFromNib("Time") as? SixPickerAlert
        
        self.scroll.isHidden = true
        
        self.picker_alert.picker_11.delegate = self
        self.picker_alert.picker_11.dataSource = self
        self.picker_alert.picker_12.delegate = self
        self.picker_alert.picker_12.dataSource = self
        self.picker_alert.picker_13.delegate = self
        self.picker_alert.picker_13.dataSource = self
        self.picker_alert.picker_21.delegate = self
        self.picker_alert.picker_21.dataSource = self
        self.picker_alert.picker_22.delegate = self
        self.picker_alert.picker_22.dataSource = self
        self.picker_alert.picker_23.delegate = self
        self.picker_alert.picker_23.dataSource = self
        
        let index11 = time_hour_array.index(where: { $0 == chat_time_array[0] })
        self.picker_alert.picker_11.selectRow(index11!, inComponent: 0, animated: true)
        let index12 = time_min_array.index(where: { $0 == chat_time_array[1] })
        self.picker_alert.picker_12.selectRow(index12!, inComponent: 0, animated: true)
        let index13 = time_am_array.index(where: { $0 == chat_time_array[2] })
        self.picker_alert.picker_13.selectRow(index13!, inComponent: 0, animated: true)
        let index21 = time_hour_array.index(where: { $0 == chat_time_array[3] })
        self.picker_alert.picker_21.selectRow(index21!, inComponent: 0, animated: true)
        let index22 = time_min_array.index(where: { $0 == chat_time_array[4] })
        self.picker_alert.picker_22.selectRow(index22!, inComponent: 0, animated: true)
        let index23 = time_am_array.index(where: { $0 == chat_time_array[5] })
        self.picker_alert.picker_23.selectRow(index23!, inComponent: 0, animated: true)
        
        picker_alert.apply_btn.addTarget(self, action: #selector(self.timePickerDone(_:)), for: .touchUpInside)
    }
    
    @IBAction func charitySelACtion(_ sender: Any) {
        
        alert_index = 4
        self.charity_alert = SearchPickerAlert.instanceFromNib(title: "Charity") as! SearchPickerAlert
        
        self.scroll.isHidden = true
        
        filterd_charity_array = ShareData.charity_list
        
        self.charity_alert.picker.delegate = self
        self.charity_alert.picker.dataSource = self
        
        self.charity_alert.search_in.delegate = self
        self.charity_alert.search_in.placeholder = "Search..."
        self.charity_alert.search_in.addTarget(self, action: #selector(charityNameDidChange(_:)), for: .editingChanged)
        
        charity_alert.add_btn.addTarget(self, action: #selector(self.newCharityAction(_:)), for: .touchUpInside)
        charity_alert.apply_btn.addTarget(self, action: #selector(self.charityPickerDone(_:)), for: .touchUpInside)
    }
    
    
    @IBAction func createAction(_ sender: Any) {
        
        
        if charity_in.text! == "" || charity_name == "" || out_cost_in.text! == "" || goal_cost_in.text! == ""
        {
            CommonFuncs().doneAlert(ShareData.appTitle, "Please fill all items", "CLOSE", {})
        }
        else
        {
            
            let array = [CommonFuncs().time12To24(chat_time_array[0], chat_time_array[2]), chat_time_array[1], CommonFuncs().time12To24(chat_time_array[3], chat_time_array[5]), chat_time_array[4]]
            let chat_time_str = CommonFuncs().strArrayTostr(array, "-")
            
            var parmeters = [:] as [String: Any]
            
            let send_time = CommonFuncs().currentTime()
            
            if !ShareData.auciton_create_edit
            {
                parmeters = ["user_id": ShareData.user_info.id!, "start_time": start_time, "duration": duration, "chat_day": chat_day, "chat_time": chat_time_str, "charity_id": charity_id, "charity_info": charity_in.text!, "out_cost": out_cost_in.text!, "goal_cost": goal_cost_in.text!, "time": send_time, "time_zone": ShareData.user_info.time_zone!] as [String: Any]
            }
            else
            {
                parmeters = ["user_id": ShareData.user_info.id!, "auction_id": ShareData.selected_auction.id!, "start_time": start_time, "duration": duration, "chat_day": chat_day, "chat_time": chat_time_str, "charity_id": charity_id, "charity_info": charity_in.text!, "out_cost": out_cost_in.text!, "goal_cost": goal_cost_in.text!, "time": send_time, "time_zone": ShareData.user_info.time_zone!] as [String: Any]
            }
            
            
            self.create_btn.isUserInteractionEnabled = false
            
            self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: progressDlg, color: .darkGray, fadeInAnimation: nil)
            
            CommonFuncs().createRequest(false, "auction/create", "POST", parmeters, completionHandler: {data in
                
                let status = data["status"] as! Bool
                let message = data["message"] as! String
                
                DispatchQueue.main.async {
                    
                    self.stopAnimating(nil)
                    if status
                    {
                        if !ShareData.auciton_create_edit
                        {
                            
                            if let temp = Mapper<AuctionMDL>().map(JSONObject: data["data"])
                            {
                                ShareData.auction_list.append(temp)
                                
                            }
                            
                        }
                        else
                        {
                            if let temp = Mapper<AuctionMDL>().map(JSONObject: data["data"])
                            {
                                let index = ShareData.auction_list.index { $0.id! == ShareData.selected_auction.id! }
                                ShareData.selected_auction = temp
                                ShareData.auction_list[index!] = temp
                            }
                            
                        }
                        
                    }
                    
                    CommonFuncs().doneAlert(ShareData.appTitle, message, "CLOSE", {self.navigationController?.popViewController(animated: true)})
                    
                    self.create_btn.isUserInteractionEnabled = true
                    
                }
            })
        }
        
    }
    
    @objc func backAction(_ sender: UIButton) {
        
        if alert != nil
        {
            alert.removeFromSuperview()
        }
        
        if picker_alert != nil
        {
            picker_alert.removeFromSuperview()
        }
        
        if duration_alert != nil
        {
            duration_alert.removeFromSuperview()
        }
        
        if charity_alert != nil
        {
            charity_alert.removeFromSuperview()
        }
        
        if new_charity_alert != nil
        {
            charity_alert.removeFromSuperview()
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension MoreInfluencerAuctionNewVC: UITextViewDelegate, UITextFieldDelegate
{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        out_cost_in.resignFirstResponder()
        goal_cost_in.resignFirstResponder()
        
        if alert_index == 4
        {
            charity_alert.search_in.resignFirstResponder()
        }
        else if alert_index == 5
        {
            new_charity_alert.name.resignFirstResponder()
        }
        
        return true
    }
    
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {

        if textField == goal_cost_in
        {
            scroll.setContentOffset(CGPoint(x: 0, y: 500), animated: true)
        }
        else
        {
            scroll.setContentOffset(CGPoint(x: 0, y: 580), animated: true)
        }

        return true
    }
    
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        if !ShareData.auciton_create_edit
        {
            charity_in.text = ""
        }
        scroll.setContentOffset(CGPoint(x: 0, y: 460), animated: true)
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        if textView.text.contains("\n")
        {
            let str = textView.text!
            textView.text = str.substring(to: str.index(before: str.endIndex))
            textView.resignFirstResponder()
        }
    }
    
    @objc func charityNameDidChange(_ textField: UITextField) {
        
        let str = charity_alert.search_in.text!
        if str == nil || str == ""
        {
            filterd_charity_array = ShareData.charity_list
        }
        else
        {
            filterd_charity_array = ShareData.charity_list.filter { $0.name.lowercased().contains(str.lowercased()) }
        }
        
        charity_alert.picker.reloadAllComponents()
    }
}


extension MoreInfluencerAuctionNewVC
{
    
    
    @objc func pickerDone(_ sender: UIButton) {
        
        let str = self.alert.time_str
        
        let array = CommonFuncs().splitString(str)
        
        if alert_index == 0
        {
            self.start_time = str
            start_time_year.text = array[0]
            start_time_mon.text = month_names[Int(array[1])! - 1]
            start_time_day.text = array[2]
        }
        else
        {
            self.chat_day = str
            chat_day_year.text = array[0]
            chat_day_mon.text = month_names[Int(array[1])! - 1]
            chat_day_day.text = array[2]
        }
        
        self.alert.removeFromSuperview()
        self.scroll.isHidden = false
    }
    
    @objc func newCharityAction(_ sender: UIButton) {
        
        self.charity_alert.removeFromSuperview()
        
        alert_index = 5
        self.new_charity_alert = ImagePickerAlert.instanceFromNib(title: "New Charity") as! ImagePickerAlert
        
        self.scroll.isHidden = true
        
        self.charity_alert.picker.delegate = self
        self.charity_alert.picker.dataSource = self
        
        self.new_charity_alert.name.delegate = self
        self.new_charity_alert.name.placeholder = "Charity Name"
        
        new_charity_alert.photo_btn.addTarget(self, action: #selector(self.charityPhotoAction(_:)), for: .touchUpInside)
        new_charity_alert.cancel_btn.addTarget(self, action: #selector(self.charityCreateCancel(_:)), for: .touchUpInside)
        new_charity_alert.add_btn.addTarget(self, action: #selector(self.charityCreateDone(_:)), for: .touchUpInside)
    }
    
    
    @objc func durationPickerDone(_ sender: UIButton) {
        
        self.duration_alert.removeFromSuperview()
        self.scroll.isHidden = false
        
        duration_btn.setTitle(duration, for: .normal)
        
    }
    
    @objc func charityPickerDone(_ sender: UIButton) {
        
        self.charity_alert.removeFromSuperview()
        self.scroll.isHidden = false
        alert_index == 1
        
        charity_btn.setTitle(charity_name, for: .normal)
        
    }
    
    @objc func charityPhotoAction(_ sender: UIButton) {
        
        
        new_charity_alert.isHidden = true
        
        let alertController = UIAlertController.init(title: "\(ShareData.appTitle)", message: "Select Charity Image", preferredStyle: .actionSheet)
        
        
        let imageAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.default)
        {
            UIAlertAction in
            
            self.ImageFromCamera()
        }
        
        let galleryAction = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.default)
        {
            UIAlertAction in
            
            self.ImageFromGallary()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
        {
            UIAlertAction in
            
            self.dismiss(animated: true, completion: nil)
            ShareData.profile_photo = nil
            self.new_charity_alert.isHidden = false
        }
        
        alertController.addAction(imageAction)
        alertController.addAction(galleryAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @objc func charityCreateDone(_ sender: UIButton) {
        
        let str = new_charity_alert.name.text!
        if str == nil || str == ""
        {
            
            CommonFuncs().doneAlert(ShareData.appTitle, "Please type charity name", "CLOSE", {return})
        }
        else
        {
            
            
            self.new_charity_alert.removeFromSuperview()
            self.scroll.isHidden = false
            
            let url = URL(string: "\(ShareData.main_url)charity/index.php")!
            let parameter = ["name":str] as! [String: String]
            
            self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: progressDlg, color: .darkGray, fadeInAnimation: nil)
            
            Alamofire.upload(multipartFormData: { (multiPartFormData: MultipartFormData) in
                for (key, value) in parameter as! [String: String] {
                    multiPartFormData.append((value as String).data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, withName: key)
                }
                
                if ShareData.profile_photo != nil
                {
                    
                    multiPartFormData.append(ShareData.profile_photo! as Data, withName: "upload", fileName: "profile.png", mimeType: "image/png")
                }
                
                
            }, to: url) { (result: SessionManager.MultipartFormDataEncodingResult) in
                switch result {
                case .success(request: let uploadRequest, _, _ ):
                    
                    
                    uploadRequest.uploadProgress(closure: { (progress) in
                        
                        print("===== \(progress)")
                    })
                    
                    
                    uploadRequest.responseJSON(completionHandler: {response in
                        
                        if let JSON = response.result.value
                        {
                            let dictData = JSON as! NSDictionary
                            let status = dictData["status"] as! Bool
                            let message = dictData["message"] as! String
                            if status
                            {
                                let data = dictData["data"] as! [String: Any]
                                
                                if let temp = Mapper<CharityMDL>().map(JSONObject: dictData["data"])
                                {
                                    ShareData.charity_list.append(temp)
                                }
                                
                                self.stopAnimating(nil)
                                CommonFuncs().doneAlert(ShareData.appTitle, message, "CLOSE", {self.alert_index == 1
                                    
                                    let str1 = self.new_charity_alert.name.text!
                                    self.charity_name = str1
                                    self.charity_btn.setTitle(self.charity_name, for: .normal)})
                                
                            }
                            else
                            {
                                self.stopAnimating(nil)
                                CommonFuncs().doneAlert(ShareData.appTitle, message, "CLOSE", {})
                                
                            }
                            
                        }
                        
                    })
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        
    }
    
    @objc func charityCreateCancel(_ sender: UIButton) {
        
        new_charity_alert.removeFromSuperview()
        
        alert_index = 4
        self.charity_alert = SearchPickerAlert.instanceFromNib(title: "Charity") as! SearchPickerAlert
        
        self.scroll.isHidden = true
        
        filterd_charity_array = ShareData.charity_list
        
        self.charity_alert.picker.delegate = self
        self.charity_alert.picker.dataSource = self
        
        self.charity_alert.search_in.delegate = self
        self.charity_alert.search_in.placeholder = "Search..."
        self.charity_alert.search_in.addTarget(self, action: #selector(charityNameDidChange(_:)), for: .editingChanged)
        
        charity_alert.add_btn.addTarget(self, action: #selector(self.newCharityAction(_:)), for: .touchUpInside)
        charity_alert.apply_btn.addTarget(self, action: #selector(self.charityPickerDone(_:)), for: .touchUpInside)
        
    }
    
    
}


extension MoreInfluencerAuctionNewVC: UIPickerViewDelegate, UIPickerViewDataSource
{
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        
        if alert_index == 2
        {
            switch(pickerView)
            {
            case picker_alert.picker_11:
                return time_hour_array.count
            case picker_alert.picker_12:
                return time_min_array.count
            case picker_alert.picker_13:
                return time_am_array.count
            case picker_alert.picker_21:
                return time_hour_array.count
            case picker_alert.picker_22:
                return time_min_array.count
            case picker_alert.picker_23:
                return time_am_array.count
                
                
            default:
                return 0
            }
        }
        else if alert_index == 3
        {
            return duration_array.count
        }
        else
        {
            return filterd_charity_array.count
        }
        
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            
            pickerLabel?.textAlignment = .center
        }
        
        var str = ""
        if alert_index == 2
        {
            pickerLabel?.font = UIFont.systemFont(ofSize: 13)
            
            switch(pickerView)
            {
            case picker_alert.picker_11:
                str = time_hour_array[row]
            case picker_alert.picker_12:
                str = time_min_array[row]
            case picker_alert.picker_13:
                str = time_am_array[row]
            case picker_alert.picker_21:
                str = time_hour_array[row]
            case picker_alert.picker_22:
                str = time_min_array[row]
            case picker_alert.picker_23:
                str = time_am_array[row]
                
            default:
                str = ""
            }
        }
        else if alert_index == 3
        {
           pickerLabel?.font = UIFont.systemFont(ofSize: 15)
            str = duration_array[row]
        }
        else
        {
            pickerLabel?.font = UIFont.systemFont(ofSize: 15)
            str = filterd_charity_array[row].name
        }
        
        
        pickerLabel?.text = str
        pickerLabel?.textColor = UIColor.darkGray
        
        return pickerLabel!
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if alert_index == 2
        {
            switch(pickerView)
            {
            case picker_alert.picker_11:
                chat_time_array[0] = time_hour_array[row]
            case picker_alert.picker_12:
                chat_time_array[1] = time_min_array[row]
            case picker_alert.picker_13:
                chat_time_array[2] = time_am_array[row]
            case picker_alert.picker_21:
                chat_time_array[3] = time_hour_array[row]
            case picker_alert.picker_22:
                chat_time_array[4] = time_min_array[row]
            case picker_alert.picker_23:
                chat_time_array[5] = time_am_array[row]
            
                
            default:
                return
            }
        }
        else if alert_index == 3
        {
            duration = duration_array[row]
        }
        else
        {
            charity_name = filterd_charity_array[row].name
            charity_id = filterd_charity_array[row].id
        }
        
    }
    
    @objc func timePickerDone(_ sender: UIButton) {
        
        self.picker_alert.removeFromSuperview()
        self.scroll.isHidden = false
        
        
        
        chat_start_time_label.attributedText = CommonFuncs().attributeString([UIFont.boldSystemFont(ofSize: 15), UIFont.boldSystemFont(ofSize: 15),UIFont.boldSystemFont(ofSize: 15), UIFont.boldSystemFont(ofSize: 12)], [UIColor.darkGray, Utility.color(withHexString: ShareData.btn_color), UIColor.darkGray, UIColor.darkGray],[chat_time_array[0], "  :  ", chat_time_array[1], "  \(chat_time_array[2])"])
        
        chat_end_time_label.attributedText = CommonFuncs().attributeString([UIFont.boldSystemFont(ofSize: 15), UIFont.boldSystemFont(ofSize: 15),UIFont.boldSystemFont(ofSize: 15), UIFont.boldSystemFont(ofSize: 12)], [UIColor.darkGray, Utility.color(withHexString: ShareData.btn_color), UIColor.darkGray, UIColor.darkGray],[chat_time_array[3], "  :  ", chat_time_array[4], "  \(chat_time_array[5])"])
        
    }
    
}

    
extension MoreInfluencerAuctionNewVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func ImageFromGallary()
    {
        let picker = UIImagePickerController.init()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        picker.navigationBar.tintColor = UIColor.white
        picker.navigationBar.barTintColor = UIColor.gray
        present(picker, animated: true, completion: nil)
    }
    
    
    func ImageFromCamera()
    {
        let picker = UIImagePickerController.init()
        picker.delegate = self
        
        picker.allowsEditing = false
        picker.sourceType = .camera
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)!
        picker.navigationBar.tintColor = UIColor.white
        picker.navigationBar.barTintColor = UIColor.gray
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let img = CommonFuncs().resizeImage(image: chosenImage, targetSize: CGSize(width: 300.0, height: 300.0))
        new_charity_alert.photo_btn.setImage(img, for: .normal)
        new_charity_alert.photo_btn.layer.cornerRadius = new_charity_alert.photo_btn.frame.width / 2
        new_charity_alert.photo_btn.clipsToBounds = true
        new_charity_alert.photo_btn.layer.borderWidth = 1
        new_charity_alert.photo_btn.layer.borderColor = Utility.color(withHexString: ShareData.btn_color).cgColor
        
        ShareData.profile_photo = UIImagePNGRepresentation(img)  as! NSData
        dismiss(animated:true, completion: nil)
        
        self.new_charity_alert.isHidden = false
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        dismiss(animated: true, completion: nil)
    }
    
}


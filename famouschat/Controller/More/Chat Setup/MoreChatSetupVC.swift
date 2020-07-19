//
//  MoreChatSetupVC.swift
//  famouschat
//
//  Created by angel oni on 2019/3/29.
//  Copyright © 2019 Oni Angel. All rights reserved.
//

import UIKit
import Alamofire
import NVActivityIndicatorView
import ObjectMapper

class MoreChatSetupVC: UIViewController, NVActivityIndicatorViewable {

    
    @IBOutlet weak var header_frame: UIView!
    @IBOutlet weak var back_img: UIImageView!
    @IBOutlet weak var back_btn: UIButton!
    @IBOutlet weak var menu_img: UIImageView!
    @IBOutlet weak var menu_btn: UIButton!
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var week_collection: UICollectionView!
    
    @IBOutlet weak var time_frame: UIView!
    @IBOutlet weak var start_time_label: UILabel!
    @IBOutlet weak var end_time_label: UILabel!
    @IBOutlet weak var rate_frame: UIView!
    @IBOutlet weak var rate_time_label: UILabel!
    @IBOutlet weak var rate_fee_label: UILabel!
    @IBOutlet weak var time_zone_frame: UIView!
    @IBOutlet weak var time_zone_sel_btn: UIButton!
    @IBOutlet weak var time_zone_sel_btn1: UIButton!
    @IBOutlet weak var publish_btn: UIButton!
    
    let week_array = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    let time_am_array = ["AM", "PM"]
    let time_hour_array = ["00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
    let time_min_array = ["00", "15", "30", "45"]
    let fee_time_hour_array = ["00", "01", "02","03", "04", "05"]
    let fee_time_min_array = ["05", "10", "15", "20", "30", "45"]
    let fee_money_dollar_array = ["01", "02", "05" ,"10", "15", "20", "30", "50", "100"]
    let fee_money_cent_array = ["00", "20", "50"]
    
    var picker_alert: SixPickerAlert!
    var picker_status = ""
    var time_zone_alert: OnePickerAlert!
    
    
    var time_zone_val = "0"
    
    var week_day_val = [String]()
    var selected_week_day_index = 0
    var chat_time_val = [String]()
    var chat_rate_val = [String]()
    var chat_time_val_array = [String]()
    var chat_rate_val_array = [String]()
    var am_str1 = "AM"
    var am_str2 = "PM"
    
    
    let progressDlg = ShareData.progressDlgs[ShareData.progress_index]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        week_day_val = CommonFuncs().splitString(ShareData.user_info.work_day!)
        chat_time_val_array = ShareData.user_info.chat_time!.characters.split(separator: ",").map(String.init)
        chat_rate_val_array = ShareData.user_info.chat_rate!.characters.split(separator: ",").map(String.init)
        
        time_zone_val = ShareData.user_info.time_zone!
            
        init_UI()
    }

    func init_UI()
    {
        self.navigationController?.isNavigationBarHidden = true
        
        header_frame.dropShadow(color: .gray, opacity: 0.5, offSet: CGSize.zero, radius: 8, scale: true)
        
        let back_image = UIImage.init(named: "back")!.withRenderingMode(.alwaysTemplate)
        back_img.image = back_image
        back_img.tintColor = Utility.color(withHexString: "10A7BA")
        
    //    let menu_image = UIImage.init(named: "menu_1")!.withRenderingMode(.alwaysTemplate)
    //    menu_img.image = menu_image
    //    menu_img.tintColor = Utility.color(withHexString: ShareData.btn_color)
        
    //    menu_btn.addTarget(self.slideMenuController, action: #selector(slideMenuController.toggleMenuAnimated(_:)), for: .touchUpInside)
        back_btn.addTarget(self, action: #selector(self.backAction(_:)), for: .touchUpInside)
        
        week_collection.dataSource = self
        week_collection.delegate = self
        week_collection.register(UINib(nibName: "OneLabelCell", bundle: nil), forCellWithReuseIdentifier: "OneLabelCell")
        
        time_frame.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        time_frame.clipsToBounds = true
        time_frame.dropShadow(color: .gray, opacity: 0.8, offSet: CGSize.zero, radius: 3, scale: true)
        
        rate_frame.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        rate_frame.clipsToBounds = true
        rate_frame.dropShadow(color: .gray, opacity: 0.8, offSet: CGSize.zero, radius: 3, scale: true)
        
        displayData(index: 0)
        
        time_zone_frame.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        time_zone_frame.clipsToBounds = true
        time_zone_frame.dropShadow(color: .gray, opacity: 0.8, offSet: CGSize.zero, radius: 3, scale: true)
        let image = UIImage(named: "listBox")?.withRenderingMode(.alwaysTemplate)
        time_zone_sel_btn.setImage(image, for: .normal)
        time_zone_sel_btn.tintColor = Utility.color(withHexString: ShareData.btn_color)
        time_zone_sel_btn1.setTitle("Eastern Time Zone(EST \(ShareData.time_zones[Int(time_zone_val)!]))", for: .normal)
        
        publish_btn.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        publish_btn.clipsToBounds = true
        publish_btn.dropShadow(color: .gray, opacity: 0.8, offSet: CGSize.zero, radius: 5, scale: true)
        
    }
    
    
    @IBAction func timeAction(_ sender: Any) {
        
        picker_status = "time"
        self.picker_alert = SixPickerAlert.instanceFromNib("Time") as! SixPickerAlert
        
        self.scrollView.isHidden = true
        
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
        
        let index11 = time_hour_array.index(where: { $0 == CommonFuncs().time24To12(chat_time_val[0])[0] })
        self.picker_alert.picker_11.selectRow(index11!, inComponent: 0, animated: true)
        let index12 = time_min_array.index(where: { $0 == chat_time_val[1] })
        self.picker_alert.picker_12.selectRow(index12!, inComponent: 0, animated: true)
        let index13 = time_am_array.index(where: { $0 == am_str1 })
        self.picker_alert.picker_13.selectRow(index13!, inComponent: 0, animated: true)
        let index21 = time_hour_array.index(where: { $0 == CommonFuncs().time24To12(chat_time_val[2])[0] })
        self.picker_alert.picker_21.selectRow(index21!, inComponent: 0, animated: true)
        let index22 = time_min_array.index(where: { $0 == chat_time_val[3] })
        self.picker_alert.picker_22.selectRow(index22!, inComponent: 0, animated: true)
        let index23 = time_am_array.index(where: { $0 == am_str2 })
        self.picker_alert.picker_23.selectRow(index23!, inComponent: 0, animated: true)
        
        picker_alert.apply_btn.addTarget(self, action: #selector(self.pickerDone(_:)), for: .touchUpInside)
    }
    
    @IBAction func rateAction(_ sender: Any) {
        
        picker_status = "rate"
        self.picker_alert = SixPickerAlert.instanceFromNib("Rate") as! SixPickerAlert
        
        self.scrollView.isHidden = true
        
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
        
        let index11 = fee_time_hour_array.index(where: { $0 == chat_rate_val[0] })
        self.picker_alert.picker_11.selectRow(index11!, inComponent: 0, animated: true)
        let index12 = fee_time_min_array.index(where: { $0 == chat_rate_val[1] })
        self.picker_alert.picker_12.selectRow(index12!, inComponent: 0, animated: true)
        let index21 = fee_money_dollar_array.index(where: { $0 == chat_rate_val[2] })
        self.picker_alert.picker_21.selectRow(index21!, inComponent: 0, animated: true)
        let index22 = fee_money_cent_array.index(where: { $0 == chat_rate_val[3] })
        self.picker_alert.picker_22.selectRow(index22!, inComponent: 0, animated: true)
        
        picker_alert.apply_btn.addTarget(self, action: #selector(self.pickerDone(_:)), for: .touchUpInside)
    }
    
    @IBAction func timeZoneSelect(_ sender: Any) {
        
        picker_status = "time_zone"
        self.time_zone_alert = OnePickerAlert.instanceFromNib(title: "Time Zone") as! OnePickerAlert
        
        self.scrollView.isHidden = true
        self.time_zone_alert.picker.delegate = self
        self.time_zone_alert.picker.dataSource = self
        
        self.time_zone_alert.picker.selectRow(Int(time_zone_val)!, inComponent: 0, animated: true)
        
        time_zone_alert.apply_btn.addTarget(self, action: #selector(self.zonePickerDone(_:)), for: .touchUpInside)
        
        
    }
    
    @IBAction func publishAction(_ sender: Any) {
        
        self.publish_btn.isUserInteractionEnabled = false
        
        self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: progressDlg, color: .darkGray, fadeInAnimation: nil)
        
        publish_btn.isUserInteractionEnabled = false
        
        for i in 0..<week_day_val.count
        {
            if week_day_val[i] == "2"
            {
                week_day_val[i] = "1"
            }
        }
        
        let week_day_str = CommonFuncs().strArrayTostr(week_day_val, ",")
        let chat_time_str = CommonFuncs().strArrayTostr(chat_time_val_array, ",")
        let chat_rate_str = CommonFuncs().strArrayTostr(chat_rate_val_array, ",")
        
        let parameter = ["user_id": ShareData.user_info.id!, "bio": ShareData.user_info.bio!, "category": ShareData.user_info.category!, "paypal_id": ShareData.user_info.paypal_id!, "venmo_id": ShareData.user_info.venmo_id!, "work_day": week_day_str, "chat_time": chat_time_str, "chat_rate": chat_rate_str, "time_zone": time_zone_val] as! [String: String]
        let url: URL! = URL(string: "\(ShareData.main_url)profile/influencer.php")!
        
        Alamofire.upload(multipartFormData: { (multiPartFormData: MultipartFormData) in
            for (key, value) in parameter as! [String: String] {
                multiPartFormData.append((value as String).data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, withName: key)
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
                            if let temp = Mapper<UserMDL>().map(JSONObject: data["profile"])
                            {
                                ShareData.user_info = temp
                            }
                        }
                        
                        self.stopAnimating(nil)
                        self.publish_btn.isUserInteractionEnabled = true
                        CommonFuncs().doneAlert(ShareData.appTitle, message, "CLOSE", {})
                    }
                    
                })
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    
    @objc func backAction(_ sender: UIButton) {
        
        if picker_alert != nil
        {
            picker_alert.removeFromSuperview()
        }
        
        ShareData.main_or_more_status = true
        UIApplication.shared.keyWindow?.setRootViewController(MainTabVC(), options: UIWindow.TransitionOptions(direction: .toLeft, style: .easeIn), slide_direction: .fromLeftToRight)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        week_collection.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if self.picker_alert != nil
        {
            self.picker_alert.removeFromSuperview()
        }
        
    }


}

extension MoreChatSetupVC
{
    func displayData(index: Int)
    {
        chat_time_val = CommonFuncs().splitString(ShareData.user_info.chat_time!.characters.split(separator: ",").map(String.init)[index])
        chat_rate_val = CommonFuncs().splitString(ShareData.user_info.chat_rate!.characters.split(separator: ",").map(String.init)[index])
        
        start_time_label.attributedText = CommonFuncs().attributeString([UIFont.boldSystemFont(ofSize: 15), UIFont.boldSystemFont(ofSize: 15),UIFont.boldSystemFont(ofSize: 15), UIFont.boldSystemFont(ofSize: 12)], [UIColor.darkGray, Utility.color(withHexString: ShareData.btn_color), UIColor.darkGray, UIColor.darkGray], [CommonFuncs().time24To12(chat_time_val[0])[0], "  :  ", "\(chat_time_val[1]) ", CommonFuncs().time24To12(chat_time_val[0])[1]])
        
        end_time_label.attributedText = CommonFuncs().attributeString([UIFont.boldSystemFont(ofSize: 15), UIFont.boldSystemFont(ofSize: 15),UIFont.boldSystemFont(ofSize: 15), UIFont.boldSystemFont(ofSize: 12)], [UIColor.darkGray, Utility.color(withHexString: ShareData.btn_color), UIColor.darkGray, UIColor.darkGray], [CommonFuncs().time24To12(chat_time_val[2])[0], "  :  ", "\(chat_time_val[3]) ", CommonFuncs().time24To12(chat_time_val[2])[1]])
        
        rate_time_label.attributedText = CommonFuncs().attributeString([UIFont.boldSystemFont(ofSize: 15), UIFont.boldSystemFont(ofSize: 15),UIFont.boldSystemFont(ofSize: 15), UIFont.boldSystemFont(ofSize: 12)], [UIColor.darkGray, Utility.color(withHexString: ShareData.btn_color), UIColor.darkGray, UIColor.darkGray], [chat_rate_val[0], "  :  ", chat_rate_val[1], "  min"])
        rate_fee_label.attributedText = CommonFuncs().attributeString([UIFont.boldSystemFont(ofSize: 12), UIFont.boldSystemFont(ofSize: 15), UIFont.boldSystemFont(ofSize: 15),UIFont.boldSystemFont(ofSize: 15)], [UIColor.darkGray, UIColor.darkGray, Utility.color(withHexString: ShareData.btn_color), UIColor.darkGray], ["$  ", chat_rate_val[2], " . ", chat_rate_val[3]])
    }
    
    @objc func zonePickerDone(_ sender: UIButton) {
        
        time_zone_sel_btn1.setTitle("Eastern Time Zone(EST \(ShareData.time_zones[Int(time_zone_val)!]))", for: .normal)
        
        self.time_zone_alert.removeFromSuperview()
        self.scrollView.isHidden = false
    }
    
}
extension MoreChatSetupVC: UIPickerViewDelegate, UIPickerViewDataSource
{
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        
        if picker_status == "time"
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
        else if picker_status == "time_zone"
        {
            return ShareData.time_zones.count
        }
        else
        {
            switch(pickerView)
            {
            case picker_alert.picker_11:
                return fee_time_hour_array.count
            case picker_alert.picker_12:
                return fee_time_min_array.count
            case picker_alert.picker_13:
                return 1
            case picker_alert.picker_21:
                return 1
            case picker_alert.picker_22:
                return fee_money_dollar_array.count
            case picker_alert.picker_23:
                return fee_money_cent_array.count
                
            default:
                return 0
            }
        }
        
    }
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont.systemFont(ofSize: 13)
            pickerLabel?.textAlignment = .center
        }
        
        var str = ""
        if picker_status == "time"
        {
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
        else if picker_status == "time_zone"
        {
            str = "Eastern Time Zone(EST \(ShareData.time_zones[row]))"
            pickerLabel?.font = UIFont.systemFont(ofSize: 15)
        }
        else
        {
            switch(pickerView)
            {
            case picker_alert.picker_11:
                str = fee_time_hour_array[row]
            case picker_alert.picker_12:
                str = fee_time_min_array[row]
            case picker_alert.picker_13:
                str = "min"
            case picker_alert.picker_21:
                str = "$"
            case picker_alert.picker_22:
                str = fee_money_dollar_array[row]
            case picker_alert.picker_23:
                str = fee_money_cent_array[row]
                
            default:
                str = ""
            }
        }
        
        pickerLabel?.text = str
        pickerLabel?.textColor = UIColor.darkGray
        
        return pickerLabel!
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        
        if picker_status == "time"
        {
            switch(pickerView)
            {
            case picker_alert.picker_11:
                chat_time_val[0] = CommonFuncs().time12To24(time_hour_array[row], am_str1)
            case picker_alert.picker_12:
                chat_time_val[1] = time_min_array[row]
            case picker_alert.picker_13:
                am_str1 = time_am_array[row]
            case picker_alert.picker_21:
                chat_time_val[2] = CommonFuncs().time12To24(time_hour_array[row], am_str2)
            case picker_alert.picker_22:
                chat_time_val[3] = time_min_array[row]
            case picker_alert.picker_23:
                am_str2 = time_am_array[row]
                
            default:
                return
            }
        }
        else if picker_status == "time_zone"
        {
            time_zone_val = "\(row)"
        }
        else
        {
            switch(pickerView)
            {
            case picker_alert.picker_11:
                chat_rate_val[0] = fee_time_hour_array[row]
            case picker_alert.picker_12:
                chat_rate_val[1] = fee_time_min_array[row]
            case picker_alert.picker_22:
                chat_rate_val[2] = fee_money_dollar_array[row]
            case picker_alert.picker_23:
                chat_rate_val[3] = fee_money_cent_array[row]
                
            default:
                return
            }
        }
    }
    
    
    
    @objc func pickerDone(_ sender: UIButton) {
        
        if picker_status == "time"
        {
            if chat_time_val[0] < chat_time_val[2]
            {
                start_time_label.attributedText = CommonFuncs().attributeString([UIFont.boldSystemFont(ofSize: 15), UIFont.boldSystemFont(ofSize: 15),UIFont.boldSystemFont(ofSize: 15), UIFont.boldSystemFont(ofSize: 12)], [UIColor.darkGray, Utility.color(withHexString: ShareData.btn_color), UIColor.darkGray, UIColor.darkGray], [CommonFuncs().time24To12(chat_time_val[0])[0], "  :  ", "\(chat_time_val[1]) ", CommonFuncs().time24To12(chat_time_val[0])[1]])
                
                end_time_label.attributedText = CommonFuncs().attributeString([UIFont.boldSystemFont(ofSize: 15), UIFont.boldSystemFont(ofSize: 15),UIFont.boldSystemFont(ofSize: 15), UIFont.boldSystemFont(ofSize: 12)], [UIColor.darkGray, Utility.color(withHexString: ShareData.btn_color), UIColor.darkGray, UIColor.darkGray], [CommonFuncs().time24To12(chat_time_val[2])[0], "  :  ", "\(chat_time_val[3]) ", CommonFuncs().time24To12(chat_time_val[2])[1]])
                
                let chat_time_str = CommonFuncs().strArrayTostr(chat_time_val, "-")
                
                chat_time_val_array[selected_week_day_index] = chat_time_str
                
                self.picker_alert.removeFromSuperview()
                self.scrollView.isHidden = false
            }
            else
            {
                CommonFuncs().doneAlert(ShareData.appTitle, "Please confirm chat time", "CLOSE", {})
            }
            
        }
        else
        {
            rate_time_label.attributedText = CommonFuncs().attributeString([UIFont.boldSystemFont(ofSize: 15), UIFont.boldSystemFont(ofSize: 15),UIFont.boldSystemFont(ofSize: 15), UIFont.boldSystemFont(ofSize: 12)], [UIColor.darkGray, Utility.color(withHexString: ShareData.btn_color), UIColor.darkGray, UIColor.darkGray], [chat_rate_val[0], "  :  ", chat_rate_val[1], "  min"])
            rate_fee_label.attributedText = CommonFuncs().attributeString([UIFont.boldSystemFont(ofSize: 12), UIFont.boldSystemFont(ofSize: 15), UIFont.boldSystemFont(ofSize: 15),UIFont.boldSystemFont(ofSize: 15)], [UIColor.darkGray, UIColor.darkGray, Utility.color(withHexString: ShareData.btn_color), UIColor.darkGray], ["$  ", chat_rate_val[2], "  :  ", chat_rate_val[3]])
            
            let chat_rate_str = CommonFuncs().strArrayTostr(chat_rate_val, "-")
            
            chat_rate_val_array[selected_week_day_index] = chat_rate_str
            
            self.picker_alert.removeFromSuperview()
            self.scrollView.isHidden = false
        }
        
    }
}


extension MoreChatSetupVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return week_array.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        if (collectionView.frame.height * 7 + 60) < collectionView.frame.width - 10
        {
            return (collectionView.frame.width - 10 - collectionView.frame.height * 7) / 6
        }
        else
        {
            return 10
        }
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var width: CGFloat = 0
        var height: CGFloat = 0
        
        if (collectionView.frame.height * 7 + 60) < collectionView.frame.width - 10
        {
            height = collectionView.frame.height - 5
            width = height
        }
        else
        {
            width = (collectionView.frame.width - 70) / 7
            height = width
        }
        
        return CGSize(width: width, height: height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OneLabelCell", for: indexPath) as! OneLabelCell
        
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = cell.frame.width / 2
        cell.clipsToBounds = true
        cell.dropShadow(color: .gray, opacity: 0.5, offSet: CGSize.zero, radius: 3, scale: true)
        
        cell.name.text = week_array[indexPath.row]
        cell.name.textColor = UIColor.darkGray
        if week_day_val[indexPath.row] == "0"
        {
            cell.backgroundColor = UIColor.white
            cell.layer.borderColor = UIColor.clear.cgColor
            cell.layer.borderWidth = 0
            
        }
        else
        {
            cell.backgroundColor = Utility.color(withHexString: ShareData.star_non_color)
            
            if week_day_val[indexPath.row] == "2"
            {
                cell.layer.borderColor = UIColor.red.cgColor
                cell.layer.borderWidth = 1
            }
            else
            {
                cell.layer.borderColor = UIColor.clear.cgColor
                cell.layer.borderWidth = 0
            }
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        if week_day_val[indexPath.row] == "2"
        {
            week_day_val[indexPath.row] = "0"
            
        }
        else
        {
            for i in 0..<week_day_val.count
            {
                if week_day_val[i] == "2"
                {
                    week_day_val[i] = "1"
                }
            }
            week_day_val[indexPath.row] = "2"
        }
        
        selected_week_day_index = indexPath.row
        displayData(index: selected_week_day_index)
        
        self.week_collection.reloadData()
    }
    
}

//
//  RegisterVC.swift
//  famouschat
//
//  Created by T-Tech Solutions LLC on 04/11/2018.
//  Copyright © 2018 T-Tech Solutions LLC. All rights reserved.
//

import UIKit
import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import NVActivityIndicatorView
import ObjectMapper

class RegisterVC: UIViewController, NVActivityIndicatorViewable {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var name_in: UITextField!
    @IBOutlet weak var name_img: UIImageView!
    @IBOutlet weak var email_img: UIImageView!
    @IBOutlet weak var email_in: UITextField!
    @IBOutlet weak var pwd_in: UITextField!
    @IBOutlet weak var pwd_img: UIImageView!
    @IBOutlet weak var pwd_Rin: UITextField!
    @IBOutlet weak var pwdR_img: UIImageView!
    @IBOutlet weak var continue_btn: UIButton!
    
    
    let progressDlg = ShareData.progressDlgs[ShareData.progress_index]
    
    var verify_status = false
    var email = ""
    var verify_in: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        init_UI()
    }
    
    func init_UI()
    {
        self.navigationController?.isNavigationBarHidden = true
        
        let image = UIImage(named: "return")?.withRenderingMode(.alwaysTemplate)
        backBtn.setImage(image, for: .normal)
        backBtn.tintColor = Utility.color(withHexString: "10A7BA")
        
        
        let image1 = UIImage.init(named: "account_profile")?.withRenderingMode(.alwaysTemplate)
        name_img.image = image1
        name_img.tintColor = UIColor.white
        
        let image2 = UIImage.init(named: "account_mail")?.withRenderingMode(.alwaysTemplate)
        email_img.image = image2
        email_img.tintColor = UIColor.white
        
        let image3 = UIImage.init(named: "account_password")?.withRenderingMode(.alwaysTemplate)
        pwd_img.image = image3
        pwd_img.tintColor = UIColor.white
        
        pwdR_img.image = image3
        pwdR_img.tintColor = UIColor.white
        
        name_in.delegate = self
        email_in.delegate = self
        pwd_in.delegate = self
        pwd_Rin.delegate = self
        
        name_in.colorPlaceHolder("Full name", UIColor.white)
        email_in.colorPlaceHolder("Email address", UIColor.white)
        pwd_in.colorPlaceHolder("Password", UIColor.white)
        pwd_Rin.colorPlaceHolder("Confirm password", UIColor.white)
        
        continue_btn.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        continue_btn.clipsToBounds = true
        continue_btn.dropShadow(color: .white, opacity: 0.8, offSet: CGSize.zero, radius: 3, scale: true)
        
    }
    
    
    
    @objc func backAction(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextAction(_ sender: Any) {
        
        if name_in.text! == "" || email_in.text! == "" || pwd_in.text! == "" || pwd_Rin.text == ""
        {
            CommonFuncs().doneAlert(ShareData.appTitle, "Please fill all fields", "CLOSE", {})
        }
        else if !Utility.validateEmail(with: email_in.text!)
        {
            CommonFuncs().doneAlert(ShareData.appTitle, "Error: invalid email", "CLOSE", {})
        }
        else if pwd_in.text!.count < 6
        {
            CommonFuncs().doneAlert(ShareData.appTitle, "Password length must be at least 6 digits", "CLOSE", {})
        }
        else if pwd_in.text! != pwd_Rin.text!
        {
            CommonFuncs().doneAlert(ShareData.appTitle, "Please confirm password", "CLOSE", {})
        }
        else
        {
            self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: self.progressDlg, color: .white, fadeInAnimation: nil)
            
            let token = Messaging.messaging().fcmToken
            
            var time_zone_val = (TimeZone.current.secondsFromGMT() / 3600) + 4
            
            if time_zone_val > 12
            {
                time_zone_val = time_zone_val - 24
            }
            
            let time_zone = "\(ShareData.time_zones.index { Int($0)! == time_zone_val }!)"
            
            let parmeters = ["name": self.name_in.text!, "email": self.email_in.text!, "password": self.pwd_in.text!, "token": token, "time_zone": time_zone] as [String: Any]
            
            CommonFuncs().createRequest(true, "signup", "POST", parmeters, completionHandler: {data in
                
                let status = data["status"] as! Bool
                let message = data["message"] as! String
                
                
                DispatchQueue.main.async {
                    
                    self.stopAnimating(nil)
                    
                    if status
                    {
                        
                        self.email = self.email_in.text!
                        self.verify_status = true
                        self.verify_in = CommonFuncs().inputAlert(ShareData.appTitle, "Please check your email", "Verify code...", 2, ["VERIFY", "CANCEL"], [Utility.color(withHexString: "10A7BA"), UIColor.gray], [UIColor.white, UIColor.white], self, [#selector(self.verify(_:)), #selector(self.verifyCancel(_:))])
                        self.verify_in.delegate = self
                        
                    }
                    else
                    {
                        CommonFuncs().doneAlert(ShareData.appTitle, message, "CLOSE", {})
                    }
                }
            })
            
        }
        
    }
}

extension RegisterVC: UITextFieldDelegate
{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        name_in.resignFirstResponder()
        email_in.resignFirstResponder()
        pwd_in.resignFirstResponder()
        pwd_Rin.resignFirstResponder()
        
        if verify_status
        {
            verify_in.resignFirstResponder()
        }
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        
        return (true)
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        switch textField {
            
        case pwd_in:
            
            scrollView.setContentOffset(CGPoint(x: 0, y: 100), animated: true)
            
        case pwd_Rin:
            
            scrollView.setContentOffset(CGPoint(x: 0, y: 140), animated: true)
            
        default:
            break
        }
    }
    
}

extension RegisterVC
{
    
    @objc func verify(_ sender: UIButton) {
        
        if verify_in.text! != ""
        {
            self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: progressDlg, color: .white, fadeInAnimation: nil)
            
            let parmeters = ["email": self.email, "verify_code": verify_in.text!] as [String: Any]
            
            CommonFuncs().createRequest(false, "signup/activate", "POST", parmeters, completionHandler: {data in
                
                let status = data["status"] as! Bool
                
                DispatchQueue.main.async {
                    
                    
                    self.stopAnimating(nil)
                    
                    if status
                    {
                        UserDefaults.standard.set(true, forKey: "loginStatus")
                        UserDefaults.standard.set(self.email_in.text!, forKey: "savedEmail")
                        UserDefaults.standard.set(self.pwd_in.text!, forKey: "savedPassword")
                        
                        let profile_data = data["data"] as! [String: Any]
                        
                        if let temp = Mapper<UserMDL>().map(JSONObject: profile_data["profile"])
                        {
                            ShareData.user_info = temp
                        }
                        
                        if let temp = Mapper<ConfigMDL>().map(JSONObject: profile_data["config"])
                        {
                            ShareData.app_config = temp
                        }
                        
                        let account_data = profile_data["profile"] as! [String: Any]
                        
                        if let emaildID = account_data["email"] as? String, let normalId = account_data["id"] as? String, let name = account_data["name"] as? String {
                            self.ConnectWithQuickBloxForVideoCall(emaildID,normalId,name)
                            
                        }
                        
                        if let top_influenrers = profile_data["top_influencers"], let temp = Mapper<UserMDL>().mapArray(JSONObject: top_influenrers)
                        {
                            ShareData.top_influencers = temp
                            
                        }
                        
                        if let charities = profile_data["charity_list"], let temp = Mapper<CharityMDL>().mapArray(JSONObject: charities)
                        {
                            ShareData.charity_list = temp
                        }
                        
                        
                        if let categories = profile_data["category_list"], let temp = Mapper<CategoryMDL>().mapArray(JSONObject: categories)
                        {
                            ShareData.category_list = temp
                        }
                        
                        CommonFuncs().doneAlert(ShareData.appTitle, "You registered successfully on \(ShareData.appTitle)", "DONE", {
                            self.navigationController?.pushViewController(StartWelcomeVC(), animated: true)})
                        
                    }
                    else
                    {
                        self.verify_status = false
                        CommonFuncs().doneAlert(ShareData.appTitle, "Verify code is wrong", "CLOSE", {})
                        
                    }
                }
            })
        }
    }
    
    @objc func verifyCancel(_ sender: UIButton) {
        
        
        let parmeters = ["email": self.email, "verify_code": "xxxxx"] as [String: Any]
        
        CommonFuncs().createRequest(false, "signup/activate", "POST", parmeters, completionHandler: {data in
            
            let status = data["status"] as! Bool
            
            DispatchQueue.main.async {
                
            }
        })
        
    }
    
   
    
    func ConnectWithQuickBloxForVideoCall(_ data:String...)
    {
        let login = data[0]
        let externalId = data[1]
        let fullName = data[2]
        
        QuickBloxHelper.loginUserWithEmail(login,userEmail: login , password: "12345678" , loginCompletionBlock: { (isConnected) in
            if isConnected {}
            else {
                self.createUserForQuicKBlox(login,externalId,fullName,"")
            }
        })
    }
    
    func createUserForQuicKBlox(_ data:String...)
    {
        let emailId = data[0]
        let externalId = data[1]
        let name = data[2]
        let deviceToken = data[3]
        
        QuickBloxHelper.createUserWithEmailID(deviceToken,email: emailId, password:"12345678", externalID: externalId, fullName: name) { (isCreated, dictUser) in
            if isCreated
            {
                
                self.ConnectWithQuickBloxForVideoCall(dictUser["login"] as! String,emailId,externalId)
            }
        }
    }
    
}


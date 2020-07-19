//
//  LoginVC.swift
//  famouschat
//
//  Created by T-Tech Solutions LLC on 04/11/2018.
//  Copyright © 2018 T-Tech Solutions LLC. All rights reserved.
//

import UIKit
import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit
import NVActivityIndicatorView
import ObjectMapper
import SCLAlertView

class LoginVC: UIViewController, NVActivityIndicatorViewable{
    
    
    @IBOutlet weak var email_frame: UIView!
    @IBOutlet weak var pwd_frame: UIView!
    @IBOutlet weak var email_in: UITextField!
    @IBOutlet weak var pwd_in: UITextField!
    @IBOutlet weak var continue_btn: UIButton!
    @IBOutlet weak var create_btn: UIButton!
    @IBOutlet weak var google_btn: UIButton!
    @IBOutlet weak var fb_btn: UIButton!
    @IBOutlet weak var scroll: UIScrollView!
    
    let fbLoginManager : LoginManager = LoginManager()
    var social_status =  false
    
    let progressDlg = ShareData.progressDlgs[ShareData.progress_index]
    var forget_email_in: UITextField!
    var new_pwd_in: UITextField!
    var forget_status = "0"
    var verify_code = ""
    var forget_email = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        init_UI()
    }
    
    func init_UI()
    {
        
        self.navigationController?.isNavigationBarHidden = true
        
        email_in.delegate = self
        pwd_in.delegate = self
        
        continue_btn.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        continue_btn.clipsToBounds = true
        continue_btn.dropShadow(color: .darkGray, opacity: 0.8, offSet: CGSize.zero, radius: 3, scale: true)
        
        if UserDefaults.standard.object(forKey: "savedEmail") != nil
        {
            email_in.text = UserDefaults.standard.string(forKey: "savedEmail")
            pwd_in.text = UserDefaults.standard.string(forKey: "savedPassword")
        }
        else
        {
            email_in.colorPlaceHolder("Username or Email", UIColor.white)
            pwd_in.colorPlaceHolder("Password", UIColor.white)
        }
        
        GIDSignIn.sharedInstance()?.presentingViewController = self

        // Automatically sign in the user.
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        
        GIDSignIn.sharedInstance().delegate = self
//        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signOut()
        
        
//        email_in.text = "onikyong1019@gmail.com"
//        pwd_in.text = "oni"
        email_in.text = "Email"
        pwd_in.text = ""
        
        
        
    }
    
    @IBAction func continueAction(_ sender: Any) {
        
        self.social_status = false
        self.loginAction(name: "", email: self.email_in.text!, password: self.pwd_in.text!)
        
    }
    
    @IBAction func helpLoginAction(_ sender: Any) {
        
        self.forget_email_in = CommonFuncs().inputAlert(ShareData.appTitle, "Please input your account email address", "Email Address...", 2, ["OK", "CANCEL"], [Utility.color(withHexString: ShareData.btn_color), UIColor.gray], [UIColor.white, UIColor.white], self, [#selector(self.forgetOk(_:)), #selector(self.forgetCancel(_:))])
        forget_status = "1"
        self.forget_email_in.delegate = self
        
    }
    
    
    @IBAction func createAction(_ sender: Any) {
        
        self.navigationController?.pushViewController(RegisterVC(), animated: true)
    }
    
    
    @IBAction func googleAction(_ sender: Any) {
        
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func facebookAction(_ sender: Any) {
        
        fbLoginManager.logIn(permissions: ["email"], from: self) { (result, error) -> Void in
            if (error == nil){
                let fbloginresult : LoginManagerLoginResult = result!
                if (result?.isCancelled)!{
                    return
                }
                if(fbloginresult.grantedPermissions.contains("email"))
                {
                    self.facebookSignIn()
                }
            }
        }
    }
    
}


extension LoginVC: UITextFieldDelegate
{

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        email_in.resignFirstResponder()
        pwd_in.resignFirstResponder()
        
        if textField == pwd_in
        {
            self.social_status = false
            self.loginAction(name: "", email: self.email_in.text!, password: self.pwd_in.text!)
        }
        
        if forget_status == "1"
        {
            forget_email_in.resignFirstResponder()
        }
        else if forget_status == "2"
        {
            new_pwd_in.resignFirstResponder()
            new_pwd_in.resignFirstResponder()
        }
        
        return (true)
    }
    
}


extension LoginVC: GIDSignInDelegate//,GIDSignInUIDelegate
{
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        }
        else
        {
            print("Login successfully.")
            googleSign(user: user)
        }
    }
    
}



extension LoginVC
{
    
    @objc func forgetOk(_ sender: UIButton) {
        
        self.forget_email = self.forget_email_in.text!
        
        let parmeters = ["email": self.forget_email, "status": "1"] as! [String: Any]
        self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: progressDlg, color: .white, fadeInAnimation: nil)
        
        CommonFuncs().createRequest(false, "login/forget", "POST", parmeters, completionHandler: {data in
            
            let status = data["status"] as! Bool
            let message = data["message"] as! String
            
            DispatchQueue.main.async {
                
                self.stopAnimating(nil)
                
                if status
                {
                    self.verify_code = data["data"] as! String
                    
                    self.forget_email_in = CommonFuncs().inputAlert(ShareData.appTitle, message, "Verify Code...", 2, ["VERIFY", "CANCEL"], [Utility.color(withHexString: ShareData.btn_color), UIColor.gray], [UIColor.white, UIColor.white], self, [#selector(self.verifyOk(_:)), #selector(self.verifyCancel(_:))])
                    
                }
                else
                {
                    CommonFuncs().doneAlert(ShareData.appTitle, message, "CLOSE", {})
                }
            }
        })
    }
    
    @objc func forgetCancel(_ sender: UIButton) {
        
        self.forget_status = "0"
        let parmeters = ["email": self.forget_email, "status": "3"] as! [String: Any]
        CommonFuncs().createRequest(false, "login/forget", "POST", parmeters, completionHandler: {_ in })
        return
    }
    
    @objc func verifyOk(_ sender: UIButton) {
        
        if self.verify_code == self.forget_email_in.text!
        {
            let appearance = SCLAlertView.SCLAppearance(
                
                kDefaultShadowOpacity: 0.6,
                kCircleIconHeight: 60,
                showCloseButton: false,
                showCircularIcon: true
                
            )
            
            let alertView = SCLAlertView(appearance: appearance)
            let alertViewIcon = UIImage(named: "mark1")
            self.forget_email_in = alertView.addTextField("New Password")
            self.new_pwd_in = alertView.addTextField("Confirm Password")
            
            alertView.addButton("CONFIRM", backgroundColor: Utility.color(withHexString: ShareData.btn_color), textColor: UIColor.white, target: self, selector: #selector(self.newPwdOK(_:)))
            alertView.addButton("CANCEL", backgroundColor: UIColor.gray, textColor: UIColor.white, target: self, selector: #selector(self.newPwdCancel(_:)))
            
            alertView.showInfo(ShareData.appTitle, subTitle: "Please input new password", circleIconImage: alertViewIcon)
            self.forget_status = "2"
        }
        else
        {
            CommonFuncs().doneAlert(ShareData.appTitle, "Verify code is wrong", "CLOSE", {
                let parmeters = ["email": self.forget_email, "status": "3"] as! [String: Any]
                CommonFuncs().createRequest(false, "login/forget", "POST", parmeters, completionHandler: {_ in })
            })
            
        }
    }
    
    @objc func verifyCancel(_ sender: UIButton) {
        
        self.forget_status = "0"
        let parmeters = ["email": self.forget_email, "status": "3"] as! [String: Any]
        CommonFuncs().createRequest(false, "login/forget", "POST", parmeters, completionHandler: {_ in })
        return
    }
    
    @objc func newPwdOK(_ sender: UIButton) {
        
        self.forget_status = "0"
        let token = Messaging.messaging().fcmToken
        let parmeters = ["email": self.forget_email, "password": self.new_pwd_in.text!, "token": token, "status": "2"] as! [String: Any]
        self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: progressDlg, color: .white, fadeInAnimation: nil)
        
        CommonFuncs().createRequest(false, "login/forget", "POST", parmeters, completionHandler: {data in
            
            let status = data["status"] as! Bool
            let message = data["message"] as! String
            
            DispatchQueue.main.async {
                
                if status
                {
                    UserDefaults.standard.set(true, forKey: "loginStatus")
                    UserDefaults.standard.set(self.forget_email, forKey: "savedEmail")
                    UserDefaults.standard.set(self.new_pwd_in.text!, forKey: "savedPassword")
                    
                    let profile_data = data["data"] as! [String: Any]
                    
                    let account_data = profile_data["profile"] as! [String: Any]
                    
                    if let emaildID = account_data["email"] as? String, let normalId = account_data["id"] as? String, let name = account_data["name"] as? String {
                        self.ConnectWithQuickBloxForVideoCall(emaildID,normalId,name)
                        
                    }
                    
                    if let temp = Mapper<UserMDL>().map(JSONObject: profile_data["profile"])
                    {
                        ShareData.user_info = temp
                    }
                    
                    if let temp = Mapper<ConfigMDL>().map(JSONObject: profile_data["config"])
                    {
                        ShareData.app_config = temp
                    }
                    
                    if let temp = Mapper<RankMDL>().map(JSONObject: profile_data["rank_info"])
                    {
                        ShareData.rank_info = temp
                    }
                    
                    if let following_influencers = profile_data["following_influencers"], let temp = Mapper<UserMDL>().mapArray(JSONObject: following_influencers)
                    {
                        ShareData.following_influencers = temp
                        
                    }
                    
                    if let top_influencers = profile_data["top_influencers"], let temp = Mapper<UserMDL>().mapArray(JSONObject: top_influencers)
                    {
                        ShareData.top_influencers = temp
                        
                    }
                    
                    if let category_matched_influencers = profile_data["category_matched_influencers"], let temp = Mapper<UserMDL>().mapArray(JSONObject: category_matched_influencers)
                    {
                        ShareData.matched_influencers = temp
                        
                    }
                    
                    if let feeds = profile_data["feeds"], let temp = Mapper<FeedMDL>().mapArray(JSONObject: feeds)
                    {
                        ShareData.feeds = temp
                        
                    }
                    
                    if let books = profile_data["books"], let temp = Mapper<BookMDL>().mapArray(JSONObject: books)
                    {
                        ShareData.books = temp
                        
                    }
                    
                    if let messages = profile_data["messages"], let temp = Mapper<MessageMDL>().mapArray(JSONObject: messages)
                    {
                        ShareData.messages = temp.sorted { $0.message.time! > $1.message.time!}
                        
                    }
                    
                    if let charities = profile_data["charity_list"], let temp = Mapper<CharityMDL>().mapArray(JSONObject: charities)
                    {
                        ShareData.charity_list = temp
                    }
                    
                    
                    if let categories = profile_data["category_list"], let temp = Mapper<CategoryMDL>().mapArray(JSONObject: categories)
                    {
                        ShareData.category_list = temp
                    }
                    
                    self.stopAnimating(nil)
                    
                    self.navigationController?.viewControllers.removeAll()
                    
                    if ShareData.user_info.permission! == "0"
                    {
                        ShareData.user_or_influencer = true
                    }
                    else
                    {
                        ShareData.user_or_influencer = false
                    }
                    
                    self.stopAnimating(nil)
                    UIApplication.shared.keyWindow?.setRootViewController(MainTabVC(), options: UIWindow.TransitionOptions(direction: .toRight, style: .easeIn), slide_direction: .fromLeftToRight)
                }
                else
                {
                    self.stopAnimating(nil)
                    CommonFuncs().doneAlert(ShareData.appTitle, message, "CLOSE", {
                        let parmeters = ["email": self.forget_email, "status": "3"] as! [String: Any]
                        CommonFuncs().createRequest(false, "login/forget", "POST", parmeters, completionHandler: {_ in })})
                }
            }
        })
        return
    }
    
    @objc func newPwdCancel(_ sender: UIButton) {
        
        self.forget_status = "0"
        let parmeters = ["email": self.forget_email, "status": "3"] as! [String: Any]
        CommonFuncs().createRequest(false, "login/forget", "POST", parmeters, completionHandler: {_ in })
        return
    }
    
    
    func googleSign(user: GIDGoogleUser!){
        
        let google_userId = user.userID!
        let google_name = user.profile.name!
        let google_email = user.profile.email!
        
        self.social_status = true
        self.loginAction(name: google_name, email: google_email, password: google_userId)
        
    }
    
    func facebookSignIn(){
        
        if((AccessToken.current) != nil){
            GraphRequest(graphPath: "me", parameters: ["fields": "id, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    if let dict:[String:Any] = result as? [String : Any] {
                        
                        let result =  dict as NSDictionary
                        let picURL = ((result.value(forKey: "picture") as! NSDictionary).value(forKey: "data") as! NSDictionary).value(forKey: "url") as! String
                        let fb_password = result.value(forKey: "id") as! String
                        let first_name = result.value(forKey: "first_name") as! String
                        let last_name = result.value(forKey: "last_name") as! String
                        var fb_email = ""
                        
                        if let email = result.value(forKey: "email")
                        {
                            fb_email = email as! String
                        }
                        else
                        {
                            fb_email = "\(first_name)1019@outlook.com"
                        }
                        
                        let name = "\(first_name) \(last_name)"
                        self.social_status = true
                        self.loginAction(name: name, email: fb_email, password: fb_password)
                        
                    }
                    
                }
            })
        }
    }
    
    func loginAction(name: String, email: String, password: String) {
        
        if email == "" || email == nil || password == nil || password == ""
        {
            CommonFuncs().doneAlert(ShareData.appTitle, "Please fill all parameters", "CLOSE", {})
            return
        }
        
        self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: progressDlg, color: .white, fadeInAnimation: nil)
        
        continue_btn.isUserInteractionEnabled = false
        create_btn.isUserInteractionEnabled = false
        google_btn.isUserInteractionEnabled = false
        fb_btn.isUserInteractionEnabled = false
        
        let send_time = CommonFuncs().currentTime()
        
        let token = Messaging.messaging().fcmToken ?? ""
        
        let parmeters = ["email": email, "password": password, "token": token, "time": send_time] as [String: Any]
        
        CommonFuncs().createRequest(true, "login", "POST", parmeters, completionHandler: {data in
            
            let status = data["status"] as! Bool
            
            DispatchQueue.main.async {
                
                if status
                {
                    UserDefaults.standard.set(true, forKey: "loginStatus")
                    UserDefaults.standard.set(email, forKey: "savedEmail")
                    UserDefaults.standard.set(password, forKey: "savedPassword")
                    
                    let profile_data = data["data"] as! [String: Any]
                    
                    let account_data = profile_data["profile"] as! [String: Any]
                    
                    if let emaildID = account_data["email"] as? String, let normalId = account_data["id"] as? String, let name = account_data["name"] as? String {
                        self.ConnectWithQuickBloxForVideoCall(emaildID,normalId,name)
                        
                    }
                    
                    if let temp = Mapper<UserMDL>().map(JSONObject: profile_data["profile"])
                    {
                        ShareData.user_info = temp
                    }
                    
                    if let temp = Mapper<ConfigMDL>().map(JSONObject: profile_data["config"])
                    {
                        ShareData.app_config = temp
                    }
                    
                    if let temp = Mapper<RankMDL>().map(JSONObject: profile_data["rank_info"])
                    {
                        ShareData.rank_info = temp
                    }
                    
                    if let following_influencers = profile_data["following_influencers"], let temp = Mapper<UserMDL>().mapArray(JSONObject: following_influencers)
                    {
                        ShareData.following_influencers = temp
                        
                    }
                    
                    if let top_influencers = profile_data["top_influencers"], let temp = Mapper<UserMDL>().mapArray(JSONObject: top_influencers)
                    {
                        ShareData.top_influencers = temp
                        
                    }
                    
                    if let category_matched_influencers = profile_data["category_matched_influencers"], let temp = Mapper<UserMDL>().mapArray(JSONObject: category_matched_influencers)
                    {
                        ShareData.matched_influencers = temp
                        
                    }
                    
                    if let feeds = profile_data["feeds"], let temp = Mapper<FeedMDL>().mapArray(JSONObject: feeds)
                    {
                        ShareData.feeds = temp
                        
                    }
                    
                    if let books = profile_data["books"], let temp = Mapper<BookMDL>().mapArray(JSONObject: books)
                    {
                        ShareData.books = temp
                        
                    }
                    
                    if let messages = profile_data["messages"], let temp = Mapper<MessageMDL>().mapArray(JSONObject: messages)
                    {
                        ShareData.messages = temp.sorted { $0.message.time! > $1.message.time!}
                        
                    }
                    
                    if let charities = profile_data["charity_list"], let temp = Mapper<CharityMDL>().mapArray(JSONObject: charities)
                    {
                        ShareData.charity_list = temp
                    }
                    
                    
                    if let categories = profile_data["category_list"], let temp = Mapper<CategoryMDL>().mapArray(JSONObject: categories)
                    {
                        ShareData.category_list = temp
                    }
                    
                    self.stopAnimating(nil)
                    
                    self.navigationController?.viewControllers.removeAll()
                    
                    if ShareData.user_info.permission! == "0"
                    {
                        ShareData.user_or_influencer = true
                    }
                    else
                    {
                        ShareData.user_or_influencer = false
                    }
                    
                    UIApplication.shared.keyWindow?.setRootViewController(MainTabVC(), options: UIWindow.TransitionOptions(direction: .toRight, style: .easeIn), slide_direction: .fromLeftToRight)
                    
                }
                else
                {
                    if self.social_status
                    {
                        var time_zone_val = (TimeZone.current.secondsFromGMT() / 3600) + 4
                        if time_zone_val > 12
                        {
                            time_zone_val = time_zone_val - 24
                        }
                        
                        let time_zone = "\(ShareData.time_zones.index { Int($0)! == time_zone_val }!)"
                        
                        let parmeters1 = ["name": name, "email": email, "password": password, "token": token, "time_zone": time_zone] as [String: Any]
                        
                        CommonFuncs().createRequest(false, "signup/google", "POST", parmeters1, completionHandler: {data1 in
                            
                            let status1 = data1["status"] as! Bool
                            
                            DispatchQueue.main.async {
                                
                                
                                if status1
                                {
                                    UserDefaults.standard.set(true, forKey: "loginStatus")
                                    UserDefaults.standard.set(email, forKey: "savedEmail")
                                    UserDefaults.standard.set(password, forKey: "savedPassword")
                                    
                                    let profile_data1 = data1["data"] as! [String: Any]
                                    
                                    let account_data = profile_data1["profile"] as! [String: Any]
                                    
                                    if let emaildID = account_data["email"] as? String, let normalId = account_data["id"] as? String, let name = account_data["name"] as? String {
                                        self.ConnectWithQuickBloxForVideoCall(emaildID,normalId,name)
                                        
                                    }
                                    
                                    if let temp = Mapper<UserMDL>().map(JSONObject: profile_data1["profile"])
                                    {
                                        ShareData.user_info = temp
                                    }
                                    
                                    if let temp = Mapper<ConfigMDL>().map(JSONObject: profile_data1["config"])
                                    {
                                        ShareData.app_config = temp
                                    }
                                    
                                    if let top_influenrers = profile_data1["top_influencers"], let temp = Mapper<UserMDL>().mapArray(JSONObject: top_influenrers)
                                    {
                                        ShareData.top_influencers = temp
                                        
                                    }
                                    
                                    if let charities = profile_data1["charity_list"], let temp = Mapper<CharityMDL>().mapArray(JSONObject: charities)
                                    {
                                        ShareData.charity_list = temp
                                    }
                                    
                                    if let categories = profile_data1["category_list"], let temp = Mapper<CategoryMDL>().mapArray(JSONObject: categories)
                                    {
                                        ShareData.category_list = temp
                                    }
                                    
                                    self.stopAnimating(nil)
                                    CommonFuncs().doneAlert(ShareData.appTitle, "You registered successfully on \(ShareData.appTitle)", "DONE", {self.navigationController?.pushViewController(StartWelcomeVC(), animated: true)})
                                    
                                }
                                else
                                {
                                    self.stopAnimating(nil)
                                    self.continue_btn.isUserInteractionEnabled = true
                                    self.create_btn.isUserInteractionEnabled = true
                                    self.google_btn.isUserInteractionEnabled = true
                                    self.fb_btn.isUserInteractionEnabled = true
                                    CommonFuncs().doneAlert(ShareData.appTitle, "Failed Sign In", "CLOSE", {})
                                    
                                }
                            }
                        })
                    }
                    else
                    {
                        self.stopAnimating(nil)
                        self.continue_btn.isUserInteractionEnabled = true
                        self.create_btn.isUserInteractionEnabled = true
                        self.google_btn.isUserInteractionEnabled = true
                        self.fb_btn.isUserInteractionEnabled = true
                        CommonFuncs().doneAlert(ShareData.appTitle, "Failed login", "CLOSE", {})
                    }
                    
                    
                }
            }
        })
    }
    
    
    func ConnectWithQuickBloxForVideoCall(_ data:String...)
    {
        let login = data[0]
        let externalId = data[1]
        let fullName = data[2]
        
        QuickBloxHelper.loginUserWithEmail(login,userEmail: login , password: "12345678" , loginCompletionBlock: { (isConnected) in
            if isConnected
            {
                print("--------------------------------YOU ARE CONNECTED----------------------------")
            } else {
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


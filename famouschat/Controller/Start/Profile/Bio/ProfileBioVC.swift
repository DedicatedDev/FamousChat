//
//  ProfileBioVC.swift
//  famouschat
//
//  Created by T-Tech Solutions LLC on 05/11/2018.
//  Copyright © 2018 T-Tech Solutions LLC. All rights reserved.
//

import UIKit
import Alamofire
import NVActivityIndicatorView
import ObjectMapper

class ProfileBioVC: UIViewController, NVActivityIndicatorViewable {

    
    @IBOutlet weak var bio_label: UILabel!
    @IBOutlet weak var bio_label_height_constrain: NSLayoutConstraint!
    @IBOutlet weak var bio_frame: UIView!
    @IBOutlet weak var bio_in: UITextView!
    @IBOutlet weak var next_frame: UIView!
    @IBOutlet weak var next_btn: UIButton!
    @IBOutlet weak var prev_frame: UIView!
    @IBOutlet weak var prev_btn: UIButton!
    
    let bio_str = "Next, introduce yourself to people who will be viewing your profile. This is what people will see when they come across your profile"
    
    let progressDlg = ShareData.progressDlgs[ShareData.progress_index]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        init_UI()
    }

    func init_UI()
    {
        
        self.navigationController?.isNavigationBarHidden = true
        
        next_frame.layer.cornerRadius = next_frame.frame.width / 2
        next_frame.clipsToBounds = true
        next_frame.dropShadow(color: .gray, opacity: 1, offSet: CGSize.zero, radius: 8, scale: true)
        let image = UIImage(named: "return")?.withRenderingMode(.alwaysTemplate)
        next_btn.setImage(image, for: .normal)
        next_btn.transform = next_btn.transform.rotated(by: CGFloat(Double.pi))
        next_btn.tintColor = UIColor.white
        
        prev_frame.layer.cornerRadius = prev_frame.frame.width / 2
        prev_frame.clipsToBounds = true
        prev_frame.dropShadow(color: .lightGray, opacity: 0.8, offSet: CGSize.zero, radius: 5, scale: true)
        prev_btn.setImage(image, for: .normal)
        prev_btn.tintColor = UIColor.white
        
        bio_frame.layer.cornerRadius = 16
        bio_frame.clipsToBounds = true
        bio_frame.dropShadow(color: .lightGray, opacity: 0.8, offSet: CGSize.zero, radius: 5, scale: true)
        
        bio_in.delegate = self
        
        bio_label.text = bio_str
        bio_label_height_constrain.constant = CommonFuncs().getStringHeight(bio_str, 15, UIScreen.main.bounds.width, 40, 20)
        
        /*if ShareData.user_info.bio! != nil && ShareData.user_info.bio! != ""
        {
            bio_in.text = ShareData.user_info.bio!
        }
        else
        {*/
        bio_in.text = "Tell us about yourself"
        /*}*/
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    @IBAction func nextAction(_ sender: Any) {
        
        nextStepAction()
        
    }
    
    @IBAction func prevAction(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
}


extension ProfileBioVC: UITextViewDelegate
{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        bio_in.resignFirstResponder()
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        bio_in.text = ""
    }
    
        
    func textViewDidChange(_ textView: UITextView) {
        
        if textView.text.contains("\n")
        {
            let str = textView.text!
            textView.text = str.substring(to: str.index(before: str.endIndex))
            textView.resignFirstResponder()
        }
    }

}


extension ProfileBioVC
{
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer)
    {
        
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer
        {
            switch swipeGesture.direction
            {
                
            case UISwipeGestureRecognizerDirection.left:
                
                nextStepAction()
                
            case UISwipeGestureRecognizerDirection.right:
                
                self.navigationController?.popViewController(animated: true)
                
            default:
                break
            }
        }
    }
    
    func nextStepAction()
    {
        
        if bio_in!.text == nil || bio_in.text! == ""
        {
            return
        }
        
        let url = URL(string: "\(ShareData.main_url)profile/influencer.php")!
        let parameter = ["user_id": ShareData.user_info.id!, "bio": bio_in.text!, "category": ShareData.profile_category, "paypal_id": ShareData.user_info.paypal_id!, "venmo_id": ShareData.user_info.venmo_id! , "work_day": ShareData.user_info.work_day!, "chat_time": ShareData.user_info.chat_time!, "chat_rate": ShareData.user_info.chat_rate!, "time_zone": ShareData.user_info.time_zone!] as! [String: String]
        
        self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: progressDlg, color: .white, fadeInAnimation: nil)
        
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
                        
                        self.stopAnimating(nil)
                        
                        if status
                        {
                            let data = dictData["data"] as! [String: Any]
                            if let temp = Mapper<UserMDL>().map(JSONObject: data["profile"])
                            {
                                ShareData.user_info = temp
                            }
                            
                            CommonFuncs().doneAlert(ShareData.appTitle, message, "DONE", {ShareData.user_or_influencer = false
                                UIApplication.shared.keyWindow?.setRootViewController(MainTabVC(), options: UIWindow.TransitionOptions(direction: .toRight, style: .easeIn), slide_direction: .fromLeftToRight)})
                            
                        }
                        else
                        {
                            CommonFuncs().doneAlert(ShareData.appTitle, message, "CLOSE", {UIApplication.shared.keyWindow?.setRootViewController(MainTabVC(), options: UIWindow.TransitionOptions(direction: .toRight, style: .easeIn), slide_direction: .fromLeftToRight)})
                            
                        }
                        
                    }
                    
                })
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
}


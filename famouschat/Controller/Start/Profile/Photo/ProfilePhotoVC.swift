//
//  ProfilePhotoVC.swift
//  famouschat
//
//  Created by T-Tech Solutions LLC on 05/11/2018.
//  Copyright © 2018 T-Tech Solutions LLC. All rights reserved.
//

import UIKit
import Alamofire
import NVActivityIndicatorView
import ObjectMapper

class ProfilePhotoVC: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet weak var photo_btn: UIButton!
    @IBOutlet weak var next_frame: UIView!
    @IBOutlet weak var next_btn: UIButton!
    @IBOutlet weak var prev_frame: UIView!
    @IBOutlet weak var prev_btn: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var time_zone_frame: UIView!
    @IBOutlet weak var time_zone_sel_btn: UIButton!
    @IBOutlet weak var time_zone_sel_btn1: UIButton!
    
    let progressDlg = ShareData.progressDlgs[ShareData.progress_index]
    var time_zone_alert: OnePickerAlert!
    
    
    var time_zone_val = "0"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        time_zone_val = ShareData.user_info.time_zone!
        init_UI()
    }
    
    func init_UI()
    {
        self.navigationController?.isNavigationBarHidden = true
        
        if ShareData.user_info.photo! != ""
        {
            photo_btn.load(url: ShareData.user_info.photo!)
            photo_btn.layer.cornerRadius = photo_btn.frame.width / 2
            photo_btn.layer.borderWidth = 1
            photo_btn.layer.borderColor = Utility.color(withHexString: ShareData.btn_color).cgColor
            photo_btn.clipsToBounds = true
        }
        else
        {
            photo_btn.setImage(UIImage.init(named: "photo_add"), for: .normal)
        }
        
        
        time_zone_frame.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        time_zone_frame.clipsToBounds = true
        time_zone_frame.dropShadow(color: .white, opacity: 0.8, offSet: CGSize.zero, radius: 5, scale: true)
        time_zone_sel_btn.setTitle("Eastern Time Zone(EST \(ShareData.time_zones[Int(time_zone_val)!]))", for: .normal)
        
        let image3 = UIImage(named: "listBox")?.withRenderingMode(.alwaysTemplate)
        time_zone_sel_btn1.setImage(image3, for: .normal)
        time_zone_sel_btn1.tintColor = Utility.color(withHexString: ShareData.btn_color)
        
        next_frame.layer.cornerRadius = next_frame.frame.width / 2
        next_frame.clipsToBounds = true
        next_frame.dropShadow(color: .lightGray, opacity: 0.8, offSet: CGSize.zero, radius: 5, scale: true)
        let image = UIImage(named: "return")?.withRenderingMode(.alwaysTemplate)
        next_btn.setImage(image, for: .normal)
        next_btn.transform = next_btn.transform.rotated(by: CGFloat(Double.pi))
        next_btn.tintColor = UIColor.white
        
        prev_frame.layer.cornerRadius = prev_frame.frame.width / 2
        prev_frame.clipsToBounds = true
        prev_frame.dropShadow(color: .lightGray, opacity: 0.8, offSet: CGSize.zero, radius: 5, scale: true)
        prev_btn.setImage(image, for: .normal)
        prev_btn.tintColor = UIColor.white
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        
    }

    @IBAction func photoAction(_ sender: Any) {
        
        let alertController = UIAlertController.init(title: "\(ShareData.appTitle)", message: "Select Profile Image", preferredStyle: .actionSheet)
        
        
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
        }
        
        alertController.addAction(imageAction)
        alertController.addAction(galleryAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func timeZoneSelect(_ sender: Any) {
        
        self.time_zone_alert = OnePickerAlert.instanceFromNib(title: "Time Zone") as! OnePickerAlert
        
        self.scrollView.isHidden = true
        self.time_zone_alert.picker.delegate = self
        self.time_zone_alert.picker.dataSource = self
        
        self.time_zone_alert.picker.selectRow(Int(time_zone_val)!, inComponent: 0, animated: true)
        
        time_zone_alert.apply_btn.addTarget(self, action: #selector(self.zonePickerDone(_:)), for: .touchUpInside)
        
        
    }
    
    @IBAction func nextAction(_ sender: Any) {
        
        nextStepAction()
    }
    
    @IBAction func prevAction(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    

}

extension ProfilePhotoVC
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
    
    
    @objc func zonePickerDone(_ sender: UIButton) {
        
        ShareData.user_info.time_zone = time_zone_val
        time_zone_sel_btn.setTitle("Eastern Time Zone(EST \(ShareData.time_zones[Int(time_zone_val)!]))", for: .normal)
        
        self.time_zone_alert.removeFromSuperview()
        self.scrollView.isHidden = false
    }
    
    func nextStepAction()
    {
       
        if ShareData.user_or_influencer
        {
            
            let url = URL(string: "\(ShareData.main_url)profile/normal.php")!
            let parameter = ["user_id": ShareData.user_info.id!, "bio": ShareData.user_info.bio!, "category": ShareData.profile_category, "paypal_id": ShareData.user_info.paypal_id!, "venmo_id": ShareData.user_info.venmo_id!, "time_zone": ShareData.user_info.time_zone!] as! [String: String]
            
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
                            
                            if status
                            {
                                let data = dictData["data"] as! [String: Any]
                                
                                if let temp = Mapper<UserMDL>().map(JSONObject: data["profile"])
                                {
                                    ShareData.user_info = temp
                                }
                                
                                self.stopAnimating(nil)
                                CommonFuncs().doneAlert(ShareData.appTitle, "You have successfully updated user profile", "DONE", {UIApplication.shared.keyWindow?.setRootViewController(MainTabVC(), options: UIWindow.TransitionOptions(direction: .toRight, style: .easeIn), slide_direction: .fromLeftToRight)})
                                
                            }
                            else
                            {
                                self.stopAnimating(nil)
                                CommonFuncs().doneAlert(ShareData.appTitle, message, "CLOSE", {UIApplication.shared.keyWindow?.setRootViewController(MainTabVC(), options: UIWindow.TransitionOptions(direction: .toRight, style: .easeIn), slide_direction: .fromLeftToRight)})
                                
                            }
                            
                            
                        }
                        
                    })
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        else
        {
            
            self.navigationController?.pushViewController(ProfileBioVC(), animated: true)
        }
        
    }
    
}


extension ProfilePhotoVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let img = CommonFuncs().resizeImage(image: chosenImage, targetSize: CGSize(width: 300.0, height: 300.0))
        photo_btn.setImage(img, for: .normal)
        photo_btn.layer.cornerRadius = photo_btn.frame.width / 2
        photo_btn.layer.borderWidth = 1
        photo_btn.layer.borderColor = Utility.color(withHexString: ShareData.btn_color).cgColor
        photo_btn.clipsToBounds = true
        
        ShareData.profile_photo = UIImagePNGRepresentation(img)  as! NSData
        dismiss(animated:true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        dismiss(animated: true, completion: nil)
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        
        return ShareData.time_zones.count
        
    }
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont.systemFont(ofSize: 13)
            pickerLabel?.textAlignment = .center
        }
        
        var str = ""
        str = "Eastern Time Zone(EST \(ShareData.time_zones[row]))"
        pickerLabel?.font = UIFont.systemFont(ofSize: 15)
        
        pickerLabel?.text = str
        pickerLabel?.textColor = UIColor.darkGray
        
        return pickerLabel!
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        time_zone_val = "\(row)"
    }
}

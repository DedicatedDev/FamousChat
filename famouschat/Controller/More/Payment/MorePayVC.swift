//
//  MorePayVC.swift
//  famouschat
//
//  Created by T-Tech Solutions LLC on 08/11/2018.
//  Copyright © 2018 T-Tech Solutions LLC. All rights reserved.
//

import UIKit
import Alamofire
import NVActivityIndicatorView

class MorePayVC: UIViewController, NVActivityIndicatorViewable {
    
    @IBOutlet weak var header_frame: UIView!
    @IBOutlet weak var back_img: UIImageView!
    @IBOutlet weak var back_btn: UIButton!
    @IBOutlet weak var menu_img: UIImageView!
    @IBOutlet weak var menu_btn: UIButton!
    
    @IBOutlet weak var pay_frame: UIView!
    @IBOutlet weak var pay_num_frame: UIStackView!
    @IBOutlet weak var paypal_go_img: UIImageView!
    @IBOutlet weak var venmo_go_img: UIImageView!
    @IBOutlet weak var paypal_label: UIStackView!
    @IBOutlet weak var venmo_label: UIStackView!
    @IBOutlet weak var card_id_in: UITextField!
    @IBOutlet weak var card_date_in: UITextField!
    @IBOutlet weak var pay_ok_btn: UIButton!
    @IBOutlet weak var pay_cancel_btn: UIButton!
    
    @IBOutlet weak var popcoin_label1: UILabel!
    @IBOutlet weak var popcoin_label2: UILabel!
    @IBOutlet weak var popcoin_buy_btn: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var withDraw_frame: UIView!
    @IBOutlet weak var withDraw_in: UITextField!
    @IBOutlet weak var withDraw_btn: UIButton!
    
    var coin_buy_status = false
    var paypal_id = ""
    var venmo_id = ""
    var card_index_status = false
    var coin_in: UITextField!
    let progressDlg = ShareData.progressDlgs[ShareData.progress_index]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        init_UI()
    }
    
    func init_UI()
    {
        self.navigationController?.isNavigationBarHidden = true
        
        header_frame.dropShadow(color: .gray, opacity: 0.5, offSet: CGSize.zero, radius: 8, scale: true)
        
        let back_image = UIImage.init(named: "back")!.withRenderingMode(.alwaysTemplate)
        back_img.image = back_image
        back_img.tintColor = Utility.color(withHexString: "10A7BA")
        
     //   let menu_image = UIImage.init(named: "menu_1")!.withRenderingMode(.alwaysTemplate)
     //   menu_img.image = menu_image
     //   menu_img.tintColor = Utility.color(withHexString: ShareData.btn_color)
        
     //   menu_btn.addTarget(self.slideMenuController, action: #selector(slideMenuController.toggleMenuAnimated(_:)), for: .touchUpInside)
        back_btn.addTarget(self, action: #selector(self.backAction(_:)), for: .touchUpInside)
        
        pay_frame.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        pay_frame.clipsToBounds = true
        pay_frame.dropShadow(color: Utility.color(withHexString: ShareData.btn_color), opacity: 1, offSet: CGSize.zero, radius: 5, scale: true)
        pay_frame.isHidden = true
        
        let image = UIImage(named: "go")?.withRenderingMode(.alwaysTemplate)
        paypal_go_img.image = image
        paypal_go_img.tintColor = UIColor.darkGray
        venmo_go_img.image = image
        venmo_go_img.tintColor = UIColor.darkGray
        
        pay_ok_btn.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        pay_ok_btn.clipsToBounds = true
        pay_ok_btn.dropShadow(color: .gray, opacity: 1, offSet: CGSize.zero, radius: 3, scale: true)
        pay_cancel_btn.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        pay_cancel_btn.clipsToBounds = true
        pay_cancel_btn.dropShadow(color: .gray, opacity: 1, offSet: CGSize.zero, radius: 3, scale: true)
        card_id_in.delegate = self
        card_date_in.delegate = self
        
        self.popcoin_label1.text = ShareData.user_info.popcoin_num!
        self.popcoin_label2.text = "PopCoins:  \(ShareData.user_info.popcoin_num!)"
        
        popcoin_buy_btn.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        popcoin_buy_btn.clipsToBounds = true
        popcoin_buy_btn.dropShadow(color: .gray, opacity: 0.8, offSet: CGSize.zero, radius: 5, scale: true)
        
        withDraw_frame.layer.cornerRadius = withDraw_frame.frame.height / 2
        withDraw_frame.clipsToBounds = true
        withDraw_frame.layer.borderWidth = 1
        withDraw_frame.layer.borderColor = Utility.color(withHexString: ShareData.btn_color).cgColor
        withDraw_frame.dropShadow(color: .gray, opacity: 0.8, offSet: CGSize.zero, radius: 3, scale: true)
        
        withDraw_in.delegate = self
        withDraw_in.placeholder = "0"
        
        withDraw_btn.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        withDraw_btn.clipsToBounds = true
        withDraw_btn.dropShadow(color: .gray, opacity: 0.8, offSet: CGSize.zero, radius: 5, scale: true)
    }
    
    
    @IBAction func payPalAction(_ sender: Any) {
        
        pay_frame.isHidden = false
        paypal_label.isHidden = false
        venmo_label.isHidden = true
        scrollView.isHidden = true
        card_index_status = false
        
        card_id_in.text =  ShareData.user_info.paypal_id!
        card_id_in.placeholder = "Paypal ID"
        
    }
    
    @IBAction func venmoActon(_ sender: Any) {
        
        scrollView.isHidden = true
        pay_frame.isHidden = false
        paypal_label.isHidden = true
        venmo_label.isHidden = false
        card_index_status = true
        
        card_id_in.text =  ShareData.user_info.venmo_id!
        card_id_in.placeholder = "venmo ID"
        
    }
    
    @IBAction func paySaveAction(_ sender: Any) {
        
        var status = false
        
        if card_index_status
        {
            venmo_id = card_id_in.text!
            
            if venmo_id == "" || venmo_id == ShareData.user_info.venmo_id!
            {
                status = true
            }
        }
        else
        {
            paypal_id = card_id_in.text!
            
            if paypal_id == "" || paypal_id == ShareData.user_info.paypal_id!
            {
                status = true
            }
            
        }
        
        self.pay_frame.isHidden = true
        self.scrollView.isHidden = false
        
        if status
        {
            return
        }
        
        self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: progressDlg, color: .darkGray, fadeInAnimation: nil)
        
        
        let url = URL(string: "\(ShareData.main_url)profile/normal.php")!
        let parameter = ["user_id": ShareData.user_info.id!, "bio": ShareData.user_info.bio!, "category": ShareData.user_info.category!, "paypal_id": self.paypal_id, "venmo_id": self.venmo_id, "time_zone": ShareData.user_info.time_zone!] as! [String: String]
        
        
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
                            
                            ShareData.user_info.paypal_id = self.paypal_id
                            ShareData.user_info.venmo_id = self.venmo_id
                            
                        }
                        
                        self.stopAnimating(nil)
                        CommonFuncs().doneAlert(ShareData.appTitle, message, "CLOSE", {self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)})
                    }
                    
                })
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        
    }
    
    @IBAction func payCancelAction(_ sender: Any) {
        
        pay_frame.isHidden = true
        scrollView.isHidden = false
        
    }
    
    
    @IBAction func coinBuyAction(_ sender: Any) {
        
        if ShareData.user_info.paypal_id! == "" && ShareData.user_info.venmo_id! == ""
        {
            
            CommonFuncs().selectAlert(ShareData.appTitle, "Your credit account is not verified. Please verify credit account", 2, ["VERIFY NOW", "CANCEL"], [Utility.color(withHexString: ShareData.btn_color), UIColor.gray], [UIColor.white, UIColor.white], self, [#selector(paymentVerifyOK(_:)), #selector(paymentVerifyCancel(_:))])
            
        }
        else
        {
            coin_in = CommonFuncs().inputAlert(ShareData.appTitle, "Buy new PopCoin", "Input coin numbers...", 2, ["BUY", "CANCEL"], [Utility.color(withHexString: ShareData.btn_color), UIColor.gray], [UIColor.white, UIColor.white], self, [#selector(coinBuyConfirmOkAction(_:)), #selector(coinBuyConfirmCancelAction(_:))])
            coin_buy_status = true
            self.coin_in.delegate = self
        }
        
        
    }
    
    @IBAction func withDrawAction(_ sender: Any) {
        
        if withDraw_in.text! == "" || withDraw_in.text! == "0"
        {
            return
        }
        
        let total_money = Double(ShareData.user_info.popcoin_num!)! * Double(ShareData.app_config.popcoin_price!)!
        let withDraw_money = Double(withDraw_in.text!)!
        
        if withDraw_money > (total_money - withDraw_money * 0.1)
        {
            CommonFuncs().doneAlert(ShareData.appTitle, "You don`t have enough PopCoin for this amount", "CLOSE", {return})
        }
        else
        {
            CommonFuncs().selectAlert(ShareData.appTitle, "Please confirm withdraw : \(Int(withDraw_money))$", 2, ["WITHDRAW", "CANCEL"], [Utility.color(withHexString: ShareData.btn_color), UIColor.gray], [UIColor.white, UIColor.white], self, [#selector(withDrawOKAction(_:)), #selector(withDrawCancelAction(_:))])
        }
        
    }
    
    
    
    @objc func backAction(_ sender: UIButton) {
        
        if ShareData.pay_from_status
        {
            ShareData.main_or_more_status = true
            UIApplication.shared.keyWindow?.setRootViewController(MainTabVC(), options: UIWindow.TransitionOptions(direction: .toLeft, style: .easeIn), slide_direction: .fromLeftToRight)
        }
        else
        {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
}

extension MorePayVC: UITextFieldDelegate
{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        card_id_in.resignFirstResponder()
        card_date_in.resignFirstResponder()
        withDraw_in.resignFirstResponder()
        if coin_buy_status
        {
            coin_in.resignFirstResponder()
        }
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        scrollView.setContentOffset(CGPoint(x: 0, y: 400), animated: true)
        
        return true
    }
    
}


extension MorePayVC
{
    
    @objc func coinBuyConfirmOkAction(_ sender: UIButton) {
        
        
        if coin_in.text == "" || coin_in.text == nil
        {
            return
        }
        else
        {
            
            let parmeters = ["user_id": ShareData.user_info.id!, "popcoin": coin_in.text!, "status": "1"] as [String: Any]
            
            self.scrollView.isHidden = false
            
            self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: self.progressDlg, color: .darkGray, fadeInAnimation: nil)
            
            
            CommonFuncs().createRequest(false, "payment/popcoin_buy", "POST", parmeters, completionHandler: {data in
                
                let status = data["status"] as! Bool
                let message = data["message"] as! String
                
                DispatchQueue.main.async {
                    
                    self.stopAnimating(nil)
                    self.coin_buy_status = false
                    if status
                    {
                        
                        var coin_num = Int(ShareData.user_info.popcoin_num!)!
                        coin_num += Int(self.coin_in.text!)!
                        ShareData.user_info.popcoin_num = "\(coin_num)"
                        self.popcoin_label1.text = "\(coin_num)"
                        self.popcoin_label2.text = "PopCoins:  \(coin_num)"
                        
                    }
                    CommonFuncs().doneAlert(ShareData.appTitle, message, "CLOSE", {self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)})   
                    
                }
            })
            
        }
        
    }
    
    
    @objc func paymentVerifyOK(_ sender: UIButton) {
        
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        return
    }
    
    @objc func paymentVerifyCancel(_ sender: UIButton) {
        
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        return
    }
    
    @objc func coinBuyConfirmCancelAction(_ sender: UIButton) {
        
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        return
    }
    
    @objc func withDrawOKAction(_ sender: UIButton) {
        
        
        let coin_num = Int(withDraw_in.text!)! / Int(ShareData.app_config.popcoin_price!)!
        let parmeters = ["user_id": ShareData.user_info.id!, "popcoin": "\(coin_num)", "status": "0"] as [String: Any]
        
        self.scrollView.isHidden = false
        
        self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: self.progressDlg, color: .darkGray, fadeInAnimation: nil)
        
        CommonFuncs().createRequest(false, "payment/popcoin_buy", "POST", parmeters, completionHandler: {data in
            
            let status = data["status"] as! Bool
            let message = data["message"] as! String
            
            DispatchQueue.main.async {
                
                self.stopAnimating(nil)
                self.coin_buy_status = false
                if status
                {                    
                    var account_coin_num = Int(ShareData.user_info.popcoin_num!)!
                    account_coin_num -= coin_num
                    ShareData.user_info.popcoin_num = "\(account_coin_num)"
                    self.popcoin_label1.text = "\(account_coin_num)"
                    self.popcoin_label2.text = "PopCoins:  \(account_coin_num)"
                    
                }
                
                CommonFuncs().doneAlert(ShareData.appTitle, message, "CLOSE", {self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)})
                
                
                
            }
        })
    }
    
    @objc func withDrawCancelAction(_ sender: UIButton) {
        
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        return
    }
    
}

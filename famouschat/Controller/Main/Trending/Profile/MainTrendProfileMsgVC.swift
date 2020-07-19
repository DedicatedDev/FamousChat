//
//  MainTrendProfileMsgVC.swift
//  famouschat
//
//  Created by T-Tech Solutions LLC on 11/11/2018.
//  Copyright © 2018 T-Tech Solutions LLC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class MainTrendProfileMsgVC: UIViewController, NVActivityIndicatorViewable  {
    
    @IBOutlet weak var back_img: UIImageView!
    @IBOutlet weak var back_btn: UIButton!
    @IBOutlet weak var menu_img: UIImageView!
    @IBOutlet weak var menu_btn: UIButton!
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var photo_height: NSLayoutConstraint!
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var message_label: UILabel!
    @IBOutlet weak var message_frame: UIView!
    @IBOutlet weak var message_in: UITextView!
    
    @IBOutlet weak var fee: UILabel!
    @IBOutlet weak var fee_label: UILabel!
    @IBOutlet weak var send_btn: UIButton!
    
    var coin_buy_status = false
    var alert_status = ""
    
    let progressDlg = ShareData.progressDlgs[ShareData.progress_index]
    
    var fee_val = 5
    var msg = ""
    var coin_num = 0
    var coin_in: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        coin_num = Int(Double(ShareData.app_config.msg_fee!)! / Double(ShareData.app_config.popcoin_price!)!)
        
        init_UI()
    }
    
    func init_UI()
    {
        
        self.navigationController?.isNavigationBarHidden = true
        
        let back_image = UIImage.init(named: "back")!.withRenderingMode(.alwaysTemplate)
        back_img.image = back_image
        back_img.tintColor = UIColor.white
        
        let menu_image = UIImage.init(named: "menu")!.withRenderingMode(.alwaysTemplate)
        menu_img.image = menu_image
        menu_img.tintColor = UIColor.white
        menu_img.isHidden = true
        
        back_btn.addTarget(self, action: #selector(self.backAction(_:)), for: .touchUpInside)
        
        photo_height.constant = photo.frame.width * 0.7
        if ShareData.msg_vc_from == "1"
        {
            photo.load(url: ShareData.selected_influencer.photo!)
            name.text = ShareData.selected_influencer.name!
            message_label.text = "MESSAGE FOR \(ShareData.selected_influencer.name!.uppercased())"
        }
        else
        {
            photo.load(url: ShareData.selected_book.profile.photo!)
            name.text = ShareData.selected_book.profile.name!
            message_label.text = "MESSAGE FOR \(ShareData.selected_book.profile.name!.uppercased())"
        }
        
        message_frame.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        message_frame.clipsToBounds = true
        message_frame.layer.borderColor = Utility.color(withHexString: ShareData.btn_color)?.cgColor
        message_frame.layer.borderWidth = 1
        message_frame.dropShadow(color: .gray, opacity: 0.5, offSet: CGSize.zero, radius: 5, scale: true)
        
        message_in.delegate = self
        message_in.textColor = UIColor.gray
        message_in.text = "Write Message..."
        
        fee.text = "$\(ShareData.app_config.msg_fee!)/Message"
        
        send_btn.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        send_btn.clipsToBounds = true
        send_btn.dropShadow(color: .gray, opacity: 0.8, offSet: CGSize.zero, radius: 5, scale: true)
        
    }
    
    @IBAction func sendAction(_ sender: Any) {
        
        alert_status = "chat"
        
        CommonFuncs().selectAlert(ShareData.appTitle, "To request a chat you must pay the influencer’s fee", 2, ["Purchase Chat", "CANCEL"], [Utility.color(withHexString: ShareData.btn_color), UIColor.gray], [UIColor.white, UIColor.white], self, [#selector(purchaseOkAction(_:)), #selector(purchaseCancelAction(_:))])
    }
    
    
    @objc func backAction(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension MainTrendProfileMsgVC: UITextViewDelegate, UITextFieldDelegate
{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if coin_buy_status
        {
            coin_in.resignFirstResponder()
        }
        
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {        
        
        message_in.textColor = UIColor.darkGray
        message_in.text = ""
        
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


extension MainTrendProfileMsgVC
{
    
    @objc func purchaseOkAction(_ sender: UIButton) {
        
        
        if ShareData.user_info.paypal_id! == "" && ShareData.user_info.venmo_id! == ""
        {
            CommonFuncs().selectAlert(ShareData.appTitle, "Your credit account is not verified. Please verify credit account", 2, ["VERIFY NOW", "CANCEL"], [Utility.color(withHexString: ShareData.btn_color), UIColor.gray], [UIColor.white, UIColor.white], self, [#selector(paymentVerifyOK(_:)), #selector(paymentVerifyCancel(_:))])
            
        }
        else
        {
            
            if Int(ShareData.user_info.popcoin_num!)! < coin_num
            {
                CommonFuncs().selectAlert(ShareData.appTitle, "You don`t have enough PopCoin for this book(need more \(coin_num - Int(ShareData.user_info.popcoin_num!)!)). Do you want to buy PopCoin?", 2, ["BUY NOW", "CANCEL"], [Utility.color(withHexString: ShareData.btn_color), UIColor.gray], [UIColor.white, UIColor.white], self, [#selector(coinBuyOkAction(_:)), #selector(coinBuyCancelAction(_:))])
            }
            else
            {
                self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: progressDlg, color: .darkGray, fadeInAnimation: nil)
                send_btn.isUserInteractionEnabled = false
                
                self.sendAction()
            }
            
        }
        
        
    }
    
    @objc func purchaseCancelAction(_ sender: UIButton) {
        
        return
    }
    
    @objc func paymentVerifyOK(_ sender: UIButton) {
        
        ShareData.pay_from_status = false
        self.navigationController?.pushViewController(MorePayVC(), animated: true)
    }
    
    @objc func paymentVerifyCancel(_ sender: UIButton) {
        
        return
    }
    
    @objc func coinBuyOkAction(_ sender: UIButton) {
        
        coin_in = CommonFuncs().inputAlert(ShareData.appTitle, "Buy new PopCoin", "Input coin numbers...", 2, ["BUY", "CANCEL"], [Utility.color(withHexString: ShareData.btn_color), UIColor.gray], [UIColor.white, UIColor.white], self, [#selector(coinBuyConfirmOkAction(_:)), #selector(coinBuyConfirmCancelAction(_:))])
        coin_buy_status = true
        self.coin_in.delegate = self
    }
    
    @objc func coinBuyCancelAction(_ sender: UIButton) {
        
        return
    }
    
    @objc func coinBuyConfirmOkAction(_ sender: UIButton) {
        
        coin_buy_status = false
        
        if coin_in.text == "" || coin_in.text == nil
        {
            return
        }
        else
        {
            
            let parmeters = ["user_id": ShareData.user_info.id!, "popcoin": coin_in.text!, "status": "1"] as [String: Any]
            
            self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: self.progressDlg, color: .darkGray, fadeInAnimation: nil)
            
            CommonFuncs().createRequest(false, "payment/popcoin_buy", "POST", parmeters, completionHandler: {data in
                
                let status = data["status"] as! Bool
                let message = data["message"] as! String
                
                DispatchQueue.main.async {
                    
                    self.stopAnimating(nil)
                    
                    if status
                    {
                        
                        var coin_num = Int(ShareData.user_info.popcoin_num!)!
                        coin_num += Int(self.coin_in.text!)!
                        ShareData.user_info.popcoin_num = "\(coin_num)"
                        
                    }
                    else
                    {
                        CommonFuncs().doneAlert(ShareData.appTitle, message, "CLOSE", {})
                        
                    }
                }
            })
            
            
        }
        
    }
    
    @objc func coinBuyConfirmCancelAction(_ sender: UIButton) {
        
        return
    }
    
    func sendAction()
    {
        self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: self.progressDlg, color: .darkGray, fadeInAnimation: nil)
        self.send_btn.isUserInteractionEnabled = false
        
        let send_time = CommonFuncs().currentTime()
        let sender_id = ShareData.user_info.id!
        let message = self.message_in.text!
        var receiver_id = ""
        
        if ShareData.msg_vc_from == "1"
        {
            receiver_id = ShareData.selected_influencer.id!
        }
        else
        {
            receiver_id = ShareData.selected_book.book.influencer_id!
        }
        
        let parmeters = ["sender_id": sender_id, "receiver_id": receiver_id, "message": message, "send_time": send_time, "time_zone": ShareData.user_info.time_zone!, "msg_fee": "\(coin_num)"] as [String: Any]
        
        self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: self.progressDlg, color: .darkGray, fadeInAnimation: nil)
        
        CommonFuncs().createRequest(false, "message/send", "POST", parmeters, completionHandler: {data in
            
            let status = data["status"] as! Bool
            let status_msg = data["message"] as! String
            DispatchQueue.main.async {
                
                self.stopAnimating(nil)
                if status
                {
                    let msg_data = data["data"] as! [String: Any]
                    
                    let new_coin_num = Int(ShareData.user_info.popcoin_num)! - self.coin_num
                    ShareData.user_info.popcoin_num = "\(new_coin_num)"
                    
                    self.send_btn.isUserInteractionEnabled = true
                    
                   CommonFuncs().doneAlert(ShareData.appTitle, status_msg, "CLOSE", {self.navigationController?.popViewController(animated: true)})
                    
                }
                else
                {
                    self.send_btn.isUserInteractionEnabled = true
                    CommonFuncs().doneAlert(ShareData.appTitle, status_msg, "CLOSE", {})
                }
            }
        })
    }
}



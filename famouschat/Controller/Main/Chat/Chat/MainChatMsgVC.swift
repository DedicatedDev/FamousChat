//
//  MainChatMsgVC.swift
//  famouschat
//
//  Created by T-Tech Solutions LLC on 08/11/2018.
//  Copyright © 2018 T-Tech Solutions LLC. All rights reserved.
//

import UIKit
import Alamofire
import UserNotifications
import AVFoundation
import SDWebImage
import NVActivityIndicatorView
import ObjectMapper


class MainChatMsgVC: UIViewController, NVActivityIndicatorViewable {
    
    @IBOutlet weak var back_img: UIImageView!
    @IBOutlet weak var back_btn: UIButton!
    @IBOutlet weak var menu_img: UIImageView!
    @IBOutlet weak var menu_btn: UIButton!
    @IBOutlet weak var header_frame: UIView!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var chat_name: UILabel!
    @IBOutlet weak var msg_in_frame: UIView!
    @IBOutlet weak var msg_in_frame_height: NSLayoutConstraint!
    
    @IBOutlet weak var msg_in: UITextView!
    @IBOutlet weak var msg_in_height: NSLayoutConstraint!
    @IBOutlet weak var input_frame: UIView!
    @IBOutlet weak var input_frame_height: NSLayoutConstraint!
    @IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint?
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var record_btn: UIButton!
    @IBOutlet weak var photo_btn: UIButton!
    @IBOutlet weak var selected_msg_frame: UIView!
    @IBOutlet weak var selected_msg_img: UIImageView!
    @IBOutlet weak var send_frame: UIView!
    @IBOutlet weak var send_btn: UIButton!
    
    @IBOutlet weak var load_more_btn: UIButton!
    @IBOutlet weak var record_frame: UIView!
    @IBOutlet weak var record_img: UIImageView!
    @IBOutlet weak var record_cancel_btn: UIButton!
    @IBOutlet weak var record_time_label: UILabel!
    @IBOutlet weak var record_save_btn: UIButton!
    
    var all_msg_status = false
    
    let progressDlg = ShareData.progressDlgs[ShareData.progress_index]
    
    let msgDefaultWidth = UIScreen.main.bounds.width / 2 + 40
    var new_photo: NSData! = nil
    var keyboardHeight: CGFloat = 0.0
    var msgFrmae: CGRect!
    
    var recordingSession : AVAudioSession!
    var audioRecorder   : AVAudioRecorder!
    var audioPlayer    : AVAudioPlayer!
    var audioURL :NSURL!
    var audioData : Data? = nil
    var settings = [String : Int]()
    
    var isRecording = false
    var record_counter = 0
    var counter_status = false
    
    var parmeters: [String: Any]!
    
    var coin_in: UITextField!
    var coin_buy_status = false
    
    var coin_num = 0
    var msg_type = "txt"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coin_num = Int(Double(ShareData.app_config.msg_fee!)! / Double(ShareData.app_config.popcoin_price!)!)
        
        init_UI()
    }
    
    func init_UI()
    {
        self.navigationController?.isNavigationBarHidden = true
        
        header_frame.dropShadow(color: .gray, opacity: 0.5, offSet: CGSize.zero, radius: 8, scale: true)
        
        let back_image = UIImage.init(named: "back")!.withRenderingMode(.alwaysTemplate)
        back_img.image = back_image
        back_img.tintColor = Utility.color(withHexString: "10A7BA")
        
        let menu_image = UIImage.init(named: "menu")!.withRenderingMode(.alwaysTemplate)
        menu_img.image = menu_image
        menu_img.tintColor = Utility.color(withHexString: "10A7BA")
        menu_img.isHidden = true
        
        back_btn.addTarget(self, action: #selector(self.backAction(_:)), for: .touchUpInside)
        
        photo.load(url: ShareData.selected_chat.profile.photo!)
        photo.layer.cornerRadius = photo.frame.width / 2
        photo.clipsToBounds = true
        
        chat_name.text = ShareData.selected_chat.profile.name!
        
        input_frame.dropShadow(color: UIColor.gray, opacity: 0.5, offSet: CGSize(width: 0, height: -1), radius: 1, scale: true)
        
        msg_in_frame.layer.borderColor = UIColor.lightGray.cgColor
        msg_in_frame.layer.borderWidth = 1
        msg_in_frame.layer.cornerRadius = msg_in_frame.frame.height / 2
        msg_in.delegate = self
        msg_in.text = "Write a message..."
        msg_in.returnKeyType = .send
        
        send_frame.layer.cornerRadius = send_frame.frame.width / 2
        send_frame.clipsToBounds = true
        
        let image = UIImage.init(named: "chat_send")!.withRenderingMode(.alwaysTemplate)
        send_btn.setImage(image, for: .normal)
        send_btn.tintColor = UIColor.white
        
        keyboardHeightLayoutConstraint?.constant = 0
        
        msgFrmae = self.input_frame.frame
        
        record_frame.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        record_frame.clipsToBounds = true
        record_frame.dropShadow(color: Utility.color(withHexString: ShareData.btn_color), opacity: 1, offSet: CGSize.zero, radius: 5, scale: true)
        
        record_img.loadGif(name: "record")
        record_time_label.text = "00 : 00"
        
        record_frame.isHidden = true
        
        load_more_btn.layer.cornerRadius = load_more_btn.frame.height / 2
        load_more_btn.clipsToBounds = true
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)
        
        
        ShareData.msg_noti_status = false
        ShareData.chat_status = true
        ShareData.chat_msg_list = [MessageMDL]()
        
        ShareData.selected_chat.unread_num = "0"
        
        let index = ShareData.messages.index { $0.message.id! == ShareData.selected_chat.message.id! }
        ShareData.messages[index!].unread_num = "0"
        
        self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: progressDlg, color: .darkGray, fadeInAnimation: nil)
        
        selected_msg_frame.isHidden = true
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(UINib(nibName: "ChatMsgCell", bundle: nil), forCellWithReuseIdentifier: "ChatMsgCell")
        
        msgLoad(last_id: "")
        
        AudioRecordingPermission()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableData), name: .chat_reload, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        collectionView.reloadData()
        self.collectionView.scrollToLast()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self);
    }
    
    @IBAction func sendAction(_ sender: Any) {
        
        self.msgSendAction()
        
    }
    
    @IBAction func photoAction(_ sender: Any) {
        
        let alertController = UIAlertController.init(title: "\(ShareData.appTitle)", message: "Select Image for sending", preferredStyle: .actionSheet)
        
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
            
            
            self.record_btn.isUserInteractionEnabled = true
            self.photo_btn.isUserInteractionEnabled = true
            self.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(imageAction)
        alertController.addAction(galleryAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func recordAction(_ sender: Any) {
        
        self.isRecording = true
        
        let audioShession = AVAudioSession.sharedInstance()
        do {
            audioRecorder = try AVAudioRecorder(url: self.directoryURL()! as URL, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()
        } catch {
            
            audioRecorder.stop()
        }
        do {
            try audioShession.setActive(true)
            
            record_frame.isHidden = false
            record_save_btn.isHidden = false
            record_btn.isUserInteractionEnabled = false
            photo_btn.isUserInteractionEnabled = false
            collectionView.alpha = 0
            record_counter = 0
            perform(#selector(countTime), with: nil, afterDelay: 1.0)
            record_time_label.text = "00 : 00"
            counter_status = true
            audioRecorder.record()
        } catch {
            
            CommonFuncs().doneAlert(ShareData.appTitle, "Failed record", "CLOSE", {})
        }
    }
    
    @IBAction func recordCancelAction(_ sender: Any) {
        
        if isRecording
        {
            audioRecorder!.stop()
            audioRecorder = nil
            counter_status = false
            self.record_frame.isHidden = true
            self.collectionView.alpha = 1
            
            record_btn.isUserInteractionEnabled = true
            photo_btn.isUserInteractionEnabled = true
        }
        else
        {
            audioPlayer!.stop()
            audioPlayer = nil
            counter_status = false
            self.record_frame.isHidden = true
            self.collectionView.alpha = 1
        }
        
        
    }
    
    @IBAction func recordSaveAction(_ sender: Any) {
        
        if audioRecorder == nil {
            
        } else {
            
            audioRecorder.stop()
            do { let audiodata1 = try Data.init(contentsOf: (audioRecorder?.url)!)
                audioData = audiodata1
                
                audioURL = (audioRecorder?.url)! as NSURL
                audioRecorder = nil
                
                self.msg_type = "sound"
                counter_status = false
                
                if ShareData.user_or_influencer
                {
                    
                    
                    if Int(ShareData.user_info.popcoin_num!)! < coin_num
                    {
                        CommonFuncs().selectAlert(ShareData.appTitle, "You don`t have enough PopCoin to send record(need more \(coin_num - Int(ShareData.user_info.popcoin_num!)!)). Do you want to buy PopCoin?", 2, ["BUY NOW", "CANCEL"], [Utility.color(withHexString: ShareData.btn_color), UIColor.gray], [UIColor.white, UIColor.white], self, [#selector(coinBuyOkAction(_:)), #selector(coinBuyCancelAction(_:))])
                        return
                    }
                    else
                    {
                        CommonFuncs().selectAlert(ShareData.appTitle, "Do you want to send record?", 2, ["SEND NOW", "CANCEL"], [Utility.color(withHexString: ShareData.btn_color), UIColor.gray], [UIColor.white, UIColor.white], self, [#selector(msgSendConfirmAction(_:)), #selector(msgSendCancelAction(_:))])
                    }
                    
                    
                }
                else
                {
                    parmeters = ["sender_id": ShareData.user_info.id!, "receiver_id": ShareData.selected_chat.message.sender_id!, "send_time": CommonFuncs().currentTime(), "time_zone": ShareData.user_info.time_zone!] as [String: Any]
                    
                    msgSendFunc()
                }

                
            } catch let error as NSError {
                print("audioPlayer error: \(error.localizedDescription)")
            }
            
        }
    }
    
    @IBAction func loadMoreAction(_ sender: Any) {
        
        if !all_msg_status
        {
            msgLoad(last_id: ShareData.chat_msg_list[0].message.id!)
        }
    }
    
    @IBAction func selectedMsgCancel(_ sender: Any) {
        
        selected_msg_frame.isHidden = true
        collectionView.alpha = 1.0
    }
    
    @IBAction func detailProfile(_ sender: Any) {
        
        
        let parameters = ["user_id": ShareData.selected_chat.profile.id!, "type": ""] as [String: Any]
        
        self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: progressDlg, color: .darkGray, fadeInAnimation: nil)
        
        CommonFuncs().createRequest(false, "review/request", "POST", parameters, completionHandler: {data in
            
            let status = data["status"] as! Bool
            let message = data["message"] as! String
            
            DispatchQueue.main.async {
                
                self.stopAnimating(nil)
                
                if status
                {
                    ShareData.reviews = [ReviewMDL]()
                    
                    if let detail = data["data"] as? [AnyHashable:Any]
                    {
                        if let profile = detail["profile"], let temp = Mapper<UserMDL>().map(JSONObject: profile)
                        {
                            ShareData.user_detail_profile = temp
                        }
                        
                        if let reviews = detail["reviews"], let temp = Mapper<ReviewMDL>().mapArray(JSONObject: reviews)
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
        
        UIApplication.shared.keyWindow?.setRootViewController(MainTabVC(), options: UIWindow.TransitionOptions(direction: .toLeft, style: .easeIn), slide_direction: .fromLeftToRight)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        ShareData.chat_status = false
    }

}

extension MainChatMsgVC
{
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let endFrameY = endFrame?.origin.y ?? 0
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if endFrameY >= UIScreen.main.bounds.size.height {
                self.keyboardHeightLayoutConstraint?.constant = 0.0
            } else {
                
                self.keyboardHeightLayoutConstraint?.constant = (endFrame?.size.height as! CGFloat * -1 + 40) ?? 0.0
                self.collectionView.scrollToLast()
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded()
                            self.viewWillAppear(true)
            },
                           completion: nil)
        }
    }
    
    @objc func reloadTableData(_ notification: Notification) {
        
        collectionView.reloadData()
        self.collectionView.scrollToLast()
        
    }
    
    func msgLoad(last_id: String)
    {
        var parmeters: [String: Any]!
        self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: progressDlg, color: .darkGray, fadeInAnimation: nil)
        if last_id == nil || last_id == ""
        {
            parmeters = ["sender_id": ShareData.user_info.id!, "receiver_id": ShareData.selected_chat.profile.id!] as [String: Any]
        }
        else
        {
            parmeters = ["sender_id": ShareData.user_info.id, "receiver_id": ShareData.selected_chat.profile.id!, "last_msg_id": last_id] as [String: Any]
            
        }
        
        CommonFuncs().createRequest(false, "message/detail", "POST", parmeters, completionHandler: {data in
            
            let status = data["status"] as! Bool
            let message = data["message"] as! String
            
            DispatchQueue.main.async {
                
                self.stopAnimating(nil)
                
                if status
                {
                    
                    if let messages = data["data"]
                    {
                        if let temp = Mapper<MessageMDL>().mapArray(JSONObject: messages)
                        {
                            ShareData.chat_msg_list.append(contentsOf: temp)
                            ShareData.chat_msg_list = ShareData.chat_msg_list.sorted(by: {$0.message.time! < $1.message.time!})
                        }
                        
                    }
                    
                    self.collectionView.reloadData()
                    
                    if last_id == nil || last_id == ""
                    {
                        self.collectionView.scrollToLast()
                    }
                }
                else
                {
                    self.all_msg_status = true
                    self.load_more_btn.isHidden = true
                    CommonFuncs().doneAlert(ShareData.appTitle, message, "CLOSE", {})
                }
                
            }
        })
    }
    
    
    @objc func countTime() {
        
        if counter_status
        {
            let sec = String(format: "%02d", Int(record_counter % 60))
            let min = String(format: "%02d", Int(record_counter / 60))
            record_time_label.text = "\(min) : \(sec)"
            
            if isRecording
            {
                record_counter += 1
                perform(#selector(countTime), with: nil, afterDelay: 1.0)
            }
            else
            {
                
                if record_counter == 0
                {
                    counter_status = false
                    audioPlayer!.stop()
                    audioPlayer = nil
                    self.record_frame.isHidden = true
                    self.collectionView.alpha = 1
                }
                else
                {
                    record_counter = record_counter - 1
                    perform(#selector(countTime), with: nil, afterDelay: 1.0)
                }
            }
        }
    }
    
    
    func msgSendAction()
    {
        if msg_in.text! != "" && msg_in.text! != nil
        {
            
            
            if ShareData.user_or_influencer
            {
                
                
                if Int(ShareData.user_info.popcoin_num!)! < coin_num
                {
                    CommonFuncs().selectAlert(ShareData.appTitle, "You don`t have enough PopCoin to send message(need more \(coin_num - Int(ShareData.user_info.popcoin_num!)!)). Do you want to buy PopCoin?", 2, ["BUY NOW", "CANCEL"], [Utility.color(withHexString: ShareData.btn_color), UIColor.gray], [UIColor.white, UIColor.white], self, [#selector(coinBuyOkAction(_:)), #selector(coinBuyCancelAction(_:))])
                    return
                }
                else
                {
                    CommonFuncs().selectAlert(ShareData.appTitle, "Do you want to send message?", 2, ["SEND NOW", "CANCEL"], [Utility.color(withHexString: ShareData.btn_color), UIColor.gray], [UIColor.white, UIColor.white], self, [#selector(msgSendConfirmAction(_:)), #selector(msgSendCancelAction(_:))])
                }
                
                
            }
            else
            {
                parmeters = ["sender_id": ShareData.user_info.id!, "receiver_id": ShareData.selected_chat.message.sender_id!, "message": self.msg_in.text!, "send_time": CommonFuncs().currentTime(), "time_zone": ShareData.user_info.time_zone!] as [String: Any]
                
                msgSendFunc()
            }
            
            
        }
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
    
    @objc func msgSendConfirmAction(_ sender: UIButton) {
        
        if self.msg_type == "txt"
        {
            parmeters = ["sender_id": ShareData.user_info.id!, "receiver_id": ShareData.selected_chat.message.sender_id!, "message": self.msg_in.text!, "send_time": CommonFuncs().currentTime(), "time_zone": ShareData.user_info.time_zone!, "msg_fee": "\(coin_num)"] as [String: Any]
        }
        else
        {
            parmeters = ["sender_id": ShareData.user_info.id!, "receiver_id": ShareData.selected_chat.message.sender_id!, "send_time": CommonFuncs().currentTime(), "time_zone": ShareData.user_info.time_zone!, "msg_fee": "\(coin_num)"] as [String: Any]
        }
        
        
        
        msgSendFunc()
    }
    
    @objc func msgSendCancelAction(_ sender: UIButton) {
        
        return
    }
    
    func msgSendFunc()
    {
        
        self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: progressDlg, color: .darkGray, fadeInAnimation: nil)
        
        if self.msg_type == "txt"
        {
            self.send_btn.isUserInteractionEnabled = false
            
            CommonFuncs().createRequest(false, "message/send", "POST", parmeters, completionHandler: {data in
                
                let status = data["status"] as! Bool
                let status_message = data["message"] as! String
                
                DispatchQueue.main.async {
                    
                    self.msg_in.resignFirstResponder()
                    self.send_btn.isUserInteractionEnabled = true
                    self.msg_in.text = ""
                    
                    self.stopAnimating(nil)
                    
                    if status
                    {
                        
                        if let temp = Mapper<MessageMDL>().map(JSONObject: data["data"])
                        {
                            ShareData.chat_msg_list.append(temp)
                            
                        }
                        
                        if ShareData.user_or_influencer
                        {
                            let new_coin_num = Int(ShareData.user_info.popcoin_num)! - self.coin_num
                            ShareData.user_info.popcoin_num = "\(new_coin_num)"
                        }
                        
                        self.msg_in.text = ""
                        
                        self.collectionView.reloadData()
                        self.collectionView.scrollToLast()
                        
                    }
                    else
                    {
                        CommonFuncs().doneAlert(ShareData.appTitle, status_message, "CLOSE", {})
                    }
                    
                }
            })
        }
        else if self.msg_type == "sound"
        {
            let url = URL(string: "\(ShareData.main_url)message/file.php")!
            
            Alamofire.upload(multipartFormData: { (multiPartFormData: MultipartFormData) in
                for (key, value) in self.parmeters as! [String: String] {
                    multiPartFormData.append((value as String).data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, withName: key)
                }
                
                multiPartFormData.append(self.audioData as! Data, withName: "upload_voice", fileName: "upload_voice", mimeType: "audio/m4a")
                
                
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
                            
                            
                            self.record_btn.isUserInteractionEnabled = true
                            self.photo_btn.isUserInteractionEnabled = true
                            self.record_frame.isHidden = true
                            self.collectionView.alpha = 1
                            self.msg_in.resignFirstResponder()
                            
                            self.stopAnimating(nil)
                            
                            if status
                            {
                                if let temp = Mapper<MessageMDL>().map(JSONObject: dictData["data"])
                                {
                                    ShareData.chat_msg_list.append(temp)
                                    
                                }
                                
                                if ShareData.user_or_influencer
                                {
                                    let new_coin_num = Int(ShareData.user_info.popcoin_num)! - self.coin_num
                                    ShareData.user_info.popcoin_num = "\(new_coin_num)"
                                }
                                
                                self.collectionView.reloadData()
                                self.collectionView.scrollToLast()
                                
                            }
                            else
                            {
                                
                                CommonFuncs().doneAlert(ShareData.appTitle, message, "CLOSE", {})
                                
                            }
                            
                            self.send_btn.isUserInteractionEnabled = true
                        }
                        
                    })
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        else
        {
            let url = URL(string: "\(ShareData.main_url)message/file.php")!
            
            Alamofire.upload(multipartFormData: { (multiPartFormData: MultipartFormData) in
                for (key, value) in self.parmeters as! [String: String] {
                    multiPartFormData.append((value as String).data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, withName: key)
                }
                
                multiPartFormData.append(self.new_photo! as Data, withName: "upload_img", fileName: "upload_img", mimeType: "image/png")
                
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
                            
                            self.msg_in.resignFirstResponder()
                            self.record_btn.isUserInteractionEnabled = true
                            self.photo_btn.isUserInteractionEnabled = true
                            
                            self.stopAnimating(nil)
                            
                            if status
                            {
                                let msg_data = dictData["data"] as! [String: Any]
                                
                                if let temp = Mapper<MessageMDL>().map(JSONObject: dictData["data"])
                                {
                                    ShareData.chat_msg_list.append(temp)
                                }
                                
                                if ShareData.user_or_influencer
                                {
                                    let new_coin_num = Int(ShareData.user_info.popcoin_num)! - self.coin_num
                                    ShareData.user_info.popcoin_num = "\(new_coin_num)"
                                }
                                
                                self.collectionView.reloadData()
                                self.collectionView.scrollToLast()
                                
                            }
                            else
                            {
                                
                                CommonFuncs().doneAlert(ShareData.appTitle, message, "CLOSE", {})
                            }
                            
                            self.send_btn.isUserInteractionEnabled = true
                        }
                        
                    })
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        
    }
}


extension MainChatMsgVC: UITextViewDelegate, UITextFieldDelegate
{
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
       
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.characters.count
        return numberOfChars < 300
        
    }
    
    
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        msg_in.text = ""
        let sender_id = ShareData.user_info.id!
        let receiver_id = ShareData.selected_chat.message.sender_id!
        
        let parmeters = ["sender_id": sender_id, "receiver_id": receiver_id] as [String: Any]
        
        CommonFuncs().createRequest(false, "message/start", "POST", parmeters, completionHandler: {_ in })
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        if textView.text.contains("\n")
        {
            let str = textView.text!
            textView.text = str.substring(to: str.index(before: str.endIndex))
            
            self.msgSendAction()
            
            self.input_frame_height.constant = 45
            msg_in_frame_height.constant = 35
            msg_in_height.constant = 30
        }
        else
        {
            var height = CommonFuncs().getStringHeight(msg_in.text!, 14, msg_in.frame.width, 10, 15)
            height = height > 30 ? height:30
            print(height)
            msg_in_height.constant = height
            msg_in_frame_height.constant = height + 5
            input_frame_height.constant = height + 15
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if coin_buy_status
        {
            coin_in.resignFirstResponder()
        }
        
        return true
    }
}


extension MainChatMsgVC: AVAudioRecorderDelegate, AVAudioPlayerDelegate
{
    
    func AudioRecordingPermission() {
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord, mode: AVAudioSessionModeDefault, options: AVAudioSessionCategoryOptions.defaultToSpeaker)
            
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        print("Allow")
                    } else {
                        print("Dont Allow")
                        AVAudioSession.sharedInstance().requestRecordPermission({ (granted) -> Void in
                            
                            if !granted {
                                let microphoneAccessAlert = UIAlertController(title: "chatterli", message: "Microphone permission access is not granted. Please allow from setting", preferredStyle: UIAlertController.Style.alert)
                                
                                let okAction = UIAlertAction(title: NSLocalizedString("Settings",comment:""), style: UIAlertAction.Style.default, handler: { (alert: UIAlertAction!) -> Void in
                                    UIApplication.shared.openURL(NSURL(string: UIApplicationOpenSettingsURLString)! as URL)
                                })
                                
                                let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel",comment:""), style: UIAlertAction.Style.cancel, handler: { (alert: UIAlertAction!) -> Void in
                                })
                                microphoneAccessAlert.addAction(okAction)
                                microphoneAccessAlert.addAction(cancelAction)
                                self.present(microphoneAccessAlert, animated: true, completion: nil)
                                return
                            }
                        });
                    }
                }
            }
        } catch {
            print("failed to record!")
        }
        // Audio Settings
        settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
    }
    
    
    func directoryURL() -> NSURL?
    {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as NSURL
        let soundURL = documentDirectory.appendingPathComponent("question.m4a")
        return soundURL as NSURL?
    }
    
}


extension MainChatMsgVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate
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
        self.new_photo = UIImagePNGRepresentation(img)  as! NSData
        
        self.msg_type = "img"
        
        if ShareData.user_or_influencer
        {
            
            if Int(ShareData.user_info.popcoin_num!)! < coin_num
            {
                CommonFuncs().selectAlert(ShareData.appTitle, "You don`t have enough PopCoin to send image(need more \(coin_num - Int(ShareData.user_info.popcoin_num!)!)). Do you want to buy PopCoin?", 2, ["BUY NOW", "CANCEL"], [Utility.color(withHexString: ShareData.btn_color), UIColor.gray], [UIColor.white, UIColor.white], self, [#selector(coinBuyOkAction(_:)), #selector(coinBuyCancelAction(_:))])
                return
            }
            else
            {
                CommonFuncs().selectAlert(ShareData.appTitle, "Do you want to send image?", 2, ["SEND NOW", "CANCEL"], [Utility.color(withHexString: ShareData.btn_color), UIColor.gray], [UIColor.white, UIColor.white], self, [#selector(msgSendConfirmAction(_:)), #selector(msgSendCancelAction(_:))])
            }
            
            
        }
        else
        {
            parmeters = ["sender_id": ShareData.user_info.id!, "receiver_id": ShareData.selected_chat.message.sender_id!, "send_time": CommonFuncs().currentTime(), "time_zone": ShareData.user_info.time_zone!] as [String: Any]
            
            msgSendFunc()
        }
        
        picker.dismiss(animated:true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        dismiss(animated: true, completion: nil)
    }
    
}



extension MainChatMsgVC: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {        
        
        return ShareData.chat_msg_list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if ShareData.chat_msg_list[indexPath.row].message.message!.contains("upload/image")
        {
            return CGSize(width: UIScreen.main.bounds.width, height: 130)
        }
        else if ShareData.chat_msg_list[indexPath.row].message.message!.contains("upload/voice")
        {
            return CGSize(width: UIScreen.main.bounds.width, height: 100)
        }
        else
        {
            
            return CGSize(width: UIScreen.main.bounds.width, height: CommonFuncs().getStringHeight(ShareData.chat_msg_list[indexPath.row].message.message!, 15, msgDefaultWidth, 10, 10) + 27)
        }
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "ChatMsgCell", for: indexPath) as! ChatMsgCell
        
        cell.selectedBackgroundView?.isHidden = true
        
        let data = ShareData.chat_msg_list[indexPath.row]
        var time_str = ""
        if data.message.sender_id! == ShareData.user_info.id!
        {
            time_str = CommonFuncs().historyTime(data.message.time!, ShareData.user_info.time_zone!)
        }
        else
        {
            time_str = CommonFuncs().historyTime(data.message.time!, ShareData.selected_chat.profile.time_zone!)
        }
        
        let time_str_width = time_str.widthOfString(font: UIFont.systemFont(ofSize: 12))
        let time_str_height = time_str.heightOfString(font: UIFont.systemFont(ofSize: 12))
        
        cell.time.text = time_str
        
        if data.message.message!.contains("upload/image")
        {
            
            cell.msg_img.isHidden = false
            cell.msg_img.contentMode = .scaleToFill
            cell.isUserInteractionEnabled = true
            
            if data.message.sender_id! == ShareData.user_info.id!
            {
                cell.image.isHidden = true
                
                cell.msg_img.frame = CGRect(x: cell.frame.width - 140, y: 5, width: 130, height: 110)
                cell.time.frame = CGRect(x: cell.msg_img.frame.maxX - time_str_width - 5, y: cell.msg_img.frame.maxY + 2, width: time_str_width, height: time_str_height)
                cell.time.textAlignment = .right
            }
            else
            {
                cell.image.isHidden = false
                cell.image.frame = CGRect(x: 5, y: 10, width: 25, height: 25)
                cell.image.layer.cornerRadius = cell.image.frame.width / 2
                cell.image.clipsToBounds = true
                cell.image.load(url: ShareData.selected_chat.profile.photo!)
                cell.msg_img.frame = CGRect(x: 40, y: 0, width: 130, height: 110)
                cell.time.frame = CGRect(x: cell.msg_img.frame.minX + 5, y: cell.msg_img.frame.maxY + 2, width: time_str_width, height: time_str_height)
                cell.time.textAlignment = .left
            }
            
            cell.msg_img.load(url: data.message.message!)
            cell.background.isHidden = true
            cell.msg.isHidden = true
        }
        else if data.message.message!.contains("upload/voice")
        {
            
            cell.msg_img.isHidden = false
            
            cell.isUserInteractionEnabled = true
            
            if data.message.sender_id! == ShareData.user_info.id!
            {
                cell.image.isHidden = true
                cell.msg_img.frame = CGRect(x: cell.frame.width - 50, y: 5, width: 40, height: 70)
                cell.time.frame = CGRect(x: cell.msg_img.frame.maxX - time_str_width - 5, y: cell.msg_img.frame.maxY + 2, width: time_str_width, height: time_str_height)
                cell.time.textAlignment = .right
            }
            else
            {
                cell.image.isHidden = false
                cell.image.frame = CGRect(x: 5, y: 10, width: 25, height: 25)
                cell.image.layer.cornerRadius = cell.image.frame.width / 2
                cell.image.clipsToBounds = true
                cell.image.load(url: ShareData.selected_chat.profile.photo!)
                cell.msg_img.frame = CGRect(x: 40, y: 0, width: 40, height: 70)
                cell.time.frame = CGRect(x: cell.msg_img.frame.minX + 5, y: cell.msg_img.frame.maxY + 2, width: time_str_width, height: time_str_height)
                cell.time.textAlignment = .left
            }
            
            cell.image.backgroundColor = UIColor.gray
            let image = UIImage.init(named: "microphone")?.withRenderingMode(.alwaysTemplate)
            cell.msg_img.sd_setImage(with: URL(string: ""), placeholderImage: image)
            cell.background.isHidden = true
            cell.msg.isHidden = true
        }
        else if data.message.message!.contains("xxx//typing")
        {
            
            cell.msg_img.isHidden = false
            
            cell.isUserInteractionEnabled = true
            
            cell.image.isHidden = false
            cell.image.frame = CGRect(x: 5, y: 10, width: 25, height: 25)
            cell.image.layer.cornerRadius = cell.image.frame.width / 2
            cell.image.clipsToBounds = true
            cell.image.load(url: ShareData.selected_chat.profile.photo!)
            
            cell.image.backgroundColor = UIColor.gray
            
            cell.time.isHidden = true
            cell.background.isHidden = true
            cell.msg.isHidden = true
            
            cell.msg_img.frame = CGRect(x: 45, y: 10, width: 30, height: 30)
            cell.msg_img.contentMode = .scaleToFill
            cell.msg_img.loadGif(name: "msg_typing")
        }
        else
        {
            cell.isUserInteractionEnabled = false
            cell.background.isHidden = false
            cell.msg.isHidden = false
            
            var width = data.message.message!.widthOfString(font: UIFont.systemFont(ofSize: 15))
            width = width < msgDefaultWidth ? width:msgDefaultWidth
            let height = CommonFuncs().getStringHeight(data.message.message!, 15, msgDefaultWidth, 10, 10)
            
            var frame = CGRect()
            
            if data.message.sender_id! == ShareData.user_info.id!
            {
                cell.image.isHidden = true
                
                cell.background.frame = CGRect(x: cell.frame.width - width - 20, y: 0, width: width + 10, height: height + 10)
                cell.background.roundCorners(corners: [.topLeft, .topRight, .bottomLeft], radius: 12)
                cell.background.clipsToBounds = true
                cell.background.backgroundColor = Utility.color(withHexString: "143755")
                cell.background.layer.borderWidth = 1
                cell.background.layer.borderColor = UIColor.gray.cgColor
                cell.background.dropShadow(color: .gray, opacity: 0.8, offSet: CGSize.zero, radius: 3, scale: true)
                
                frame = CGRect(x: cell.frame.width - width - 15, y: 5, width: width, height: height)
                cell.time.frame = CGRect(x: cell.background.frame.maxX - time_str_width - 5, y: cell.background.frame.maxY + 2, width: time_str_width, height: time_str_height)
                cell.time.textAlignment = .right
                cell.msg.textColor = UIColor.white
            }
            else
            {
                cell.image.isHidden = false
                cell.image.frame = CGRect(x: 5, y: height - 15, width: 25, height: 25)
                cell.image.layer.cornerRadius = cell.image.frame.width / 2
                cell.image.clipsToBounds = true
                
                cell.image.load(url: ShareData.selected_chat.profile.photo!)
                
                cell.background.frame = CGRect(x: 40, y: 0, width: width + 10, height: height + 10)
                cell.background.layer.cornerRadius = 10
                cell.background.layer.borderColor = UIColor.gray.cgColor
                cell.background.layer.borderWidth = 1

                
                if #available(iOS 11.0, *) {
                    cell.background.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
                } else {
                    // Fallback on earlier versions
                }
                cell.background.dropShadow(color: .gray, opacity: 0.8, offSet: CGSize.zero, radius: 1, scale: true)
                
                frame = CGRect(x: 45, y: 5, width: width, height: height)
                cell.time.frame = CGRect(x: cell.background.frame.minX + 5, y: cell.background.frame.maxY + 2, width: time_str_width, height: time_str_height)
                cell.time.textAlignment = .left
                cell.msg.textColor = UIColor.darkGray
            }
            
            cell.msg.frame = frame
            
            cell.msg_img.isHidden = true
            
            cell.msg.text = data.message.message!
            cell.time.text = time_str
            
        }
        
        return cell
        
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if ShareData.chat_msg_list[indexPath.row].message.message!.contains("upload/image")
        {
            collectionView.alpha = 0.05
            selected_msg_frame.isHidden = false
            selected_msg_img.load(url: "\(ShareData.chat_msg_list[indexPath.row].message.message!)" )
        }
        else if ShareData.chat_msg_list[indexPath.row].message.message!.contains("upload/voice")
        {
            
            let imgURL:String = "\(ShareData.main_url)\(ShareData.chat_msg_list[indexPath.row].message.message!)"
            if let url = URL(string: imgURL)
            {
                if let data = try? Data(contentsOf: url) {
                    
                    do{
                        
                        record_frame.isHidden = false
                        collectionView.alpha = 0.05
                        record_save_btn.isHidden = true
                        self.isRecording = false
                        
                        try audioPlayer = AVAudioPlayer(data: data)
                        
                        audioPlayer!.delegate = self
                        audioPlayer!.prepareToPlay()
                        
                        record_counter = Int(audioPlayer.duration)
                        let sec = String(format: "%02d", Int(record_counter % 60))
                        let min = String(format: "%02d", Int(record_counter / 60))
                        record_time_label.text = "\(min) : \(sec)"
                        counter_status = true
                        perform(#selector(countTime), with: nil, afterDelay: 1.0)
                        audioPlayer!.play()
                        
                        audioPlayer.volume = 1.0
                    }
                    catch let error as NSError
                    {
                        print("audioPlayer error: \(error.localizedDescription)")
                    }
                    
                    
                }
            }
            
        }
    }
}




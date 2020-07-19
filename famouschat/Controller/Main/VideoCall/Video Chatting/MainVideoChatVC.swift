//
//  MainVideoChatVC.swift
//  famouschat
//
//  Created by T-Tech Solutions LLC on 07/11/2018.
//  Copyright © 2018 T-Tech Solutions LLC. All rights reserved.
//

import UIKit
import UserNotifications
import MBCircularProgressBar
import Quickblox
import QuickbloxWebRTC

class MainVideoChatVC: UIViewController {

    @IBOutlet weak var chat_title: UILabel!
    @IBOutlet weak var photo_you: UIView!
    @IBOutlet weak var other_view: QBRTCRemoteVideoView!
    
    @IBOutlet weak var photo_me: UIView!
    @IBOutlet weak var self_view: UIView!
    
    @IBOutlet weak var switch_btn: UIButton!
    @IBOutlet weak var end_btn: UIButton!
    @IBOutlet weak var remain_time: UILabel!
    @IBOutlet weak var more_frame: UIView!
    @IBOutlet weak var more_time_picker: UIPickerView!
    @IBOutlet weak var more_time_money: UILabel!
    @IBOutlet weak var more_buy_btn: UIButton!
    @IBOutlet weak var more_cancel_btn: UIButton!
    
    @IBOutlet weak var time_cnt_frame: UIView!
    @IBOutlet weak var time_counter: MBCircularProgressBarView!
    @IBOutlet weak var time_cnt_label: UILabel!
    
    var videoCapture:QBRTCCameraCapture?
    var isCommingFromInfluencer:Bool = true
    private var screenCapture: ScreenCapture?
    private var cameraCapture: QBRTCCameraCapture?
    var fee_rate: Double = 0
    
    let more_time_array = ["1", "3", "5", "10", "15", "20", "30"]
    var more_time = 5
    
    struct time_modal {
        
        var h: String = ""
        var m: String = ""
        var s: String = ""
        
        init(h: String, m: String, s: String) {
            
            self.h = h
            self.m = m
            self.s = s
        }
    }
    
    var duration = time_modal(h: "0", m: "1", s: "06")
    
    var time = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var formater = DateFormatter()
        formater.dateFormat = "yyyy-MM-dd-hh-mm"
        let time_str = formater.date(from: ShareData.selected_book.book.time!)!
        
        let calendar = Calendar.current
        let weekDay = calendar.component(.weekday, from: time_str) as! Int - 1
        
        let array2 = CommonFuncs().splitString(ShareData.selected_book.profile.chat_rate!.characters.split(separator: ",").map(String.init)[weekDay])
        fee_rate = (Double(array2[2])! + Double(array2[3])! / 100) / (Double(array2[0])! * 60 + Double(array2[1])!)
        
        init_UI()
        
        setCallBacks()
        
        QuickBloxHelper.sharedInstance.toggleSpeaker(mode: true)
    }

    func init_UI()
    {
        self.navigationController?.isNavigationBarHidden = true
        
        let data = ShareData.selected_book!
        
        chat_title.text = "Chat with " + data.profile.name!
        
        photo_me.layer.cornerRadius = photo_me.frame.width / 2
        photo_me.layer.borderColor = UIColor.green.cgColor
        photo_me.layer.borderWidth = 2
        photo_me.clipsToBounds = true
        
        let image = UIImage.init(named: "camera_switch")!.withRenderingMode(.alwaysTemplate)
        switch_btn.setImage(image, for: .normal)
        switch_btn.tintColor = UIColor.blue
        
        duration = time_modal(h: "00", m: "\(data.book.duration!)", s: "00")
        
        var duration_txt = ""
        if duration.h != "0"
        {
            duration_txt = "\(duration.h)h : \(duration.m)m : \(duration.s)s"
            time = Int(duration.h)! * 3600 + Int(duration.m)! * 60 + Int(duration.s)!
        }
        else
        {
            if duration.m != "0"
            {
                duration_txt = "\(duration.m)m : \(duration.s)s"
                time = Int(duration.m)! * 60 + Int(duration.s)!
            }
            else
            {
                duration_txt = "\(duration.s)s"
                time = Int(duration.s)!
            }
        }
        
        var attributedString1 = NSMutableAttributedString(string:"")
        
        let attrs1 = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: CGFloat(13.0)), NSAttributedStringKey.foregroundColor: UIColor.white] as [NSAttributedStringKey : Any]
        
        let numString = NSMutableAttributedString(string: "Time Remaining  ", attributes:attrs1)
        if time > 30
        {
            let attrs2 = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: CGFloat(13.0)), NSAttributedStringKey.foregroundColor: UIColor.white] as [NSAttributedStringKey : Any]
            var txtString = NSMutableAttributedString(string: duration_txt, attributes:attrs2)
            attributedString1.append(numString)
            attributedString1.append(txtString)
        }
        else
        {
            let attrs2 = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: CGFloat(13.0)), NSAttributedStringKey.foregroundColor: UIColor.red] as [NSAttributedStringKey : Any]
            var txtString = NSMutableAttributedString(string: duration_txt, attributes:attrs2)
            attributedString1.append(numString)
            attributedString1.append(txtString)
        }
        
        remain_time.attributedText = attributedString1
        remain_time.textColor = UIColor.white
        
        perform(#selector(countTime), with: nil, afterDelay: 1.0)
        
        more_frame.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        more_frame.clipsToBounds = true
        more_frame.dropShadow(color: Utility.color(withHexString: ShareData.btn_color), opacity: 1, offSet: CGSize.zero, radius: 5, scale: true)
        more_buy_btn.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        more_buy_btn.clipsToBounds = true
        more_buy_btn.dropShadow(color: .white, opacity: 0.8, offSet: CGSize.zero, radius: 3, scale: true)
        more_cancel_btn.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        more_cancel_btn.clipsToBounds = true
        more_cancel_btn.dropShadow(color: .white, opacity: 0.8, offSet: CGSize.zero, radius: 3, scale: true)
        more_time_picker.dataSource = self
        more_time_picker.delegate = self
        more_time_picker.selectRow(2, inComponent: 0, animated: true)
        more_frame.isHidden = true
        
        time_cnt_frame.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        time_cnt_frame.clipsToBounds = true
        
        time_cnt_frame.dropShadow(color: Utility.color(withHexString: ShareData.btn_color), opacity: 1, offSet: CGSize.zero, radius: 5, scale: true)
        time_counter.progressAngle = 100
        time_counter.maxValue = 60
        time_counter.value = 60
        
        time_cnt_frame.isHidden = true
        
        
        let videoFormat = QBRTCVideoFormat.init()
        videoFormat.frameRate = 30
        videoFormat.pixelFormat = QBRTCPixelFormat.format420f
        videoFormat.width = 640
        videoFormat.height = 480
        
        self.videoCapture = QBRTCCameraCapture.init(videoFormat: videoFormat, position: AVCaptureDevice.Position.front)
        
        if let session = QuickBloxHelper.getCurrentSession()
        {
            session.localMediaStream.videoTrack.videoCapture = self.videoCapture
            
            self.videoCapture!.previewLayer.frame = self.self_view.bounds
            self.videoCapture!.startSession()
            
            self.self_view.layer.insertSublayer(self.videoCapture!.previewLayer, at: 0)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(timeAdded), name: .time_added, object: nil)
    }
    
    
    @IBAction func switchAction(_ sender: Any) {
        
        guard let cameraCapture = self.videoCapture else {
            return
        }
        let newPosition: AVCaptureDevice.Position = cameraCapture.position == .back ? .front : .back
        guard cameraCapture.hasCamera(for: newPosition) == true else {
            return
        }
        
        cameraCapture.position = newPosition
        
    }
    
    
    
    @IBAction func hangUp(_ sender: Any) {
        
        self.callEnd()
        
    }
    
    @IBAction func timeAddAction(_ sender: Any) {
        
        more_frame.isHidden = false
        time_cnt_frame.isHidden = true
        
        more_time_money.text = "$\(String(format: "%.02f", Double(fee_rate) * Double(more_time)))"
        
    }
    
    @IBAction func moreBuyAction(_ sender: Any) {
        
                
        let coin_num = Int(Double(fee_rate) * Double(more_time) / Double(ShareData.app_config.popcoin_price!)!)
        
        let send_time = CommonFuncs().currentTime()
        
        let parmeters = ["book_id": ShareData.selected_book.book.id!, "add_time": "\(more_time)", "popcoin": "\(coin_num)", "time": send_time, "time_zone": ShareData.user_info.time_zone!] as [String: Any]
        
        
        CommonFuncs().createRequest(false, "book/add_time", "POST", parmeters, completionHandler: {data in
            
            let status = data["status"] as! Bool
            let message = data["message"] as! String
            
            DispatchQueue.main.async {
                
                
                self.more_frame.isHidden = true
                
                if status
                {
                    self.time += self.more_time * 60
                }
                else
                {
                   CommonFuncs().doneAlert(ShareData.appTitle, "You can not add more time", "CLOSE", {})
                }
                
            }
        })
        
    }
    
    @IBAction func moreCancelAction(_ sender: Any) {
        
        more_frame.isHidden = true
        time_cnt_frame.isHidden = false
    }
    
}


extension MainVideoChatVC
{
    
    @objc func timeAdded(_ notification: Notification) {
        
        self.time += Int(ShareData.add_time)! * 60
        
    }
    
    @objc func countTime() {
        
        time = time - 1
        let h = time / 3600
        let m = (time % 3600) / 60
        let s = time % 60
        
        var duration_txt = ""
        if h != 0
        {
            
            duration_txt = "\(h)h : \(m)m : \(s)s"
        }
        else
        {
            if m != 0
            {
                duration_txt = "\(m)m : \(s)s"
            }
            else
            {
                duration_txt = "\(s)s"
            }
        }
        
        var attributedString1 = NSMutableAttributedString(string:"")
        
        let attrs1 = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: CGFloat(13.0)), NSAttributedStringKey.foregroundColor: UIColor.white] as [NSAttributedStringKey : Any]
        let numString = NSMutableAttributedString(string: "Time Remaining  ", attributes:attrs1)
        if time > 30
        {
            remain_time.attributedText = CommonFuncs().attributeString([UIFont.boldSystemFont(ofSize: 13), UIFont.systemFont(ofSize: 13)], [UIColor.white, UIColor.white], ["Time Remaining  ", duration_txt])
        }
        else
        {
            remain_time.attributedText = CommonFuncs().attributeString([UIFont.boldSystemFont(ofSize: 13), UIFont.systemFont(ofSize: 13)], [UIColor.white, UIColor.red], ["Time Remaining  ", duration_txt])
        }
        
        if !ShareData.video_chat_start_status
        {
            if time == 60
            {
                time_cnt_frame.isHidden = false
            }
            
            time_counter.value = CGFloat(time)
            time_cnt_label.text = duration_txt
        }
        
        if time > 0
        {
            perform(#selector(countTime), with: nil, afterDelay: 1.0)
        }
        else
        {
            time_cnt_frame.isHidden = true
            
            self.callEnd()
        }
    }
    
    func callEnd()
    {
        QuickBloxHelper.sharedInstance.endCall(remoteView: other_view)
        
        let send_time = CommonFuncs().currentTime()
        
        let parmeters = ["book_id": ShareData.selected_book.book.id!, "time": send_time, "time_zone": ShareData.user_info.time_zone!] as [String: Any]
        
        CommonFuncs().createRequest(false, "book/finish", "POST", parmeters, completionHandler: {data in
            
            let status = data["status"] as! Bool
            let message = data["message"] as! String
            
            DispatchQueue.main.async {
                
                self.navigationController?.pushViewController(MainVideoReviewVC(), animated: true)
                
            }
        })
        
    }
    
    
    func setCallBacks()
    {
        QuickBloxHelper.sharedInstance.callDidReceiveOpponentVideo = { (session:QBRTCBaseSession,videoTrack:QBRTCVideoTrack,opponentId:NSNumber) in
            
            self.screenCapture = ScreenCapture.init(view:self.view)
            self.other_view.setVideoTrack(videoTrack)
        }
    }
}


extension MainVideoChatVC: UIPickerViewDelegate, UIPickerViewDataSource
{
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        
        return more_time_array.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            
            pickerLabel?.textAlignment = .center
        }
        
        var str = more_time_array[row]
        pickerLabel?.font = UIFont.systemFont(ofSize: 17)
        
        pickerLabel?.text = str
        pickerLabel?.textColor = UIColor.white
        
        return pickerLabel!
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        var str = more_time_array[row]
        more_time = Int(str)!
        
        
        more_time_money.text = "$\(String(format: "%.02f", Double(fee_rate) * Double(more_time)))"
        
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        var str = more_time_array[row]
        more_time = Int(str)!
        
        more_time_money.text = "$\(String(format: "%.02f", Double(fee_rate) * Double(more_time)))"
        
        return str
    }
    
}

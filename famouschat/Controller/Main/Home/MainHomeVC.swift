//
//  MainHomeVC.swift
//  famouschat
//
//  Created by T-Tech Solutions LLC on 06/11/2018.
//  Copyright © 2018 T-Tech Solutions LLC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import ObjectMapper
import SCLAlertView

class MainHomeVC: UIViewController, NVActivityIndicatorViewable, UIWebViewDelegate {
    
    let progressDlg = ShareData.progressDlgs[ShareData.progress_index]
    @IBOutlet weak var menu_img: UIImageView!
    @IBOutlet weak var menu_btn: UIButton!
    @IBOutlet weak var hello_label: UILabel!
    @IBOutlet weak var profile_name: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bell_notification_frame: UIView!
    @IBOutlet weak var feed_num_frame: UIView!
    @IBOutlet weak var feed_num_label: UILabel!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var post_field: UITextField!
    
    @IBOutlet weak var video_view_frame: UIView!
    @IBOutlet weak var video_view: VideoView!
    @IBOutlet weak var video_panel_view: UIView!
    @IBOutlet weak var video_replay_btn: UIButton!
    @IBOutlet weak var video_pause_btn: UIButton!
    @IBOutlet weak var video_close_btn: UIButton!
    
    var isHiddenNotification = true
    
    
    var alert_status = false
    var selected_feed: FeedMDL!
    var selected_index = 0
    
    var video_paused = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        init_UI()
    }
    
    
    
    func init_UI()
    {
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.isToolbarHidden = true
        
        let menu_image = UIImage.init(named: "menu")!.withRenderingMode(.alwaysTemplate)
        menu_img.image = menu_image
        menu_img.tintColor = UIColor.white
        
        
        menu_btn.addTarget(self.slideMenuController, action: #selector(slideMenuController.toggleMenuAnimated(_:)), for: .touchUpInside)
        
        
        let time = Int(CommonFuncs().splitString(CommonFuncs().currentTime())[3])!
       
        hello_label.text = "Welcome,"
        
        
        profile_name.text = ShareData.user_info.name!
        
        feed_num_frame.layer.cornerRadius = feed_num_frame.frame.width / 2
        feed_num_frame.clipsToBounds = true
        
        feed_num_label.text = "88"
        
        post_field.layer.cornerRadius = post_field.frame.height / 2
        post_field.layer.borderColor = Utility.color(withHexString: ShareData.btn_color).cgColor
        post_field.layer.borderWidth = 1
        post_field.clipsToBounds = true
        post_field.textColor = Utility.color(withHexString: ShareData.btn_color)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TrendCell", bundle: nil), forCellReuseIdentifier: "TrendCell")
//        tableView.register(UINib(nibName: "FeedPhotoCell", bundle: nil), forCellReuseIdentifier: "FeedPhotoCell")
//        tableView.register(UINib(nibName: "FeedWarnCell", bundle: nil), forCellReuseIdentifier: "FeedWarnCell")
//        tableView.register(UINib(nibName: "FeedPromotionCell", bundle: nil), forCellReuseIdentifier: "FeedPromotionCell")
        tableView.separatorColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        
        feed_num_label.text = "\(ShareData.feeds.count)"
        
        video_view_frame.isHidden = true
        
        video_panel_view.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        
        var image = UIImage.init(named: "video_replay")?.withRenderingMode(.alwaysTemplate)
        video_replay_btn.setImage(image, for: .normal)
        video_replay_btn.tintColor = UIColor.white
        
        image = UIImage.init(named: "video_play")?.withRenderingMode(.alwaysTemplate)
        video_pause_btn.setImage(image, for: .normal)
        video_pause_btn.tintColor = UIColor.white
        
        image = UIImage.init(named: "video_close")?.withRenderingMode(.alwaysTemplate)
        video_close_btn.setImage(image, for: .normal)
        video_close_btn.tintColor = UIColor.white
        
        self.selectBell()
        
        
        
    }
    
    func selectBell()
    {
        webView.backgroundColor = UIColor.clear
        
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        
        let url = Bundle.main.url(forResource: "about_us", withExtension: "htm")
        let request = NSURLRequest.init(url: url!)
        webView.loadRequest(request as URLRequest)
        
//        webView.isHidden = false
//        tableView.isHidden = true
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.showNotificationAction))
        self.bell_notification_frame.addGestureRecognizer(gesture)

    }

    @objc func showNotificationAction(sender : UITapGestureRecognizer) {
        
        // goto notification screen
        
        
//        if isHiddenNotification
//        {
//            isHiddenNotification = !isHiddenNotification
//            self.showNotification()
//
//
//
//        } else {
//            isHiddenNotification = !isHiddenNotification
//            webView.isHidden = false
//            tableView.isHidden = true
//        }
        
        if ShareData.feeds.count != 0
        {
//            NotificationView.GlobalVariable.notificationCnt = feed_num_label.text!
            let notification = NotificationView(nibName: "NotificationView", bundle: nil)
            self.navigationController?.pushViewController(NotificationView(), animated: true)
            
        }
        
    }
    
    @IBAction func searchAction(_ sender: Any) {
        
        let parmeters = ["user_id": ShareData.user_info.id!, "category_key": "total"] as [String: Any]
        
        CommonFuncs().createRequest(true, "category", "POST", parmeters, completionHandler: {data in
            
            let status = data["status"] as! Bool
            let message = data["message"] as! String
            
            DispatchQueue.main.async {
                
                if status
                {
                    if let influencers = data["data"]
                    {
                        if let temp = Mapper<UserMDL>().mapArray(JSONObject: influencers)
                        {
                            ShareData.new_following_list = temp
                        }
                        
                    }
                    self.stopAnimating(nil)
                    let search = SearchUserInfuluencer(nibName: "SearchVC", bundle: nil)
                    
                    self.navigationController?.pushViewController(search, animated: true)
                }
                else
                {
                    self.stopAnimating(nil)
                    CommonFuncs().doneAlert(ShareData.appTitle, message, "CLOSE", {})
                }
            }
        })
        
        
    }
    func showNotification()
    {
        if ShareData.feeds.count == 0
        {
            webView.isHidden = false
            tableView.isHidden = true
        }
        else
        {
            webView.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !ShareData.msg_noti_status
        {
            ShareData.main_tab_index = 0
        }
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        feed_num_label.text = "\(ShareData.feeds.count)"
        
//        webView.isHidden = false
//        tableView.isHidden = true
        
        isHiddenNotification = true
    }
    
    @IBAction func videoClose(_ sender: Any) {
        
        video_view.stop()
        
        let parmeters = ["feed_id": selected_feed.id!, "time": CommonFuncs().currentTime(), "time_zone": ShareData.user_info.time_zone!] as [String: Any]
        
        self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: self.progressDlg, color: .white, fadeInAnimation: nil)
        
        CommonFuncs().createRequest(false, "book/video_seen", "POST", parmeters, completionHandler: {data in
            
            let status = data["status"] as! Bool
            let message = data["message"] as! String
            
            DispatchQueue.main.async {
                
                self.stopAnimating()
                self.feedRemove(index: self.selected_index)
                self.video_view_frame.isHidden = true
                
            }
        })
    }
    
    @IBAction func videoReplay(_ sender: Any) {
        
        video_view.stop()
        video_view.play()
        
        var image = UIImage.init(named: "video_pause")?.withRenderingMode(.alwaysTemplate)
        video_pause_btn.setImage(image, for: .normal)
        video_pause_btn.tintColor = UIColor.white
        video_paused = false
    }
    
    @IBAction func videoPause(_ sender: Any) {
        
        if self.video_paused
        {
            video_view.play()
            video_paused = false
            
            var image = UIImage.init(named: "video_pause")?.withRenderingMode(.alwaysTemplate)
            video_pause_btn.setImage(image, for: .normal)
            video_pause_btn.tintColor = UIColor.white
            
        }
        else
        {
            video_view.pause()
            video_paused = true
            
            var image = UIImage.init(named: "video_play")?.withRenderingMode(.alwaysTemplate)
            video_pause_btn.setImage(image, for: .normal)
            video_pause_btn.tintColor = UIColor.white
        }
        
    }
}

extension MainHomeVC: UITextFieldDelegate
{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
       
        return (true)
    }
    
}


extension MainHomeVC
{
    
    
    func feedRemove(index: Int)
    {
        let delete_id = ShareData.feeds[index].id!
        ShareData.feeds = ShareData.feeds.filter { $0.id != delete_id }
        self.tableView.beginUpdates()
        self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .middle)
        self.tableView.endUpdates()
        self.stopAnimating(nil)
        self.tableView.isUserInteractionEnabled = true
    }
    
    func feedDelete(id: String)
    {
        let num = feed_num_label.text!
        feed_num_label.text = "\(Int(num)! - 1)"
        let parmeters = ["feed_id": id] as [String: Any]
        self.tableView.isUserInteractionEnabled = false
        CommonFuncs().createRequest(false, "feed/delete", "POST", parmeters, completionHandler: {data in
            
        })
    }
    
}

extension MainHomeVC: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return ShareData.matched_influencers.count
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//
//        let data = ShareData.feeds[indexPath.row]
//        let array = self.feedDataProcess(data)
//
//        if data.type! == ShareData.feed_type().promotion
//        {
//
//            return CommonFuncs().getStringHeight(CommonFuncs().splitString(data.optional_value!)[2], 12, UIScreen.main.bounds.width, 80, 200)
//        }
//
//        if array[1] == "1"
//        {
//            return CommonFuncs().getStringHeight(array[0], 12, UIScreen.main.bounds.width, 80, 30)
//        }
//        else
//        {
//            return CommonFuncs().getStringHeight(array[0], 12, UIScreen.main.bounds.width, 80, 55)
//        }
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
//        let data = ShareData.feeds[indexPath.row]
//        let array = self.feedDataProcess(data)
//
//        if data.type! == ShareData.feed_type().promotion
//        {
//            let cell : FeedPromotionCell = tableView.dequeueReusableCell(withIdentifier: "FeedPromotionCell", for: indexPath) as! FeedPromotionCell
//
//            cell.backgroundColor = UIColor.clear
//            cell.contentView.backgroundColor = UIColor.clear
//            cell.selectionStyle = UITableViewCellSelectionStyle.none
//
//            cell.photo.load(url: data.photo!)
//            cell.photo.layer.cornerRadius = cell.photo.frame.width / 2
//            cell.photo.clipsToBounds = true
//            cell.name.text = data.name!
//            cell.time.backgroundColor = Utility.color(withHexString: ShareData.btn_color)
//            cell.time.layer.cornerRadius = 4
//            cell.time.clipsToBounds = true
//
//            let array = CommonFuncs().splitString(data.optional_value!)
//            cell.promotion_txt.text = array[2]
//            cell.promotion_img.load(url: array[0])
//
//            return cell
//
//        }
//
//        if array[1] == "1"
//        {
//            let cell : FeedWarnCell = tableView.dequeueReusableCell(withIdentifier: "FeedWarnCell", for: indexPath) as! FeedWarnCell
//
//            cell.backgroundColor = UIColor.clear
//            cell.contentView.backgroundColor = UIColor.clear
//            cell.selectionStyle = UITableViewCellSelectionStyle.none
//
//            cell.warn_view.backgroundColor = Utility.color(withHexString: "143755")
//            cell.warn_view.layer.cornerRadius = cell.warn_view.frame.height / 2
//            cell.warn_view.clipsToBounds = true
//
//            let attributedString = NSMutableAttributedString(string: array[0])
//            let paragraphStyle = NSMutableParagraphStyle()
//            paragraphStyle.lineSpacing = 5
//            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
//            cell.message.attributedText = attributedString
//
//            return cell
//        }
//        else
//        {
//            let cell : FeedPhotoCell = tableView.dequeueReusableCell(withIdentifier: "FeedPhotoCell", for: indexPath) as! FeedPhotoCell
//
//            cell.backgroundColor = UIColor.clear
//            cell.contentView.backgroundColor = UIColor.clear
//            cell.selectionStyle = UITableViewCellSelectionStyle.none
//
//            cell.photo.load(url: data.photo!)
//            cell.photo.layer.cornerRadius = cell.photo.frame.width / 2
//            cell.photo.clipsToBounds = true
//            cell.name.text = data.name!
//            cell.history.text = CommonFuncs().historyTime(data.time!, data.time_zone!)
//            cell.message.text = array[0]
//
//            return cell
//        }
        
        let cell : TrendCell = tableView.dequeueReusableCell(withIdentifier: "TrendCell", for: indexPath) as! TrendCell
         
        cell.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear
         
        cell.selectionStyle = UITableViewCellSelectionStyle.none
         
        var data: UserMDL!
        //var data2: FeedMDL!
         
//         if indexPath.section == 0
//         {
//             data = ShareData.top_influencers[indexPath.row]
//         }
//         else if indexPath.section == 1 && ShareData.following_influencers.count > 0
//         {
//             data = ShareData.following_influencers[indexPath.row]
//         }
//         else
//         {
//             data = ShareData.matched_influencers[indexPath.row]
//         }
        data = ShareData.matched_influencers[indexPath.row]
        //data2 = ShareData.feeds[indexPath.row]
        cell.photo.load(url: data.photo!)
        cell.photo.layer.cornerRadius = cell.photo.frame.width / 2
        cell.photo.clipsToBounds = true
         
        cell.name.text = data.name!
         
        var str = ""
         
        if data.category! != ""
        {
            if data.category!.contains(",")
            {
                let array = CommonFuncs().splitString(data.category!)
                 
                for i in 0..<array.count - 1
                {
                    str += "\(ShareData.category_list.filter{$0.id! == array[i]}[0].name!), "
                     
                }
                str += "\(ShareData.category_list.filter{$0.id! == array[array.count - 1]}[0].name!)"
            }
            else
            {
                str = ShareData.category_list.filter{$0.id! == data.category!}[0].name!
                 
            }
         }
        
        cell.category.text = str
        
        cell.bio.text = data.bio!
//        cell.like.text = String(format: "%.01f", Double(data.rate!)!)
        
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        let data = ShareData.feeds[indexPath.row]
//        selected_feed = data
//        selected_index = indexPath.row
//
//        if data.type! == ShareData.feed_type().promotion
//        {
//
//            let array = CommonFuncs().splitString(data.optional_value!)
//            if UIApplication.shared.canOpenURL(URL(string: array[1])!) {
//                UIApplication.shared.open(URL(string: array[1])!, options: [:])
//            }
//
//            self.feedRemove(index: self.selected_index)
//            return
//
//        }
//
//        let feed = self.feedDataProcess(data)
//
//        switch data.type {
//
//        case ShareData.feed_type().auction_create:
//
//            feedAction(ShareData.appTitle, "\(feed[0]). Will you bid now on his auction?", 2, ["BID NOW", "CANCEL"], [Utility.color(withHexString: ShareData.btn_color), UIColor.gray], [UIColor.white, UIColor.white], [#selector(self.auctionBid(_:)), #selector(self.defaultAction(_:))])
//            break
//
//        case ShareData.feed_type().auction_update:
//
//            feedAction(ShareData.appTitle, "\(feed[0]). Will you bid now on his auction?", 2, ["BID NOW", "CANCEL"], [Utility.color(withHexString: ShareData.btn_color), UIColor.gray], [UIColor.white, UIColor.white], [#selector(self.auctionBid(_:)), #selector(self.defaultAction(_:))])
//            break
//
//        case ShareData.feed_type().auction_bid:
//
//            feedAction(ShareData.appTitle, "\(feed[0]). Do you want to view now?", 2, ["VIEW NOW", "CANCEL"], [Utility.color(withHexString: ShareData.btn_color), UIColor.gray], [UIColor.white, UIColor.white], [#selector(self.auctionBid(_:)), #selector(self.defaultAction(_:))])
//            break
//
//        case ShareData.feed_type().auction_bid_update:
//
//            feedAction(ShareData.appTitle, "\(feed[0]). Do you want to view now?", 2, ["VIEW NOW", "CANCEL"], [Utility.color(withHexString: ShareData.btn_color), UIColor.gray], [UIColor.white, UIColor.white], [#selector(self.auctionBid(_:)), #selector(self.defaultAction(_:))])
//            break
//
//        case ShareData.feed_type().auction_win:
//
//            break
//
//        case ShareData.feed_type().book_request:
//
//            bookRequestProcess()
//            break
//
//        case ShareData.feed_type().book_video_sent:
//
//            feedAction(ShareData.appTitle, "\(feed[0]). Do you want to watch now?", 2, ["WATCH NOW", "CANCEL"], [Utility.color(withHexString: ShareData.btn_color), UIColor.gray], [UIColor.white, UIColor.white], [#selector(self.bookVideoWatch(_:)), #selector(self.defaultAction(_:))])
//            break
//
//        case ShareData.feed_type().book_video_seen:
//
//            feedAction(ShareData.appTitle, feed[0], 1, ["CLOSE"], [Utility.color(withHexString: ShareData.btn_color)], [UIColor.white], [#selector(self.defaultAction(_:))])
//            break
//
//        case ShareData.feed_type().follow_request:
//
//            feedAction(ShareData.appTitle, "\(feed[0]). Will you accept or reject?", 2, ["ACCEPT", "REJECT"], [Utility.color(withHexString: ShareData.btn_color), UIColor.gray], [UIColor.white, UIColor.white], [#selector(self.followAccept(_:)), #selector(self.followReject(_:))])
//            break
//
//        case ShareData.feed_type().review_left:
//
//            feedAction(ShareData.appTitle, "\(feed[0]). Do you want to view now?", 2, ["VIEW  NOW", "CANCEL"], [Utility.color(withHexString: ShareData.btn_color), UIColor.gray], [UIColor.white, UIColor.white], [#selector(self.reviewView(_:)), #selector(self.defaultAction(_:))])
//            break
//
//        case ShareData.feed_type().other_popcoin_zero:
//
//            feedAction(ShareData.appTitle, "\(feed[0]).  Do you want to buy PopCoins now?", 2, ["BUY  NOW", "CANCEL"], [Utility.color(withHexString: ShareData.btn_color), UIColor.gray], [UIColor.white, UIColor.white], [#selector(self.coinBuy(_:)), #selector(self.defaultAction(_:))])
//            break
//
//        default:
//
//            feedAction(ShareData.appTitle, feed[0], 1, ["CLOSE"], [Utility.color(withHexString: ShareData.btn_color)], [UIColor.white], [#selector(self.defaultAction(_:))])
//            break
//        }
        
        self.tableView.isUserInteractionEnabled = false
        
        self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: progressDlg, color: .darkGray, fadeInAnimation: nil)
        
        var data: UserMDL!
//        if indexPath.section == 0
//        {
//            data = ShareData.top_influencers[indexPath.row]
//        }
//        else if indexPath.section == 1 && ShareData.following_influencers.count > 0
//        {
//            data = ShareData.following_influencers[indexPath.row]
//        }
//        else
//        {
//            data = ShareData.matched_influencers[indexPath.row]
//        }
        data = ShareData.matched_influencers[indexPath.row]
        
        let parmeters = ["user_id": data.id!] as [String: Any]
        
        
        CommonFuncs().createRequest(true, "detail", "POST", parmeters, completionHandler: {data in
            
            let status = data["status"] as! Bool
            
            DispatchQueue.main.async {
                
                if status
                {
                    
                    if let temp = Mapper<UserMDL>().map(JSONObject: data["data"])
                    {
                        ShareData.selected_influencer = temp
                        
                        self.tableView.isUserInteractionEnabled = true
                        
                        self.stopAnimating(nil)
                        self.navigationController?.pushViewController(MainTrendProfileVC(), animated: true)
                    }
                    
                }
                else
                {
                    
                    self.tableView.isUserInteractionEnabled = true
                    self.stopAnimating(nil)
                    CommonFuncs().doneAlert(ShareData.appTitle, "Failed detail request", "CLOSE", {})
                }
            }
        })
    }
}

extension MainHomeVC
{
    
    func feedDataProcess(_ data: FeedMDL) -> [String]
    {
        var txt = ""
        var status = "0"
        
        switch data.type!
        {
            
        case ShareData.feed_type().auction_create:
            
            let array = CommonFuncs().splitString(data.optional_value!)
            let index = ShareData.charity_list.index {$0.id == array[1]}!
            txt = "\(data.name!) created new auction for \(ShareData.charity_list![index].name!) that will begin on \(CommonFuncs().timeString("\(array[2])-\(array[3])-\(array[4])-00-00", "", 0))"
            status = "0"
            break
            
        case ShareData.feed_type().auction_update:
            
            let array = CommonFuncs().splitString(data.optional_value!)
            let index = ShareData.charity_list.index {$0.id == array[1]}!
            txt = "\(data.name!) updated his auction for \(ShareData.charity_list![index].name!) that will begin on \(CommonFuncs().timeString("\(array[2])-\(array[3])-\(array[4])-00-00", "", 0))"
            status = "0"
            break
            
        case ShareData.feed_type().auction_follow:
            
            let array = CommonFuncs().splitString(data.optional_value!)
            let index = ShareData.charity_list.index {$0.id == array[1]}!
            txt = "\(data.name!) followed your auction for \(ShareData.charity_list![index].name!) that will begin on \(CommonFuncs().timeString("\(array[2])-\(array[3])-\(array[4])-00-00", "", 0))"
            status = "0"
            break
            
        case ShareData.feed_type().auction_bid:
            
            let array = CommonFuncs().splitString(data.optional_value!)
            let index = ShareData.charity_list.index {$0.id == array[1]}!
            txt = "\(data.name!) bidded on your auction for \(ShareData.charity_list![index].name!) that will begin on \(CommonFuncs().timeString("\(array[2])-\(array[3])-\(array[4])-00-00", "", 0))"
            status = "0"
            break
            
        case ShareData.feed_type().auction_bid_update:
            
            let array = CommonFuncs().splitString(data.optional_value!)
            let index = ShareData.charity_list.index {$0.id == array[1]}!
            txt = "\(data.name!) updated his bid on your auction for \(ShareData.charity_list![index].name!) that will begin on \(CommonFuncs().timeString("\(array[2])-\(array[3])-\(array[4])-00-00", "", 0))"
            status = "0"
            break
            
        case ShareData.feed_type().book_request:
            
            let array = CommonFuncs().splitString(data.optional_value!)
            txt = "\(data.name!) want to chat with you on \(CommonFuncs().timeString("\(array[1])-\(array[2])-\(array[3])-\(array[4])-\(array[5])", "", 0))"
            status = "0"
            break
            
        case ShareData.feed_type().book_video_sent:
            
            txt = "\(data.name!) sent new video"
            status = "0"
            break
            
        case ShareData.feed_type().book_video_seen:
            
            txt = "\(data.name!) had seen your video"
            status = "0"
            break
            
        case ShareData.feed_type().book_accept:
            
            let array = CommonFuncs().splitString(data.optional_value!)
            txt = "\(data.name!) accepted your booking request on \(CommonFuncs().timeString("\(array[1])-\(array[2])-\(array[3])-\(array[4])-\(array[5])", "", 0))"
            status = "0"
            break
            
        case ShareData.feed_type().book_cancel:
            
            let array = CommonFuncs().splitString(data.optional_value!)
            txt = "\(data.name!) rejected your booking request on \(CommonFuncs().timeString("\(array[1])-\(array[2])-\(array[3])-\(array[4])-\(array[5])", "", 0))"
            status = "0"
            break
            
        case ShareData.feed_type().book_add_time:
            
            let array = CommonFuncs().splitString(data.optional_value!)
            txt = "\(data.name!) paid \(array[1]) PopCoin for additional \(array[0]) minutes  for book on \(CommonFuncs().timeString("\(array[1])-\(array[2])-\(array[3])-\(array[4])-\(array[5])", "", 0))"
            status = "0"
            break
            
        case ShareData.feed_type().follow_request:
            
            txt = "\(data.name!) want to follow"
            status = "0"
            break
            
        case ShareData.feed_type().follow_accept:
            
            txt = "\(data.name!) accepted your following request"
            status = "0"
            break
            
        case ShareData.feed_type().follow_cancel:
            
            txt = "\(data.name!) rejected your following request"
            status = "0"
            break
            
        case ShareData.feed_type().fee_msg:
            
            txt = data.optional_value!
            status = "0"
            break
            
        case ShareData.feed_type().review_left:
            
            txt = "\(data.name!) left review for book with you on \(CommonFuncs().timeString(data.optional_value!, "", 0))"
            status = "0"
            break
            
        case ShareData.feed_type().other_popcoin_zero:
            
            txt = "Your PopCoin balance is depleted.  You will need to buy some additional PopCoins before scheduling a booking"
            status = "1"
            break
            
            
        case ShareData.feed_type().other_book_fee_charged:
            
            let array = CommonFuncs().splitString(data.optional_value!)
            txt = "You paid \(array[0]) PopCoin for book with \(data.name!) on \(CommonFuncs().timeString("\(array[1])-\(array[2])-\(array[3])-\(array[4])-\(array[5])", "", 0))"
            status = "1"
            break
            
            
        case ShareData.feed_type().other_book_fee_received:
            
            let array = CommonFuncs().splitString(data.optional_value!)
            txt = "You finished book with \(data.name!) on \(CommonFuncs().timeString("\(array[1])-\(array[2])-\(array[3])-\(array[4])-\(array[5])", "", 0)) and received \(array[0]) PopCoin"
            status = "1"
            break
            
        case ShareData.feed_type().other_book_fee_refunded:
            
            let array = CommonFuncs().splitString(data.optional_value!)
            txt = "You have refuned \(array[0]) PopCoin for book with \(data.name!) on \(CommonFuncs().timeString("\(array[1])-\(array[2])-\(array[3])-\(array[4])-\(array[5])", "", 0))"
            status = "1"
            break
            
        case ShareData.feed_type().other_book_add_time:
            
            let array = CommonFuncs().splitString(data.optional_value!)
            txt = "You paid \(array[1]) PopCoin for additional \(array[0]) minutes for book with \(data.name!) on \(CommonFuncs().timeString("\(array[2])-\(array[3])-\(array[4])-\(array[5])-\(array[6])", "", 0))"
            status = "1"
            break
            
        case ShareData.feed_type().other_book_time_over:
            
            let array = CommonFuncs().splitString(data.optional_value!)
            txt = "A book with \(data.name!) on \(CommonFuncs().timeString("\(array[1])-\(array[2])-\(array[3])-\(array[4])-\(array[5])", "", 0)) is canceled, be course time is expired"
            status = "1"
            break
            
        case ShareData.feed_type().other_book_process_fee:
            
            let array = CommonFuncs().splitString(data.optional_value!)
            txt = "You paid \(array[0]) PopCoin fee for book with \(data.name!) on \(CommonFuncs().timeString("\(array[1])-\(array[2])-\(array[3])-\(array[4])-\(array[5])", "", 0))"
            status = "1"
            break
            
        default:
            break
        }
        
        return [txt, status]
    }
    
    
    func feedAction(_ title: String, _ subtitle: String, _ btn_num: Int, _ btn_titles: [String], _ btn_colors: [UIColor], _ btn_txt_colors: [UIColor], _ btn_actions: [Selector])
    {
        let appearance = SCLAlertView.SCLAppearance(
            
            kDefaultShadowOpacity: 0.5,
            kCircleIconHeight: 60,
            showCloseButton: false,
            showCircularIcon: true
            
        )
        
        let alertView = SCLAlertView(appearance: appearance)
        let alertViewIcon = UIImage(named: "mark1")
        
        for i in 0..<btn_num
        {
            alertView.addButton(btn_titles[i], backgroundColor: btn_colors[i], textColor: btn_txt_colors[i], target: self, selector: btn_actions[i])
        }
        
        alertView.showInfo(title, subTitle: subtitle, circleIconImage: alertViewIcon)
        
    }
    
    @objc func auctionBid(_ sender: UIButton) {
        
        let parmeters = ["auction_id": CommonFuncs().splitString(selected_feed.optional_value!)[0]] as [String: Any]
        
        self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: self.progressDlg, color: .darkGray, fadeInAnimation: nil)
        
        CommonFuncs().createRequest(false, "auction/request", "POST", parmeters, completionHandler: {data in
            
            let status = data["status"] as! Bool
            let message = data["message"] as! String
            
            DispatchQueue.main.async {
                
                if status
                {
                    let response_data = data["data"] as! [String: Any]
                    
                    if let temp = Mapper<AuctionMDL>().map(JSONObject: response_data["auction"])
                    {
                        ShareData.selected_auction = temp
                    }
                    
                    if let temp = Mapper<AuctionBidMDL>().mapArray(JSONObject: response_data["bidders"])
                    {
                        ShareData.selected_auction_bidders = temp
                    }
                    
                    self.feedDelete(id: self.selected_feed.id!)
                    self.stopAnimating()
                    self.navigationController?.pushViewController(MoreAuctionBidVC(), animated: true)
                }
                
                self.feedRemove(index: self.selected_index)
                self.stopAnimating(nil)
                self.tableView.isUserInteractionEnabled = true
                
            }
        })
        
    }
    
    func bookRequestProcess() {
        
        
        let parmeters = ["book_id": CommonFuncs().splitString(selected_feed.optional_value!)[0]] as [String: Any]
        
        self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: self.progressDlg, color: .darkGray, fadeInAnimation: nil)
        
        CommonFuncs().createRequest(false, "book/detail", "POST", parmeters, completionHandler: {data in
            
            let status = data["status"] as! Bool
            let message = data["message"] as! String
            
            if status
            {
                DispatchQueue.main.async {
                    
                    self.feedDelete(id: self.selected_feed.id!)
                    self.feedRemove(index: self.selected_index)
                    self.stopAnimating(nil)
                    
                    if let temp = Mapper<BookMDL>().map(JSONObject: data["data"])
                    {
                        ShareData.selected_book = temp
                        ShareData.book_detail_from_status = false
                        self.stopAnimating()
                        self.navigationController?.pushViewController(MainBookDetailVC(), animated: true)
                    }
                    
                }
            }
            else
            {
                CommonFuncs().doneAlert(ShareData.appTitle, message, "CLOSE", {})
            }
            
        })
    }
    
    @objc func bookVideoWatch(_ sender: UIButton) {
        
        
        self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: self.progressDlg, color: .darkGray, fadeInAnimation: nil)
        video_view_frame.isHidden = false
        video_view.configure(url: selected_feed.optional_value!, local_or_sever: false)
//        video_view.isLoop = true
        self.stopAnimating(nil)
        var image = UIImage.init(named: "video_play")?.withRenderingMode(.alwaysTemplate)
        video_pause_btn.setImage(image, for: .normal)
        video_pause_btn.tintColor = UIColor.white
        video_paused = true
    }
    
    @objc func followAccept(_ sender: UIButton) {
        
        let send_time = CommonFuncs().currentTime()
        
        let parmeters = ["follow_id": selected_feed.optional_value!, "time": send_time, "time_zone": ShareData.user_info.time_zone!] as [String: Any]
        
        self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: self.progressDlg, color: .darkGray, fadeInAnimation: nil)
        
        CommonFuncs().createRequest(false, "follow/accept", "POST", parmeters, completionHandler: {data in
            
            let status = data["status"] as! Bool
            let message = data["message"] as! String
            
            DispatchQueue.main.async {
                
                self.feedDelete(id: self.selected_feed.id!)
                self.feedRemove(index: self.selected_index)
                
            }
        })
    }
    
    
    @objc func followReject(_ sender: UIButton) {
        
        let send_time = CommonFuncs().currentTime()
        
        let parmeters = ["follow_id": selected_feed.optional_value!, "time": send_time, "time_zone": ShareData.user_info.time_zone!] as [String: Any]
        
        self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: self.progressDlg, color: .darkGray, fadeInAnimation: nil)
        
        CommonFuncs().createRequest(false, "follow/cancel", "POST", parmeters, completionHandler: {data in
            
            let status = data["status"] as! Bool
            let message = data["message"] as! String
            
            DispatchQueue.main.async {
                
                self.feedDelete(id: self.selected_feed.id!)
                self.feedRemove(index: self.selected_index)
                
            }
        })
    }
    
    @objc func reviewView(_ sender: UIButton) {
        
        self.feedDelete(id: self.selected_feed.id!)
        self.feedRemove(index: self.selected_index)
        ShareData.pay_from_status = true
        ShareData.rate_or_follow_status = true
        
        UIApplication.shared.keyWindow?.setRootViewController(MoreRateReviewVC(), options: UIWindow.TransitionOptions(direction: .toRight, style: .easeIn), slide_direction: .fromRightToLeft)
    }
    
    @objc func coinBuy(_ sender: UIButton) {
        
        self.feedDelete(id: self.selected_feed.id!)
        self.feedRemove(index: self.selected_index)
        ShareData.pay_from_status = true
        UIApplication.shared.keyWindow?.setRootViewController(MorePayVC(), options: UIWindow.TransitionOptions(direction: .toRight, style: .easeIn), slide_direction: .fromRightToLeft)
    }
    
    @objc func defaultAction(_ sender: UIButton) {
        
        self.feedDelete(id: self.selected_feed.id!)
        self.feedRemove(index: self.selected_index)
    }
}

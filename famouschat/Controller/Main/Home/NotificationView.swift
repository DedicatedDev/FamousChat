//
//  NotificationView.swift
//  famouschat
//
//  Created by mappexpert on 1/9/20.
//  Copyright © 2020 Oni Angel. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import ObjectMapper
import SCLAlertView

class NotificationView: UIViewController, NVActivityIndicatorViewable {
    @IBOutlet weak var back_img: UIImageView!
    @IBOutlet weak var back_btn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let progressDlg = ShareData.progressDlgs[ShareData.progress_index]
    var selected_feed: FeedMDL!
    var selected_index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        init_UI()
    }
    
    func init_UI()
    {
        
        self.navigationController?.isNavigationBarHidden = true
        
        let back_image = UIImage.init(named: "back")!.withRenderingMode(.alwaysTemplate)
        back_img.image = back_image
        back_img.tintColor = Utility.color(withHexString: "10A7BA")
        
        back_btn.addTarget(self, action: #selector(self.backAction(_:)), for: .touchUpInside)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "FeedPhotoCell", bundle: nil), forCellReuseIdentifier: "FeedPhotoCell")
        tableView.register(UINib(nibName: "FeedWarnCell", bundle: nil), forCellReuseIdentifier: "FeedWarnCell")
        tableView.register(UINib(nibName: "FeedPromotionCell", bundle: nil), forCellReuseIdentifier: "FeedPromotionCell")
        tableView.separatorColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        
    }
    
    @objc func backAction(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
}

extension NotificationView: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return ShareData.feeds.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let data = ShareData.feeds[indexPath.row]
        let array = self.feedDataProcess(data)
        
        if data.type! == ShareData.feed_type().promotion
        {
            
            return CommonFuncs().getStringHeight(data.optional_value!, 12, UIScreen.main.bounds.width, 80, 200)
        }
        
        if array[1] == "1"
        {
            return CommonFuncs().getStringHeight(array[0], 12, UIScreen.main.bounds.width, 80, 30)
        }
        else
        {
            return CommonFuncs().getStringHeight(array[0], 12, UIScreen.main.bounds.width, 80, 55)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let data = ShareData.feeds[indexPath.row]
        let array = self.feedDataProcess(data)
        
        if data.type! == ShareData.feed_type().promotion
        {
            let cell : FeedPromotionCell = tableView.dequeueReusableCell(withIdentifier: "FeedPromotionCell", for: indexPath) as! FeedPromotionCell
            
            cell.backgroundColor = UIColor.clear
            cell.contentView.backgroundColor = UIColor.clear
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            cell.photo.load(url: data.photo!)
            cell.photo.layer.cornerRadius = cell.photo.frame.width / 2
            cell.photo.clipsToBounds = true
            cell.name.text = data.name!
            cell.time.backgroundColor = Utility.color(withHexString: "10A7BA")
            cell.time.layer.cornerRadius = 4
            cell.time.clipsToBounds = true
            
            let array = CommonFuncs().splitString(data.optional_value!)
            cell.promotion_txt.text = data.optional_value!
            //cell.promotion_img.load(url: array[0])
            
            return cell
            
        }
        
        if array[1] == "1"
        {
            let cell : FeedWarnCell = tableView.dequeueReusableCell(withIdentifier: "FeedWarnCell", for: indexPath) as! FeedWarnCell
            
            cell.backgroundColor = UIColor.clear
            cell.contentView.backgroundColor = UIColor.clear
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            cell.warn_view.backgroundColor = Utility.color(withHexString: "143755")
            cell.warn_view.layer.cornerRadius = cell.warn_view.frame.height / 2
            cell.warn_view.clipsToBounds = true
            
            let attributedString = NSMutableAttributedString(string: array[0])
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 5
            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
            cell.message.attributedText = attributedString
            
            return cell
        }
        else
        {
            let cell : FeedPhotoCell = tableView.dequeueReusableCell(withIdentifier: "FeedPhotoCell", for: indexPath) as! FeedPhotoCell
            
            cell.backgroundColor = UIColor.clear
            cell.contentView.backgroundColor = UIColor.clear
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            cell.photo.load(url: data.photo!)
            cell.photo.layer.cornerRadius = cell.photo.frame.width / 2
            cell.photo.clipsToBounds = true
            cell.name.text = data.name!
            cell.history.text = CommonFuncs().historyTime(data.time!, data.time_zone!)
            cell.message.text = array[0]
            
            return cell
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let data = ShareData.feeds[indexPath.row]
        selected_feed = data
        selected_index = indexPath.row
        
        if data.type! == ShareData.feed_type().promotion
        {
            
            let array = CommonFuncs().splitString(data.optional_value!)
            if UIApplication.shared.canOpenURL(URL(string: array[1])!) {
                UIApplication.shared.open(URL(string: array[1])!, options: [:])
            }
            
            self.feedRemove(index: self.selected_index)
            return
            
        }
        
        let feed = self.feedDataProcess(data)
        
        switch data.type {
            
        case ShareData.feed_type().auction_create:
            
            feedAction(ShareData.appTitle, "\(feed[0]). Will you bid now on his auction?", 2, ["BID NOW", "CANCEL"], [Utility.color(withHexString: ShareData.btn_color), UIColor.gray], [UIColor.white, UIColor.white], [#selector(self.auctionBid(_:)), #selector(self.defaultAction(_:))])
            break
            
        case ShareData.feed_type().auction_update:
            
            feedAction(ShareData.appTitle, "\(feed[0]). Will you bid now on his auction?", 2, ["BID NOW", "CANCEL"], [Utility.color(withHexString: ShareData.btn_color), UIColor.gray], [UIColor.white, UIColor.white], [#selector(self.auctionBid(_:)), #selector(self.defaultAction(_:))])
            break
            
        case ShareData.feed_type().auction_bid:
            
            feedAction(ShareData.appTitle, "\(feed[0]). Do you want to view now?", 2, ["VIEW NOW", "CANCEL"], [Utility.color(withHexString: ShareData.btn_color), UIColor.gray], [UIColor.white, UIColor.white], [#selector(self.auctionBid(_:)), #selector(self.defaultAction(_:))])
            break
            
        case ShareData.feed_type().auction_bid_update:
            
            feedAction(ShareData.appTitle, "\(feed[0]). Do you want to view now?", 2, ["VIEW NOW", "CANCEL"], [Utility.color(withHexString: ShareData.btn_color), UIColor.gray], [UIColor.white, UIColor.white], [#selector(self.auctionBid(_:)), #selector(self.defaultAction(_:))])
            break
            
        case ShareData.feed_type().auction_win:
            
            break
            
        case ShareData.feed_type().book_request:
            
            bookRequestProcess()
            break
            
        case ShareData.feed_type().book_video_sent:
            
//            feedAction(ShareData.appTitle, "\(feed[0]). Do you want to watch now?", 2, ["WATCH NOW", "CANCEL"], [Utility.color(withHexString: ShareData.btn_color), UIColor.gray], [UIColor.white, UIColor.white], [#selector(self.bookVideoWatch(_:)), #selector(self.defaultAction(_:))])
            break
            
        case ShareData.feed_type().book_video_seen:
            
            feedAction(ShareData.appTitle, feed[0], 1, ["CLOSE"], [Utility.color(withHexString: ShareData.btn_color)], [UIColor.white], [#selector(self.defaultAction(_:))])
            break
            
        case ShareData.feed_type().follow_request:
            
            feedAction(ShareData.appTitle, "\(feed[0]). Will you accept or reject?", 2, ["ACCEPT", "REJECT"], [Utility.color(withHexString: ShareData.btn_color), UIColor.gray], [UIColor.white, UIColor.white], [#selector(self.followAccept(_:)), #selector(self.followReject(_:))])
            break
            
        case ShareData.feed_type().review_left:
            
            feedAction(ShareData.appTitle, "\(feed[0]). Do you want to view now?", 2, ["VIEW  NOW", "CANCEL"], [Utility.color(withHexString: ShareData.btn_color), UIColor.gray], [UIColor.white, UIColor.white], [#selector(self.reviewView(_:)), #selector(self.defaultAction(_:))])
            break
            
        case ShareData.feed_type().other_popcoin_zero:
            
            feedAction(ShareData.appTitle, "\(feed[0]).  Do you want to buy PopCoins now?", 2, ["BUY  NOW", "CANCEL"], [Utility.color(withHexString: ShareData.btn_color), UIColor.gray], [UIColor.white, UIColor.white], [#selector(self.coinBuy(_:)), #selector(self.defaultAction(_:))])
            break
            
        default:
            
            feedAction(ShareData.appTitle, feed[0], 1, ["CLOSE"], [Utility.color(withHexString: ShareData.btn_color)], [UIColor.white], [#selector(self.defaultAction(_:))])
            break
        }
    }
}

extension NotificationView
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
        let parmeters = ["feed_id": id] as [String: Any]
        self.tableView.isUserInteractionEnabled = false
        CommonFuncs().createRequest(false, "feed/delete", "POST", parmeters, completionHandler: {data in
            
        })
    }
    
}

extension NotificationView
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
            
            txt = "Your PopCoin balance is depleted. Click here to add additional PopCoins"
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
    
//    @objc func bookVideoWatch(_ sender: UIButton) {
//
//
//        self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: self.progressDlg, color: .darkGray, fadeInAnimation: nil)
//        video_view_frame.isHidden = false
//        video_view.configure(url: selected_feed.optional_value!, local_or_sever: false)
////        video_view.isLoop = true
//        self.stopAnimating(nil)
//        var image = UIImage.init(named: "video_play")?.withRenderingMode(.alwaysTemplate)
//        video_pause_btn.setImage(image, for: .normal)
//        video_pause_btn.tintColor = UIColor.white
//        video_paused = true
//    }
    
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


//
//  MoreAuctionCharitVC.swift
//  famouschat
//
//  Created by T-Tech Solutions LLC on 09/11/2018.
//  Copyright © 2018 T-Tech Solutions LLC. All rights reserved.
//

import UIKit
import MBCircularProgressBar
import NVActivityIndicatorView
import ObjectMapper

class MoreAuctionBidVC: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet weak var back_img: UIImageView!
    @IBOutlet weak var back_btn: UIButton!
    @IBOutlet weak var menu_img: UIImageView!
    @IBOutlet weak var menu_btn: UIButton!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var photo_height: NSLayoutConstraint!
    @IBOutlet weak var auction_title: UILabel!
    
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var current_frame: UIView!
    @IBOutlet weak var total_views: UILabel!
    @IBOutlet weak var total_bids: UILabel!
    @IBOutlet weak var starting_bid: UILabel!
    @IBOutlet weak var goal_bid: UILabel!
    @IBOutlet weak var edit_auction_btn: UIButton!
    @IBOutlet weak var edit_auction_width: NSLayoutConstraint!
    @IBOutlet weak var current_bid_progress: MBCircularProgressBarView!
    
    @IBOutlet weak var current_bid_frame: UIView!
    @IBOutlet weak var current_bid_label: UILabel!
    @IBOutlet weak var remain_time: UILabel!
    @IBOutlet weak var auction_end_time: UILabel!
    
    @IBOutlet weak var desc_frame: UIView!
    @IBOutlet weak var desc_frame_height: NSLayoutConstraint!
    @IBOutlet weak var desc_label: UILabel!
    
    @IBOutlet weak var bid_place_frame: UIView!
    @IBOutlet weak var place_bid_btn: UIButton!
    @IBOutlet weak var bid_out_cost: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var bid_frame: UIView!
    @IBOutlet weak var time_left: UILabel!
    @IBOutlet weak var current_bid: UILabel!
    @IBOutlet weak var bid_in_frame: UIView!
    @IBOutlet weak var bid_in: UITextField!
    @IBOutlet weak var bid_place_btn: UIButton!
    @IBOutlet weak var bid_cancel_btn: UIButton!
    
    let progressDlg = ShareData.progressDlgs[ShareData.progress_index]
    
    let bider_list = [["Oni Angel", "3500", "15"], ["Bai Tu", "5600", "56"], ["Kalashi", "8900", "32"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ShareData.selected_auction_bidders.sort { Int($0.cost!)! > Int($1.cost!)! }
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
        
        let data = ShareData.selected_auction!
        let charity_index = ShareData.charity_list.index { $0.id == data.charity_id! }
        photo_height.constant = photo.frame.width * 0.7
        photo.load(url: data.photo!)
        auction_title.text = "\(data.name!)`s Auction for the \(ShareData.charity_list[charity_index!].name!)"
        
        current_frame.dropShadow(color: .gray, opacity: 0.5, offSet: CGSize.zero, radius: 10, scale: true)
        
        current_bid_progress.progressAngle = 100
        current_bid_progress.progressLineWidth = 7
        current_bid_progress.maxValue = CGFloat(Int(data.goal_cost!)!)
        
        current_bid_frame.layer.cornerRadius = current_bid_frame.frame.width / 2
        current_bid_frame.clipsToBounds = true
        current_bid_frame.dropShadow(color: .gray, opacity: 0.8, offSet: CGSize.zero, radius: 5, scale: true)
        
        total_views.text = data.total_views!
        total_bids.text = data.total_bids!
        starting_bid.attributedText =  CommonFuncs().attributeString([UIFont.boldSystemFont(ofSize: 15), UIFont.systemFont(ofSize: 13)], [Utility.color(withHexString: ShareData.btn_color), Utility.color(withHexString: ShareData.btn_color)],  [data.start_bid_cost!, " PopCoin"])
        goal_bid.attributedText = CommonFuncs().attributeString([UIFont.boldSystemFont(ofSize: 15), UIFont.systemFont(ofSize: 13)], [Utility.color(withHexString: ShareData.btn_color), Utility.color(withHexString: ShareData.btn_color)],  [data.goal_cost!, " PopCoin"])
        
        current_bid_label.attributedText = CommonFuncs().attributeString([UIFont.boldSystemFont(ofSize: 15)], [Utility.color(withHexString: ShareData.btn_color)],  [data.current_cost!])
        if data.status == "1"
        {
            current_bid_label.textColor = UIColor.red
        }
        
        let array = CommonFuncs().splitString(data.start_time!)
        let array1 = CommonFuncs().splitString(data.chat_time!)
        
        let start_time_str = "\(array[0])-\(array[1])-\(array[2])-\(array1[0])-\(array1[1])"
        let formater = DateFormatter()
        formater.dateFormat = "yyyy-MM-dd-HH-mm"
        let end_time = formater.date(from: start_time_str)!.addingTimeInterval(TimeInterval(3600 * 24 * Int(data.duration!)!))
        let end_time_str = formater.string(from: end_time)
        let end_time_hour = Calendar.current.component(.hour, from: end_time) as! Int
        let end_time_min = Calendar.current.component(.minute, from: end_time) as! Int
        
        let end_time_hour_array = CommonFuncs().time24To12("\(end_time_hour)")
        
        auction_end_time.text = "Auction ends \(CommonFuncs().timeString(end_time_str, "", 1)) at \(end_time_hour_array[0]):\(String(format: "%02d", end_time_min)) \(end_time_hour_array[1])"
        
        let currentDate = Date()
        let components = Set<Calendar.Component>([.minute, .hour, .day, .month, .year])
        let diff_time = Calendar.current.dateComponents(components, from: currentDate, to: end_time)
        
        var remain_str = ""
        if diff_time.year! == 0
        {
            if diff_time.month! == 0
            {
                if diff_time.day! == 0
                {
                    if diff_time.hour! == 0
                    {
                        remain_str = "\(diff_time.minute!)min"
                    }
                    else
                    {
                        remain_str = "\(diff_time.hour!)hr \(diff_time.minute!)min"
                    }
                }
                else
                {
                    remain_str = "\(diff_time.day!)d \(diff_time.hour!)hr \(diff_time.minute!)min"
                }
            }
            else
            {
                remain_str = "\(diff_time.month!)month \(diff_time.day!)day"
            }
        }
        else
        {
            remain_str = "\(diff_time.year!)year \(diff_time.month!)month"
        }
        
        remain_time.text = remain_str
        
        edit_auction_btn.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        edit_auction_btn.clipsToBounds = true
        edit_auction_btn.dropShadow(color: .gray, opacity: 0.8, offSet: CGSize.zero, radius: 3, scale: true)
        
        if ShareData.user_info.id! != data.user_id!
        {
            edit_auction_btn.setTitle("Follow This Auction", for: .normal)
            edit_auction_width.constant = 130
            
            edit_auction_btn.addTarget(self, action: #selector(self.followAction(_:)), for: .touchUpInside)
            
            bid_frame.layer.cornerRadius = CGFloat(ShareData.btn_radius)
            bid_frame.clipsToBounds = true
            bid_frame.dropShadow(color: Utility.color(withHexString: ShareData.btn_color), opacity: 1, offSet: CGSize.zero, radius: 5, scale: true)
            
            time_left.attributedText = CommonFuncs().attributeString([UIFont.boldSystemFont(ofSize: 13), UIFont.systemFont(ofSize: 13)], [UIColor.gray, UIColor.gray], ["Time Left: ", remain_str])
            
            current_bid.attributedText = CommonFuncs().attributeString([UIFont.boldSystemFont(ofSize: 13), UIFont.systemFont(ofSize: 12)], [UIColor.gray, UIColor.gray], ["Current Bid: \(data.current_cost!)", " PopCoin"])
            
            bid_in_frame.layer.cornerRadius = bid_in_frame.frame.height / 2
            bid_in_frame.layer.borderColor = Utility.color(withHexString: ShareData.btn_color).cgColor
            bid_in_frame.layer.borderWidth = 1
            bid_in_frame.clipsToBounds = true
            
            bid_in.delegate = self
            
            place_bid_btn.layer.cornerRadius = CGFloat(ShareData.btn_radius)
            place_bid_btn.clipsToBounds = true
            place_bid_btn.dropShadow(color: .gray, opacity: 0.8, offSet: CGSize.zero, radius: 5, scale: true)
            
            if let index = ShareData.selected_auction_bidders.index(where: { $0.user_id! == ShareData.user_info.id! })
            {
                place_bid_btn.setTitle("UPDATE BID", for: .normal)
                bid_place_btn.setTitle("Update Bid", for: .normal)
            }
            else
            {
                place_bid_btn.setTitle("PLACE BID", for: .normal)
                bid_place_btn.setTitle("Place Bid", for: .normal)
            }
            
            bid_place_btn.layer.cornerRadius = CGFloat(ShareData.btn_radius)
            bid_place_btn.clipsToBounds = true
            bid_place_btn.dropShadow(color: .gray, opacity: 0.8, offSet: CGSize.zero, radius: 5, scale: true)
            
            bid_cancel_btn.layer.cornerRadius = CGFloat(ShareData.btn_radius)
            bid_cancel_btn.clipsToBounds = true
            bid_cancel_btn.dropShadow(color: .gray, opacity: 0.8, offSet: CGSize.zero, radius: 5, scale: true)
            
            bid_frame.isHidden = true
            
        }
        else
        {
            edit_auction_btn.setTitle("Edit Auction", for: .normal)
            edit_auction_width.constant = 100
            
            edit_auction_btn.addTarget(self, action: #selector(self.editAction(_:)), for: .touchUpInside)
            
            place_bid_btn.isHidden = true
            bid_frame.isHidden = true
            
        }
        
       
        let txt = data.charity_info!
        let height = CommonFuncs().getStringHeight(txt, 13, UIScreen.main.bounds.width, 30, 70)
       
        desc_frame_height.constant = height
        desc_label.text = data.charity_info!
        
        bid_place_frame.dropShadow(color: .gray, opacity: 0.5, offSet: CGSize.zero, radius: 10, scale: true)
        bid_out_cost.attributedText = CommonFuncs().attributeString([UIFont.boldSystemFont(ofSize: 15), UIFont.systemFont(ofSize: 13)], [Utility.color(withHexString: ShareData.btn_color), Utility.color(withHexString: ShareData.btn_color)],  [data.out_cost!, " PopCoin"])
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ChatListCell", bundle: nil), forCellReuseIdentifier: "ChatListCell")
        tableView.separatorStyle = .none
        tableView.reloadData()
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        
        init_UI()
    }
    
    override func viewDidLayoutSubviews() {
        
        current_bid_progress.value = 0
        
        UIView.animate(withDuration: 3.0) {
            
            self.current_bid_progress.value = CGFloat(Int(ShareData.selected_auction.current_cost!)!)
        }
    }
    
    
    @objc func backAction(_ sender: UIButton) {
        
        ShareData.selected_auction_bidders = [AuctionBidMDL]()
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func placeBidAction(_ sender: Any) {
        
        bid_frame.isHidden = false
        scroll.isHidden = true
        
    }
    
    
    @IBAction func bidOkAction(_ sender: Any) {
        
        if bid_in.text != "" && bid_in.text != nil
        {
            if Int(bid_in.text!)! < Int(ShareData.selected_auction.current_cost!)!
            {
                CommonFuncs().doneAlert(ShareData.appTitle, "Your bid cost must be highter than current cost", "CLOSE", {return})
                
            }
            
            self.bid_place_btn.isUserInteractionEnabled = false

            let send_time = CommonFuncs().currentTime()
            
            let parmeters = ["user_id": ShareData.user_info.id!, "auction_id": ShareData.selected_auction.id!, "bid_cost": bid_in.text!, "time": send_time, "time_zone": ShareData.user_info.time_zone!] as [String: Any]
            
            self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: progressDlg, color: .darkGray, fadeInAnimation: nil)

            CommonFuncs().createRequest(false, "auction/bid", "POST", parmeters, completionHandler: {data in

                let status = data["status"] as! Bool
                let message = data["message"] as! String

                DispatchQueue.main.async {

                    self.stopAnimating(nil)
                    
                    self.bid_frame.isHidden = true
                    self.bid_place_btn.isUserInteractionEnabled = true
                        
                    if let index = ShareData.selected_auction_bidders.index(where: { $0.user_id! == ShareData.user_info.id! })
                    {
                        ShareData.selected_auction_bidders[index].cost = self.bid_in.text!
                    }
                    else
                    {
                        
                        let cell = ["bidder_id": "", "auction_id": ShareData.selected_auction.id!, "user_id": ShareData.user_info.id!, "name": ShareData.user_info.name!, "photo": ShareData.user_info.photo!, "cost": self.bid_in.text!, "time": send_time, "time_zone": ShareData.user_info.time_zone!, "on_status": "1"] as [String: Any]
                        
                        if let temp = Mapper<AuctionBidMDL>().map(JSONObject: cell)
                        {
                            ShareData.selected_auction_bidders.append(temp)
                        }
                    }
                    
                    
                    CommonFuncs().doneAlert(ShareData.appTitle, message, "CLOSE", {self.current_bid_label.attributedText = CommonFuncs().attributeString([UIFont.boldSystemFont(ofSize: 15)], [Utility.color(withHexString: ShareData.btn_color)],  [self.bid_in.text!])
                        UIView.animate(withDuration: 2.0) {
                            
                            self.current_bid_progress.value = CGFloat(Int(self.bid_in.text!)!)
                            self.place_bid_btn.setTitle("UPDATE BID", for: .normal)
                            self.bid_place_btn.setTitle("Update Bid", for: .normal)
                        }
                        self.tableView.reloadData()})
                }
            })
        }
        
        
    }
    
    @IBAction func bidCancelAction(_ sender: Any) {
        
        bid_frame.isHidden = true
        scroll.isHidden = false
    }

}


extension MoreAuctionBidVC: UITextFieldDelegate
{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        bid_in.resignFirstResponder()
        return true
    }
    
}


extension MoreAuctionBidVC
{
    
    @objc func followAction(_ sender: UIButton) {
        
        self.edit_auction_btn.isUserInteractionEnabled = false
        
        let send_time = CommonFuncs().currentTime()
        
        let parmeters = ["user_id": ShareData.user_info.id!, "auction_id": ShareData.selected_auction.id!, "time": send_time, "time_zone": ShareData.user_info.time_zone!] as [String: Any]
        
        self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: progressDlg, color: .darkGray, fadeInAnimation: nil)
        
        CommonFuncs().createRequest(false, "auction/follow", "POST", parmeters, completionHandler: {data in
            
            let status = data["status"] as! Bool
            let message = data["message"] as! String
            
            DispatchQueue.main.async {
                
                self.stopAnimating(nil)
                
                self.edit_auction_btn.isUserInteractionEnabled = true
                CommonFuncs().doneAlert(ShareData.appTitle, message, "DONE", {})
                
            }
        })
    }
    
    @objc func editAction(_ sender: UIButton) {
        
        ShareData.auciton_create_edit = true
        self.navigationController?.pushViewController(MoreInfluencerAuctionNewVC(), animated: true)
    }
    
    
    
}

extension MoreAuctionBidVC: UITableViewDelegate, UITableViewDataSource
{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return ShareData.selected_auction_bidders.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 75
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell : ChatListCell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell", for: indexPath) as! ChatListCell
        
        
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none  // remove grey when selected
        
        cell.select_bar.isHidden = false
        cell.select_bar.backgroundColor = UIColor.white
        
        cell.select_bar.layer.masksToBounds = true
        cell.select_bar.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        cell.select_bar.clipsToBounds = true
        
        if ShareData.selected_auction.status! == "1" && indexPath.row == 0
        {
            cell.select_bar.dropShadow(color: .red, opacity: 0.5, offSet: CGSize.zero, radius: 5, scale: true)
        }
        else
        {
            cell.select_bar.dropShadow(color: .gray, opacity: 0.5, offSet: CGSize.zero, radius: 5, scale: true)
        }
        
        let data = ShareData.selected_auction_bidders[indexPath.section]
        
        cell.photo.load(url: data.photo!)
        cell.photo.layer.cornerRadius = cell.photo.frame.width / 2
        cell.photo.clipsToBounds = true
        
        cell.name.attributedText = CommonFuncs().attributeString([UIFont.boldSystemFont(ofSize: 15), UIFont.systemFont(ofSize: 13)], [Utility.color(withHexString: ShareData.btn_color), Utility.color(withHexString: ShareData.btn_color)],  [CommonFuncs().kiloData(num: data.cost!), " PopCoin"])
        cell.name.font = UIFont.boldSystemFont(ofSize: 15)
        cell.name.textColor = Utility.color(withHexString: ShareData.btn_color)
        cell.last_msg.text = data.name!
        cell.last_msg.font = UIFont.systemFont(ofSize: 13)
        cell.last_msg.textColor = UIColor.black
        cell.last_time.text = CommonFuncs().historyTime(data.time!, data.time_zone!)
        cell.under_line.isHidden = true
        
        cell.unread_frame.isHidden = true
        
        cell.camera_img.isHidden = true
        cell.last_msg_left_constrain.constant = 0
        
        cell.status.layer.cornerRadius = cell.status.frame.width / 2
        cell.status.clipsToBounds = true
        
        if data.on_status == "1"
        {
            cell.status.backgroundColor = UIColor.green
            cell.status.dropShadow(color: .green, opacity: 1, offSet: CGSize.zero, radius: 4, scale: true)
        }
        else
        {
            cell.status.backgroundColor = UIColor.gray
            cell.status.dropShadow(color: .gray, opacity: 1, offSet: CGSize.zero, radius: 4, scale: true)
        }
        
        return cell
        
    }
}

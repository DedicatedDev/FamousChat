//
//  MoreAuctionVC.swift
//  famouschat
//
//  Created by T-Tech Solutions LLC on 09/11/2018.
//  Copyright © 2018 T-Tech Solutions LLC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import ObjectMapper

class MoreAuctionVC: UIViewController, NVActivityIndicatorViewable {
    
    @IBOutlet weak var back_img: UIImageView!
    @IBOutlet weak var back_btn: UIButton!
    @IBOutlet weak var menu_img: UIImageView!
    @IBOutlet weak var menu_btn: UIButton!
    @IBOutlet weak var header_frame: UIView!
    @IBOutlet weak var following_bar: UIView!
    @IBOutlet weak var following_btn: UIButton!
    @IBOutlet weak var all_bar: UIView!
    @IBOutlet weak var all_btn: UIButton!
    @IBOutlet weak var charit_bar: UIView!
    @IBOutlet weak var charit_btn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var search_frame: UIView!
    @IBOutlet weak var search_in: UITextField!
    @IBOutlet weak var search_img: UIImageView!
    
    let progressDlg = ShareData.progressDlgs[ShareData.progress_index]
    
    var auction_list = [AuctionMDL]()
    var auction_filter_list = [AuctionMDL]()
    var following_auction_list = [AuctionMDL]()
    var following_auction_filter_list = [AuctionMDL]()
    var charity_auction_list = [[AuctionMDL]]()
    var charity_auction_filter_list = [[AuctionMDL]]()
    var tab_index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.tableView.separatorColor = UIColor.clear
        self.tableView.separatorStyle = .none
        self.tableView.tableFooterView = UIView()
        
        self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: progressDlg, color: .darkGray, fadeInAnimation: nil)
        
        let parmeters = ["user_id": ShareData.user_info.id!, "status": "1"] as [String: Any]
        
        CommonFuncs().createRequest(false, "auction/request", "POST", parmeters, completionHandler: {data in
            
            let status = data["status"] as! Bool
            let message = data["message"] as! String
            
            DispatchQueue.main.async {
                
                self.stopAnimating(nil)
                if status
                {
                    let response_data = data["data"] as! [String: Any]
                    
                    if let temp = Mapper<AuctionMDL>().mapArray(JSONObject: response_data["auctions"])
                    {
                        self.auction_list = temp
                        self.following_auction_list = temp.filter {$0.followers!.contains(",\(ShareData.user_info.id!),")}
                        let array = Dictionary(grouping: temp, by: { $0.charity_id! })
                        for cell in array
                        {
                            self.charity_auction_list.append(cell.value)
                        }
                       
                    }
                    
                    
                    self.tab_index = 0
                    self.auction_filter_list = self.auction_list
                    self.following_auction_filter_list = self.following_auction_list
                    self.charity_auction_filter_list = self.charity_auction_list                    
                    
                    self.tableView.delegate = self
                    self.tableView.dataSource = self
                    self.tableView.register(UINib(nibName: "FeedPhotoCell", bundle: nil), forCellReuseIdentifier: "FeedPhotoCell")
                    self.tableView.register(UINib(nibName: "SocialCell", bundle: nil), forCellReuseIdentifier: "SocialCell")
                    self.tableView.reloadData()
                    
                }
                else
                {
                    CommonFuncs().doneAlert(ShareData.appTitle, message, "CLOSE", {})
                }
                
            }
        })
        
        init_UI()
        
    }
    
    func init_UI()
    {
        self.navigationController?.isNavigationBarHidden = true
        
        header_frame.dropShadow(color: .gray, opacity: 0.5, offSet: CGSize.zero, radius: 8, scale: true)
        
        let back_image = UIImage.init(named: "back")!.withRenderingMode(.alwaysTemplate)
        back_img.image = back_image
        back_img.tintColor = Utility.color(withHexString: ShareData.btn_color)
        
        let menu_image = UIImage.init(named: "menu_1")!.withRenderingMode(.alwaysTemplate)
        menu_img.image = menu_image
        menu_img.tintColor = Utility.color(withHexString: ShareData.btn_color)
        
        menu_btn.addTarget(self.slideMenuController, action: #selector(slideMenuController.toggleMenuAnimated(_:)), for: .touchUpInside)
        back_btn.addTarget(self, action: #selector(self.backAction(_:)), for: .touchUpInside)
        
        following_bar.backgroundColor = Utility.color(withHexString: ShareData.btn_color)
        all_bar.backgroundColor = UIColor.white
        charit_bar.backgroundColor = UIColor.white
        
        search_in.delegate = self
        search_in.returnKeyType = .search
        search_in.textColor = Utility.color(withHexString: ShareData.btn_color)
        search_in.colorPlaceHolder("Search..", Utility.color(withHexString: ShareData.btn_color))
        
        search_frame.layer.cornerRadius = search_frame.frame.height / 2
        search_frame.clipsToBounds = true
        search_frame.layer.borderWidth = 1
        search_frame.layer.borderColor = Utility.color(withHexString: ShareData.btn_color)?.cgColor
        
        let image = UIImage.init(named: "menu_search")?.withRenderingMode(.alwaysTemplate)
        search_img.image = image
        search_img.tintColor = Utility.color(withHexString: ShareData.btn_color)
        
        
    }
    
    @IBAction func followAction(_ sender: Any) {
        
        following_bar.backgroundColor = Utility.color(withHexString: ShareData.btn_color)
        all_bar.backgroundColor = UIColor.white
        charit_bar.backgroundColor = UIColor.white
        tab_index = 0
        search_in.colorPlaceHolder("Search..", Utility.color(withHexString: ShareData.btn_color))
        self.following_auction_filter_list = self.following_auction_list
        tableView.reloadData()
    }
    
    @IBAction func allAction(_ sender: Any) {
        
        following_bar.backgroundColor = UIColor.white
        all_bar.backgroundColor = Utility.color(withHexString: ShareData.btn_color)
        charit_bar.backgroundColor = UIColor.white
        tab_index = 1
        search_in.colorPlaceHolder("Search..", Utility.color(withHexString: ShareData.btn_color))
        self.auction_filter_list = self.auction_list
        tableView.reloadData()
    }
    
    @IBAction func charitAction(_ sender: Any) {
        
        following_bar.backgroundColor = UIColor.white
        all_bar.backgroundColor = UIColor.white
        charit_bar.backgroundColor = Utility.color(withHexString: ShareData.btn_color)
        tab_index = 2
        search_in.colorPlaceHolder("Search Name..", Utility.color(withHexString: ShareData.btn_color))
        self.charity_auction_filter_list = self.charity_auction_list
        tableView.reloadData()
    }
    
    @IBAction func searchAction(_ sender: Any) {
        
        let str = search_in.text!.lowercased()
        if tab_index == 0
        {
            if str == nil || str == ""
            {
                following_auction_filter_list = following_auction_list
            }
            else
            {
                following_auction_filter_list = following_auction_list.filter { $0.name!.lowercased().contains(str)}
                
            }
        }
        else if tab_index == 1
        {
            if str == nil || str == ""
            {
                auction_filter_list = auction_list
            }
            else
            {
                auction_filter_list = auction_list.filter { $0.name!.lowercased().contains(str)}
            }
        }
        else
        {
            if str == nil || str == ""
            {
                charity_auction_filter_list = charity_auction_list
            }
            else
            {
                charity_auction_filter_list = [[AuctionMDL]]()
                
                for cell in charity_auction_list
                {
                    
                    let charity_index = ShareData.charity_list.index { $0.id == cell[0].charity_id! }
                    let name = ShareData.charity_list[charity_index!].name!
                    
                    if !name.lowercased().contains(str)
                    {
                        charity_auction_filter_list.append(cell)
                    }
                }
                
            }
        }
        
        tableView.reloadData()
    }
    
    
    @objc func backAction(_ sender: UIButton) {
        
        ShareData.main_or_more_status = true
        UIApplication.shared.keyWindow?.setRootViewController(MainTabVC(), options: UIWindow.TransitionOptions(direction: .toLeft, style: .easeIn), slide_direction: .fromLeftToRight)
    }
    
}


extension MoreAuctionVC: UITextFieldDelegate
{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        search_in.resignFirstResponder()
        
        return (true)
    }
    
}


extension MoreAuctionVC: UITableViewDelegate, UITableViewDataSource
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tab_index == 0
        {
            return self.following_auction_filter_list.count
        }
        else if tab_index == 1
        {
            return self.auction_filter_list.count
        }
        else
        {
            return self.charity_auction_filter_list.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tab_index == 2
        {
            return 65
        }
        else
        {
            return 70
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        var data: AuctionMDL!
        
        if tab_index == 2
        {
            let cell : SocialCell = tableView.dequeueReusableCell(withIdentifier: "SocialCell", for: indexPath) as! SocialCell
            
            cell.backgroundColor = UIColor.clear
            cell.contentView.backgroundColor = UIColor.clear
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            data = charity_auction_filter_list[indexPath.row][0]
            let charity_index = ShareData.charity_list.index { $0.id == data.charity_id! }
            
            cell.img.load(url: ShareData.charity_list[charity_index!].photo!)
            cell.name.text = ShareData.charity_list[charity_index!].name!
            
            cell.img.layer.cornerRadius = cell.img.frame.height / 2
            cell.img.clipsToBounds = true
            
            cell.img.layer.borderWidth = 1
            cell.img.layer.borderColor = UIColor.gray.cgColor
            
            let image = UIImage(named: "go")?.withRenderingMode(.alwaysTemplate)
            cell.go_img.image = image
            cell.go_img.tintColor = UIColor.darkGray
            
            return cell
            
        }
        else
        {
            let cell : FeedPhotoCell = tableView.dequeueReusableCell(withIdentifier: "FeedPhotoCell", for: indexPath) as! FeedPhotoCell
            
            cell.backgroundColor = UIColor.clear
            cell.contentView.backgroundColor = UIColor.clear
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            if tab_index == 0
            {
                data = following_auction_filter_list[indexPath.row]
            }
            else
            {
                data = auction_filter_list[indexPath.row]
            }
            
            cell.photo.load(url: data.photo!)
            cell.photo.layer.cornerRadius = cell.photo.frame.width / 2
            cell.photo.clipsToBounds = true
            
            cell.name.text = data.name!
            
            let array = CommonFuncs().splitString(data.start_time!)
            cell.history.text = "\(ShareData.month_names[Int(array[1])! - 1]) \(array[2]), \(array[0])"
            
            let charity_index = ShareData.charity_list.index { $0.id == data.charity_id! }
            cell.message.text = "Auction for \(ShareData.charity_list[charity_index!].name!)"
            cell.message.textColor = Utility.color(withHexString: ShareData.btn_color)
            cell.message.font = UIFont.boldSystemFont(ofSize: 14)
            
            return cell
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tab_index == 2
        {
            ShareData.selected_charity_auctions = charity_auction_filter_list[indexPath.row]
            self.navigationController?.pushViewController(MoreAuctionCharityVC(), animated: true)
        }
        else
        {
            self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: progressDlg, color: .darkGray, fadeInAnimation: nil)
            
            var auction_id = ""
            if tab_index == 0
            {
                auction_id = following_auction_filter_list[indexPath.row].id!
                ShareData.selected_auction = following_auction_filter_list[indexPath.row]
            }
            else
            {
                auction_id = auction_filter_list[indexPath.row].id!
                ShareData.selected_auction = auction_filter_list[indexPath.row]
            }
            
            let parmeters = ["auction_id": auction_id] as [String: Any]
            
            CommonFuncs().createRequest(false, "auction/request", "POST", parmeters, completionHandler: {data in
                
                let status = data["status"] as! Bool
                let message = data["message"] as! String
                
                DispatchQueue.main.async {
                    
                    self.stopAnimating(nil)
                    if status
                    {
                        let response_data = data["data"] as! [String: Any]
                        
                        if let temp = Mapper<AuctionBidMDL>().mapArray(JSONObject: response_data["bidders"])
                        {
                            ShareData.selected_auction_bidders = temp
                        }
                        
                        self.navigationController?.pushViewController(MoreAuctionBidVC(), animated: true)
                        
                    }
                    else
                    {
                        CommonFuncs().doneAlert(ShareData.appTitle, message, "CLOSE", {})
                    }
                    
                }
            })
        }
    }
}


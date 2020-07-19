//
//  MoreInfluencerAuctionVC.swift
//  famouschat
//
//  Created by T-Tech Solutions LLC on 11/11/2018.
//  Copyright © 2018 T-Tech Solutions LLC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import ObjectMapper

class MoreInfluencerAuctionVC: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet weak var back_img: UIImageView!
    @IBOutlet weak var back_btn: UIButton!
    @IBOutlet weak var header_frame: UIView!
    @IBOutlet weak var menu_btn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let progressDlg = ShareData.progressDlgs[ShareData.progress_index]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        ShareData.auction_list = [AuctionMDL]()
        
        init_UI()
    }
    
    func init_UI()
    {
        self.navigationController?.isNavigationBarHidden = true
        
        header_frame.dropShadow(color: .gray, opacity: 0.5, offSet: CGSize.zero, radius: 8, scale: true)
       
        let back_image = UIImage.init(named: "back")!.withRenderingMode(.alwaysTemplate)
        back_img.image = back_image
        back_img.tintColor = Utility.color(withHexString: ShareData.btn_color)
        
        back_btn.addTarget(self, action: #selector(self.backAction(_:)), for: .touchUpInside)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "SocialCell", bundle: nil), forCellReuseIdentifier: "SocialCell")
        self.tableView.separatorColor = UIColor.lightGray
        self.tableView.separatorStyle = .none
        self.tableView.tableFooterView = UIView()
        
        self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: progressDlg, color: .darkGray, fadeInAnimation: nil)
        
        let parmeters = ["user_id": ShareData.user_info.id!, "status": "0"] as [String: Any]
        
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
                        ShareData.auction_list = temp
                    }
                    
                    self.tableView.reloadData()
                }
                else
                {
                    CommonFuncs().doneAlert(ShareData.appTitle, message, "CLOSE", {})
                }
                
            }
        })
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        tableView.reloadData()
    }
    
    @IBAction func createAction(_ sender: Any) {
        
        ShareData.auciton_create_edit = false
        self.navigationController?.pushViewController(MoreInfluencerAuctionNewVC(), animated: true)
    }
    
    @objc func backAction(_ sender: UIButton) {
        
        ShareData.main_or_more_status = true
        UIApplication.shared.keyWindow?.setRootViewController(MainTabVC(), options: UIWindow.TransitionOptions(direction: .toLeft, style: .easeIn), slide_direction: .fromLeftToRight)
    }
    

}


extension MoreInfluencerAuctionVC: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return ShareData.auction_list.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell : SocialCell = tableView.dequeueReusableCell(withIdentifier: "SocialCell", for: indexPath) as! SocialCell
        
        cell.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        let data = ShareData.auction_list[indexPath.row]
        cell.img.isHidden = true
        cell.name.text = CommonFuncs().timeString("\(data.start_time!)-00-00", "", 1)
        cell.name.font = UIFont.systemFont(ofSize: 15)
        
        let image = UIImage(named: "go")?.withRenderingMode(.alwaysTemplate)
        cell.go_img.image = image
        cell.go_img.tintColor = UIColor.darkGray
        cell.left_constrain.constant = 10
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: progressDlg, color: .darkGray, fadeInAnimation: nil)
        
        ShareData.selected_auction = ShareData.auction_list[indexPath.row]
        let parmeters = ["auction_id": ShareData.auction_list[indexPath.row].id!] as [String: Any]
        
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
                    self.stopAnimating(nil)
                    
                    self.navigationController?.pushViewController(MoreAuctionBidVC(), animated: true)
                    
                }
                else
                {
                    self.stopAnimating(nil)
                    CommonFuncs().doneAlert(ShareData.appTitle, message, "CLOSE", {})
                }
                
            }
        })
        
    }
    
}

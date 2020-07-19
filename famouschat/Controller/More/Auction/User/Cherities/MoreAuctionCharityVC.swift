//
//  MoreAuctionCharityVC.swift
//  famouschat
//
//  Created by T-Tech Solutions LLC on 11/11/2018.
//  Copyright © 2018 T-Tech Solutions LLC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import ObjectMapper

class MoreAuctionCharityVC: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet weak var back_img: UIImageView!
    @IBOutlet weak var back_btn: UIButton!
    @IBOutlet weak var menu_img: UIImageView!
    @IBOutlet weak var menu_btn: UIButton!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var photo_height: NSLayoutConstraint!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var search_frame: UIView!
    @IBOutlet weak var search_in: UITextField!
    @IBOutlet weak var search_img: UIImageView!
    
    let progressDlg = ShareData.progressDlgs[ShareData.progress_index]
    var filter_list = [AuctionMDL]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        filter_list = ShareData.selected_charity_auctions
        
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
        
        let charity_index = ShareData.charity_list.index { $0.id == ShareData.selected_charity_auctions[0].charity_id! }
        
        photo_height.constant = photo.frame.width * 0.7
        photo.load(url: ShareData.charity_list[charity_index!].photo!)
        name.text = ShareData.charity_list[charity_index!].name!
        
        search_in.delegate = self
        search_in.textColor = Utility.color(withHexString: ShareData.btn_color)
        search_in.colorPlaceHolder("Search", Utility.color(withHexString: ShareData.btn_color))
        
        search_frame.layer.cornerRadius = search_frame.frame.height / 2
        search_frame.clipsToBounds = true
        search_frame.layer.borderWidth = 1
        search_frame.layer.borderColor = Utility.color(withHexString: ShareData.btn_color)?.cgColor
        
        let image = UIImage.init(named: "menu_search")?.withRenderingMode(.alwaysTemplate)
        search_img.image = image
        search_img.tintColor = Utility.color(withHexString: ShareData.btn_color)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "FeedPhotoCell", bundle: nil), forCellReuseIdentifier: "FeedPhotoCell")
        tableView.separatorColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        
    }

    @IBAction func searchAction(_ sender: Any) {
        
        let str = search_in.text!.lowercased()
        
        if str == "" || str == nil
        {
            filter_list = ShareData.selected_charity_auctions
        }
        else
        {
            filter_list = ShareData.selected_charity_auctions.filter { $0.name.lowercased().contains(str)}
        }
        
        tableView.reloadData()
    }
    
    
    @objc func backAction(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
}

extension MoreAuctionCharityVC: UITextFieldDelegate
{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        search_in.resignFirstResponder()
        
        return (true)
    }
    
}

extension MoreAuctionCharityVC: UITableViewDelegate, UITableViewDataSource
{ 
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return filter_list.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 70
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell : FeedPhotoCell = tableView.dequeueReusableCell(withIdentifier: "FeedPhotoCell", for: indexPath) as! FeedPhotoCell
        
        cell.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        let data = filter_list[indexPath.row]
        
       
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let auction_id = filter_list[indexPath.row].id!
        ShareData.selected_auction = filter_list[indexPath.row]
        
        self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: progressDlg, color: .darkGray, fadeInAnimation: nil)
        
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


//
//  MainBookDetailProfileVC.swift
//  famouschat
//
//  Created by angel oni on 2019/5/12.
//  Copyright © 2019 Oni Angel. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import ObjectMapper

class MainBookDetailProfileVC: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var photo_height: NSLayoutConstraint!
    
    @IBOutlet weak var back_img: UIImageView!
    @IBOutlet weak var back_btn: UIButton!
    @IBOutlet weak var menu_img: UIImageView!
    @IBOutlet weak var menu_btn: UIButton!
    
    @IBOutlet weak var profile_frame: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var bio: UILabel!
    @IBOutlet weak var bio_height: NSLayoutConstraint!
    @IBOutlet weak var follwoing_num: UILabel!
    @IBOutlet weak var follower_num: UILabel!
    @IBOutlet weak var rating_num: UILabel!
    @IBOutlet weak var follow_btn: UIButton!
    @IBOutlet weak var msg_frame: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    let progressDlg = ShareData.progressDlgs[ShareData.progress_index]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.init_UI()
        
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
        profile_frame.dropShadow(color: .gray, opacity: 0.5, offSet: CGSize.zero, radius: 5, scale: true)
        photo.load(url: ShareData.user_detail_profile.photo!)
        
        if ShareData.user_detail_profile.permission! == "0"
        {
            bio_height.constant = 0
        }
        else
        {            
            bio_height.constant = CommonFuncs().getStringHeight(ShareData.user_detail_profile.bio!, 13, UIScreen.main.bounds.width, 25, 5)
            bio.text = ShareData.user_detail_profile.bio!
        }
        
        name.text = ShareData.user_detail_profile.name!
      
        follow_btn.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        follow_btn.clipsToBounds = true
        follow_btn.dropShadow(color: .gray, opacity: 0.8, offSet: CGSize.zero, radius: 3, scale: true)
        
        msg_frame.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        msg_frame.clipsToBounds = true
        msg_frame.dropShadow(color: .gray, opacity: 0.8, offSet: CGSize.zero, radius: 3, scale: true)
        
        follower_num.text = ShareData.user_detail_profile.follow_num!
        follwoing_num.text = ShareData.user_detail_profile.following_num!
        rating_num.text = String(format: "%.01f", Double(ShareData.user_detail_profile.rate!)!)
        
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "ReviewCell", bundle: nil), forCellReuseIdentifier: "ReviewCell")
        self.tableView.separatorColor = UIColor.clear
        self.tableView.separatorStyle = .none
        self.tableView.tableFooterView = UIView()
        
    }
    
    
    @IBAction func followAction(_ sender: Any) {
        
        self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: progressDlg, color: .darkGray, fadeInAnimation: nil)
        
        let send_time = CommonFuncs().currentTime()
        
        let parmeters = ["normal_id": ShareData.user_info.id!, "influencer_id": ShareData.user_detail_profile.id!, "time": send_time, "time_zone": ShareData.user_info.time_zone!] as [String: Any]
        
        CommonFuncs().createRequest(false, "follow/request", "POST", parmeters, completionHandler: {data in
            
            let status = data["status"] as! Bool
            let message = data["message"] as! String
            
            DispatchQueue.main.async {
                
                self.stopAnimating(nil)
                CommonFuncs().doneAlert(ShareData.appTitle, message, "CLOSE", {})
                
            }
        })
        
    }
    
    @IBAction func msgAction(_ sender: Any) {
       
       ShareData.msg_vc_from = "0"
        self.navigationController?.pushViewController(MainTrendProfileMsgVC(), animated: true)
    }
    
    @objc func backAction(_ sender: UIButton) {

        self.navigationController?.popViewController(animated: true)
        
    }

}

extension MainBookDetailProfileVC: UITableViewDelegate, UITableViewDataSource
{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return ShareData.user_detail_reviews.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return CommonFuncs().getStringHeight(ShareData.user_detail_reviews[indexPath.row].review, 15, UIScreen.main.bounds.width, 100, 50)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell : ReviewCell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! ReviewCell
        
        cell.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        let data = ShareData.user_detail_reviews[indexPath.row]
        
        cell.photo.load(url: data.photo!)
        cell.photo.layer.cornerRadius = cell.photo.frame.height / 2
        cell.photo.clipsToBounds = true
        
        cell.name.text = data.name!
        
        cell.post_date.text = CommonFuncs().historyTime(data.time!, data.time_zone!)
        
        CommonFuncs().likeStars((Double(data.mark1)! + Double(data.mark2)! + Double(data.mark3)!) / 3, cell.like_stars)
        
        cell.review.text = data.review!
        
        return cell
        
    }
    
}

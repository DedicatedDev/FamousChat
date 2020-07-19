//
//  MoreRateVC.swift
//  famouschat
//
//  Created by T-Tech Solutions LLC on 09/11/2018.
//  Copyright © 2018 T-Tech Solutions LLC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import ObjectMapper

class MoreRateVC: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet weak var header_frame: UIView!
    @IBOutlet weak var back_img: UIImageView!
    @IBOutlet weak var back_btn: UIButton!
    @IBOutlet weak var menu_img: UIImageView!
    @IBOutlet weak var menu_btn: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var rate_frame: UIView!
    
    @IBOutlet weak var minute_today: UILabel!
    @IBOutlet weak var minute_month_frame: UIView!
    @IBOutlet weak var minute_month: UILabel!
    @IBOutlet weak var minute_year_frame: UIView!
    @IBOutlet weak var minute_year: UILabel!
    @IBOutlet weak var minute_total_frame: UIView!
    @IBOutlet weak var minute_total: UILabel!
    
    @IBOutlet weak var earn_today: UILabel!
    @IBOutlet weak var earn_month_frame: UIView!
    @IBOutlet weak var earn_month: UILabel!
    @IBOutlet weak var earn_year_frame: UIView!
    @IBOutlet weak var earn_year: UILabel!
    @IBOutlet weak var earn_total_frame: UIView!
    @IBOutlet weak var earn_total: UILabel!
    
    @IBOutlet weak var call_today: UILabel!
    @IBOutlet weak var call_month_frame: UIView!
    @IBOutlet weak var call_month: UILabel!
    @IBOutlet weak var call_year_frame: UIView!
    @IBOutlet weak var call_year: UILabel!
    @IBOutlet weak var call_total_frame: UIView!
    @IBOutlet weak var call_total: UILabel!
    
    @IBOutlet weak var review_frame: UIView!
    @IBOutlet weak var review_go_img: UIImageView!
    
    
    @IBOutlet weak var rate_label: UILabel!
    @IBOutlet weak var like_0: UIImageView!
    @IBOutlet weak var like_1: UIImageView!
    @IBOutlet weak var like_2: UIImageView!
    @IBOutlet weak var like_3: UIImageView!
    @IBOutlet weak var like_4: UIImageView!
    @IBOutlet weak var go_img: UIImageView!
    
    
    
    var like_stars = [UIImageView]()
    
    let progressDlg = ShareData.progressDlgs[ShareData.progress_index]
    var collectionViewLayout: LGHorizontalLinearFlowLayout?

    let rate_cnt = ShareData.rank_info.category_rank!.count + 1
    var shadow_10_views = [UIView]()
    var shadow_5_views = [UIView]()
    
    var selectedIndexPath: IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        like_stars = [like_0, like_1, like_2, like_3, like_4]
        shadow_10_views = [header_frame]
        shadow_5_views = [rate_frame, minute_month_frame, minute_year_frame, minute_total_frame, earn_month_frame, earn_year_frame, earn_total_frame, call_month_frame, call_year_frame, call_total_frame]
        
        init_UI()
    }

    func init_UI()
    {
        
        self.navigationController?.isNavigationBarHidden = true
        
        let back_image = UIImage.init(named: "back")!.withRenderingMode(.alwaysTemplate)
        back_img.image = back_image
        back_img.tintColor = Utility.color(withHexString: "10A7BA")
        
     //   let menu_image = UIImage.init(named: "menu_1")!.withRenderingMode(.alwaysTemplate)
      //  menu_img.image = menu_image
     //   menu_img.tintColor = Utility.color(withHexString: ShareData.btn_color)
        
        let go_image = UIImage.init(named: "go")!.withRenderingMode(.alwaysTemplate)
        go_img.image = go_image
        go_img.tintColor = UIColor.darkGray
        
    // menu_btn.addTarget(self.slideMenuController, action: #selector(slideMenuController.toggleMenuAnimated(_:)), for: .touchUpInside)
        back_btn.addTarget(self, action: #selector(self.backAction(_:)), for: .touchUpInside)
        
        
        for cell in shadow_10_views
        {
            cell.dropShadow(color: .gray, opacity: 0.8, offSet: CGSize.zero, radius: 10, scale: true)
        }
        for cell in shadow_5_views
        {
            cell.layer.cornerRadius = CGFloat(ShareData.btn_radius)
            cell.clipsToBounds = true
            cell.dropShadow(color: .gray, opacity: 0.8, offSet: CGSize.zero, radius: 5, scale: true)
        }
        
        rate_label.text = String(format: "%.01f", Double(ShareData.user_info.rate!)!)
        CommonFuncs().likeStars(Double(ShareData.user_info.rate!)!, [like_0, like_1, like_2, like_3, like_4])
        
        let data = ShareData.rank_info!
        minute_today.text = "\(data.today_minutes!)"
        minute_month.text = "\(data.month_minutes!)"
        minute_year.text = "\(data.year_minutes!)"
        minute_total.text = "\(data.total_minutes!)"
        
        let array = CommonFuncs().splitString(ShareData.user_info.chat_rate!.characters.split(separator: ",").map(String.init)[0])
        let rate = (Double(array[2])! + Double(array[3])! / 100) / (Double(array[0])! * 60 + Double(array[1])!)
        
        earn_today.text = String(format: "%.01f", rate * Double(data.today_minutes!)!)
        earn_month.text = String(format: "%.01f", rate * Double(data.month_minutes!)!)
        earn_year.text = String(format: "%.01f", rate * Double(data.year_minutes!)!)
        earn_total.text = String(format: "%.01f", rate * Double(data.total_minutes!)!)
        
        call_today.text = "\(data.today_calls!)"
        call_month.text = "\(data.month_calls!)"
        call_year.text = "\(data.year_calls!)"
        call_total.text = "\(data.total_calls!)"
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "RateCell", bundle: nil), forCellWithReuseIdentifier: "RateCell")
        
        let height = collectionView.frame.height - 10
        let width = height
        
        collectionViewLayout = LGHorizontalLinearFlowLayout.init(configuredWith: collectionView, itemSize: CGSize(width: width, height: height), minimumLineSpacing: 0)
        
//        self.tableView.separatorColor = UIColor.clear
//        self.tableView.separatorStyle = .none
//        self.tableView.tableFooterView = UIView()
//
//        self.tableView.delegate = self
//        self.tableView.dataSource = self
//        self.tableView.register(UINib(nibName: "ReviewCell", bundle: nil), forCellReuseIdentifier: "ReviewCell")
            
        
    }
    
    override func viewDidLayoutSubviews() {
        
        let indexPath = IndexPath(item: rate_cnt / 2, section: 0)
        self.collectionView.scrollToItem(at: indexPath, at: [.centeredVertically,   .centeredHorizontally], animated: true)
    }
    
    @objc func backAction(_ sender: UIButton) {

        ShareData.main_or_more_status = true
        UIApplication.shared.keyWindow?.setRootViewController(MainTabVC(), options: UIWindow.TransitionOptions(direction: .toLeft, style: .easeIn), slide_direction: .fromLeftToRight)
    }
    
    @IBAction func reviewAction(_ sender: Any) {
        
        ShareData.review_from_status = true
        ShareData.rate_or_follow_status = true
        
        self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: progressDlg, color: .darkGray, fadeInAnimation: nil)
        let parmeters = ["user_id": ShareData.user_info.id!, "type": "0"] as [String: Any]
        
        CommonFuncs().createRequest(false, "review/request", "POST", parmeters, completionHandler: {data in
            
            let status = data["status"] as! Bool
            let message = data["message"] as! String
            
            DispatchQueue.main.async {
                
                if status
                {
                    if let detail = data["data"] as? [AnyHashable:Any], let temp = Mapper<ReviewMDL>().mapArray(JSONObject: detail["reviews"])
                    {
                        ShareData.reviews = temp
                        self.navigationController?.pushViewController(MoreRateReviewVC(), animated: true)
                    }
                    else
                    {
                        CommonFuncs().doneAlert(ShareData.appTitle, "There are currently no reviews", "CLOSE", {})
                    }
                }
                else
                {
                    CommonFuncs().doneAlert(ShareData.appTitle, "There are currently no reviews", "CLOSE", {})
                }
                
                self.stopAnimating(nil)
            }
        })
    }
    

}

extension MoreRateVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return rate_cnt
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 50
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        let height = collectionView.frame.height - 10
        let width = height
        

        return CGSize(width: width, height: height)
        
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RateCell", for: indexPath) as! RateCell
     
        
        cell.first_frame.layer.cornerRadius = cell.first_frame.frame.height / 2
        cell.first_frame.clipsToBounds = true
        
        let data = ShareData.rank_info!
        let array = CommonFuncs().splitString(ShareData.user_info.category!)
        
        
        if indexPath.row == rate_cnt / 2
        {
            cell.rate.text = "\(data.total_rank!)"
            cell.category.text = "GENERAL RANKING"
        }
        else if indexPath.row < rate_cnt / 2
        {
            cell.rate.text = "\(data.category_rank[indexPath.row])"
            cell.category.text = ShareData.category_list.filter{$0.id! == array[indexPath.row]}[0].name!.uppercased()
        }
        else
        {
            cell.rate.text = "\(data.category_rank[indexPath.row - 1])"
            cell.category.text = ShareData.category_list.filter{$0.id! == array[indexPath.row - 1]}[0].name!.uppercased()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedIndexPath = indexPath
    }
    
}


extension MoreRateVC: UITableViewDelegate, UITableViewDataSource
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return ShareData.reviews.count
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return CommonFuncs().getStringHeight(ShareData.reviews[indexPath.row].review, 15, UIScreen.main.bounds.width, 100, 60)
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell : ReviewCell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! ReviewCell
        
        cell.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        let data = ShareData.reviews[indexPath.row]
        
        cell.photo.load(url: data.photo!)
        cell.photo.layer.cornerRadius = cell.photo.frame.height / 2
        cell.photo.clipsToBounds = true
        
        cell.name.text = data.name!
        
        cell.post_date.text = CommonFuncs().historyTime(data.time!, data.time_zone!)
        
        CommonFuncs().likeStars((Double(data.mark1!)! + Double(data.mark2!)! + Double(data.mark3!)!) / 3, cell.like_stars)
        
        cell.review.text = data.review!
        
        return cell
        
        
    }
    
}

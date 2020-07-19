//
//  MoreRateReviewVC.swift
//  famouschat
//
//  Created by angel oni on 2019/2/8.
//  Copyright © 2019 Oni Angel. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import ObjectMapper


class MoreRateReviewVC: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet weak var title_label: UILabel!
    @IBOutlet weak var back_img: UIImageView!
    @IBOutlet weak var back_btn: UIButton!
    @IBOutlet weak var menu_img: UIImageView!
    @IBOutlet weak var menu_btn: UIButton!
    @IBOutlet weak var header_view: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    let progressDlg = ShareData.progressDlgs[ShareData.progress_index]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        init_UI()
        
    }
    
    func init_UI()
    {
        
        self.navigationController?.isNavigationBarHidden = true
        
        header_view.dropShadow(color: .gray, opacity: 0.5, offSet: CGSize.zero, radius: 8, scale: true)
      
        let back_image = UIImage.init(named: "back")!.withRenderingMode(.alwaysTemplate)
        back_img.image = back_image
        back_img.tintColor = Utility.color(withHexString: "10A7BA")
        
        let menu_image = UIImage.init(named: "menu_1")!.withRenderingMode(.alwaysTemplate)
        menu_img.image = menu_image
        menu_img.tintColor = Utility.color(withHexString: "10A7BA")
        menu_img.isHidden = true
        
        back_btn.addTarget(self, action: #selector(self.backAction(_:)), for: .touchUpInside)
        
        self.tableView.separatorColor = UIColor.clear
        self.tableView.separatorStyle = .none
        self.tableView.tableFooterView = UIView()
        
        if ShareData.rate_or_follow_status
        {
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.register(UINib(nibName: "ReviewCell", bundle: nil), forCellReuseIdentifier: "ReviewCell")
            
            title_label.text = "Reviews"
        }
        else
        {
            if ShareData.follow_or_following == "1"
            {
                title_label.text = "Users you Follow"
            }
            else
            {
                title_label.text = "Users that Follow you"
            }
            
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.register(UINib(nibName: "TrendSearchCell", bundle: nil), forCellReuseIdentifier: "TrendSearchCell")
        }
        
    }
    
    @objc func backAction(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
}

extension MoreRateReviewVC: UITableViewDelegate, UITableViewDataSource
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if ShareData.rate_or_follow_status
        {
            return ShareData.reviews.count
        }
        else
        {
            return ShareData.new_following_list.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if ShareData.rate_or_follow_status
        {
            return CommonFuncs().getStringHeight(ShareData.reviews[indexPath.row].review, 13, UIScreen.main.bounds.width, 60, 65)
        }
        else
        {
            return 70
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if ShareData.rate_or_follow_status
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
        else
        {
            let cell : TrendSearchCell = tableView.dequeueReusableCell(withIdentifier: "TrendSearchCell", for: indexPath) as! TrendSearchCell
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            let data = ShareData.new_following_list[indexPath.row]
            
            cell.photo.load(url: data.photo!)
            cell.photo.layer.cornerRadius = cell.photo.frame.height / 2
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
                        str += "\(ShareData.category_list.filter{$0.id! == array[i]}[0].name!) , "
                        
                    }
                    str += "\(ShareData.category_list.filter{$0.id! == array[array.count - 1]}[0].name!)"
                }
                else
                {
                    str = ShareData.category_list.filter{$0.id! == data.category!}[0].name!
                    
                }
            }
            
            cell.job.text = str
            
            cell.under_line.alpha = 0.2
            
            CommonFuncs().likeStars(Double(data.rate!)!, cell.like_stars)
            
            cell.status.layer.cornerRadius = cell.status.frame.width / 2
            cell.status.clipsToBounds = true
            
            if data.status! == "1"
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
    
}

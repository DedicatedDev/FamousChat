//
//  MainTrendVC.swift
//  famouschat
//
//  Created by T-Tech Solutions LLC on 07/11/2018.
//  Copyright © 2018 T-Tech Solutions LLC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import ObjectMapper

class MainTrendVC: UIViewController, NVActivityIndicatorViewable {
    
    @IBOutlet weak var menu_img: UIImageView!
    @IBOutlet weak var menu_btn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var category_btn: UIButton!
    
    let progressDlg = ShareData.progressDlgs[ShareData.progress_index]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        init_UI()
    }
    
    func init_UI()
    {
        self.navigationController?.isNavigationBarHidden = true
       
        let menu_image = UIImage.init(named: "menu")!.withRenderingMode(.alwaysTemplate)
        menu_img.image = menu_image
        menu_img.tintColor = UIColor.white
        
        menu_btn.addTarget(self.slideMenuController, action: #selector(slideMenuController.toggleMenuAnimated(_:)), for: .touchUpInside)
        
        category_btn.layer.cornerRadius = category_btn.frame.height / 2
        category_btn.clipsToBounds = true
        
        category_btn.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        category_btn.layer.borderColor = UIColor.white.cgColor
        category_btn.layer.borderWidth = 2
        category_btn.clipsToBounds = true
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TrendCell", bundle: nil), forCellReuseIdentifier: "TrendCell")
        tableView.separatorColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if !ShareData.msg_noti_status
        {
            ShareData.main_tab_index = 1
        }
        tableView.reloadData()
    }
    
    
    @IBAction func cateAction(_ sender: Any) {
        
        self.navigationController?.pushViewController(MainTrendCatVC(), animated: true)
    }
}



extension MainTrendVC: UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if ShareData.following_influencers.count > 0
        {
            return 3
        }
        else
        {
            return 2
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section == 0
        {
            return ShareData.top_influencers.count
        }
        else if section == 1 && ShareData.following_influencers.count > 0
        {
            return ShareData.following_influencers.count
        }
        else
        {
            return ShareData.matched_influencers.count
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        
        return tableView.frame.width * 0.5
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        
        let image = UIImageView()
        image.frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.frame.width * 0.5)
        
        /*if section == 0
        {
            image.load(url: "config/hyundai.jpg")
        }
            else if section == 1 && ShareData.following_influencers.count > 0
        {
            image.load(url: "config/hyundai.jpg")
       }
        else
       {
            image.load(url: "config/hyundai.jpg")
        }*/
        
        headerView.addSubview(image)
        
        let image1 = UIView()
        image1.frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.frame.width * 0.5)
        image1.backgroundColor = UIColor.black
        image1.alpha = 0.5
        headerView.addSubview(image1)
        
        let headerLabel = UILabel(frame: CGRect(x: 20, y: tableView.frame.width * 0.5 - 40, width:
            tableView.bounds.size.width, height: tableView.bounds.size.height))
        headerLabel.font = UIFont.boldSystemFont(ofSize: CGFloat(17))
        headerLabel.textColor = UIColor.white
        headerLabel.text = self.tableView(self.tableView, titleForHeaderInSection: section)
        headerLabel.sizeToFit()
        
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0
        {
            return "TRENDING TODAY"
        }
        else if section == 1 && ShareData.following_influencers.count > 0
        {
            return "PEOPLE YOU FOLLOW"
        }
        else
        {
            return "CATEGORIES YOU FOLLOW"
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell : TrendCell = tableView.dequeueReusableCell(withIdentifier: "TrendCell", for: indexPath) as! TrendCell
        
        cell.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        var data: UserMDL!
        
        if indexPath.section == 0
        {
            data = ShareData.top_influencers[indexPath.row]
        }
        else if indexPath.section == 1 && ShareData.following_influencers.count > 0
        {
            data = ShareData.following_influencers[indexPath.row]
        }
        else
        {
            data = ShareData.matched_influencers[indexPath.row]
        }
       
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
                    str += "\(ShareData.category_list.filter{$0.id! == array[i]}[0].name!) , "
                    
                }
                str += "\(ShareData.category_list.filter{$0.id! == array[array.count - 1]}[0].name!)"
            }
            else
            {
                str = ShareData.category_list.filter{$0.id! == data.category!}[0].name!
                
            }
        }
        
        
//        let cate_len = str.widthOfString(font: UIFont.systemFont(ofSize: 13)) + 10
//        
//        let max_cate_len = UIScreen.main.bounds.width - 150
//        cell.category_length.constant = cate_len > max_cate_len ? max_cate_len : cate_len
        cell.category.text = str
        
        cell.bio.text = data.bio!
//        cell.like.text = String(format: "%.01f", Double(data.rate!)!)
        
        return cell
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        self.tableView.isUserInteractionEnabled = false
        
        self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: progressDlg, color: .darkGray, fadeInAnimation: nil)
        
        var data: UserMDL!
        if indexPath.section == 0
        {
            data = ShareData.top_influencers[indexPath.row]
        }
        else if indexPath.section == 1 && ShareData.following_influencers.count > 0
        {
            data = ShareData.following_influencers[indexPath.row]
        }
        else
        {
            data = ShareData.matched_influencers[indexPath.row]
        }
        
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


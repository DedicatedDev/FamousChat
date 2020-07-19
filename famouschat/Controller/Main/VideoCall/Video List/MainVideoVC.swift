//
//  MainVideoVC.swift
//  famouschat
//
//  Created by T-Tech Solutions LLC on 07/11/2018.
//  Copyright © 2018 T-Tech Solutions LLC. All rights reserved.
//

import UIKit

class MainVideoVC: UIViewController {

    
    @IBOutlet weak var menu_img: UIImageView!
    @IBOutlet weak var menu_btn: UIButton!
    @IBOutlet weak var header_frame: UIView!
    @IBOutlet weak var no_schedule_lable: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var filter_list = [BookMDL]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        init_UI()
    }

    func init_UI()
    {
        
        self.navigationController?.isNavigationBarHidden = true
        
        let menu_image = UIImage.init(named: "menu")!.withRenderingMode(.alwaysTemplate)
        menu_img.image = menu_image
        menu_img.tintColor = Utility.color(withHexString: ShareData.btn_color)
        
        menu_btn.tag = 1
        menu_btn.addTarget(self.slideMenuController, action: #selector(slideMenuController.toggleMenuAnimated(_:)), for: .touchUpInside)
        
        header_frame.dropShadow(color: .gray, opacity: 0.5, offSet: CGSize.zero, radius: 8, scale: true)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "VideoCell", bundle: nil), forCellReuseIdentifier: "VideoCell")
        tableView.separatorColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if !ShareData.msg_noti_status
        {
            ShareData.main_tab_index = 2
        }
        
        if ShareData.user_or_influencer
        {
            filter_list = ShareData.books.filter { $0.book.normal_id! == ShareData.user_info.id! }
        }
        else
        {
            filter_list = ShareData.books.filter { $0.book.influencer_id! == ShareData.user_info.id! }
        }
        
        filter_list.sort{$0.book.time! < $1.book.time!}
        
        if filter_list.count == 0
        {
            no_schedule_lable.isHidden = false
            tableView.isHidden = true
        }
        else
        {
            no_schedule_lable.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
        
    }
    
}


extension MainVideoVC: UITableViewDelegate, UITableViewDataSource
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
        let cell : VideoCell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as! VideoCell
        
        cell.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none  // remove grey when selected
        
        let data = filter_list[indexPath.row]
        
        cell.photo.load(url: data.profile.photo!)
        cell.photo.layer.cornerRadius = cell.photo.frame.height / 2
        cell.photo.clipsToBounds = true
        
        cell.name.text = data.profile.name!
        
        let time_zone_div = Int(ShareData.time_zones[Int(ShareData.user_info.time_zone!)!])! - Int(ShareData.time_zones[Int(data.profile.time_zone!)!])!
        
        cell.time.text = CommonFuncs().timeString(data.book.time!, data.book.duration!, 2)
        
        cell.duration.text = data.book.duration! + " mins"
        
        let formater = DateFormatter()
        formater.dateFormat = "yyyy-MM-dd-HH-mm"
        let start_time = formater.date(from: data.book.time!)!.addingTimeInterval(TimeInterval(time_zone_div * 3600))
        let week_num = Calendar.current.component(.weekday, from: start_time) as! Int - 1
        
        let array3_rate = data.profile.chat_rate!.split(separator: ",").map(String.init)
        let array3_book_time = CommonFuncs().splitString(data.book.time!)
        
        let array3 = CommonFuncs().splitString(array3_rate[week_num])
        let fee_rate = (Double(array3[2])! + Double(array3[3])! / 100) / (Double(array3[0])! * 60 + Double(array3[1])!)

        cell.rate.text = "$\(String(format: "%.02f", fee_rate * Double(data.book.duration!)!))"
        
        if data.profile.status! == "0"
        {
            cell.status.backgroundColor = UIColor.gray
            cell.status.dropShadow(color: .gray, opacity: 1, offSet: CGSize.zero, radius: 4, scale: true)
        }
        else
        {
            cell.status.backgroundColor = UIColor.green
            cell.status.dropShadow(color: .green, opacity: 1, offSet: CGSize.zero, radius: 4, scale: true)
        }
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        ShareData.selected_book = filter_list[indexPath.row]
        ShareData.book_detail_from_status = true
        self.navigationController?.pushViewController(MainBookDetailVC(), animated: true)
        
        
    }
    
}

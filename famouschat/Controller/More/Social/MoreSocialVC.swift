//
//  MoreSocialVC.swift
//  famouschat
//
//  Created by T-Tech Solutions LLC on 09/11/2018.
//  Copyright © 2018 T-Tech Solutions LLC. All rights reserved.
//

import UIKit

class MoreSocialVC: UIViewController {

    @IBOutlet weak var header_frame: UIView!
    @IBOutlet weak var back_img: UIImageView!
    @IBOutlet weak var back_btn: UIButton!
    @IBOutlet weak var menu_img: UIImageView!
    @IBOutlet weak var menu_btn: UIButton!
    @IBOutlet weak var input_frame: UIView!
    @IBOutlet weak var invite_link_in: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    let socail_titles = ["Instagram", "Youtube", "Twitter", "Facebook", "Twitch", "Wordpress"]
    let socail_images = ["social_instergram", "socail_youtube", "social_twitter", "socail_facebook", "socail_twich", "socail_wordpress"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        init_UI()
    }
    
    func init_UI()
    {
        self.navigationController?.isNavigationBarHidden = true
        
        header_frame.dropShadow(color: .gray, opacity: 0.5, offSet: CGSize.zero, radius: 8, scale: true)
        
        let back_image = UIImage.init(named: "back")!.withRenderingMode(.alwaysTemplate)
        back_img.image = back_image
        back_img.tintColor = Utility.color(withHexString: "10A7BA")
        
     //   let menu_image = UIImage.init(named: "menu_1")!.withRenderingMode(.alwaysTemplate)
     //   menu_img.image = menu_image
     //   menu_img.tintColor = Utility.color(withHexString: ShareData.btn_color)
        
     //   menu_btn.addTarget(self.slideMenuController, action: #selector(slideMenuController.toggleMenuAnimated(_:)), for: .touchUpInside)
        back_btn.addTarget(self, action: #selector(self.backAction(_:)), for: .touchUpInside)
        
        input_frame.layer.cornerRadius = input_frame.frame.height / 2
        input_frame.layer.borderColor = Utility.color(withHexString: ShareData.btn_color)!.cgColor
        input_frame.layer.borderWidth = 1
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "SocialCell", bundle: nil), forCellReuseIdentifier: "SocialCell")
        tableView.separatorColor = UIColor.lightGray
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
    }

    @objc func backAction(_ sender: UIButton) {
        
        ShareData.main_or_more_status = true
        UIApplication.shared.keyWindow?.setRootViewController(MainTabVC(), options: UIWindow.TransitionOptions(direction: .toLeft, style: .easeIn), slide_direction: .fromLeftToRight)
    }
    
}

extension MoreSocialVC: UITextFieldDelegate
{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        invite_link_in.resignFirstResponder()
        
        return true
    }
}


extension MoreSocialVC: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return socail_titles.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell : SocialCell = tableView.dequeueReusableCell(withIdentifier: "SocialCell", for: indexPath) as! SocialCell
        
        cell.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        cell.img.image = UIImage.init(named: socail_images[indexPath.row])
        cell.name.text = socail_titles[indexPath.row]
        
        let image = UIImage(named: "go")?.withRenderingMode(.alwaysTemplate)
        cell.go_img.image = image
        cell.go_img.tintColor = Utility.color(withHexString: ShareData.btn_color)        
        
        return cell
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
            
        case 0:
            
            if UIApplication.shared.canOpenURL(URL(string: ShareData.app_config.instagram!)!) {
                UIApplication.shared.open(URL(string: ShareData.app_config.instagram!)!, options: [:])
            }
            break
            
        case 1:
            
            if UIApplication.shared.canOpenURL(URL(string: ShareData.app_config.youtube!)!) {
                UIApplication.shared.open(URL(string: ShareData.app_config.youtube!)!, options: [:])
            }
            break
            
        case 2:
            
            if UIApplication.shared.canOpenURL(URL(string: ShareData.app_config.twitter!)!) {
                UIApplication.shared.open(URL(string: ShareData.app_config.twitter!)!, options: [:])
            }
            break
            
        case 3:
            
            if UIApplication.shared.canOpenURL(URL(string: ShareData.app_config.facebook!)!) {
                UIApplication.shared.open(URL(string: ShareData.app_config.facebook!)!, options: [:])
            }
            break
            
        case 4:
            
            if UIApplication.shared.canOpenURL(URL(string: ShareData.app_config.twitch!)!) {
                UIApplication.shared.open(URL(string: ShareData.app_config.twitch!)!, options: [:])
            }
            break
            
        case 5:
            
            if UIApplication.shared.canOpenURL(URL(string: ShareData.app_config.wordpress!)!) {
                UIApplication.shared.open(URL(string: ShareData.app_config.wordpress!)!, options: [:])
            }
            
        default:
            
            break
        }
    }
}

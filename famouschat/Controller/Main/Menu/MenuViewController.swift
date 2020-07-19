//
//  MenuViewController.swift
//  Lineology
//
//  Created by Neha on 21/11/17.
//  Copyright © 2017 Neha. All rights reserved.
//

import UIKit
import SDWebImage
import ObjectMapper
import NVActivityIndicatorView

class MenuViewController: UIViewController, NVActivityIndicatorViewable {
    
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet var tableView: UITableView!
    
    let Delegate = UIApplication.shared.delegate
    let progressDlg = ShareData.progressDlgs[ShareData.progress_index]
    let slideMenuVC : NVSlideMenuController! = nil
    let menuVC : MenuViewController! = nil
    
    
    var influencer_ArrayServices : NSMutableArray = ["MY PROFILE" , "RANKINGS", "PAYMENT", "CHAT SETUP", "SOCIAL MEDIA","", "", "", "PRIVACY & SECURITY", "Standard/Influencer", "LOG OUT"]
    var user_ArrayServices : NSMutableArray = ["MY PROFILE" , "PAYMENT", "", "", "", "", "", "", "PRIVACY & SECURITY", "Standard/Influencer", "LOG OUT"]
    
    var influencer_ArrayServicesIcons : NSMutableArray = ["menu_profile" , "menu_star", "menu_pay", "menu_chat", "menu_social","", "", "", "menu_search", "menu_switch", "menu_out"]
    var user_ArrayServicesIcons : NSMutableArray = ["menu_profile" , "menu_pay", "", "", "", "", "", "", "menu_search", "menu_switch", "menu_out"]
    //AUCTION && menu_auction
    var index:Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if ShareData.user_info == nil
        {
            return
        }
        
        init_UI()
        
        
    }
    
    
    func init_UI()
    {
        
        navigationController?.isNavigationBarHidden = true
        
        let layerGradient = CAGradientLayer()
        
        layerGradient.colors = [Utility.color(withHexString: "10A7BA")!.cgColor, Utility.color(withHexString: "5BDD96")!.cgColor]
        layerGradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        layerGradient.endPoint = CGPoint(x: 0.5, y: 1)
        layerGradient.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.view.layer.addSublayer(layerGradient)
        
        photo.layer.cornerRadius = photo.frame.width / 2
        photo.clipsToBounds = true
        
        self.view.layer.addSublayer(header.layer)
        
        name.text = ShareData.user_info.name!
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "MenuCell", bundle: nil), forCellReuseIdentifier: "MenuCell")
        tableView.estimatedRowHeight = 570
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
         self.view.layer.addSublayer(tableView.layer)
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        if ShareData.user_info != nil
        {
            address.text = "PopCoins: \(ShareData.user_info.popcoin_num!)"
            photo.load(url: ShareData.user_info.photo!)
            
            tableView.reloadData()
        }
        
    }
    
}

extension MenuViewController: UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if ShareData.user_or_influencer
        {
            return user_ArrayServices.count
        }
        else
        {
            return influencer_ArrayServices.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell : MenuCell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuCell
        
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        if ShareData.user_or_influencer
        {
            if indexPath.row > 2 && indexPath.row < 7
            {
                cell.title.isHidden = true
                cell.imageIco.isHidden = true
            }
            else if indexPath.row == 9
            {
                
                let attributedString = NSMutableAttributedString(string:"")
                let attr1 = [NSAttributedStringKey.foregroundColor : UIColor.yellow]
                let str1 = NSMutableAttributedString(string: "USER", attributes: attr1)
                let attr2 = [NSAttributedStringKey.foregroundColor : UIColor.lightGray]
                let str2 = NSMutableAttributedString(string: " / INFLUENCER", attributes: attr2)
                
                attributedString.append(str1)
                attributedString.append(str2)
                
                cell.title.attributedText = attributedString
                cell.imageIco?.image = UIImage.init(named: user_ArrayServicesIcons[indexPath.row] as! String)
            }
            else
            {
                cell.title?.text = user_ArrayServices.object(at: indexPath.row) as? String
                cell.imageIco?.image = UIImage.init(named: user_ArrayServicesIcons[indexPath.row] as! String)
                
            }
        }
        else
        {
            
            if indexPath.row == 6
            {
                cell.title.isHidden = true
                cell.imageIco.isHidden = true
            }
            else if indexPath.row == 9
            {
                
                let attributedString = NSMutableAttributedString(string:"")
                
                let attr1 = [NSAttributedStringKey.foregroundColor : UIColor.lightGray]
                let str1 = NSMutableAttributedString(string: "USER / ", attributes: attr1)
                let attr2 = [NSAttributedStringKey.foregroundColor : UIColor.yellow]
                let str2 = NSMutableAttributedString(string: "INFLUENCER", attributes: attr2)
                
                attributedString.append(str1)
                attributedString.append(str2)
                
                cell.title.attributedText = attributedString
                cell.imageIco?.image = UIImage.init(named: influencer_ArrayServicesIcons[indexPath.row] as! String)
            }
            else
            {
                cell.title?.text = influencer_ArrayServices.object(at: indexPath.row) as? String
                
                
                if indexPath.row == 3
                {
                    let image = UIImage.init(named: influencer_ArrayServicesIcons[indexPath.row] as! String)?.withRenderingMode(.alwaysTemplate)
                    cell.imageIco?.image = image
                    cell.imageIco.tintColor = UIColor.white
                }
                else
                {
                    cell.imageIco?.image = UIImage.init(named: influencer_ArrayServicesIcons[indexPath.row] as! String)
                }
            }
        }
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:

            if ShareData.main_or_more_status
            {
                ShareData.main_or_more_status = false
                UIApplication.shared.keyWindow?.setRootViewController(MoreProfileVC(), options: UIWindow.TransitionOptions(direction: .toRight, style: .easeIn), slide_direction: .fromRightToLeft)
            }
            else
            {
                UIApplication.shared.keyWindow?.setRootViewController(MoreProfileVC(), options: UIWindow.TransitionOptions(direction: .toLeft, style: .easeIn), slide_direction: .fromRightToLeft)
            }
            
            break
            
        case 1:
            
            
            if ShareData.user_or_influencer
            {
                ShareData.pay_from_status = true
                if ShareData.main_or_more_status
                {
                    ShareData.main_or_more_status = false
                    UIApplication.shared.keyWindow?.setRootViewController(MorePayVC(), options: UIWindow.TransitionOptions(direction: .toRight, style: .easeIn), slide_direction: .fromRightToLeft)
                }
                else
                {
                    UIApplication.shared.keyWindow?.setRootViewController(MorePayVC(), options: UIWindow.TransitionOptions(direction: .toLeft, style: .easeIn), slide_direction: .fromRightToLeft)
                }
            }
            else
            {
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
                            }
                        }
                        
                        self.stopAnimating(nil)
                        if ShareData.main_or_more_status
                        {
                            ShareData.main_or_more_status = false
                            UIApplication.shared.keyWindow?.setRootViewController(MoreRateVC(), options: UIWindow.TransitionOptions(direction: .toRight, style: .easeIn), slide_direction: .fromRightToLeft)
                        }
                        else
                        {
                            UIApplication.shared.keyWindow?.setRootViewController(MoreRateVC(), options: UIWindow.TransitionOptions(direction: .toLeft, style: .easeIn), slide_direction: .fromRightToLeft)
                        }
                    }
                })
                
            }
            
            
            break
            
        case 2:
            
            if ShareData.user_or_influencer
            {
                if ShareData.main_or_more_status
                {
                    ShareData.main_or_more_status = false
                    UIApplication.shared.keyWindow?.setRootViewController(MoreAuctionVC(), options: UIWindow.TransitionOptions(direction: .toRight, style: .easeIn), slide_direction: .fromRightToLeft)
                }
                else
                {
                    UIApplication.shared.keyWindow?.setRootViewController(MoreAuctionVC(), options: UIWindow.TransitionOptions(direction: .toLeft, style: .easeIn), slide_direction: .fromRightToLeft)
                }
                
                
            }
            else
            {
                ShareData.pay_from_status = true
                if ShareData.main_or_more_status
                {
                    ShareData.main_or_more_status = false
                    UIApplication.shared.keyWindow?.setRootViewController(MorePayVC(), options: UIWindow.TransitionOptions(direction: .toRight, style: .easeIn), slide_direction: .fromRightToLeft)
                }
                else
                {
                    UIApplication.shared.keyWindow?.setRootViewController(MorePayVC(), options: UIWindow.TransitionOptions(direction: .toLeft, style: .easeIn), slide_direction: .fromRightToLeft)
                }
            }
            
            break
            
        case 3:
            
            if !ShareData.user_or_influencer
            {
                if ShareData.main_or_more_status
                {
                    ShareData.main_or_more_status = false
                    UIApplication.shared.keyWindow?.setRootViewController(MoreChatSetupVC(), options: UIWindow.TransitionOptions(direction: .toRight, style: .easeIn), slide_direction: .fromRightToLeft)
                }
                else
                {
                    UIApplication.shared.keyWindow?.setRootViewController(MoreChatSetupVC(), options: UIWindow.TransitionOptions(direction: .toLeft, style: .easeIn), slide_direction: .fromRightToLeft)
                }
            }
            
            break
            
        case 4:
            
            if !ShareData.user_or_influencer
            {
                if ShareData.main_or_more_status
                {
                    ShareData.main_or_more_status = false
                    UIApplication.shared.keyWindow?.setRootViewController(MoreSocialVC(), options: UIWindow.TransitionOptions(direction: .toRight, style: .easeIn), slide_direction: .fromRightToLeft)
                }
                else
                {
                    UIApplication.shared.keyWindow?.setRootViewController(MoreSocialVC(), options: UIWindow.TransitionOptions(direction: .toLeft, style: .easeIn), slide_direction: .fromRightToLeft)
                }
            }
            
            break
            
        case 5:
            
            if !ShareData.user_or_influencer
            {
               
                if ShareData.main_or_more_status
                {
                    ShareData.main_or_more_status = false
                    UIApplication.shared.keyWindow?.setRootViewController(MoreInfluencerAuctionVC(), options: UIWindow.TransitionOptions(direction: .toRight, style: .easeIn), slide_direction: .fromRightToLeft)
                }
                else
                {
                    UIApplication.shared.keyWindow?.setRootViewController(MoreInfluencerAuctionVC(), options: UIWindow.TransitionOptions(direction: .toLeft, style: .easeIn), slide_direction: .fromRightToLeft)
                }
            }
            
            break
            
        case 9:
            
            if ShareData.user_or_influencer
            {
                if ShareData.user_info.permission == "0"
                {
                    CommonFuncs().selectAlert(ShareData.appTitle, "You do not have an influencer account, would you like to create one?", 2, ["CREATE NOW", "CANCEL"], [Utility.color(withHexString: ShareData.btn_color), UIColor.gray], [UIColor.white, UIColor.white], self, [#selector(influencerCreateAction(_:)), #selector(influencerCancelAction(_:))])
                   
                }
                else
                {
                    ShareData.user_or_influencer = false
                    ShareData.main_or_more_status = true
                    UIApplication.shared.keyWindow?.setRootViewController(MainTabVC(), options: UIWindow.TransitionOptions(direction: .toRight, style: .easeIn), slide_direction: .fromLeftToRight)
                }
                
            }
            else
            {
                ShareData.user_or_influencer = true
                ShareData.main_or_more_status = true
                UIApplication.shared.keyWindow?.setRootViewController(MainTabVC(), options: UIWindow.TransitionOptions(direction: .toRight, style: .easeIn), slide_direction: .fromLeftToRight)
                break
            }
            
            
            
        case 10:
            
            self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: progressDlg, color: .darkGray, fadeInAnimation: nil)
            
            let parmeters = ["user_id": ShareData.user_info.id!] as [String: Any]
            
            CommonFuncs().createRequest(false, "login/logout", "POST", parmeters, completionHandler: {data in
                
                DispatchQueue.main.async {
                    
                    
                    ShareData.user_info = nil                    
                    ShareData.category_list = [CategoryMDL]()
                    ShareData.top_influencers = [UserMDL]()
                    ShareData.matched_influencers = [UserMDL]()
                    ShareData.following_influencers = [UserMDL]()
                    
                    ShareData.feeds = [FeedMDL]()
                    ShareData.books = [BookMDL]()
                    ShareData.reviews = [ReviewMDL]()
                    ShareData.selected_day_books = [BookMDL]()
                    ShareData.auctions = [AuctionMDL]()
                    ShareData.messages = [MessageMDL]()
                    
                    ShareData.main_tab_index = 0
                    UserDefaults.standard.set(false, forKey: "loginStatus")
                    
                    SDImageCache.shared.clearMemory()
                    SDImageCache.shared.clearDisk()
                    
                    self.stopAnimating(nil)
                    
                    let navigationController = UINavigationController.init(rootViewController: LoginVC())
                    navigationController.navigationBar.isTranslucent = false
                    self.slideMenuController.closeMenuBehindContentViewController(navigationController, animated: true, completion: nil)
                    
                    
                }
            })
            
            
            
        default:
            break
        }
        
        
    }
    
}


extension MenuViewController
{
    @objc func influencerCreateAction(_ sender: UIButton) {
        
        var navigationController = UINavigationController()
        navigationController = UINavigationController.init(rootViewController: StartCategoryVC())
        slideMenuController.closeMenuBehindContentViewController(navigationController, animated: true, completion: nil)
    }
    
    @objc func influencerCancelAction(_ sender: UIButton) {
        
        ShareData.user_or_influencer = true
        var navigationController = UINavigationController()
        navigationController = UINavigationController.init(rootViewController: MainTabVC())
        slideMenuController.closeMenuBehindContentViewController(navigationController, animated: true, completion: nil)
    }
}


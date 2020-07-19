//
//  MoreProfileVC.swift
//  famouschat
//
//  Created by T-Tech Solutions LLC on 11/11/2018.
//  Copyright © 2018 T-Tech Solutions LLC. All rights reserved.
//

import UIKit
import Alamofire
import NVActivityIndicatorView
import ObjectMapper

class MoreProfileVC: UIViewController, NVActivityIndicatorViewable {
    
    @IBOutlet weak var back_img: UIImageView!
    @IBOutlet weak var back_btn: UIButton!
    @IBOutlet weak var menu_img: UIImageView!
    @IBOutlet weak var menu_btn: UIButton!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var photo_height: NSLayoutConstraint!
    @IBOutlet weak var profile_edit_btn: UIButton!
    @IBOutlet weak var profile_frame: UIView!
    @IBOutlet weak var profile_frame_height: NSLayoutConstraint!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var job: UILabel!
    @IBOutlet weak var follwoing_num: UILabel!
    @IBOutlet weak var follower_num: UILabel!
    @IBOutlet weak var rating_num: UILabel!
    @IBOutlet weak var about: UILabel!
    @IBOutlet weak var news_bar: UIView!
    @IBOutlet weak var news_btn: UIButton!
    @IBOutlet weak var review_bar: UIView!
    @IBOutlet weak var review_btn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    
    
    let progressDlg = ShareData.progressDlgs[ShareData.progress_index]
    
    var new_photo: NSData! = nil
    
    var filter_reviews = [ReviewMDL]()
    var tab_index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tab_index = 0
        news_bar.backgroundColor = Utility.color(withHexString: "10A7BA")
        review_bar.backgroundColor = UIColor.white
        tableView.isHidden = false
        
        self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: progressDlg, color: .darkGray, fadeInAnimation: nil)
        
        var parmeters: [String: Any]!
        if ShareData.user_or_influencer
        {
            parmeters = ["user_id": ShareData.user_info.id!, "type": ""] as [String: Any]
        }
        else
        {
            parmeters = ["user_id": ShareData.user_info.id!, "type": ""] as [String: Any]
        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "FeedPhotoCell", bundle: nil), forCellReuseIdentifier: "FeedPhotoCell")
        self.tableView.register(UINib(nibName: "FeedWarnCell", bundle: nil), forCellReuseIdentifier: "FeedWarnCell")
        tableView.register(UINib(nibName: "FeedPromotionCell", bundle: nil), forCellReuseIdentifier: "FeedPromotionCell")
        self.tableView.register(UINib(nibName: "ReviewCell", bundle: nil), forCellReuseIdentifier: "ReviewCell")
        
        self.tableView.separatorColor = UIColor.clear
        self.tableView.separatorStyle = .none
        self.tableView.tableFooterView = UIView()
        
        CommonFuncs().createRequest(false, "review/request", "POST", parmeters, completionHandler: {data in
            
            let status = data["status"] as! Bool
            let message = data["message"] as! String
            
            DispatchQueue.main.async {
                
                if status
                {
                    if let detail = data["data"] as? [AnyHashable:Any]
                    {
                        if let reviews = detail["reviews"], let temp = Mapper<ReviewMDL>().mapArray(JSONObject: reviews)
                        {
                            self.filter_reviews = temp
                            self.tableView.reloadData()
                        }
                        
                    }
                }
                
                self.stopAnimating(nil)
                
            }
        })
        
        init_UI()
    }
    
    func init_UI()
    {
        self.navigationController?.isNavigationBarHidden = true
        
        let back_image = UIImage.init(named: "back")!.withRenderingMode(.alwaysTemplate)
        back_img.image = back_image
        back_img.tintColor = UIColor.white
        
       // let menu_image = UIImage.init(named: "menu_1")!.withRenderingMode(.alwaysTemplate)
       // menu_img.image = menu_image
       // menu_img.tintColor = UIColor.white
        
       // menu_btn.addTarget(self.slideMenuController, action: #selector(slideMenuController.toggleMenuAnimated(_:)), for: .touchUpInside)
        back_btn.addTarget(self, action: #selector(self.backAction(_:)), for: .touchUpInside)
        
        photo_height.constant = photo.frame.width * 0.7
        photo.load(url: ShareData.user_info.photo!)
        
        profile_edit_btn.layer.cornerRadius = 6
        profile_edit_btn.clipsToBounds = true
        
        profile_edit_btn.layer.borderWidth = 2
        profile_edit_btn.layer.borderColor = UIColor.white.cgColor
        
        profile_frame.dropShadow(color: .gray, opacity: 0.8, offSet: CGSize.zero, radius: 5, scale: true)
        
        name.text = ShareData.user_info.name!
        job.text = ShareData.user_info.link!
        
        profile_frame_height.constant = CommonFuncs().getStringHeight(ShareData.user_info.bio!, 10, UIScreen.main.bounds.width, 30, 80)
        about.text = ShareData.user_info.bio!
        
        follower_num.text = ShareData.user_info.follow_num!
        follwoing_num.text = ShareData.user_info.following_num!
        rating_num.text = String(format: "%.01f", Double(ShareData.user_info.rate!)!)
        
        news_bar.backgroundColor = Utility.color(withHexString: "10A7BA")
        review_bar.backgroundColor = UIColor.white
        
        
    }
    
    @IBAction func photoEditAction(_ sender: Any) {
        
        let alertController = UIAlertController.init(title: "\(ShareData.appTitle)", message: "Select new Profile Image", preferredStyle: .actionSheet)
        
        let imageAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.default)
        {
            UIAlertAction in
            
            self.ImageFromCamera()
        }
        
        let galleryAction = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.default)
        {
            UIAlertAction in
            
            self.ImageFromGallary()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
        {
            UIAlertAction in
            
            self.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(imageAction)
        alertController.addAction(galleryAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func profileEditAction(_ sender: Any) {
        
        UIApplication.shared.keyWindow?.setRootViewController(StartCategoryVC(), options: UIWindow.TransitionOptions(direction: .toRight, style: .easeIn), slide_direction: .fromRightToLeft)
    }
    
    @IBAction func reviewViewAction(_ sender: Any) {
        
        ShareData.review_from_status = false
        ShareData.rate_or_follow_status = true
        self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: progressDlg, color: .darkGray, fadeInAnimation: nil)
        let parmeters = ["user_id": ShareData.user_info.id!, "type": ""] as [String: Any]
        
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
    
    @IBAction func followingUserAction(_ sender: Any) {
        
        ShareData.follow_or_following = "1"
        ShareData.rate_or_follow_status = false
        self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: progressDlg, color: .darkGray, fadeInAnimation: nil)
        let parmeters = ["user_id": ShareData.user_info.id!, "status": ShareData.follow_or_following] as [String: Any]
        
        
        CommonFuncs().createRequest(false, "detail/follow_users", "POST", parmeters, completionHandler: {data in
            
            let status = data["status"] as! Bool
            let message = data["message"] as! String
            
            DispatchQueue.main.async {
                
                if status
                {
                    if let temp = Mapper<UserMDL>().mapArray(JSONObject: data["data"])
                    {
                        ShareData.new_following_list = temp
                        self.navigationController?.pushViewController(MoreRateReviewVC(), animated: true)
                    }
                    
                }
                else
                {
                    CommonFuncs().doneAlert(ShareData.appTitle, "You don`t have any following users yet", "CLOSE", {})
                }
                
                self.stopAnimating(nil)
            }
        })
        
    }
    
    
    @IBAction func followedUserAction(_ sender: Any) {
        
        ShareData.follow_or_following = "0"
        ShareData.rate_or_follow_status = false
        self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: progressDlg, color: .darkGray, fadeInAnimation: nil)
        let parmeters = ["user_id": ShareData.user_info.id!, "status": ShareData.follow_or_following] as [String: Any]
        
        
        CommonFuncs().createRequest(false, "detail/follow_users", "POST", parmeters, completionHandler: {data in
            
            let status = data["status"] as! Bool
            let message = data["message"] as! String
            
            DispatchQueue.main.async {
                
                if status
                {
                    if let temp = Mapper<UserMDL>().mapArray(JSONObject: data["data"])
                    {
                        ShareData.new_following_list = temp
                        self.navigationController?.pushViewController(MoreRateReviewVC(), animated: true)
                    }
                    
                }
                else
                {
                    CommonFuncs().doneAlert(ShareData.appTitle, "You don`t have any followed users yet", "CLOSE", {})
                }
                
                self.stopAnimating(nil)
            }
        })
    }
    
    @IBAction func newsAction(_ sender: Any) {
        
        tab_index = 0
        news_bar.backgroundColor = Utility.color(withHexString: ShareData.btn_color)
        review_bar.backgroundColor = UIColor.white
        tableView.isHidden = false
        tableView.reloadData()
    }
    
    
    @IBAction func reviewAction(_ sender: Any) {
        
        tab_index = 1
        review_bar.backgroundColor = Utility.color(withHexString: ShareData.btn_color)
        news_bar.backgroundColor = UIColor.white
        tableView.isHidden = false
        tableView.reloadData()
    }
    
    @objc func backAction(_ sender: UIButton) {
        
        ShareData.main_or_more_status = true
        UIApplication.shared.keyWindow?.setRootViewController(MainTabVC(), options: UIWindow.TransitionOptions(direction: .toLeft, style: .easeIn), slide_direction: .fromLeftToRight)
        
    }
    
}

extension MoreProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    
    func ImageFromGallary()
    {
        let picker = UIImagePickerController.init()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        picker.navigationBar.tintColor = UIColor.white
        picker.navigationBar.barTintColor = UIColor.gray
        present(picker, animated: true, completion: nil)
    }
    
    func ImageFromCamera()
    {
        let picker = UIImagePickerController.init()
        picker.delegate = self
        
        picker.allowsEditing = false
        picker.sourceType = .camera
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)!
        picker.navigationBar.tintColor = UIColor.white
        picker.navigationBar.barTintColor = UIColor.gray
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let img = CommonFuncs().resizeImage(image: chosenImage, targetSize: CGSize(width: 300.0, height: 300.0))
        photo.image = img
        self.new_photo = UIImagePNGRepresentation(img)  as! NSData
        
        var parameter: [String: String]!
        var url: URL!
        
        self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: progressDlg, color: .darkGray, fadeInAnimation: nil)
        
        if !ShareData.user_or_influencer
        {
            
            url = URL(string: "\(ShareData.main_url)profile/influencer.php")!
            parameter = ["user_id": ShareData.user_info.id!, "bio": ShareData.user_info.bio!, "category": ShareData.user_info.category!, "paypal_id": ShareData.user_info.paypal_id!, "venmo_id": ShareData.user_info.venmo_id!, "work_day": ShareData.user_info.work_day!, "chat_time": ShareData.user_info.chat_time!, "chat_rate": ShareData.user_info.chat_rate!, "time_zone": ShareData.user_info.time_zone!] as! [String: String]
            
        }
        else
        {
            
            url = URL(string: "\(ShareData.main_url)profile/normal.php")!
            parameter = ["user_id": ShareData.user_info.id!, "bio": ShareData.user_info.bio!, "category": ShareData.user_info.category!, "paypal_id": ShareData.user_info.paypal_id!, "venmo_id": ShareData.user_info.venmo_id!, "time_zone": ShareData.user_info.time_zone!] as! [String: String]
        }
        
        
        Alamofire.upload(multipartFormData: { (multiPartFormData: MultipartFormData) in
            for (key, value) in parameter as! [String: String] {
                multiPartFormData.append((value as String).data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, withName: key)
            }
            
            if self.new_photo != nil
            {
                
                multiPartFormData.append(self.new_photo! as Data, withName: "upload", fileName: "profile.png", mimeType: "image/png")
            }
            
            
        }, to: url) { (result: SessionManager.MultipartFormDataEncodingResult) in
            switch result {
            case .success(request: let uploadRequest, _, _ ):
                
                
                uploadRequest.uploadProgress(closure: { (progress) in
                    
                    print("===== \(progress)")
                })
                
                
                uploadRequest.responseJSON(completionHandler: {response in
                    
                    if let JSON = response.result.value
                    {
                        let dictData = JSON as! NSDictionary
                        let status = dictData["status"] as! Bool
                        let message = dictData["message"] as! String
                        if status
                        {
                            let data = dictData["data"] as! [String: Any]
                            
                            if let temp = Mapper<UserMDL>().map(JSONObject: data["profile"])
                            {
                                ShareData.user_info = temp
                            }
                            
                        }
                        
                        self.stopAnimating(nil)
                        CommonFuncs().doneAlert(ShareData.appTitle, message, "CLOSE", {picker.dismiss(animated:true, completion: nil)})
                    }
                    
                })
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        dismiss(animated: true, completion: nil)
    }
    
}

extension MoreProfileVC: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tab_index == 0
        {
            return ShareData.feeds.count
        }
        else
        {
            return filter_reviews.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tab_index == 0
        {
            let data = ShareData.feeds[indexPath.row]
            let array = self.feedDataProcess(data)
            
            if data.type! == ShareData.feed_type().promotion
            {
                
                return CommonFuncs().getStringHeight(CommonFuncs().splitString(data.optional_value!)[2], 12, UIScreen.main.bounds.width, 80, 200)
            }
            
            if array[1] == "1"
            {
                return CommonFuncs().getStringHeight(array[0], 12, UIScreen.main.bounds.width, 80, 30)
            }
            else
            {
                return CommonFuncs().getStringHeight(array[0], 12, UIScreen.main.bounds.width, 80, 55)
            }
        }
        else
        {
            let height = CommonFuncs().getStringHeight(filter_reviews[indexPath.row].review!, 13, UIScreen.main.bounds.width, 60, 65)
            
            return height
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if tab_index == 0
        {
            let data = ShareData.feeds[indexPath.row]
            let array = self.feedDataProcess(data)
            
            if data.type! == ShareData.feed_type().promotion
            {
                let cell : FeedPromotionCell = tableView.dequeueReusableCell(withIdentifier: "FeedPromotionCell", for: indexPath) as! FeedPromotionCell
                
                cell.backgroundColor = UIColor.clear
                cell.contentView.backgroundColor = UIColor.clear
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                
                cell.photo.load(url: data.photo!)
                cell.photo.layer.cornerRadius = cell.photo.frame.width / 2
                cell.photo.clipsToBounds = true
                cell.name.text = data.name!
                cell.time.backgroundColor = Utility.color(withHexString: ShareData.btn_color)
                cell.time.layer.cornerRadius = 4
                cell.time.clipsToBounds = true
                
                let array = CommonFuncs().splitString(data.optional_value!)
                cell.promotion_txt.text = array[2]
                cell.promotion_img.load(url: array[0])
                
                return cell
                
            }
            
            if array[1] == "1"
            {
                let cell : FeedWarnCell = tableView.dequeueReusableCell(withIdentifier: "FeedWarnCell", for: indexPath) as! FeedWarnCell
                
                cell.backgroundColor = UIColor.clear
                cell.contentView.backgroundColor = UIColor.clear
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                
                cell.warn_view.backgroundColor = Utility.color(withHexString: "143755")
                cell.warn_view.layer.cornerRadius = cell.warn_view.frame.height / 2
                cell.warn_view.clipsToBounds = true
                
                let attributedString = NSMutableAttributedString(string: array[0])
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 5
                attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
                cell.message.attributedText = attributedString
                
                return cell
            }
            else
            {
                let cell : FeedPhotoCell = tableView.dequeueReusableCell(withIdentifier: "FeedPhotoCell", for: indexPath) as! FeedPhotoCell
                
                cell.backgroundColor = UIColor.clear
                cell.contentView.backgroundColor = UIColor.clear
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                
                cell.photo.load(url: data.photo!)
                cell.photo.layer.cornerRadius = cell.photo.frame.width / 2
                cell.photo.clipsToBounds = true
                cell.name.text = data.name!
                cell.history.text = CommonFuncs().historyTime(data.time!, data.time_zone!)
                cell.message.text = array[0]
                
                return cell
            }
        }
        else
        {
            let cell : ReviewCell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! ReviewCell
            
            cell.backgroundColor = UIColor.clear
            cell.contentView.backgroundColor = UIColor.clear
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            let data = filter_reviews[indexPath.row]
            
            cell.photo.load(url: data.photo!)
            cell.photo.layer.cornerRadius = cell.photo.frame.width / 2
            cell.photo.clipsToBounds = true
            
            cell.name.text = data.name!
            
            cell.post_date.text = CommonFuncs().historyTime(data.time!, data.time_zone!)
            
            CommonFuncs().likeStars((Double(data.mark1!)! + Double(data.mark2!)! + Double(data.mark3!)!) / 3, cell.like_stars)
            
            cell.review.text = data.review!
            
            return cell
        }
        
        
    }
    
    func feedDataProcess(_ data: FeedMDL) -> [String]
    {
        var txt = ""
        var status = "0"
        
        switch data.type!
        {
            
        case ShareData.feed_type().auction_create:
            
            let array = CommonFuncs().splitString(data.optional_value!)
            let index = ShareData.charity_list.index {$0.id == array[1]}!
            txt = "\(data.name!) created new auction for \(ShareData.charity_list![index].name!) that will begin on \(CommonFuncs().timeString("\(array[2])-\(array[3])-\(array[4])-00-00", "", 0))"
            status = "0"
            break
            
        case ShareData.feed_type().auction_update:
            
            let array = CommonFuncs().splitString(data.optional_value!)
            let index = ShareData.charity_list.index {$0.id == array[1]}!
            txt = "\(data.name!) updated his auction for \(ShareData.charity_list![index].name!) that will begin on \(CommonFuncs().timeString("\(array[2])-\(array[3])-\(array[4])-00-00", "", 0))"
            status = "0"
            break
            
        case ShareData.feed_type().auction_follow:
            
            let array = CommonFuncs().splitString(data.optional_value!)
            let index = ShareData.charity_list.index {$0.id == array[1]}!
            txt = "\(data.name!) followed your auction for \(ShareData.charity_list![index].name!) that will begin on \(CommonFuncs().timeString("\(array[2])-\(array[3])-\(array[4])-00-00", "", 0))"
            status = "0"
            break
            
        case ShareData.feed_type().auction_bid:
            
            let array = CommonFuncs().splitString(data.optional_value!)
            let index = ShareData.charity_list.index {$0.id == array[1]}!
            txt = "\(data.name!) bidded on your auction for \(ShareData.charity_list![index].name!) that will begin on \(CommonFuncs().timeString("\(array[2])-\(array[3])-\(array[4])-00-00", "", 0))"
            status = "0"
            break
            
        case ShareData.feed_type().auction_bid_update:
            
            let array = CommonFuncs().splitString(data.optional_value!)
            let index = ShareData.charity_list.index {$0.id == array[1]}!
            txt = "\(data.name!) updated his bid on your auction for \(ShareData.charity_list![index].name!) that will begin on \(CommonFuncs().timeString("\(array[2])-\(array[3])-\(array[4])-00-00", "", 0))"
            status = "0"
            break
            
        case ShareData.feed_type().book_request:
            
            let array = CommonFuncs().splitString(data.optional_value!)
            txt = "\(data.name!) want to chat with you on \(CommonFuncs().timeString("\(array[1])-\(array[2])-\(array[3])-\(array[4])-\(array[5])", "", 0))"
            status = "0"
            break
            
        case ShareData.feed_type().book_accept:
            
            let array = CommonFuncs().splitString(data.optional_value!)
            txt = "\(data.name!) accepted your booking request on \(CommonFuncs().timeString("\(array[1])-\(array[2])-\(array[3])-\(array[4])-\(array[5])", "", 0))"
            status = "0"
            break
            
        case ShareData.feed_type().book_cancel:
            
            let array = CommonFuncs().splitString(data.optional_value!)
            txt = "\(data.name!) rejected your booking request on \(CommonFuncs().timeString("\(array[1])-\(array[2])-\(array[3])-\(array[4])-\(array[5])", "", 0))"
            status = "0"
            break
            
        case ShareData.feed_type().book_add_time:
            
            let array = CommonFuncs().splitString(data.optional_value!)
            txt = "\(data.name!) paid \(array[1]) PopCoin for additional \(array[0]) minutes  for book on \(CommonFuncs().timeString("\(array[1])-\(array[2])-\(array[3])-\(array[4])-\(array[5])", "", 0))"
            status = "0"
            break
            
        case ShareData.feed_type().book_video_sent:
            
            txt = "\(data.name!) sent new video"
            status = "0"
            break
            
        case ShareData.feed_type().book_video_seen:
            
            txt = "\(data.name!) had seen your video"
            status = "0"
            break
            
        case ShareData.feed_type().follow_request:
            
            txt = "\(data.name!) want to follow"
            status = "0"
            break
            
        case ShareData.feed_type().follow_accept:
            
            txt = "\(data.name!) accepted your following request"
            status = "0"
            break
            
        case ShareData.feed_type().follow_cancel:
            
            txt = "\(data.name!) rejected your following request"
            status = "0"
            break
            
        case ShareData.feed_type().fee_msg:
            
            txt = data.optional_value!
            status = "0"
            break
            
        case ShareData.feed_type().review_left:
            
            txt = "\(data.name!) left review for book with you on \(CommonFuncs().timeString(data.optional_value!, "", 0))"
            status = "0"
            break
            
        case ShareData.feed_type().other_popcoin_zero:
            
            txt = "Your PopCoin balance is depleted.  You will need to buy some additional PopCoins before scheduling a booking"
            status = "1"
            break
            
            
        case ShareData.feed_type().other_book_fee_charged:
            
            let array = CommonFuncs().splitString(data.optional_value!)
            txt = "You paid \(array[0]) PopCoin for book with \(data.name!) on \(CommonFuncs().timeString("\(array[1])-\(array[2])-\(array[3])-\(array[4])-\(array[5])", "", 0))"
            status = "1"
            break
            
            
        case ShareData.feed_type().other_book_fee_received:
            
            let array = CommonFuncs().splitString(data.optional_value!)
            txt = "You finished book with \(data.name!) on \(CommonFuncs().timeString("\(array[1])-\(array[2])-\(array[3])-\(array[4])-\(array[5])", "", 0)) and received \(array[0]) PopCoin"
            status = "1"
            break
            
        case ShareData.feed_type().other_book_fee_refunded:
            
            let array = CommonFuncs().splitString(data.optional_value!)
            txt = "You have refuned \(array[0]) PopCoin for book with \(data.name!) on \(CommonFuncs().timeString("\(array[1])-\(array[2])-\(array[3])-\(array[4])-\(array[5])", "", 0))"
            status = "1"
            break
            
        case ShareData.feed_type().other_book_add_time:
            
            let array = CommonFuncs().splitString(data.optional_value!)
            txt = "You paid \(array[1]) PopCoin for additional \(array[0]) minutes for book with \(data.name!) on \(CommonFuncs().timeString("\(array[2])-\(array[3])-\(array[4])-\(array[5])-\(array[6])", "", 0))"
            status = "1"
            break
            
        case ShareData.feed_type().other_book_time_over:
            
            let array = CommonFuncs().splitString(data.optional_value!)
            txt = "A book with \(data.name!) on \(CommonFuncs().timeString("\(array[1])-\(array[2])-\(array[3])-\(array[4])-\(array[5])", "", 0)) is canceled, be course time is expired"
            status = "1"
            break
            
        case ShareData.feed_type().other_book_process_fee:
            
            let array = CommonFuncs().splitString(data.optional_value!)
            txt = "You paid \(array[0]) PopCoin fee for book with \(data.name!) on \(CommonFuncs().timeString("\(array[1])-\(array[2])-\(array[3])-\(array[4])-\(array[5])", "", 0))"
            status = "1"
            break
            
        default:
            break
        }
        
        return [txt, status]
    }
}

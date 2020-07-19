//
//  MainVideoReviewVC.swift
//  famouschat
//
//  Created by T-Tech Solutions LLC on 07/11/2018.
//  Copyright © 2018 T-Tech Solutions LLC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class MainVideoReviewVC: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet weak var menu_img: UIImageView!
    @IBOutlet weak var menu_btn: UIButton!
    @IBOutlet weak var header_frame: UIView!
    @IBOutlet weak var review_title: UILabel!
    @IBOutlet weak var que1_star0: UIButton!
    @IBOutlet weak var que1_star1: UIButton!
    @IBOutlet weak var que1_star2: UIButton!
    @IBOutlet weak var que1_star3: UIButton!
    @IBOutlet weak var que1_star4: UIButton!
    @IBOutlet weak var que2_star0: UIButton!
    @IBOutlet weak var que2_star1: UIButton!
    @IBOutlet weak var que2_star2: UIButton!
    @IBOutlet weak var que2_star3: UIButton!
    @IBOutlet weak var que2_star4: UIButton!
    @IBOutlet weak var que3_star0: UIButton!
    @IBOutlet weak var que3_star1: UIButton!
    @IBOutlet weak var que3_star2: UIButton!
    @IBOutlet weak var que3_star3: UIButton!
    @IBOutlet weak var que3_star4: UIButton!
    @IBOutlet weak var review_frame: UIView!
    @IBOutlet weak var review_in: UITextView!
    @IBOutlet weak var publish_btn: UIButton!
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var ques_label1: UILabel!
    @IBOutlet weak var ques_label2: UILabel!
    @IBOutlet weak var ques_label3: UILabel!
    
    let progressDlg = ShareData.progressDlgs[ShareData.progress_index]
    var scroll_offset: CGFloat = 0.0
    
    var que1_btns = [UIButton]()
    var que2_btns = [UIButton]()
    var que3_btns = [UIButton]()
    
    var review = "0"
    var mark1 = "0"
    var mark2 = "0"
    var mark3 = "0"
    var review_type = "0"
    var provider_id = "0"
    var receiver_id = "0"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        que1_btns = [que1_star0, que1_star1, que1_star2, que1_star3, que1_star4]
        que2_btns = [que2_star0, que2_star1, que2_star2, que2_star3, que2_star4]
        que3_btns = [que3_star0, que3_star1, que3_star2, que3_star3, que3_star4]
        
        init_UI()
    }

    func init_UI()
    {
        self.navigationController?.isNavigationBarHidden = true
        
        header_frame.dropShadow(color: .gray, opacity: 0.5, offSet: CGSize.zero, radius: 8, scale: true)
        
        let menu_image = UIImage.init(named: "menu")!.withRenderingMode(.alwaysTemplate)
        menu_img.image = menu_image
        menu_img.tintColor = Utility.color(withHexString: "10A7BA")
        menu_img.isHidden = true
        
        review_title.text = "Review Chat with " + ShareData.selected_book.profile.name!
        
        ques_label1.text = "Did \(ShareData.selected_book.profile.name!) answer your question?"
        ques_label2.text = "Did \(ShareData.selected_book.profile.name!) answer your question?"
        ques_label3.text = "Did \(ShareData.selected_book.profile.name!) answer your question?"
        
        review_frame.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        review_frame.layer.borderWidth = 1
        review_frame.layer.borderColor = UIColor.gray.cgColor
        review_frame.clipsToBounds = true
        
        review_in.delegate = self
        review_in.text = "Write review here..."
        
        publish_btn.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        publish_btn.clipsToBounds = true
        publish_btn.dropShadow(color: .gray, opacity: 0.8, offSet: CGSize.zero, radius: 5, scale: true)
        
        
        for que1_btn in que1_btns
        {
            let image = UIImage(named: "star")?.withRenderingMode(.alwaysTemplate)
            que1_btn.setImage(image, for: .normal)
            que1_btn.tintColor = Utility.color(withHexString: ShareData.star_non_color)
        }
        
        for que1_btn in que2_btns
        {
            let image = UIImage(named: "star")?.withRenderingMode(.alwaysTemplate)
            que1_btn.setImage(image, for: .normal)
            que1_btn.tintColor = Utility.color(withHexString: ShareData.star_non_color)
        }
        
        for que1_btn in que3_btns
        {
            let image = UIImage(named: "star")?.withRenderingMode(.alwaysTemplate)
            que1_btn.setImage(image, for: .normal)
            que1_btn.tintColor = Utility.color(withHexString: ShareData.star_non_color)
        }
        
    }
    
    
    
    @IBAction func que1Star1Action(_ sender: Any) {
        
        mark1 = "1"
        starAction(stars: que1_btns, index: 1)
    }
    
    @IBAction func que1Star2Action(_ sender: Any) {
        
        mark1 = "2"
        starAction(stars: que1_btns, index: 2)
    }
    
    @IBAction func que1Star3Action(_ sender: Any) {
        
        mark1 = "3"
        starAction(stars: que1_btns, index: 3)
    }
    
    @IBAction func que1Star4Action(_ sender: Any) {
        
        mark1 = "4"
        starAction(stars: que1_btns, index: 4)
    }
    
    @IBAction func que1Star5Action(_ sender: Any) {
        
        mark1 = "5"
        starAction(stars: que1_btns, index: 5)
    }
    
    @IBAction func que2Star1Action(_ sender: Any) {
        
        mark2 = "1"
        starAction(stars: que2_btns, index: 1)
    }
    
    @IBAction func que2Star2Action(_ sender: Any) {
        
        mark2 = "2"
        starAction(stars: que2_btns, index: 2)
    }
    
    @IBAction func que2Star3Action(_ sender: Any) {
        
        mark2 = "3"
        starAction(stars: que2_btns, index: 3)
    }
    
    @IBAction func que2Star4Action(_ sender: Any) {
        
        mark2 = "4"
        starAction(stars: que2_btns, index: 4)
    }
    
    @IBAction func que2Star5Action(_ sender: Any) {
        
        mark2 = "5"
        starAction(stars: que2_btns, index: 5)
    }
    
    @IBAction func que3Star1Action(_ sender: Any) {
        
        mark3 = "1"
        starAction(stars: que3_btns, index: 1)
    }
    
    @IBAction func que3Star2Action(_ sender: Any) {
        
        mark3 = "2"
        starAction(stars: que3_btns, index: 2)
    }
    
    @IBAction func que3Star3Action(_ sender: Any) {
        
        mark3 = "3"
        starAction(stars: que3_btns, index: 3)
    }
    
    @IBAction func que3Star4Action(_ sender: Any) {
        
        mark3 = "4"
        starAction(stars: que3_btns, index: 4)
    }
    
    @IBAction func que3Star5Action(_ sender: Any) {
        
        mark3 = "5"
        starAction(stars: que3_btns, index: 5)
    }
    
    
    
    @IBAction func publishAction(_ sender: Any) {
        
        if review_in.text! == "" || review_in.text! == nil || review_in.text! == "Write review here..."
        {
            return
        }
        
        if ShareData.video_chat_start_status
        {
            provider_id = ShareData.selected_book.book.influencer_id!
            receiver_id = ShareData.selected_book.book.normal_id!
            review_type = "1"
        }
        else
        {
            provider_id = ShareData.selected_book.book.normal_id!
            receiver_id = ShareData.selected_book.book.influencer_id!
            review_type = "0"
        }
        
        ShareData.video_chat_start_status = false
        
        self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: progressDlg, color: .darkGray, fadeInAnimation: nil)
        
        let send_time = CommonFuncs().currentTime()
        
        let parmeters = ["provider_id": provider_id, "receiver_id": receiver_id, "review_type": review_type, "book_id": ShareData.selected_book.book.id!, "mark1": mark1, "mark2": mark2, "mark3": mark3, "review": review_in.text!, "review_date": send_time, "time": send_time, "time_zone": ShareData.user_info.time_zone!] as [String: Any]
        
        CommonFuncs().createRequest(true, "review", "POST", parmeters, completionHandler: {data in
            
            let status = data["status"] as! Bool
            let message = data["message"] as! String
            
            DispatchQueue.main.async {
                
                self.stopAnimating(nil)
                CommonFuncs().doneAlert(ShareData.appTitle, message, "DONE", {ShareData.books = ShareData.books.filter { $0.book.id! != ShareData.selected_book.book.id! }
                    UIApplication.shared.keyWindow?.setRootViewController(MainTabVC(), options: UIWindow.TransitionOptions(direction: .toLeft, style: .easeIn), slide_direction: .fromLeftToRight)})
                
            }
        })
        
    }
   
}

extension MainVideoReviewVC: UITextViewDelegate
{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        review_in.text = ""
        scroll.setContentOffset(CGPoint(x: CGFloat(0), y: CGFloat(250)), animated: true)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        if textView.text.contains("\n")
        {
            let str = textView.text!
            textView.text = str.substring(to: str.index(before: str.endIndex))
            textView.resignFirstResponder()
        }
    }
    
}


extension MainVideoReviewVC
{
    
    func starAction(stars:[UIButton], index: Int)
    {
        let image = UIImage(named: "star")?.withRenderingMode(.alwaysTemplate)
        for i in 0..<index
        {
            stars[i].setImage(image, for: .normal)
            stars[i].tintColor = Utility.color(withHexString: ShareData.star_color)
        }
        for i in index..<stars.count
        {
            stars[i].setImage(image, for: .normal)
            stars[i].tintColor = Utility.color(withHexString: ShareData.star_non_color)
        }
    }
}

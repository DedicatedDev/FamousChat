//
//  StartCategoryVC.swift
//  famouschat
//
//  Created by T-Tech Solutions LLC on 05/11/2018.
//  Copyright © 2018 T-Tech Solutions LLC. All rights reserved.
//

import UIKit
import Alamofire
import UICollectionViewLeftAlignedLayout
import NVActivityIndicatorView
import ObjectMapper

class StartCategoryVC: UIViewController, NVActivityIndicatorViewable{
    
    @IBOutlet weak var category_label: UILabel!
    @IBOutlet weak var category_label_height_constrain: NSLayoutConstraint!
    @IBOutlet weak var next_frame: UIView!
    @IBOutlet weak var next_btn: UIButton!
    @IBOutlet weak var prev_frame: UIView!
    @IBOutlet weak var prev_btn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let progressDlg = ShareData.progressDlgs[ShareData.progress_index]
    
    let user_category_label = "What categories are you most interested in? Click a few and we’ll suggest people to follow!"
    let influencer_category_label = "Please choose the category you would like to associate yourself with. Whatever best suits your content!"
    
    var category_status = [Bool]()
    var selected_categories = [CategoryMDL]()
    var category_open_status = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        var index = [String]()
        
        if ShareData.user_info.category! != ""
        {
            if ShareData.user_info.category!.contains(",")
            {
                index = CommonFuncs().splitString(ShareData.user_info.category!)
            }
            else
            {
                index = [ShareData.user_info.category!]
            }
            
        }
        
        category_status = Array(repeating: false, count: ShareData.category_list.count)
        
        if index.count > 0
        {
            for i in 0..<ShareData.category_list.count
            {
                for j in index
                {
                    if j == ShareData.category_list[i].id
                    {
                        category_status[i] = true
                        selected_categories.append(ShareData.category_list[i])
                    }
                }
            }
        }
        
        
        init_UI()
    }
    
    func init_UI()
    {
        self.navigationController?.isNavigationBarHidden = true
        
        if ShareData.user_or_influencer
        {
            category_label.text = user_category_label
            category_label_height_constrain.constant = CommonFuncs().getStringHeight(user_category_label, 15, UIScreen.main.bounds.width, 40, 20)
        }
        else
        {
            category_label.text = influencer_category_label
            category_label_height_constrain.constant = CommonFuncs().getStringHeight(influencer_category_label, 15, UIScreen.main.bounds.width, 40, 10)
        }
        
        
        
        next_frame.layer.cornerRadius = next_frame.frame.width / 2
        next_frame.clipsToBounds = true
        next_frame.dropShadow(color: .lightGray, opacity: 0.8, offSet: CGSize.zero, radius: 5, scale: true)
        let image = UIImage(named: "return")?.withRenderingMode(.alwaysTemplate)
        next_btn.setImage(image, for: .normal)
        next_btn.transform = next_btn.transform.rotated(by: CGFloat(Double.pi))
        next_btn.tintColor = UIColor.white
        
        
        prev_frame.layer.cornerRadius = prev_frame.frame.width / 2
        prev_frame.clipsToBounds = true
        prev_frame.dropShadow(color: .lightGray, opacity: 0.8, offSet: CGSize.zero, radius: 5, scale: true)
        prev_btn.setImage(image, for: .normal)
        prev_btn.tintColor = UIColor.white
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "OneLabelCell", bundle: nil), forCellWithReuseIdentifier: "OneLabelCell")
        collectionView.collectionViewLayout = UICollectionViewLeftAlignedLayout()
        
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    
    
    @IBAction func prevAction(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextAction(_ sender: Any) {
        
        nextAction()
        
    }
    
}

extension StartCategoryVC
{
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer)
    {
        
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer
        {
            switch swipeGesture.direction
            {
                
            case UISwipeGestureRecognizerDirection.left:
                
                 nextAction()
                
            case UISwipeGestureRecognizerDirection.right:
                
                self.navigationController?.popViewController(animated: true)
                
            default:
                break
            }
        }
    }
    
    func nextAction()
    {
        
        if selected_categories == nil || selected_categories.count == 0
        {
            CommonFuncs().doneAlert(ShareData.appTitle, "Please select one category at least", "CLOSE", {})
            return
        }
        
        var category = ""
        
        for i in 0..<selected_categories.count - 1
        {
            category += "\(selected_categories[i].id as! String),"
        }
        category += selected_categories[selected_categories.count - 1].id as! String
        
        ShareData.profile_category = category as! String
        
        
        if ShareData.user_or_influencer
        {
            ShareData.new_following_list = [UserMDL]()
            
            self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: progressDlg, color: .white, fadeInAnimation: nil)
            
            next_btn.isUserInteractionEnabled = false
            prev_btn.isUserInteractionEnabled = false
            collectionView.isUserInteractionEnabled = false
            
            let parmeters = ["user_id": ShareData.user_info.id!, "category_key": ShareData.profile_category] as [String: Any]
            
            CommonFuncs().createRequest(true, "category", "POST", parmeters, completionHandler: {data in
                
                let status = data["status"] as! Bool
                let message = data["message"] as! String
                
                DispatchQueue.main.async {
                    
                    if status
                    {
                        if let influencers = data["data"]
                        {
                            if let temp = Mapper<UserMDL>().mapArray(JSONObject: influencers)
                            {
                                ShareData.new_following_list = temp
                            }
                            
                        }
                    }
                    
                    self.stopAnimating(nil)
                    self.next_btn.isUserInteractionEnabled = true
                    self.prev_btn.isUserInteractionEnabled = true
                    self.collectionView.isUserInteractionEnabled = true
                    self.navigationController?.pushViewController(StartDiscoverVC(), animated: true)
                }
            })
        }
        else
        {
            self.stopAnimating(nil)
            self.next_btn.isUserInteractionEnabled = true
            self.prev_btn.isUserInteractionEnabled = true
            self.collectionView.isUserInteractionEnabled = true
            self.navigationController?.pushViewController(ProfilePhotoVC(), animated: true)
        }
    }
    
}


extension StartCategoryVC: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return ShareData.category_list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return section == 0 ? 15 :5
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(10, 10, 10, 10)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let str = ShareData.category_list[indexPath.row].name!
        let font = UIFont.systemFont(ofSize: CGFloat(13))
        let width = str.widthOfString(font: font) + 50
        let height = CGFloat(30)
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OneLabelCell", for: indexPath) as! OneLabelCell
        
        cell.layer.cornerRadius = cell.frame.height / 2
        cell.layer.borderColor = Utility.color(withHexString: ShareData.btn_color).cgColor
        cell.layer.borderWidth = 1
        cell.clipsToBounds = true
        
        if category_status[indexPath.row]
        {
            cell.backgroundColor = Utility.color(withHexString: ShareData.btn_color)
        }
        else
        {
            cell.backgroundColor = UIColor.clear
        }
        
        cell.name.text = ShareData.category_list[indexPath.row].name
        
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if !category_status[indexPath.row]
        {
            selected_categories.append(ShareData.category_list[indexPath.row])
            category_status[indexPath.row] = true
        }
        else
        {
            
            let index = selected_categories.index{ $0.id == ShareData.category_list[indexPath.row].id }
            selected_categories.remove(at: index!)
            category_status[indexPath.row] = false
        }
        
        collectionView.reloadData()
    }
    
}


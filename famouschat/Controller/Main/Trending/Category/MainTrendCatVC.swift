//
//  MainTrendCatVC.swift
//  famouschat
//
//  Created by T-Tech Solutions LLC on 07/11/2018.
//  Copyright © 2018 T-Tech Solutions LLC. All rights reserved.
//

import UIKit
import SDWebImage
import NVActivityIndicatorView
import ObjectMapper

class MainTrendCatVC: UIViewController, NVActivityIndicatorViewable {
    
    @IBOutlet weak var back_img: UIImageView!
    @IBOutlet weak var back_btn: UIButton!
    @IBOutlet weak var menu_img: UIImageView!
    @IBOutlet weak var menu_btn: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let progressDlg = ShareData.progressDlgs[ShareData.progress_index]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        init_UI()
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
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "TrendCatCell", bundle: nil), forCellWithReuseIdentifier: "TrendCatCell")
        
        
    }
    
    @objc func backAction(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
}

extension MainTrendCatVC: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
   
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        if ShareData.category_list.count % 2 == 0
        {
            return ShareData.category_list.count / 2
        }
        else
        {
            return ShareData.category_list.count / 2 + 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        return UIEdgeInsets(top: 5, left: 5, bottom: 15, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 15
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = (collectionView.frame.width - 30) / 2
        let height = width * 0.6
        
        return CGSize(width: width, height: height)

    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrendCatCell", for: indexPath) as! TrendCatCell
        
        cell.layer.cornerRadius = 12
        cell.clipsToBounds = true
        
        let index = indexPath.section * 2 + indexPath.row
        
        if index < ShareData.category_list.count
        {
            let str = ShareData.category_list[index].name!
            
            let label_height = CommonFuncs().getStringHeight(str, 13, cell.frame.width, 30, 15)
            
            cell.name_height.constant = label_height
            cell.name.text = str
            cell.image.load(url: ShareData.category_list[index].photo!)
        }
        else
        {
            cell.alpha = 0
        }
        
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.collectionView.isUserInteractionEnabled = false
        
        let index = indexPath.section * 2 + indexPath.row
        
        if index >= ShareData.category_list.count
        {
            return
        }
        
        ShareData.new_following_list = [UserMDL]()
        
        ShareData.trend_selected_category = ShareData.category_list[index]
        
        self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: progressDlg, color: .white, fadeInAnimation: nil)
        
        let parmeters = ["user_id": ShareData.user_info.id!, "category_key": ShareData.category_list[index].id!] as [String: Any]
        
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
                    self.stopAnimating(nil)
                    self.collectionView.isUserInteractionEnabled = true
                    self.navigationController?.pushViewController(MainTrendCatResultVC(), animated: true)
                }
                else
                {
                    self.collectionView.isUserInteractionEnabled = true
                    self.stopAnimating(nil)
                    CommonFuncs().doneAlert(ShareData.appTitle, message, "CLOSE", {})
                }
            }
        })
    }
    
}


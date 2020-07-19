//
//  StartDiscoverVC.swift
//  famouschat
//
//  Created by T-Tech Solutions LLC on 05/11/2018.
//  Copyright © 2018 T-Tech Solutions LLC. All rights reserved.
//

import UIKit
import SDWebImage
import NVActivityIndicatorView

class StartDiscoverVC: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var next_frame: UIView!
    @IBOutlet weak var next_btn: UIButton!
    @IBOutlet weak var prev_frame: UIView!
    @IBOutlet weak var prev_btn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var exp_label1: UILabel!
    @IBOutlet weak var exp_label2: UILabel!
    @IBOutlet weak var exp_label3: UILabel!
    @IBOutlet weak var alert_frame: UIView!
    @IBOutlet weak var alert_image: UIImageView!
    @IBOutlet weak var alert_name: UILabel!
    @IBOutlet weak var alert_specialty: UILabel!
    @IBOutlet weak var alert_follow_btn: UIButton!
    @IBOutlet weak var alert_cancel_btn: UIButton!
    
    var collectionViewLayout: LGHorizontalLinearFlowLayout?
    
    let progressDlg = ShareData.progressDlgs[ShareData.progress_index]
    var selected_influencer: UserMDL!
    var follow_status = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        init_UI()
    }

    func init_UI()
    {
        
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
        collectionView.register(UINib(nibName: "DiscoverCell", bundle: nil), forCellWithReuseIdentifier: "DiscoverCell")
        
        let height = collectionView.frame.height - 20
        let width = height * 0.75
        
        collectionViewLayout = LGHorizontalLinearFlowLayout.init(configuredWith: collectionView, itemSize: CGSize(width: width, height: height), minimumLineSpacing: 0)
        
        alert_frame.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        alert_frame.clipsToBounds = true
        alert_frame.dropShadow(color: Utility.color(withHexString: ShareData.btn_color), opacity: 1, offSet: CGSize.zero, radius: 5, scale: true)
        alert_follow_btn.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        alert_follow_btn.clipsToBounds = true
        alert_follow_btn.dropShadow(color: .darkGray, opacity: 0.8, offSet: CGSize.zero, radius: 3, scale: true)
        alert_cancel_btn.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        alert_cancel_btn.clipsToBounds = true
        alert_cancel_btn.dropShadow(color: .darkGray, opacity: 0.8, offSet: CGSize.zero, radius: 3, scale: true)
        alert_frame.isHidden = true
       
        
        if ShareData.new_following_list == nil || ShareData.new_following_list.count == 0
        {
            CommonFuncs().doneAlert(ShareData.appTitle, "There is no matched influencer", "CLOSE", {})
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let mid_num = ShareData.new_following_list.count / 2
        collectionView.scrollToIndex(index: mid_num)
        
        if follow_status
        {
            alert_image.layer.cornerRadius = alert_image.frame.width / 2
            alert_image.clipsToBounds = true
            
            alert_image.load(url: selected_influencer.photo!)
            alert_name.text = selected_influencer.name!
            alert_specialty.text = selected_influencer.email!
        }
    }
    
    @IBAction func followAction(_ sender: Any) {
        
        
        self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: progressDlg, color: .white, fadeInAnimation: nil)
        
        let send_time = CommonFuncs().currentTime()
        
        let parmeters = ["normal_id": ShareData.user_info.id!, "influencer_id": selected_influencer.id!, "time": send_time, "time_zone": ShareData.user_info.time_zone!] as [String: Any]
        
        CommonFuncs().createRequest(false, "follow/request", "POST", parmeters, completionHandler: {data in
            
            let status = data["status"] as! Bool
            let message = data["message"] as! String
            self.stopAnimating(nil)
            
            DispatchQueue.main.async {
                
                if status
                {
                    CommonFuncs().doneAlert(ShareData.appTitle, message, "CLOSE", {self.alert_frame.isHidden = true
                        self.scrollView.isHidden = false})
                    
                }
                else
                {
                    
                    CommonFuncs().doneAlert(ShareData.appTitle, message, "CLOSE", {self.alert_frame.isHidden = true})
                    
                }
            }
        })
        
        
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        
        scrollView.isHidden = false
        follow_status = false
        alert_frame.isHidden = true
    }
    
    @IBAction func nextAction(_ sender: Any) {

        self.navigationController?.pushViewController(ProfilePhotoVC(), animated: true)
        
    }
    
    @IBAction func prevAction(_ sender: Any) {
        
        if ShareData.new_following_list.count > 0
        {
            ShareData.new_following_list.removeAll()
        }
//        SDImageCache.shared.clearMemory()
//        SDImageCache.shared.clearDisk()
        self.navigationController?.popViewController(animated: true)
    }
    
   

}


extension StartDiscoverVC: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return ShareData.new_following_list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 50
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let height = collectionView.frame.height - 20
        let width = height * 0.75
        return CGSize(width: width, height: height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverCell", for: indexPath) as! DiscoverCell
        
        cell.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        cell.clipsToBounds = true
        cell.dropShadow(color: .white, opacity: 0.8, offSet: CGSize.zero, radius: 5, scale: true)
        
        
        let data = ShareData.new_following_list[indexPath.row]
        cell.image.load(url: data.photo!)
        cell.name.text = data.name!
        
        if data.name!.contains(" ")
        {
            let array = data.name!.characters.split{$0 == " "}.map(String.init)
            cell.chanel.text = "@" + CommonFuncs().strArrayTostr(array, "")
        }
        else
        {
            cell.chanel.text = "@" + data.name!
        }
        
        cell.image.layer.cornerRadius = cell.image.frame.width / 2
        cell.image.clipsToBounds = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let center0 = self.collectionView.frame.midX
        let center1 = cell.frame.midX
        
        let diff = abs(Int(center0 - center1))
        print("\(indexPath.row): \(center0) - \(center1)")
        if diff < 50
        {
            print(indexPath.row)
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selected_influencer = ShareData.new_following_list[indexPath.row]
        scrollView.isHidden = true
        alert_frame.isHidden = false
        follow_status = true
        self.viewWillAppear(true)
    }
    
}

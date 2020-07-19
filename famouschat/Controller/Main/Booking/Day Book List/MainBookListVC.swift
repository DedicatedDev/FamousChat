//
//  MainBookListVC.swift
//  famouschat
//
//  Created by T-Tech Solutions LLC on 08/11/2018.
//  Copyright © 2018 T-Tech Solutions LLC. All rights reserved.
//

import UIKit

class MainBookListVC: UIViewController {

    @IBOutlet weak var back_img: UIImageView!
    @IBOutlet weak var back_btn: UIButton!
    @IBOutlet weak var menu_img: UIImageView!
    @IBOutlet weak var menu_btn: UIButton!
    
    @IBOutlet weak var header_frame: UIView!
    @IBOutlet weak var book_title: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    
    var sorted_list = [BookMDL]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sorted_list = ShareData.selected_day_books.sorted { $0.book.time! < $1.book.time! }
        init_UI()
    }
    
    func init_UI()
    {
        self.navigationController?.isNavigationBarHidden = true
        
        header_frame.dropShadow(color: .gray, opacity: 0.5, offSet: CGSize.zero, radius: 8, scale: true)
        
        let back_image = UIImage.init(named: "back")!.withRenderingMode(.alwaysTemplate)
        back_img.image = back_image
        back_img.tintColor = Utility.color(withHexString: "10A7BA")
        
        let menu_image = UIImage.init(named: "menu")!.withRenderingMode(.alwaysTemplate)
        menu_img.image = menu_image
        menu_img.tintColor = Utility.color(withHexString: "10A7BA")
        menu_img.isHidden = true
        
        back_btn.addTarget(self, action: #selector(self.backAction(_:)), for: .touchUpInside)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "BookListCell", bundle: nil), forCellWithReuseIdentifier: "BookListCell")
        
        let date_arrary = ShareData.book_selected_date.components(separatedBy: "-").flatMap { Int($0.trimmingCharacters(in: .whitespaces))}
        
        book_title.text = "\(ShareData.month_names[Int(date_arrary[1]) - 1]) \(Int(date_arrary[2]))th, \(date_arrary[0])"
        
    }

    @objc func backAction(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
}


extension MainBookListVC: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        let num = sorted_list.count / 2
        let rem = sorted_list.count % 2
        if rem == 0
        {
            return num
        }
        else
        {
            return num + 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 10
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = CGFloat((collectionView.frame.width - 40) / 2)
        let height = width * 0.6 + 100
        
        return CGSize(width: width, height: height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookListCell", for: indexPath) as! BookListCell
        
        let num = indexPath.section * 2 + indexPath.row
        if (num + 1) > sorted_list.count
        {
            cell.isHidden = true
        }
        else
        {
            
            cell.photo.load(url: ShareData.selected_day_books[num].profile.photo!)
            cell.image_height.constant = cell.frame.width * 0.6
            cell.image_frame.layer.cornerRadius = 12
            cell.image_frame.clipsToBounds = true
            
            let array1 = CommonFuncs().splitString(sorted_list[num].book.time!)
            let start_time_str = "\(CommonFuncs().time24To12(array1[3])[0]):\(array1[4]) \(CommonFuncs().time24To12(array1[3])[1])"
            
            
            cell.time.text = "\(start_time_str)"
            
            cell.name.text = sorted_list[num].profile.name!
            cell.question.text = sorted_list[num].book.question!
            
            cell.layer.cornerRadius = 12
            cell.clipsToBounds = true
            
            cell.dropShadow(color: UIColor.gray, opacity: 0.5, offSet: CGSize.zero, radius: 5, scale: true)
            
            
        }
        
        
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let num = indexPath.section * 2 + indexPath.row
        if (num + 1) <= sorted_list.count
        {
            ShareData.selected_book = sorted_list[num]
            ShareData.book_detail_from_status = true
            self.navigationController?.pushViewController(MainBookDetailVC(), animated: true)
        }
        
    }
    
}

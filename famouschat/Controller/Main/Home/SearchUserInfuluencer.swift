//
//  SearchUserInfuluencer.swift
//  famouschat
//
//  Created by mappexpert on 1/14/20.
//  Copyright © 2020 Oni Angel. All rights reserved.
//

import UIKit
import SDWebImage
import NVActivityIndicatorView
import ObjectMapper

class SearchUserInfuluencer: UIViewController, NVActivityIndicatorViewable, UITextFieldDelegate {
    
    
    @IBOutlet weak var back_btn: UIButton!
    @IBOutlet weak var backImg: UIImageView!
    
    @IBOutlet weak var header_frame: UIView!
    @IBOutlet weak var search_frame: UIView!
    @IBOutlet weak var search_img: UIImageView!
    @IBOutlet weak var search_in: UITextField!
    @IBOutlet weak var tableView: UITableView!


    let progressDlg = ShareData.progressDlgs[ShareData.progress_index]
    
   
    var filterd_list = [UserMDL]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filterd_list = ShareData.new_following_list
        init_UI()
        
    }
    
    func init_UI()
    {
        self.navigationController?.isNavigationBarHidden = true
        
        let back_image = UIImage.init(named: "back")!.withRenderingMode(.alwaysTemplate)
        backImg.image = back_image
        backImg.tintColor = Utility.color(withHexString: ShareData.btn_color)
        
        back_btn.addTarget(self, action: #selector(self.backAction(_:)), for: .touchUpInside)
        
        
        header_frame.dropShadow(color: .gray, opacity: 0.5, offSet: CGSize.zero, radius: 8, scale: true)
        
        search_frame.layer.cornerRadius = search_frame.frame.height / 2
        search_frame.layer.borderColor = Utility.color(withHexString: ShareData.btn_color).cgColor
        search_frame.layer.borderWidth = 1
        search_frame.clipsToBounds = true
        
        let image = UIImage(named: "menu_search")!.withRenderingMode(.alwaysTemplate)
        search_img.image = image
        search_img.tintColor = Utility.color(withHexString: ShareData.btn_color)
        
        search_in.delegate = self
        search_in.returnKeyType = .search
        
        search_in.attributedPlaceholder = NSAttributedString(string: "Search...",
                                                             attributes: [NSAttributedStringKey.foregroundColor: Utility.color(withHexString: ShareData.btn_color)])
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TrendSearchCell", bundle: nil), forCellReuseIdentifier: "TrendSearchCell")
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        search_in.resignFirstResponder()
        return true
    }
    
    
    @IBAction func search(_ sender: Any) {
        
        let name_key = search_in.text!
        
        if name_key == nil || name_key == ""
        {
            filterd_list = ShareData.new_following_list
        }
        else
        {
            filterd_list = ShareData.new_following_list.filter { $0.name.lowercased().contains(name_key.lowercased()) }
        }
        
        tableView.reloadData()
    }
    
    
    @objc func backAction(_ sender: UIButton) {
        ShareData.new_following_list.removeAll()
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension SearchUserInfuluencer: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return filterd_list.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell : TrendSearchCell = tableView.dequeueReusableCell(withIdentifier: "TrendSearchCell", for: indexPath) as! TrendSearchCell
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        let data = filterd_list[indexPath.row]
        
        cell.photo.load(url: data.photo!)
        cell.photo.layer.cornerRadius = cell.photo.frame.height / 2
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
        
        cell.job.text = str
        
        cell.under_line.alpha = 0.2
        
        CommonFuncs().likeStars(Double(data.rate!)!, cell.like_stars)
        
        cell.status.layer.cornerRadius = cell.status.frame.width / 2
        cell.status.clipsToBounds = true
        
        if data.status! == "1"
        {
            cell.status.backgroundColor = UIColor.green
            cell.status.dropShadow(color: .green, opacity: 1, offSet: CGSize.zero, radius: 4, scale: true)
        }
        else
        {
            cell.status.backgroundColor = UIColor.gray
            cell.status.dropShadow(color: .gray, opacity: 1, offSet: CGSize.zero, radius: 4, scale: true)
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {



        let parmeters = ["user_id": filterd_list[indexPath.row].id] as [String: Any]

        self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: progressDlg, color: .darkGray, fadeInAnimation: nil)

        CommonFuncs().createRequest(true, "detail", "POST", parmeters, completionHandler: {data in

            let status = data["status"] as! Bool

            DispatchQueue.main.async {


                self.stopAnimating(nil)

                if status
                {
                    if let temp = Mapper<UserMDL>().map(JSONObject: data["data"])
                    {
                        ShareData.selected_influencer = temp

                        self.tableView.isUserInteractionEnabled = true

                        self.navigationController?.pushViewController(MainTrendProfileVC(), animated: true)
                    }

                }
                else
                {

                    CommonFuncs().doneAlert(ShareData.appTitle, "Failed detail request", "CLOSE", {})
                }
            }
        })

    }
}

//
//  MainChatVC.swift
//  famouschat
//
//  Created by T-Tech Solutions LLC on 07/11/2018.
//  Copyright © 2018 T-Tech Solutions LLC. All rights reserved.
//

import UIKit

class MainChatVC: UIViewController {
    
    
    @IBOutlet weak var menu_img: UIImageView!
    @IBOutlet weak var menu_btn: UIButton!
    @IBOutlet weak var header_view: UIView!
    @IBOutlet weak var search_frame: UIView!
    @IBOutlet weak var search_img: UIImageView!
    @IBOutlet weak var search_in: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var no_label: UILabel!
    
    var filtered_list = [MessageMDL]()
    var selected_index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func init_UI()
    {
        
        self.navigationController?.isNavigationBarHidden = true
        
        header_view.dropShadow(color: .gray, opacity: 0.5, offSet: CGSize.zero, radius: 8, scale: true)
        
        let menu_image = UIImage.init(named: "menu")!.withRenderingMode(.alwaysTemplate)
        menu_img.image = menu_image
        menu_img.tintColor = Utility.color(withHexString: "10A7BA")
        
        menu_btn.addTarget(self.slideMenuController, action: #selector(slideMenuController.toggleMenuAnimated(_:)), for: .touchUpInside)
        
        search_frame.layer.cornerRadius = search_frame.frame.height / 2
        search_frame.layer.borderColor = Utility.color(withHexString: ShareData.btn_color).cgColor
        search_frame.layer.borderWidth = 1
        search_frame.clipsToBounds = true
        
        let image = UIImage(named: "menu_search")?.withRenderingMode(.alwaysTemplate)
        search_img.image = image
        search_img.tintColor = Utility.color(withHexString: ShareData.btn_color)
        
        search_in.delegate = self
        search_in.returnKeyType = .search
        
        search_in.attributedPlaceholder = NSAttributedString(string: "Search History...",
                                                             attributes: [NSAttributedStringKey.foregroundColor: Utility.color(withHexString: ShareData.btn_color)])
        
        if ShareData.messages.count == 0
        {
            no_label.isHidden = false
            tableView.isHidden = true
        }
        else
        {
            no_label.isHidden = true
            tableView.isHidden = false
        }
        
        filtered_list = ShareData.messages
        
        if !ShareData.msg_noti_status
        {
            ShareData.main_tab_index = 4
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ChatListCell", bundle: nil), forCellReuseIdentifier: "ChatListCell")
        tableView.separatorStyle = .none
        tableView.reloadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .msg_list_reload, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        init_UI()
        
        if ShareData.msg_noti_status
        {
            ShareData.selected_chat = ShareData.messages[0]
            self.navigationController?.pushViewController(MainChatMsgVC(), animated: true)
            
        }
        
    }
    
    @IBAction func searchAction(_ sender: Any) {
        
        let txt = search_in.text!
        if txt == nil || txt == ""
        {
            filtered_list = ShareData.messages
            
        }
        else
        {
            filtered_list = ShareData.messages.filter { $0.profile.name!.lowercased().contains(txt.lowercased()) }
        }
        tableView.reloadData()
        
    }
    
    @IBAction func addAction(_ sender: Any) {
        
        
    }
    
    
}

extension MainChatVC: UITextFieldDelegate
{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        search_in.resignFirstResponder()
        return true
    }
    
    @objc func reloadData(_ notification: Notification) {
        
        let txt = search_in.text!
        if txt == nil || txt == ""
        {
            filtered_list = ShareData.messages
            
        }
        else
        {
            filtered_list = ShareData.messages.filter { $0.profile.name!.lowercased().contains(txt.lowercased()) }
        }
        tableView.reloadData()
        
    }
}

extension MainChatVC: UITableViewDelegate, UITableViewDataSource
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return filtered_list.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell : ChatListCell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell", for: indexPath) as! ChatListCell
        
        cell.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        let data = filtered_list[indexPath.row]
        
        cell.photo.load(url: data.profile.photo!)
        cell.photo.layer.cornerRadius = cell.photo.frame.height / 2
        cell.photo.clipsToBounds = true
        
        cell.name.text = data.profile.name!
        
        if data.message.message!.contains("upload/image")
        {
            
            cell.camera_img.isHidden = false
            let image = UIImage.init(named: "camera")
            cell.camera_img.image = image
            cell.camera_img.tintColor = UIColor.gray
            cell.last_msg_left_constrain.constant = 20
            cell.last_msg.text = "photo"
        }
        else if data.message.message!.contains("upload/voice")
        {
            
            cell.camera_img.isHidden = false
            let image = UIImage.init(named: "microphone")
            cell.camera_img.image = image
            cell.camera_img.tintColor = UIColor.gray
            cell.last_msg_left_constrain.constant = 20
            cell.last_msg.text = "record"
        }
        else
        {
            cell.camera_img.isHidden = true
            cell.last_msg_left_constrain.constant = 0
            
            cell.last_msg.text = data.message.message!
        }
        
        if data.unread_num! == "0"
        {
            cell.unread_frame.isHidden = true
        }
        else
        {
            cell.unread_frame.isHidden = false
            cell.unread_frame.backgroundColor = UIColor.red
            cell.unread_frame.layer.cornerRadius = cell.unread_frame.frame.height / 2
            cell.unread_frame.clipsToBounds = true
            
            cell.unread_num.text = data.unread_num!
        }
        
        
        
        cell.last_time.text = CommonFuncs().historyTime(data.message.time!, data.profile.time_zone!)
        
        cell.status.layer.cornerRadius = cell.status.frame.width / 2
        cell.status.clipsToBounds = true
        
        if data.profile.status! == "1"
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
        
        selected_index = indexPath.row
        
        ShareData.selected_chat = self.filtered_list[selected_index]
        
        let index = ShareData.messages.index { $0.profile.id! == ShareData.selected_chat.profile.id! }!
        ShareData.messages[index].unread_num = "0"
        
        NotificationCenter.default.post(name: .msg_unread_num, object: nil)
        NotificationCenter.default.post(name: .msg_list_reload, object: nil)
        
        self.navigationController?.pushViewController(MainChatMsgVC(), animated: true)
    }
    
}


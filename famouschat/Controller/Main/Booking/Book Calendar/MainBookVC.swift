//
//  MainBookVC.swift
//  famouschat
//
//  Created by T-Tech Solutions LLC on 07/11/2018.
//  Copyright © 2018 T-Tech Solutions LLC. All rights reserved.
//

import UIKit
import FSCalendar
import NVActivityIndicatorView
import ObjectMapper

class MainBookVC: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet weak var back_img: UIImageView!
    @IBOutlet weak var back_btn: UIButton!
    @IBOutlet weak var menu_img: UIImageView!
    @IBOutlet weak var menu_img_width: NSLayoutConstraint!
    @IBOutlet weak var menu_img_height: NSLayoutConstraint!
    @IBOutlet weak var menu_btn: UIButton!
    @IBOutlet weak var header_frame: UIView!
    @IBOutlet weak var search_frame: UIView!
    @IBOutlet weak var search_img: UIImageView!
    @IBOutlet weak var search_in: UITextField!
    @IBOutlet weak var week_btn: UIButton!
    @IBOutlet weak var month_btn: UIButton!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var no_book_label: UILabel!
    
    var searched_influencers_list = [UserMDL]()
    let progressDlg = ShareData.progressDlgs[ShareData.progress_index]
    var search_status = false
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    
    var book_color_list = [String]()
    var filter_list = [BookMDL]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        init_UI()
    }

    func init_UI()
    {
        self.navigationController?.isNavigationBarHidden = true
        
        if !ShareData.msg_noti_status
        {
            ShareData.main_tab_index = 3
        }
        
        header_frame.dropShadow(color: .gray, opacity: 0.5, offSet: CGSize.zero, radius: 8, scale: true)
        
//        let back_image = UIImage.init(named: "back")!.withRenderingMode(.alwaysTemplate)
//        back_img.image = back_image
//        back_img.tintColor = Utility.color(withHexString: ShareData.btn_color)
        
        let menu_image = UIImage.init(named: "menu")!.withRenderingMode(.alwaysTemplate)
        menu_img.image = menu_image
        menu_img.tintColor = Utility.color(withHexString: "10A7BA")
        menu_img_width.constant = 18
        menu_img_height.constant = 20
        
        menu_btn.addTarget(self.slideMenuController, action: #selector(slideMenuController.toggleMenuAnimated(_:)), for: .touchUpInside)
        
        back_img.isHidden = true
        back_btn.isUserInteractionEnabled = false
        
        search_frame.layer.cornerRadius = search_frame.frame.height / 2
        search_frame.layer.borderColor = Utility.color(withHexString: ShareData.btn_color).cgColor
        search_frame.layer.borderWidth = 1
        search_frame.clipsToBounds = true
        
        let image = UIImage(named: "menu_search")?.withRenderingMode(.alwaysTemplate)
        search_img.image = image
        search_img.tintColor = Utility.color(withHexString: ShareData.btn_color)
        
        search_in.delegate = self
        search_in.returnKeyType = .search
        
        search_in.attributedPlaceholder = NSAttributedString(string: "Search...",
                                                             attributes: [NSAttributedStringKey.foregroundColor: Utility.color(withHexString: ShareData.btn_color)])
        
        calendar.dataSource = self
        calendar.delegate = self
        calendar.allowsMultipleSelection = false
        calendar.swipeToChooseGesture.isEnabled = true
        calendar.backgroundColor = UIColor.white
        calendar.appearance.headerDateFormat = "MMMM"
        calendar.appearance.headerTitleFont = UIFont.boldSystemFont(ofSize: 17)
        calendar.appearance.caseOptions = [.headerUsesUpperCase,.weekdayUsesSingleUpperCase]
        calendar.accessibilityIdentifier = "calendar"
        calendar.scope = FSCalendarScope.month
        
        week_btn.setImage(UIImage.init(named: "week_icon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        week_btn.tintColor = UIColor.init(red: 148/255, green: 168/255, blue: 178/255, alpha: 1)
        week_btn.setTitleColor(UIColor.init(red: 148/255, green: 168/255, blue: 178/255, alpha: 1), for: .normal)
        month_btn.setImage(UIImage.init(named: "month_icon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        month_btn.tintColor = Utility.color(withHexString: ShareData.btn_color)
        month_btn.setTitleColor(Utility.color(withHexString: ShareData.btn_color), for: .normal)
        
        calendar.calendarHeaderView.backgroundColor = Utility.color(withHexString: "083B56")
        
        let weekDayLabel = calendar.calendarWeekdayView.weekdayLabels
        
        for i in 0..<weekDayLabel.count
        {
            if i == 0
            {
                weekDayLabel[i].textColor = UIColor.red
            }
            else
            {
                weekDayLabel[i].textColor = UIColor.init(red: 0/255, green: 173/255, blue: 171/255, alpha: 1)
            }
            
        }
        
        book_color_list = [String]()
        
        if ShareData.user_or_influencer
        {
            filter_list = ShareData.books.filter { $0.book.normal_id! == ShareData.user_info.id! }
            
            for cell in filter_list
            {
                let array = cell.book.time!.characters.split{$0 == "-"}.map(String.init)
                let time = "\(array[0])-\(array[1])-\(array[2])"
                book_color_list.append(time)
            }
        }
        else
        {
            filter_list = ShareData.books.filter { $0.book.influencer_id! == ShareData.user_info.id! }
            
            for cell in filter_list
            {
                let array = cell.book.time!.characters.split{$0 == "-"}.map(String.init)
                let time = "\(array[0])-\(array[1])-\(array[2])"
                book_color_list.append(time)
            }
        }
        
        /*if filter_list.count == 0
        {
            
            no_book_label.text = "No booking currently scheduled"
            no_book_label.isHidden = false
            calendar.isHidden = true
        }
        else
        {*/
            no_book_label.isHidden = true
            calendar.isHidden = false
        //}
        
        if filter_list.count > 0
        {
            let first_book_time = filter_list[0].book.time!.characters.split{$0 == "-"}.map(String.init)
            let first_start_time = "\(first_book_time[0])-\(first_book_time[1])-\(first_book_time[2])"
            var dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let firstDate = dateFormatter.date(from: first_start_time)
            calendar.currentPage = self.formatter.date(from: self.formatter.string(from: firstDate!)) ?? calendar.today!
        }
        else
        {
            calendar.select(self.formatter.date(from: self.formatter.string(from: calendar.today!)))
        }
        
        
        calendar.reloadData()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TrendSearchCell", bundle: nil), forCellReuseIdentifier: "TrendSearchCell")
        tableView.separatorStyle = .none
        tableView.isHidden = true
        tableView.reloadData()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
//        init_UI()
    }
    
    @IBAction func weekSelected(_ sender: Any) {
        
        calendar.scope = FSCalendarScope.week
        
        week_btn.setImage(UIImage.init(named: "week_icon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        week_btn.tintColor = Utility.color(withHexString: ShareData.btn_color)
        week_btn.setTitleColor(Utility.color(withHexString: ShareData.btn_color), for: .normal)
        month_btn.setImage(UIImage.init(named: "month_icon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        month_btn.tintColor = UIColor.init(red: 148/255, green: 168/255, blue: 178/255, alpha: 1)
        month_btn.setTitleColor(UIColor.init(red: 148/255, green: 168/255, blue: 178/255, alpha: 1), for: .normal)
    }
    
    @IBAction func monthSelected(_ sender: Any) {
        
        calendar.scope = FSCalendarScope.month
        
        month_btn.setImage(UIImage.init(named: "month_icon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        month_btn.tintColor = Utility.color(withHexString: ShareData.btn_color)
        month_btn.setTitleColor(Utility.color(withHexString: ShareData.btn_color), for: .normal)
        week_btn.setImage(UIImage.init(named: "week_icon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        week_btn.tintColor = UIColor.init(red: 148/255, green: 168/255, blue: 178/255, alpha: 1)
        week_btn.setTitleColor(UIColor.init(red: 148/255, green: 168/255, blue: 178/255, alpha: 1), for: .normal)
    }
    
    @objc func backAction(_ sender: UIButton) {
        
        search_in.text = ""
        search_in.attributedPlaceholder = NSAttributedString(string: "Book with...",
                                                             attributes: [NSAttributedStringKey.foregroundColor: Utility.color(withHexString: ShareData.btn_color)])
        /*if filter_list.count == 0
        {
            
            no_book_label.text = "No booking currently scheduled"
            no_book_label.isHidden = false
            calendar.isHidden = true
            month_btn.isHidden = true
            week_btn.isHidden = true
        }
        else
        {*/
            no_book_label.isHidden = true
            calendar.isHidden = false
            month_btn.isHidden = false
            week_btn.isHidden = false
        //}
        
        tableView.isHidden = true
        let back_image = UIImage.init(named: "menu")!.withRenderingMode(.alwaysTemplate)
        self.menu_img.image = back_image
        self.menu_img.tintColor = Utility.color(withHexString: ShareData.btn_color)
        
        menu_img_width.constant = 18
        menu_img_height.constant = 20
        
        menu_btn.addTarget(self.slideMenuController, action: #selector(slideMenuController.toggleMenuAnimated(_:)), for: .touchUpInside)
    }
    
}

extension MainBookVC: UITextFieldDelegate
{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        search_in.resignFirstResponder()
        
        return (true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        searchAction()
    }
    
}


extension MainBookVC
{
    
    func searchAction()
    {
        searched_influencers_list = [UserMDL]()
        
        if search_in.text == "" || search_in.text == nil
        {
            if filter_list.count == 0
            {
                
                no_book_label.text = "No booking currently scheduled"
                no_book_label.isHidden = false
                calendar.isHidden = true
                month_btn.isHidden = true
                week_btn.isHidden = true
            }
            else
            {
                no_book_label.isHidden = true
                calendar.isHidden = false
                month_btn.isHidden = false
                week_btn.isHidden = false
            }
            
            tableView.isHidden = true
//            back_img.isHidden = true
//            back_btn.isUserInteractionEnabled = false
            let back_image = UIImage.init(named: "menu")!.withRenderingMode(.alwaysTemplate)
            self.menu_img.image = back_image
            self.menu_img.tintColor = Utility.color(withHexString: ShareData.btn_color)
            
            menu_img_width.constant = 18
            menu_img_height.constant = 20
            
            menu_btn.addTarget(self.slideMenuController, action: #selector(slideMenuController.toggleMenuAnimated(_:)), for: .touchUpInside)
//            self.menu_img.isHidden = false
//            self.menu_btn.isUserInteractionEnabled = true
        }
        else
        {
            
            
            let parmeters = ["name_key": search_in.text!] as [String: Any]
            
            self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: progressDlg, color: .darkGray, fadeInAnimation: nil)
            
            CommonFuncs().createRequest(true, "search", "POST", parmeters, completionHandler: {data in
                
                let status = data["status"] as! Bool
                
                DispatchQueue.main.async {
                    
                    self.stopAnimating(nil)
                    
                    if status
                    {
                        
                        if let influencers = data["data"]
                        {
                            if let temp = Mapper<UserMDL>().mapArray(JSONObject: influencers)
                            {
                                self.searched_influencers_list = temp
                            }
                            
                        }
                        
                        if self.searched_influencers_list.count == 0
                        {
                            CommonFuncs().doneAlert(ShareData.appTitle, "No influencers matched name", "DONE", {})
                        }
                        else
                        {
                            self.calendar.isHidden = true
                            self.month_btn.isHidden = true
                            self.week_btn.isHidden = true
//                            self.back_img.isHidden = false
//                            self.back_btn.isUserInteractionEnabled = true
                            self.tableView.isHidden = false
                            self.no_book_label.isHidden = true
                            
                            let back_image = UIImage.init(named: "back")!.withRenderingMode(.alwaysTemplate)
                            self.menu_img.image = back_image
                            self.menu_img.tintColor = Utility.color(withHexString: ShareData.btn_color)
                            self.menu_btn.addTarget(self, action: #selector(self.backAction(_:)), for: .touchUpInside)
                            
                            self.menu_img_width.constant = 12
                            self.menu_img_height.constant = 18
                            self.tableView.reloadData()
                        }
                        
                    }
                    else
                    {
                        CommonFuncs().doneAlert(ShareData.appTitle, "No influencers matched name", "DONE", {})
                    }
                }
            })
        }
    }
}

extension MainBookVC: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance
{
    
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        
        let key = "\(self.formatter.string(from: date))"
        
        if date == calendar.today
        {
            return UIColor.white
        }
        
        if book_color_list.contains(key)
        {
            return Utility.color(withHexString: ShareData.btn_color)
            
        }
        
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {

        let key = "\(self.formatter.string(from: date))"
        
        if date == calendar.today
        {
            return UIColor.black
        }
        
        if book_color_list.contains(key)
        {
            return UIColor.white
        }
        
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderSelectionColorFor date: Date) -> UIColor? {
        
        let key = "\(self.formatter.string(from: date))"
        
        
        if book_color_list.contains(key)
        {
            return UIColor.gray
            
        }
        
        return nil
    }
    
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        print("change page to \(self.formatter.string(from: calendar.currentPage))")
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("calendar did select date \(self.formatter.string(from: date))")
        
        if monthPosition == .previous || monthPosition == .next {
            calendar.setCurrentPage(date, animated: true)
        }
        
        let selected_day = self.formatter.string(from: date)
        ShareData.book_selected_date = selected_day
        
        ShareData.selected_day_books = [BookMDL]()
        
        if ShareData.user_or_influencer
        {
            ShareData.selected_day_books = ShareData.books.filter { $0.book.time!.contains(selected_day) && $0.book.normal_id! == ShareData.user_info.id! }
        }
        else
        {
            ShareData.selected_day_books = ShareData.books.filter { $0.book.time!.contains(selected_day) && $0.book.influencer_id! == ShareData.user_info.id! }
        }
        
        if ShareData.selected_day_books.count > 0
        {
            self.navigationController?.pushViewController(MainBookListVC(), animated: true)
        }
        
    }
    
}


extension MainBookVC: UITableViewDelegate, UITableViewDataSource
{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return searched_influencers_list.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell : TrendSearchCell = tableView.dequeueReusableCell(withIdentifier: "TrendSearchCell", for: indexPath) as! TrendSearchCell
        
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        let data = searched_influencers_list[indexPath.row]
        
     
        cell.photo.load(url: data.photo!)
        cell.photo.layer.cornerRadius = cell.photo.frame.width / 2
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
        
        ShareData.selected_influencer = self.searched_influencers_list[indexPath.row]
        
        self.navigationController?.pushViewController(MainTrendProfileVC(), animated: true)
        
    }
    
}

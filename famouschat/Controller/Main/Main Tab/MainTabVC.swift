//
//  MainTabVC.swift
//  famouschat
//
//  Created by T-Tech Solutions LLC on 06/11/2018.
//  Copyright © 2018 T-Tech Solutions LLC. All rights reserved.
//

import UIKit

class MainTabVC: UIViewController {
    
    var tabBarView: UITabBarController!
    var window: UIWindow?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        init_UI()
        
    }
    
    
    func init_UI()
    {
        self.navigationController?.isNavigationBarHidden = true
        
        tabBarView = UITabBarController()
        tabBarView.tabBar.barStyle = .blackOpaque
        
        
        let layerGradient = CAGradientLayer()
        
        layerGradient.colors = [Utility.color(withHexString: "ffffff")!.cgColor, Utility.color(withHexString: "ffffff")!.cgColor]
        layerGradient.locations = [0.0, 1.0]
        layerGradient.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: tabBarView.tabBar.bounds.height)
        tabBarView.tabBar.layer.addSublayer(layerGradient)
        
        tabBarView.tabBar.unselectedItemTintColor = Utility.color(withHexString: "10A7BA")
        tabBarView.tabBar.selectedImageTintColor = Utility.color(withHexString: "5BDD96")
        
        let firstVC = MainHomeVC()
        let secondVC = MainTrendVC()
        let thirdVC = MainVideoVC()
        let fourthVC = MainBookVC()
        let fifthVC = MainChatVC()
        
        
        firstVC.tabBarItem =  UITabBarItem(title: nil, image: UIImage.init(named: "tab_1.png"), tag: 0)
        firstVC.tabBarItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: -8, right: 0)
        
        
        secondVC.tabBarItem = UITabBarItem(title: nil, image: UIImage.init(named: "tab_2.png"), tag: 1)
        secondVC.tabBarItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: -8, right: 0)
        
        let img = CommonFuncs().resizeImage(image: UIImage.init(named: "tab_3.png")!, targetSize: CGSize(width: 38.0, height: 38.0))
        
        thirdVC.tabBarItem = UITabBarItem(title: nil, image: img, tag: 1)
        thirdVC.tabBarItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: -8, right: 0)
        
        fourthVC.tabBarItem = UITabBarItem(title: nil, image: UIImage.init(named: "tab_4.png"), tag: 3)
        fourthVC.tabBarItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: -8, right: 0)
        
        fifthVC.tabBarItem = UITabBarItem(title: nil, image: UIImage.init(named: "tab_5.png"), tag: 4)
        fifthVC.tabBarItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: -8, right: 0)
        
        let controllers = [firstVC, secondVC, thirdVC, fourthVC, fifthVC]
        tabBarView.viewControllers = controllers
        tabBarView.viewControllers = controllers.map { UINavigationController(rootViewController: $0)}
        
        tabBarView.navigationController?.isNavigationBarHidden = true
        
        self.view.addSubview(tabBarView.view)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateBadge), name: .msg_unread_num, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        tabBarView.selectedIndex = ShareData.main_tab_index
        
        var unread_msg_num = 0
        for cell in ShareData.messages
        {
            unread_msg_num += Int(cell.unread_num!)!
        }
        
        if unread_msg_num > 0
        {
            tabBarView.tabBar.items?[4].badgeValue = "\(unread_msg_num)"
            tabBarView.tabBar.items?[4].badgeColor = UIColor.red
        }
        
    }
    
    
    
}


extension MainTabVC
{
    
    @objc func updateBadge(_ notification: Notification) {
        
        var unread_msg_num = 0
        for cell in ShareData.messages
        {
            unread_msg_num += Int(cell.unread_num!)!
        }
        
        if unread_msg_num > 0
        {
            tabBarView.tabBar.items?[4].badgeValue = "\(unread_msg_num)"
            tabBarView.tabBar.items?[4].badgeColor = UIColor.red
        }
        
    }
    
    
}

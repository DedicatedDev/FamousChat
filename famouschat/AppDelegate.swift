//
//  AppDelegate.swift
//  famouschat
//
//  Created by T-Tech Solutions LLC on 04/11/2018.
//  Copyright © 2018 T-Tech Solutions LLC. All rights reserved.
//

import UIKit

import UserNotifications

import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import GoogleSignIn
import FBSDKLoginKit
import ObjectMapper
import Quickblox
import QuickbloxWebRTC

let google_sign_key =
//        "70130845129-rt33s0ah3173l75bpdb94dehnojmfqs2.apps.googleusercontent.com"
    "520146656243-q3e471cu920168tgr8ehgqfl1lhvjgfh.apps.googleusercontent.com"



@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    var window: UIWindow?
    
    var slideMenuVC : NVSlideMenuController?
    var menuVC : MenuViewController?
    var navigationController: UINavigationController?
    var noti_status = false
    var msg_noti_status = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        GIDSignIn.sharedInstance().clientID = google_sign_key //"324075445380-38j39ivlk9rrup8u0nmdp6l53376f8sn.apps.googleusercontent.com"
        
        QuickBloxHelper.sharedInstance.initializeQuickBlox()
        /*QBSettings.applicationID = 76912
        QBSettings.authKey = "ne4Q4ecGPzg5xaz"
        QBSettings.authSecret = "LF3WUj925RQM7Et"
        QBSettings.accountKey = "9CUph7CxWWQmGTCoRqzq"
        
        QBSettings.autoReconnectEnabled = true
        QBSettings.logLevel = QBLogLevel.debug
        QBSettings.enableXMPPLogging()
        QBRTCConfig.setLogLevel(QBRTCLogLevel.verbose)*/
        
      
        
        
        QBRTCClient.initializeRTC()
         
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            application.registerForRemoteNotifications()
            // For iOS 10 data message (sent via FCM
            Messaging.messaging().delegate = self
        } else {
            
            
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        FirebaseApp.configure()
        
//        Settings.appID = "538888289949953"
        Settings.appID = "3199906693357537"
        
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        
    }
    
    
    ///////// --------- notification for  foreground mode -------------
    func userNotificationCenter(_ center: UNUserNotificationCenter,  willPresent notification: UNNotification, withCompletionHandler   completionHandler: @escaping (_ options:   UNNotificationPresentationOptions) -> Void) {
        
        
        let dict = notification.request.content.userInfo
        
        
        if ShareData.user_info! == nil
        {
            self.navigationController?.pushViewController(LoginVC(), animated: true)
        }
        else
        {
            if let noti_sort = dict["noti_sort"]
            {
            
                notiProcess(dict: dict)
                
                if self.msg_noti_status
                {
                    NotificationCenter.default.post(name: .msg_unread_num, object: nil)
                    NotificationCenter.default.post(name: .msg_list_reload, object: nil)
                }
                
                if !noti_status
                {
                    completionHandler([.alert,.sound, .badge])
                }
                
            }
        }
        
    }
    
    ///////// --------- notification for background mode -------------
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        ShareData.badge_num += 1
        
        let application = UIApplication.shared
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.badge, .alert, .sound], completionHandler: {(sucess, error) in
            print("success")
        })
        
        application.applicationIconBadgeNumber = ShareData.badge_num as! Int
        application.registerForRemoteNotifications()
        
        let dict = response.notification.request.content.userInfo

        if ShareData.user_info! == nil
        {
            self.navigationController?.pushViewController(LoginVC(), animated: true)
        }
        else
        {
            if let noti_sort = dict["noti_sort"]
            {
                ShareData.msg_noti_status = self.msg_noti_status
                
                UIApplication.shared.keyWindow?.setRootViewController(MainTabVC(), options: UIWindow.TransitionOptions(direction: .toRight, style: .easeIn), slide_direction: .fromLeftToRight)
                
                if !noti_status
                {
                    completionHandler()
                }
                
            }
        }
        
        
    }
    
    
    func notiProcess(dict: [AnyHashable: Any])
    {
        let noti_type = dict["noti_sort"] as! String
        
        noti_status = false
        ShareData.main_tab_index = 0
        self.msg_noti_status = false
        
        switch(noti_type)
        {
        case ShareData.feed_type().msg_left:
            
            
            let msg_data = ["msg_id": dict["msg_id"] as! String, "sender_id": dict["sender_id"] as! String, "receiver_id": ShareData.user_info.id!, "message": dict["message"] as! String, "time": dict["send_time"] as! String, "status": "0"]  as [String : Any]
            let user_data = ["id": dict["sender_id"] as! String, "name": dict["sender_name"] as! String, "photo": dict["sender_photo"] as! String, "time_zone": dict["time_zone"] as! String]  as [String : Any]
            
            let cell = ["message": msg_data, "profile": user_data, "unread_num": "1"] as [String : Any]
            
            let sender_id = dict["sender_id"] as! String
            let message = dict["message"] as! String
            let send_time = dict["send_time"] as! String
            
            if let msg_index = ShareData.messages.index(where: { $0.message.sender_id! == sender_id })
            {
                ShareData.messages[msg_index].message.message = message
                ShareData.messages[msg_index].message.time = send_time
                ShareData.messages[msg_index].message.status = "0"
                ShareData.messages[msg_index].unread_num = "\(Int(ShareData.messages[msg_index].unread_num!)! + 1)"
            }
            else
            {
                if let temp = Mapper<MessageMDL>().map(JSONObject: cell)
                {
                    ShareData.messages.append(temp)
                    
                }
            }
            
            ShareData.messages = ShareData.messages.sorted { $0.message.time! > $1.message.time!}
            
            if ShareData.chat_status
            {
                if let temp = Mapper<MessageMDL>().map(JSONObject: cell)
                {
                    if sender_id == ShareData.selected_chat.profile.id!
                    {
                        ShareData.chat_msg_list = ShareData.chat_msg_list.filter { !($0.message.message!.contains("xxx//typing"))}
                        ShareData.chat_msg_list.append(temp)
                        noti_status = true
                        NotificationCenter.default.post(name: .chat_reload, object: nil)
                    }
                    
                }
                
            }
            
            self.msg_noti_status = true
            ShareData.main_tab_index = 4
            
            break
            
        case ShareData.feed_type().msg_typing:
            
            let time = CommonFuncs().currentTime()
            
            let data = ["msg_id": "", "sender_id": dict["sender_id"] as! String, "receiver_id": ShareData.user_info.id!, "message": "xxx//typing", "time": time, "status": "1"]  as [String : Any]
            let cell = ["message": data, "unread_num": "1"] as [String : Any]
            
            let sender_id = dict["sender_id"] as! String
            
            noti_status = true
            if ShareData.chat_status
            {
                if let temp = Mapper<MessageMDL>().map(JSONObject: cell)
                {
                    if sender_id == ShareData.selected_chat.profile.id!
                    {
                        ShareData.chat_msg_list.append(temp)
                        noti_status = true
                        NotificationCenter.default.post(name: .chat_reload, object: nil)
                    }
                    
                }
                
            }
            
            break
            
        case ShareData.feed_type().fee_msg:
            
            if let temp = Mapper<FeedMDL>().map(JSONString: dict["feed"] as! String)
            {
                
                let msg_data = ["msg_id": "0", "sender_id": dict["sender_id"] as! String, "receiver_id": ShareData.user_info.id!, "message": temp.optional_value!, "time": temp.time!, "status": "0"]  as [String : Any]
                let user_data = ["id": dict["sender_id"] as! String, "name": temp.name!, "photo": temp.photo!, "time_zone": temp.time_zone!]  as [String : Any]
                
                let cell = ["message": msg_data, "profile": user_data, "unread_num": "1"] as [String : Any]
                
                let sender_id = dict["sender_id"] as! String
                
                if let msg_index = ShareData.messages.index(where: { $0.message.sender_id! == sender_id })
                {
                    ShareData.messages[msg_index].message.message = temp.optional_value!
                    ShareData.messages[msg_index].message.time = temp.time!
                    ShareData.messages[msg_index].message.status = "0"
                    ShareData.messages[msg_index].unread_num = "\(Int(ShareData.messages[msg_index].unread_num!)! + 1)"
                    
                }
                else
                {
                    if let temp = Mapper<MessageMDL>().map(JSONObject: cell)
                    {
                        
                        ShareData.messages.append(temp)
                        
                    }
                }
                
                ShareData.messages = ShareData.messages.sorted { $0.message.time! > $1.message.time!}
                self.msg_noti_status = true
                ShareData.main_tab_index = 4
            }
            
            break
            
            
        case ShareData.feed_type().book_accept:
            
            if let temp = Mapper<BookMDL>().map(JSONString: dict["book"] as! String)
            {
                ShareData.books.append(temp)
            }
            
            break
            
        case ShareData.feed_type().book_cancel:
            
            if let temp = Mapper<FeedMDL>().map(JSONString: dict["feed"] as! String)
            {
                ShareData.books = ShareData.books.filter { $0.book.id! != CommonFuncs().splitString(temp.optional_value!)[0] }
            }
            
            break
            
        case ShareData.feed_type().book_video_sent:
            
            if let temp = Mapper<FeedMDL>().map(JSONString: dict["feed"] as! String)
            {
                ShareData.books = ShareData.books.filter { $0.book.id! != CommonFuncs().splitString(temp.optional_value!)[0] }
            }
            
            break
            
        case ShareData.feed_type().book_video_seen:
            
            if let temp = Mapper<FeedMDL>().map(JSONString: dict["feed"] as! String)
            {
                ShareData.books = ShareData.books.filter { $0.book.id! != CommonFuncs().splitString(temp.optional_value!)[0] }
            }
            
            break
            
        case ShareData.feed_type().book_add_time:            
            
            if let temp = Mapper<FeedMDL>().map(JSONString: dict["feed"] as! String)
            {
                ShareData.add_time = CommonFuncs().splitString(temp.optional_value!)[0]
                NotificationCenter.default.post(name: .time_added, object: nil)
            }
            
            break
            
            
        case ShareData.feed_type().follow_accept:
            
            if let temp = Mapper<UserMDL>().map(JSONString: dict["profile"] as! String)
            {
                ShareData.following_influencers.append(temp)
            }
            
            break
            
            
        case ShareData.feed_type().other_book_fee_charged:
            
            ShareData.user_info.popcoin_num = "\(Int(ShareData.user_info.popcoin_num!)! - Int(dict["popcoin"] as! String)!)"
            
            break
            
        case ShareData.feed_type().other_book_fee_received:
            
            ShareData.user_info.popcoin_num = "\(Int(ShareData.user_info.popcoin_num!)! + Int(dict["popcoin"] as! String)!)"
            
            break
            
        case ShareData.feed_type().other_book_fee_refunded:
            
            ShareData.user_info.popcoin_num = "\(Int(ShareData.user_info.popcoin_num!)! + Int(dict["popcoin"] as! String)!)"
            
            break
            
        case ShareData.feed_type().other_book_add_time:
            
            ShareData.user_info.popcoin_num = "\(Int(ShareData.user_info.popcoin_num!)! + Int(dict["popcoin"] as! String)!)"
            
            break
            
            
        case ShareData.feed_type().other_book_time_over:
            
            ShareData.user_info.popcoin_num = "\(Int(ShareData.user_info.popcoin_num!)! + Int(dict["popcoin"] as! String)!)"
            
            break
            
        case ShareData.feed_type().other_book_process_fee:
            
            ShareData.user_info.popcoin_num = "\(Int(ShareData.user_info.popcoin_num!)! - Int(dict["popcoin"] as! String)!)"
            
            break            
            
        default:
            break
        }
        
        if let feed = dict["feed"]
        {
            if let temp = Mapper<FeedMDL>().map(JSONString: feed as! String)
            {
                if let index = ShareData.feeds.index(where: { $0.id! == temp.id!}){}
                else
                {
                    ShareData.feeds.append(temp)
                }
            }
        }
    }
    
    func assignNotification()
    {
        
        UIApplication().registerForRemoteNotifications()
    }
    
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        let number: Int = 2
        let application = UIApplication.shared
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.badge, .alert, .sound], completionHandler: {(sucess, error) in
            print("success")
        })
        
        application.applicationIconBadgeNumber = ShareData.badge_num as! Int
        application.registerForRemoteNotifications()
       
    }
    
    
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
    }
    
    
//    @available(iOS 9.0, *)
//    func application(application: UIApplication,
//                     openURL url: URL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
//        var options: [String: AnyObject] = [UIApplicationOpenURLOptionsKey.sourceApplication.rawValue: sourceApplication as AnyObject,
//                                            UIApplicationOpenURLOptionsKey.annotation.rawValue: annotation!]
//        return GIDSignIn.sharedInstance()!.handle(url)
//    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        
        let handled: Bool = ApplicationDelegate.shared.application(application, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        // Add any custom logic here.
        return handled
    }
    
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {

        return ApplicationDelegate.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)

    }
    
    
}


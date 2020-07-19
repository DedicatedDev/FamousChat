//
//  UserLocalData.swift
//  VideoCallTest
//
//  Created by Teena Nath Paul on 14/06/17.
//  Copyright © 2017 Teena Nath Paul. All rights reserved.
//


import Foundation

extension UserDefaults
{
    class var qbUserId:String? {
        set
        {
            UserDefaults.standard.set(newValue, forKey: "userId")
            UserDefaults.standard.synchronize()
        }
        get
        {
            return UserDefaults.standard.object(forKey: "userId") as? String
        }
    }

    class var qbEmail:String? {
        set
        {
            UserDefaults.standard.set(newValue, forKey: "email")
            UserDefaults.standard.synchronize()
        }
        get
        {
            return UserDefaults.standard.object(forKey: "email") as? String
        }
    }
    
    class var qbPassword:String? {
        set
        {
            UserDefaults.standard.set(newValue, forKey: "password")
            UserDefaults.standard.synchronize()
        }
        get
        {
            return UserDefaults.standard.object(forKey: "password") as? String
        }
    }
    
    class var id:String? {
        set
        {
            UserDefaults.standard.set(newValue, forKey: "id")
            UserDefaults.standard.synchronize()
        }
        get
        {
            return UserDefaults.standard.object(forKey: "id") as? String
        }
    }

    
    class func removeAllUserDefaults()
    {
//        let deviceToken = UserDefaults.deviceToken ?? ""
        
        let appDomain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: appDomain)
        
//        UserDefaults.deviceToken = deviceToken
        
        UserDefaults.standard.synchronize()
    }
}

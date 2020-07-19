//
//  AccountMDL.swift
//  famouschat
//
//  Created by angel oni on 2019/5/12.
//  Copyright © 2019 Oni Angel. All rights reserved.
//

import Foundation
import ObjectMapper

public final class UserMDL: Mappable {
    
    private struct SerializationKeys {
        
        static let id = "id"
        static let name = "name"
        static let photo = "photo"
        static let email = "email"
        static let password = "password"
        static let link = "link"
        static let permission = "permission"
        static let token = "token"
        static let follow_num = "follow_num"
        static let following_num = "following_num"
        static let total_minutes = "total_minutes"
        static let rate = "rate"
        static let rate_num = "rate_num"
        static let category = "category"
        static let bio = "bio"
        static let work_day = "work_day"
        static let chat_time = "chat_time"
        static let chat_rate = "chat_rate"
        static let paypal_id = "paypal_id"
        static let venmo_id = "venmo_id"
        static let time_zone = "time_zone"
        static let popcoin_num = "popcoin_num"
        static let status = "status"
        static let booked_list = "booked_list"
    }
  
    
    public var id: String!
    public var name: String!
    public var photo: String!
    public var email: String!
    public var password: String!
    public var link: String!
    public var permission: String!
    public var token: String!
    public var follow_num: String!
    public var following_num: String!
    public var total_minutes: String!
    public var rate: String!
    public var rate_num: String!
    public var category: String!
    public var bio: String!
    public var work_day: String!
    public var chat_time: String!
    public var chat_rate: String!
    public var paypal_id: String!
    public var venmo_id: String!
    public var time_zone: String!
    public var popcoin_num: String!
    public var status: String!
    public var booked_list: [String]!
    
    
    public required init?(map: Map){
        
    }
    
    
    public func mapping(map: Map) {
        
        id <- map[SerializationKeys.id]
        name <- map[SerializationKeys.name]
        photo <- map[SerializationKeys.photo]
        email <- map[SerializationKeys.email]
        password <- map[SerializationKeys.password]
        link <- map[SerializationKeys.link]
        permission <- map[SerializationKeys.permission]
        token <- map[SerializationKeys.token]
        follow_num <- map[SerializationKeys.follow_num]
        following_num <- map[SerializationKeys.following_num]
        total_minutes <- map[SerializationKeys.total_minutes]
        rate <- map[SerializationKeys.rate]
        rate_num <- map[SerializationKeys.rate_num]
        category <- map[SerializationKeys.category]
        bio <- map[SerializationKeys.bio]
        work_day <- map[SerializationKeys.work_day]
        chat_time <- map[SerializationKeys.chat_time]
        chat_rate <- map[SerializationKeys.chat_rate]
        paypal_id <- map[SerializationKeys.paypal_id]
        venmo_id <- map[SerializationKeys.venmo_id]
        time_zone <- map[SerializationKeys.time_zone]
        popcoin_num <- map[SerializationKeys.popcoin_num]
        status <- map[SerializationKeys.status]
        booked_list <- map[SerializationKeys.booked_list]
    }
    
    
    public func dictionaryRepresentation() -> [String: Any] {
        
        var dictionary: [String: Any] = [:]
        if let value = id { dictionary[SerializationKeys.id] = value }
        if let value = name { dictionary[SerializationKeys.name] = value }
        if let value = photo { dictionary[SerializationKeys.photo] = value }
        if let value = email { dictionary[SerializationKeys.email] = value }
        if let value = password { dictionary[SerializationKeys.password] = value }
        if let value = link {dictionary[SerializationKeys.link] = value}
        if let value = permission { dictionary[SerializationKeys.permission] = value }
        if let value = token { dictionary[SerializationKeys.token] = value }
        if let value = follow_num { dictionary[SerializationKeys.follow_num] = value }
        if let value = following_num { dictionary[SerializationKeys.following_num] = value }
        if let value = total_minutes { dictionary[SerializationKeys.total_minutes] = value }
        if let value = rate { dictionary[SerializationKeys.rate] = value }
        if let value = rate_num { dictionary[SerializationKeys.rate_num] = value }
        if let value = category { dictionary[SerializationKeys.category] = value }
        if let value = bio { dictionary[SerializationKeys.bio] = value }
        if let value = work_day { dictionary[SerializationKeys.work_day] = value }
        if let value = chat_time { dictionary[SerializationKeys.chat_time] = value }
        if let value = chat_rate { dictionary[SerializationKeys.chat_rate] = value }
        if let value = paypal_id { dictionary[SerializationKeys.paypal_id] = value }
        if let value = venmo_id { dictionary[SerializationKeys.venmo_id] = value }
        if let value = time_zone { dictionary[SerializationKeys.time_zone] = value }
        if let value = popcoin_num { dictionary[SerializationKeys.popcoin_num] = value }
        if let value = status { dictionary[SerializationKeys.status] = value }
        if let value = booked_list { dictionary[SerializationKeys.booked_list] = value }
        
        return dictionary
    }
    
}


//
//  AccountMDL.swift
//  famouschat
//
//  Created by angel oni on 2019/5/12.
//  Copyright © 2019 Oni Angel. All rights reserved.
//

import Foundation
import ObjectMapper

public final class AuctionMDL: Mappable {
    
    private struct SerializationKeys {
        
        static let id = "auction_id"
        static let user_id = "user_id"
        static let name = "name"
        static let photo = "photo"
        static let start_time = "start_time"
        static let duration = "duration"
        static let chat_day = "chat_day"
        static let chat_time = "chat_time"
        static let charity_id = "charity_id"
        static let charity_info = "charity_info"
        static let out_cost = "out_cost"
        static let current_cost = "current_cost"
        static let goal_cost = "goal_cost"
        static let total_views = "total_views"
        static let total_bids = "total_bids"
        static let start_bid_cost = "start_bid_cost"
        static let followers = "followers"
        static let status = "status"
    }
    
    
    public var id: String!
    public var user_id: String!
    public var name: String!
    public var photo: String!
    public var start_time: String!
    public var duration: String!
    public var chat_day: String!
    public var chat_time: String!
    public var charity_id: String!
    public var charity_info: String!
    public var out_cost: String!
    public var current_cost: String!
    public var goal_cost: String!
    public var total_views: String!
    public var total_bids: String!
    public var start_bid_cost: String!
    public var followers: String!
    public var status: String!
    
    
    public required init?(map: Map){
        
    }
    
    
    public func mapping(map: Map) {
        
        id <- map[SerializationKeys.id]
        user_id <- map[SerializationKeys.user_id]
        name <- map[SerializationKeys.name]
        photo <- map[SerializationKeys.photo]
        start_time <- map[SerializationKeys.start_time]
        duration <- map[SerializationKeys.duration]
        chat_day <- map[SerializationKeys.chat_day]
        chat_time <- map[SerializationKeys.chat_time]
        charity_id <- map[SerializationKeys.charity_id]
        charity_info <- map[SerializationKeys.charity_info]
        out_cost <- map[SerializationKeys.out_cost]
        current_cost <- map[SerializationKeys.current_cost]
        goal_cost <- map[SerializationKeys.goal_cost]
        total_views <- map[SerializationKeys.total_views]
        total_bids <- map[SerializationKeys.total_bids]
        start_bid_cost <- map[SerializationKeys.start_bid_cost]
        followers <- map[SerializationKeys.followers]
        status <- map[SerializationKeys.status]
    }
    
    
    public func dictionaryRepresentation() -> [String: Any] {
        
        var dictionary: [String: Any] = [:]
        if let value = id { dictionary[SerializationKeys.id] = value }
        if let value = user_id { dictionary[SerializationKeys.user_id] = value }
        if let value = name { dictionary[SerializationKeys.name] = value }
        if let value = photo { dictionary[SerializationKeys.photo] = value }
        if let value = start_time { dictionary[SerializationKeys.start_time] = value }
        if let value = duration { dictionary[SerializationKeys.duration] = value }
        if let value = chat_day { dictionary[SerializationKeys.chat_day] = value }
        if let value = chat_time { dictionary[SerializationKeys.chat_time] = value }
        if let value = charity_id { dictionary[SerializationKeys.charity_id] = value }
        if let value = charity_info { dictionary[SerializationKeys.charity_info] = value }
        if let value = out_cost { dictionary[SerializationKeys.out_cost] = value }
        if let value = current_cost { dictionary[SerializationKeys.current_cost] = value }
        if let value = goal_cost { dictionary[SerializationKeys.goal_cost] = value }
        if let value = total_views { dictionary[SerializationKeys.total_views] = value }        
        if let value = total_bids { dictionary[SerializationKeys.total_bids] = value }
        if let value = start_bid_cost { dictionary[SerializationKeys.start_bid_cost] = value }
        if let value = followers { dictionary[SerializationKeys.followers] = value }
        if let value = status { dictionary[SerializationKeys.status] = value }
        
        return dictionary
    }
    
}

public final class AuctionBidMDL: Mappable {
    
    private struct SerializationKeys {
        
        static let id = "bidder_id"
        static let auction_id = "auction_id"
        static let user_id = "user_id"
        static let name = "name"
        static let photo = "photo"
        static let cost = "cost"
        static let time = "time"
        static let time_zone = "time_zone"
        static let on_status = "on_status"
    }
    
    
    public var id: String!
    public var auction_id: String!
    public var user_id: String!
    public var name: String!
    public var photo: String!
    public var cost: String!
    public var time: String!
    public var time_zone: String!
    public var on_status: String!
    
    
    
    public required init?(map: Map){
        
    }
    
    
    public func mapping(map: Map) {
        
        id <- map[SerializationKeys.id]
        auction_id <- map[SerializationKeys.auction_id]
        user_id <- map[SerializationKeys.user_id]
        name <- map[SerializationKeys.name]
        photo <- map[SerializationKeys.photo]
        cost <- map[SerializationKeys.cost]
        time <- map[SerializationKeys.time]
        time_zone <- map[SerializationKeys.time_zone]
        on_status <- map[SerializationKeys.on_status]
    }
    
    
    public func dictionaryRepresentation() -> [String: Any] {
        
        var dictionary: [String: Any] = [:]
        if let value = id { dictionary[SerializationKeys.id] = value }
        if let value = auction_id { dictionary[SerializationKeys.auction_id] = value }
        if let value = user_id { dictionary[SerializationKeys.user_id] = value }
        if let value = name { dictionary[SerializationKeys.name] = value }
        
        if let value = photo { dictionary[SerializationKeys.photo] = value }
        if let value = cost { dictionary[SerializationKeys.cost] = value }
        if let value = time { dictionary[SerializationKeys.time] = value }
        if let value = time_zone { dictionary[SerializationKeys.time_zone] = value }
        if let value = on_status { dictionary[SerializationKeys.on_status] = value }
        
        return dictionary
    }
    
}

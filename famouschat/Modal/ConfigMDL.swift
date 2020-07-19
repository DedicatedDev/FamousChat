//
//  NormalUserMDL.swift
//  famouschat
//
//  Created by angel oni on 2019/5/12.
//  Copyright © 2019 Oni Angel. All rights reserved.
//

import Foundation
import ObjectMapper

public final class ConfigMDL: Mappable {
    
    private struct SerializationKeys {
        
        static let popcoin_price = "popcoin_price"
        static let process_fee = "process_fee"
        static let min_fee = "min_fee"
        static let msg_fee = "msg_fee"
        static let trend_cnt = "trend_cnt"
        static let instagram = "instagram"
        static let youtube = "youtube"
        static let twitter = "twitter"
        static let facebook = "facebook"
        static let twitch = "twitch"
        static let wordpress = "wordpress"
    }
    
    public var popcoin_price: String!
    public var process_fee: String!
    public var min_fee: String!
    public var msg_fee: String!
    public var trend_cnt: String!
    public var instagram: String!
    public var youtube: String!
    public var twitter: String!
    public var facebook: String!
    public var twitch: String!
    public var wordpress: String!
    
    public required init?(map: Map){
        
    }
    
    public func mapping(map: Map) {
        
        popcoin_price <- map[SerializationKeys.popcoin_price]
        process_fee <- map[SerializationKeys.process_fee]
        min_fee <- map[SerializationKeys.min_fee]
        msg_fee <- map[SerializationKeys.msg_fee]
        trend_cnt <- map[SerializationKeys.trend_cnt]
        instagram <- map[SerializationKeys.instagram]
        youtube <- map[SerializationKeys.youtube]
        twitter <- map[SerializationKeys.twitter]
        facebook <- map[SerializationKeys.facebook]
        twitch <- map[SerializationKeys.twitch]
        wordpress <- map[SerializationKeys.wordpress]
    }
    
    
    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        
        if let value = popcoin_price { dictionary[SerializationKeys.popcoin_price] = value }
        if let value = process_fee { dictionary[SerializationKeys.process_fee] = value }
        if let value = min_fee { dictionary[SerializationKeys.min_fee] = value }
        if let value = msg_fee { dictionary[SerializationKeys.msg_fee] = value }
        if let value = trend_cnt { dictionary[SerializationKeys.trend_cnt] = value }
        if let value = instagram { dictionary[SerializationKeys.instagram] = value }
        if let value = youtube { dictionary[SerializationKeys.youtube] = value }
        if let value = twitter { dictionary[SerializationKeys.twitter] = value }
        if let value = facebook { dictionary[SerializationKeys.facebook] = value }
        if let value = twitch { dictionary[SerializationKeys.twitch] = value }
        if let value = wordpress { dictionary[SerializationKeys.wordpress] = value }
        
        return dictionary
    }
    
}

//
//  NormalUserMDL.swift
//  famouschat
//
//  Created by angel oni on 2019/5/12.
//  Copyright © 2019 Oni Angel. All rights reserved.
//

import Foundation
import ObjectMapper

public final class FeedMDL: Mappable {
    
    private struct SerializationKeys {
        
        static let id = "feed_id"
        static let provider_id = "provider_id"
        static let name = "name"
        static let photo = "photo"
        static let receiver_id = "receiver_id"
        static let type = "type"
        static let optional_value = "optional_value"
        static let time = "time"
        static let time_zone = "time_zone"
    }
    
    
    public var id: String!
    public var provider_id: String!
    public var name: String!
    public var photo: String!
    public var receiver_id: String!
    public var type: String!
    public var optional_value: String!
    public var time: String!
    public var time_zone: String!
    
    public required init?(map: Map){
        
    }
    
    public func mapping(map: Map) {
        
        id <- map[SerializationKeys.id]
        provider_id <- map[SerializationKeys.provider_id]
        name <- map[SerializationKeys.name]
        photo <- map[SerializationKeys.photo]
        receiver_id <- map[SerializationKeys.receiver_id]
        type <- map[SerializationKeys.type]
        optional_value <- map[SerializationKeys.optional_value]
        time <- map[SerializationKeys.time]
        time_zone <- map[SerializationKeys.time_zone]
    }
    
    
    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        
        if let value = id { dictionary[SerializationKeys.id] = value }
        if let value = provider_id { dictionary[SerializationKeys.provider_id] = value }
        if let value = name { dictionary[SerializationKeys.name] = value }
        if let value = photo { dictionary[SerializationKeys.photo] = value }
        if let value = receiver_id { dictionary[SerializationKeys.receiver_id] = value }
        if let value = type { dictionary[SerializationKeys.type] = value }
        if let value = optional_value { dictionary[SerializationKeys.optional_value] = value }
        if let value = time { dictionary[SerializationKeys.time] = value }
        if let value = time_zone { dictionary[SerializationKeys.time_zone] = value }
        
        return dictionary
    }
    
}

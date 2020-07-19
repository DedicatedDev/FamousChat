//
//  AccountMDL.swift
//  famouschat
//
//  Created by angel oni on 2019/5/12.
//  Copyright © 2019 Oni Angel. All rights reserved.
//

import Foundation
import ObjectMapper

public final class ReviewMDL: Mappable {
    
    private struct SerializationKeys {
        
        static let id = "review_id"
        static let type = "type"
        static let provider_id = "provider_id"
        static let photo = "photo"
        static let name = "name"
        static let receiver_id = "receiver_id"
        static let book_id = "book_id"
        static let review = "review"
        static let mark1 = "mark1"
        static let mark2 = "mark2"
        static let mark3 = "mark3"
        static let time = "time"
        static let time_zone = "time_zone"
    }
    
    
    public var id: String!
    public var type: String!
    public var provider_id: String!
    public var photo: String!
    public var name: String!
    public var receiver_id: String!
    public var book_id: String!
    public var review: String!
    public var mark1: String!
    public var mark2: String!
    public var mark3: String!
    public var time: String!
    public var time_zone: String!
    
    public required init?(map: Map){
        
    }
    
    
    public func mapping(map: Map) {
        
        id <- map[SerializationKeys.id]
        type <- map[SerializationKeys.type]
        provider_id <- map[SerializationKeys.provider_id]
        photo <- map[SerializationKeys.photo]
        name <- map[SerializationKeys.name]
        receiver_id <- map[SerializationKeys.receiver_id]
        book_id <- map[SerializationKeys.book_id]
        review <- map[SerializationKeys.review]
        mark1 <- map[SerializationKeys.mark1]
        mark2 <- map[SerializationKeys.mark2]
        mark3 <- map[SerializationKeys.mark3]
        time <- map[SerializationKeys.time]
        time_zone <- map[SerializationKeys.time_zone]
        
    }
    
    
    public func dictionaryRepresentation() -> [String: Any] {
        
        var dictionary: [String: Any] = [:]
        if let value = id { dictionary[SerializationKeys.id] = value }
        if let value = type { dictionary[SerializationKeys.type] = value }
        if let value = provider_id { dictionary[SerializationKeys.provider_id] = value }
        if let value = photo { dictionary[SerializationKeys.photo] = value }
        if let value = name { dictionary[SerializationKeys.name] = value }
        if let value = receiver_id { dictionary[SerializationKeys.receiver_id] = value }
        if let value = book_id { dictionary[SerializationKeys.book_id] = value }
        if let value = review { dictionary[SerializationKeys.review] = value }
        if let value = mark1 { dictionary[SerializationKeys.mark1] = value }
        if let value = mark2 { dictionary[SerializationKeys.mark2] = value }
        if let value = mark3 { dictionary[SerializationKeys.mark3] = value }
        if let value = time_zone { dictionary[SerializationKeys.time_zone] = value }
        
        
        return dictionary
    }
    
}


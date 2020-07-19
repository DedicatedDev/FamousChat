//
//  AccountMDL.swift
//  famouschat
//
//  Created by angel oni on 2019/5/12.
//  Copyright © 2019 Oni Angel. All rights reserved.
//

import Foundation
import ObjectMapper

public final class BookData: Mappable {
    
    private struct SerializationKeys {
        
        static let id = "book_id"
        static let influencer_id = "influencer_id"
        static let normal_id = "normal_id"
        static let time = "time"
        static let duration = "duration"
        static let question = "question"
        static let status = "status"
        static let popcoin = "popcoin"
    }
    
    
    public var id: String!
    public var influencer_id: String!
    public var normal_id: String!
    public var time: String!
    public var duration: String!
    public var question: String!
    public var status: String!
    public var popcoin: String!
    
    
    public required init?(map: Map){
        
    }
    
    
    public func mapping(map: Map) {
        
        id <- map[SerializationKeys.id]
        influencer_id <- map[SerializationKeys.influencer_id]
        normal_id <- map[SerializationKeys.normal_id]
        time <- map[SerializationKeys.time]
        duration <- map[SerializationKeys.duration]
        question <- map[SerializationKeys.question]
        status <- map[SerializationKeys.status]
        popcoin <- map[SerializationKeys.popcoin]
    }
    
    
    public func dictionaryRepresentation() -> [String: Any] {
        
        var dictionary: [String: Any] = [:]
        if let value = id { dictionary[SerializationKeys.id] = value }
        if let value = influencer_id { dictionary[SerializationKeys.influencer_id] = value }
        if let value = normal_id { dictionary[SerializationKeys.normal_id] = value }
        if let value = time { dictionary[SerializationKeys.time] = value }
        if let value = duration { dictionary[SerializationKeys.duration] = value }
        if let value = question { dictionary[SerializationKeys.question] = value }
        if let value = status { dictionary[SerializationKeys.status] = value }
        if let value = popcoin { dictionary[SerializationKeys.popcoin] = value }
        
        return dictionary
    }
    
}

public final class BookMDL: Mappable {
    
    private struct SerializationKeys {
        
        static let book = "book"
        static let profile = "profile"
    }
    
    public var book: BookData!
    public var profile: UserMDL!
    
    public required init?(map: Map){
        
    }
    
    
    public func mapping(map: Map) {
        
        book <- map[SerializationKeys.book]
        profile <- map[SerializationKeys.profile]
    }
    
    
    public func dictionaryRepresentation() -> [String: Any] {
        
        var dictionary: [String: Any] = [:]
        
        if let value = book { dictionary[SerializationKeys.book] = value }
        if let value = profile { dictionary[SerializationKeys.profile] = value }
        
        return dictionary
    }
    
}


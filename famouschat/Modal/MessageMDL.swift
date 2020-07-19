//
//  AccountMDL.swift
//  famouschat
//
//  Created by angel oni on 2019/5/12.
//  Copyright © 2019 Oni Angel. All rights reserved.
//

import Foundation
import ObjectMapper

public final class MessageData: Mappable {
    
    private struct SerializationKeys {
        
        static let id = "msg_id"
        static let sender_id = "sender_id"
        static let receiver_id = "receiver_id"
        static let message = "message"
        static let time = "time"
        static let status = "status"
    }
    
    
    public var id: String!
    public var sender_id: String!
    public var receiver_id: String!
    public var message: String!
    public var time: String!
    public var status: String!
    
    public required init?(map: Map){
        
    }
    
    
    public func mapping(map: Map) {
        
        id <- map[SerializationKeys.id]
        sender_id <- map[SerializationKeys.sender_id]
        receiver_id <- map[SerializationKeys.receiver_id]
        message <- map[SerializationKeys.message]
        time <- map[SerializationKeys.time]
        status <- map[SerializationKeys.status]
    }
    
    
    public func dictionaryRepresentation() -> [String: Any] {
        
        var dictionary: [String: Any] = [:]
        if let value = id { dictionary[SerializationKeys.id] = value }
        if let value = sender_id { dictionary[SerializationKeys.sender_id] = value }
        if let value = receiver_id { dictionary[SerializationKeys.receiver_id] = value }
        if let value = message { dictionary[SerializationKeys.message] = value }
        if let value = time { dictionary[SerializationKeys.time] = value }
        if let value = status { dictionary[SerializationKeys.status] = value }
        
        return dictionary
    }
    
}

public final class MessageMDL: Mappable {
    
    private struct SerializationKeys {
        
        static let message = "message"
        static let profile = "profile"
        static let unread_num = "unread_num"
    }
    
    public var message: MessageData!
    public var profile: UserMDL!
    public var unread_num: String!
    
    
    public required init?(map: Map){
        
    }
    
    
    public func mapping(map: Map) {
        
        message <- map[SerializationKeys.message]
        profile <- map[SerializationKeys.profile]
        unread_num <- map[SerializationKeys.unread_num]
        
    }
    
    
    public func dictionaryRepresentation() -> [String: Any] {
        
        var dictionary: [String: Any] = [:]
        
        if let value = message { dictionary[SerializationKeys.message] = value }
        if let value = profile { dictionary[SerializationKeys.profile] = value }
        if let value = unread_num { dictionary[SerializationKeys.unread_num] = value }
        
        return dictionary
    }
    
}


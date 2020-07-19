//
//  NormalUserMDL.swift
//  famouschat
//
//  Created by angel oni on 2019/5/12.
//  Copyright © 2019 Oni Angel. All rights reserved.
//

import Foundation
import ObjectMapper

public final class CharityMDL: Mappable {
    
    private struct SerializationKeys {
        
        static let id = "charity_id"
        static let name = "name"
        static let photo = "photo"
    }
    
    
    public var id: String!
    public var name: String!
    public var photo: String!
    
    public required init?(map: Map){
        
    }
    
    public func mapping(map: Map) {
        
        id <- map[SerializationKeys.id]
        name <- map[SerializationKeys.name]
        photo <- map[SerializationKeys.photo]
    }
    
    
    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        
        if let value = id { dictionary[SerializationKeys.id] = value }
        if let value = name { dictionary[SerializationKeys.name] = value }
        if let value = photo { dictionary[SerializationKeys.photo] = value }
        
        return dictionary
    }
    
}

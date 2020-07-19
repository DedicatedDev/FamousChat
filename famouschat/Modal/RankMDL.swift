//
//  AccountMDL.swift
//  famouschat
//
//  Created by angel oni on 2019/5/12.
//  Copyright © 2019 Oni Angel. All rights reserved.
//

import Foundation
import ObjectMapper

public final class RankMDL: Mappable {
    
    private struct SerializationKeys {
        
        static let today_minutes = "today_minutes"
        static let month_minutes = "month_minutes"
        static let year_minutes = "year_minutes"
        static let total_minutes = "total_minutes"
        static let today_calls = "today_calls"
        static let month_calls = "month_calls"
        static let year_calls = "year_calls"
        static let total_calls = "total_calls"
        static let category_rank = "category_rank"
        static let total_rank = "total_rank"
    }
    
    
    public var today_minutes: String!
    public var month_minutes: String!
    public var year_minutes: String!
    public var total_minutes: String!
    public var today_calls: String!
    public var month_calls: String!
    public var year_calls: String!
    public var total_calls: String!
    public var category_rank: [Int]!
    public var total_rank: String!
    
    public required init?(map: Map){
        
    }
    
    
    public func mapping(map: Map) {
        
        today_minutes <- map[SerializationKeys.today_minutes]
        month_minutes <- map[SerializationKeys.month_minutes]
        year_minutes <- map[SerializationKeys.year_minutes]
        total_minutes <- map[SerializationKeys.total_minutes]
        today_calls <- map[SerializationKeys.today_calls]
        month_calls <- map[SerializationKeys.month_calls]
        year_calls <- map[SerializationKeys.year_calls]
        total_calls <- map[SerializationKeys.total_calls]
        category_rank <- map[SerializationKeys.category_rank]
        total_rank <- map[SerializationKeys.total_rank]
    }
    
    
    public func dictionaryRepresentation() -> [String: Any] {
        
        var dictionary: [String: Any] = [:]
        if let value = today_minutes { dictionary[SerializationKeys.today_minutes] = value }
        if let value = month_minutes { dictionary[SerializationKeys.month_minutes] = value }
        if let value = year_minutes { dictionary[SerializationKeys.year_minutes] = value }
        if let value = total_minutes { dictionary[SerializationKeys.total_minutes] = value }
        if let value = today_calls { dictionary[SerializationKeys.today_calls] = value }
        if let value = month_calls { dictionary[SerializationKeys.month_calls] = value }
        if let value = year_calls { dictionary[SerializationKeys.year_calls] = value }
        if let value = total_calls { dictionary[SerializationKeys.total_calls] = value }
        if let value = category_rank { dictionary[SerializationKeys.category_rank] = value }
        if let value = total_rank { dictionary[SerializationKeys.total_rank] = value }
        
        return dictionary
    }
    
}


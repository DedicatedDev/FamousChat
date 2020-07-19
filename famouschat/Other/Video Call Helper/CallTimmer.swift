//
//  CallTimmer.swift
//  RealEstate
//
//  Created by Deepak Singh on 10/11/16.
//  Copyright © 2016 RealEstate. All rights reserved.
//

import UIKit

class CallTimmer: NSObject
{
    var startDateTime : Date?
    var endDateTime : Date?
    
    static let sharedInstance : CallTimmer = {
        let instance = CallTimmer()
        return instance
    }()
    
    override init()
     {
        super.init()
    }
    public func startCallTime()
    {
        if self.startDateTime == nil
        {
            self.startDateTime = Date.init()
        }
        else
        {
            print("Timer was already started.")
        }
    }
    
    public func endCallTimer() -> TimeInterval
    {
        if self.startDateTime != nil
        {
            self.endDateTime = Date.init()
            let timeInterval = self.endDateTime?.timeIntervalSince(startDateTime!)
            
            self.startDateTime = nil
            self.endDateTime = nil
            return timeInterval!
        }
        else
        {
            return 0
        }
    }
    
    public func getCurrentDuration() -> String
    {
        if self.startDateTime != nil
        {
            let currentDateTime = Date.init()
            
            let timeInterval = currentDateTime.timeIntervalSince(startDateTime!)
            
            let hours = Int(timeInterval) / 3600
            let minutes = Int(timeInterval) / 60 % 60
            let seconds = Int(timeInterval) % 60
            return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
        }
        else
        {
            return ""
        }
    }
}

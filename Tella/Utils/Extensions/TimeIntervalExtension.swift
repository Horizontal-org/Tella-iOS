//
//  TimeIntervalExtension.swift
//  Tella
//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation


extension TimeInterval{
    
    /// - Returns: "00:23:46"
    func formattedAsHHMMSS() -> String {
        let time = NSInteger(self)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        
        return String(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds)
    }
    
    /// - Function to format time into MM:SS
    /// - Returns: "00:23"
    func formattedAsMMSS() -> String {
        let time = NSInteger(self)
        let minutesPart = Int(time) / 60
        let secondsPart = Int(time) % 60
        
        return String(format: "%02d:%02d", minutesPart, secondsPart)
    }

}

//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import UIKit

class DiskStatus: NSObject {

    func MBFormatter(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits =  [.useBytes,.useKB, .useMB, .useGB]
        formatter.countStyle = ByteCountFormatter.CountStyle.decimal
        return formatter.string(fromByteCount: bytes) as String
    }
    
    ///  Get the remaining time in the device
    /// - Returns:  2 hours 46 min (452 MB) left
    func getRemainingTime() -> String {
        
        let timeMinutes = Double(deviceRemainingFreeSpaceInBytes ?? 0) / 262144.0 // 4 minutes --> 1MB  approximation/1024*256
        
        let days = Int(timeMinutes / 1440)
        let hours = Int((timeMinutes - Double(days * 1440)) / 60)
        let minutes = Int((timeMinutes - Double(days * 1440) - Double(hours * 60)))
        
        let daysString =  days > 1 ? "days" : "day"
        let fullDaysString = "\(days) \(daysString)"
        
        let hoursString =  hours > 1 ? "hours" : "hour"
        let fullHoursString = "\(hours) \(hoursString)"
        
        let minutesString = "\(minutes) min"
        
        if days > 0 {
            return  "\(fullDaysString) \(fullHoursString) \(minutesString) (\(usedDiskSpaceInMB)) left"
        } else {
            return  " \(fullHoursString) \(minutesString) (\(usedDiskSpaceInMB)) left"
        }
    }
    
    var usedDiskSpaceInMB:String {
        return MBFormatter(deviceRemainingFreeSpaceInBytes ?? 0)
    }
    
    /// Get the remaining free space in the device
    var deviceRemainingFreeSpaceInBytes : Int64? {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        guard
            let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: documentDirectory),
            let freeSize = systemAttributes[.systemFreeSize] as? NSNumber
        else {
            // something failed
            return nil
        }
        return freeSize.int64Value
    }
    
}

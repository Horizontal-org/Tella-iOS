//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import UIKit
import SystemConfiguration.CaptiveNetwork
import Network

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
        
        let daysString =  days > 1 ? LocalizableRecorder.deviceTimeLeftDays.localized : LocalizableRecorder.deviceTimeLeftDay.localized
        let fullDaysString = "\(days) \(daysString)"
        
        let hoursString =  hours > 1 ? LocalizableRecorder.deviceTimeLeftHours.localized : LocalizableRecorder.deviceTimeLeftHour.localized
        let fullHoursString = "\(hours) \(hoursString)"
        
        let minutesString = "\(minutes) \(LocalizableRecorder.deviceTimeLeftMinutes.localized)"
        
        if days > 0 {
            return  "\(fullDaysString) \(fullHoursString) \(minutesString) (\(usedDiskSpaceInMB)) \(LocalizableRecorder.deviceTimeLeft.localized)"
        } else {
            return  " \(fullHoursString) \(minutesString) (\(usedDiskSpaceInMB)) \(LocalizableRecorder.deviceTimeLeft.localized)"
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

extension UIDevice {
    
    func getIPAddress(for type: NWInterface.InterfaceType?) -> String? {
        
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        defer { freeifaddrs(ifaddr) }
        
        var ptr = ifaddr
        while ptr != nil {
            defer { ptr = ptr?.pointee.ifa_next }
            
            let interface = ptr?.pointee
            let addrFamily = interface?.ifa_addr.pointee.sa_family
            
            if addrFamily == UInt8(AF_INET), let name = interface?.ifa_name {
                let interfaceName = String(cString: name)
                
                if (type == .wifi && interfaceName == "en0") || (type == .cellular && interfaceName == "bridge100") {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    
                    getnameinfo(
                        interface?.ifa_addr,
                        socklen_t((interface?.ifa_addr.pointee.sa_len)!),
                        &hostname,
                        socklen_t(hostname.count),
                        nil,
                        0,
                        NI_NUMERICHOST
                    )
                    
                    return String(cString: hostname)
                }
            }
        }
        
        return nil
    }
}

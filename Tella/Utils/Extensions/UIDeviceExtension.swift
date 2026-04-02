//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import UIKit
import SystemConfiguration.CaptiveNetwork
import Network
import Darwin.POSIX

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
    
    /// Returns IPv4 addresses for Wi-Fi (`en0`) and Personal Hotspot (`bridge100`)
    func wifiAndHotspotIPv4Addresses() -> [String] {
        let allowedInterfaces: Set<String> = ["en0", "bridge100"]
        
        var result = Set<String>()
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        
        guard getifaddrs(&ifaddr) == 0, let first = ifaddr else {
            return []
        }
        defer { freeifaddrs(ifaddr) }
        
        var ptr: UnsafeMutablePointer<ifaddrs>? = first
        
        while let current = ptr {
            let interface = current.pointee
            defer { ptr = interface.ifa_next }
            
            guard let nameC = interface.ifa_name else { continue }
            let name = String(cString: nameC)
            
            // Only Wi-Fi + Hotspot
            guard allowedInterfaces.contains(name) else { continue }
            
            let flags = interface.ifa_flags
            guard (flags & UInt32(IFF_UP)) != 0,
                  (flags & UInt32(IFF_LOOPBACK)) == 0 else { continue }
            
            guard let addr = interface.ifa_addr,
                  addr.pointee.sa_family == UInt8(AF_INET) else { continue }
            
            var host = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            
            let resultCode = getnameinfo(
                addr,
                socklen_t(MemoryLayout<sockaddr_in>.size),
                &host,
                socklen_t(host.count),
                nil,
                0,
                NI_NUMERICHOST
            )
            
            guard resultCode == 0 else { continue }
            
            result.insert(String(cString: host))
        }
        
        return Array(result)
    }
}

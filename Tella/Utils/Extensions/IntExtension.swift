//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

extension Int64 {

    func getFormattedFileSize() -> String {
        if (self < 1000) { return "\(self) B" }
        let exp = Int(log2(Double(self)) / log2(1000.0))
        let unit = ["KB", "MB", "GB", "TB", "PB", "EB"][exp - 1]
        let number = Double(self) / pow(1000, Double(exp))
        if exp <= 1 || number >= 100 {
            return String(format: "%.0f %@", number, unit)
        } else {
            return String(format: "%.1f %@", number, unit)
                .replacingOccurrences(of: ".0", with: "")
        }
    }
}

extension Int {

    func getFormattedFileSize() -> String {
        if (self < 1000) { return "\(self) B" }
        let exp = Int(log2(Double(self)) / log2(1000.0))
        let unit = ["KB", "MB", "GB", "TB", "PB", "EB"][exp - 1]
        let number = Double(self) / pow(1000, Double(exp))
        if exp <= 1 || number >= 100 {
            return String(format: "%.0f %@", number, unit)
        } else {
            return String(format: "%.1f %@", number, unit)
                .replacingOccurrences(of: ".0", with: "")
        }
    }
    
    func getchunkSize() -> Int {
        // Adjust chunk size based on file size
        if self <= 10 * 1024 * 1024 { // Files smaller than or equal to 10 MB
            return 1 * 1024 * 1024 // 1 MB chunks
        } else if self <= 500 * 1024 * 1024 { // Files between 10 MB and 500 MB
            return 5 * 1024 * 1024 // 5 MB chunks
        } else { // Files larger than 500 MB
            return 10 * 1024 * 1024 // 10 MB chunks
        }
    }
}

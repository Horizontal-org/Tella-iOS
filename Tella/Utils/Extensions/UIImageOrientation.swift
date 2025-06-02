//  Tella
//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import UIKit
import AVFoundation

extension UIImage.Orientation {
    
    init(_ cgOrientation: CGImagePropertyOrientation) {
        // Map with enum values becuase raw values do not match
        switch cgOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        }
    }
    
    /// Returns a UIImage.Orientation based on the matching cgOrientation raw value
    static func orientation(fromCGOrientationRaw cgOrientationRaw: UInt32) -> UIImage.Orientation? {
        var orientation: UIImage.Orientation?
        if let cgOrientation = CGImagePropertyOrientation(rawValue: cgOrientationRaw) {
            orientation = UIImage.Orientation(cgOrientation)
        } else {
            orientation = nil  
        }
        return orientation
    }
}

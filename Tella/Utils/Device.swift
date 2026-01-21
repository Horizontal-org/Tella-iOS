//
//  Device.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 15/1/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import UIKit

class Device {
    static let defaultReferenceScreenWidth: CGFloat = 360
    
    static var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    static var ratio: CGFloat {
        screenWidth / defaultReferenceScreenWidth
    }
}

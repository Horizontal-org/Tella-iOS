//
//  Copyright © 2021 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import UIKit
import SwiftUI

struct Styles {
    
    struct uiColor {
        static let backgroundMain = UIColor(hexValue: 0x2C275A)
        static let backgroundTab = UIColor(hexValue: 0x3D3867)
        static let yellow = UIColor(hexValue: 0xD6933B)
        static let lightBlue = UIColor(hexValue: 0x2C6C97)
        static let disabledYellow = UIColor(hexValue: 0x463755)
        
        static let yellowWhite = UIColor(hexValue: 0xDDA45A)
        
        static let darkRed = UIColor(hexValue: 0x971212)
        static let red = UIColor(hexValue: 0xFC4444)
        
        static let backgroundToast = UIColor(hexValue: 0xE8E8EC)
        
        static let grey1 = UIColor(hexValue: 0xDCDCDC)
        static let grey2 = UIColor(hexValue: 0xA8ADAF)
        
        static let backgroundGrey1 = UIColor(hexValue: 0x1F2125)
        static let backgroundGrey2 = UIColor(hexValue: 0x3A3C40)
    }
    
    struct Colors {
        static let backgroundMain = Color(uiColor.backgroundMain)
        static let backgroundTab = Color(uiColor.backgroundTab)
        static let yellow = Color(uiColor.yellow)
        static let lightBlue = Color(uiColor.lightBlue)
        static let disabledYellow = Color(uiColor.disabledYellow)
        
        static let yellowWhite = Color(uiColor.yellowWhite)
        
        static let red = Color(uiColor.red)
        static let darkRed = Color(uiColor.darkRed)
        
        static let backgroundToast = Color(uiColor.backgroundToast)
        
        static let grey1 = Color(uiColor.grey1)
        static let grey2 = Color(uiColor.grey2)
        
        static let backgroundGrey1 = Color(uiColor.backgroundGrey1)
        static let backgroundGrey2 = Color(uiColor.backgroundGrey2)
    }
    
    struct Stroke {
        static let buttonAdd = StrokeStyle(
            lineWidth: 1,
            lineCap: .round,
            lineJoin: .miter,
            miterLimit: 0,
            dash: [8, 2],
            dashPhase: 0
        )
    }
    
    struct Fonts {
        static var boldFontName = "OpenSans-Bold"
        static var regularFontName = "OpenSans"
        static var semiBoldFontName = "OpenSans-Semibold"
        static var lightFontName = "OpenSans-Light"
        static var lightRobotoFontName = "Roboto-Light"
        static var italicRobotoFontName = "OpenSans-Italic"
    }
}

public extension UIColor {
    
    convenience init(redInt: Int, greenInt: Int, blueInt: Int, alpha: CGFloat=1.0) {
        self.init(red: CGFloat(redInt)/255.0, green: CGFloat(greenInt)/255.0, blue: CGFloat(blueInt)/255.0, alpha: alpha)
    }
    
    convenience init(hexValue: Int) {
        let red = (hexValue >> 16) & 0xFF
        let green = (hexValue >> 8) & 0xFF
        let blue = hexValue & 0xFF
        
        self.init(redInt: red, greenInt: green, blueInt: blue)
    }
}

var safeArea: UIEdgeInsets {
    return UIApplication.shared.windows.last?.safeAreaInsets ?? .zero
}


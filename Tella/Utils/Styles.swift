//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import UIKit
import SwiftUI

struct Styles {
    
    struct uiColor {
        static let backgroundMain = UIColor(hexValue: 0x2C275A)
        static let backgroundTab = UIColor(hexValue: 0x3D3867)
        static let yellow = UIColor(hexValue: 0xD6933B)
        static let lightBlue = UIColor(hexValue: 0x2C6C97)
    }
    
    struct Colors {
        static let backgroundMain = Color(uiColor.backgroundMain)
        static let backgroundTab = Color(uiColor.backgroundTab)
        static let yellow = Color(uiColor.yellow)
        static let lightBlue = Color(uiColor.lightBlue)

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


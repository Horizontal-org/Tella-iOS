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
       
        static let mint = UIColor(hexValue: 0xE6F4F3)
        static let lightGray = UIColor(hexValue: 0xF3F3F3)
        static let darkGray = UIColor(hexValue: 0xA4A2A2)
        static let petrol = UIColor(hexValue: 0x3C6E72)
        static let ironGray = UIColor(hexValue: 0x494848)
        static let red = UIColor(hexValue: 0xCE1515)

        
        
      

        
         
    }
    
    struct Colors {
        static let backgroundMain = Color(uiColor.backgroundMain)
        static let backgroundTab = Color(uiColor.backgroundTab)
        static let yellow = Color(uiColor.yellow)
        static let lightBlue = Color(uiColor.lightBlue)

        static let mint = Color(uiColor.mint)
        static let lightGray = Color(uiColor.lightGray)
        static let darkGray = Color(uiColor.darkGray)
        static let petrol = Color(uiColor.petrol)
        static let ironGray = Color(uiColor.ironGray)
        static let red = Color(uiColor.red)

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


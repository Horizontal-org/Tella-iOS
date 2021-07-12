//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import UIKit
import SwiftUI

struct Styles {

    struct uiColor {
        static let backgroundFileButton = UIColor(hexValue: 0x4e4a74)
        static let backgroundMain = UIColor(hexValue: 0x2C275A)
        static let backgroundTab = UIColor(hexValue: 0x46407D)
        static let buttonAdd = UIColor(hexValue: 0xD6933B)
        static let fileIconBackground = UIColor(hexValue: 0x57527b)
    }
    
    struct Colors {
        static let backgroundFileButton = Color(uiColor.backgroundFileButton)
        static let backgroundMain = Color(uiColor.backgroundMain)
        static let backgroundTab = Color(uiColor.backgroundTab)
        static let buttonAdd = Color(uiColor.buttonAdd)
        static let fileIconBackground = Color(uiColor.fileIconBackground)
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


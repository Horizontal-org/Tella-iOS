//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import SwiftUI

enum ButtonType {
    case yellow
    case clear
}

protocol TellaButtonStyleProtocol {
    var backgroundColor : Color {get}
    var pressedBackgroundColor : Color {get}
    var overlayColor : Color {get}
    
}

struct ClearButtonStyle : TellaButtonStyleProtocol {
    var backgroundColor = Color.white.opacity(0.16)
    var pressedBackgroundColor = Color.white.opacity(0.32)
    var overlayColor = Color.white.opacity(0.64)
    
}

struct YellowButtonStyle : TellaButtonStyleProtocol {
    var backgroundColor = Styles.Colors.yellow
    var pressedBackgroundColor = Color(UIColor(hexValue: 0xe0ad6a))
    var overlayColor = Color.white.opacity(0.64)
}

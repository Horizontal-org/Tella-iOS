//  Tella
//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import SwiftUI

enum ButtonType {
    case yellow
    case clear
}
enum ButtonRole {
    case primary
    case secondary
}

protocol TellaButtonStyleProtocol {
    var backgroundColor : Color {get}
    var disabledBackgroundColor : Color {get}
    var pressedBackgroundColor : Color {get}
    var overlayColor : Color {get}
    var foregroundColor : Color {get}
    var disabledForegroundColor : Color {get}

}

struct ClearButtonStyle : TellaButtonStyleProtocol {
    var backgroundColor = Color.white.opacity(0.16)
    var disabledBackgroundColor = Color.white.opacity(0.16)
    var pressedBackgroundColor = Color.white.opacity(0.32)
    var overlayColor = Color.white.opacity(0.64)
    var foregroundColor = Color.white
    var disabledForegroundColor = Color.white.opacity(0.38)
}

struct YellowButtonStyle : TellaButtonStyleProtocol {
    var backgroundColor = Styles.Colors.yellow
    var disabledBackgroundColor = Styles.Colors.disabledYellow
    var pressedBackgroundColor = Color(UIColor(hexValue: 0xe0ad6a))
    var overlayColor = Color.white.opacity(0.64)
    var foregroundColor = Color.black
    var disabledForegroundColor = Color.black.opacity(0.38)
}

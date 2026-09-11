//  Tella
//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct CameraControlRotation {
    var deviceOrientation: UIDeviceOrientation = UIDevice.current.orientation
    var shouldAnimate: Bool = false
}

extension View {
    
    func rotate(_ rotation: CameraControlRotation) -> some View {
        rotate(deviceOrientation: rotation.deviceOrientation,
               shouldAnimate: rotation.shouldAnimate)
    }
    
    public func rotate(deviceOrientation: UIDeviceOrientation,
                       shouldAnimate: Bool) -> some View {
        
        var degree : Double = 0
        switch deviceOrientation {
        case .faceDown, .portraitUpsideDown:
            degree = 180
        case .landscapeLeft:
            degree = 90
        case .landscapeRight:
            degree = -90
        default:
            break
        }
        return self.modifier(RotationViewModifier(degree: degree, shouldAnimate: shouldAnimate))
    }
}

struct RotationViewModifier : ViewModifier {
    
    var degree : Double
    var shouldAnimate : Bool
    
    public func body(content: Content) -> some View {
        
        content
            .rotationEffect(.degrees(degree))
            .animation(shouldAnimate ? .easeInOut(duration: 0.3) : nil, value: degree)
    }
}

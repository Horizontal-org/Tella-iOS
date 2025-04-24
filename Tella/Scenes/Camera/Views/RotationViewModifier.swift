//  Tella
//
//  Copyright © 2022 HORIZONTAL. All rights reserved.
//

import SwiftUI

extension View {
    
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
        
        content.rotationEffect(.degrees(degree))
            .if(shouldAnimate, transform: { view in
                view.animation(.easeInOut(duration: 0.3))
            })
    }
}

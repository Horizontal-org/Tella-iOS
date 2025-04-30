//  Tella
//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import UIKit
import AVFoundation

extension UIDeviceOrientation {
   
    func videoOrientation() -> AVCaptureVideoOrientation {
        
        var videoOrientation: AVCaptureVideoOrientation!

        switch self {

        case .faceUp, .faceDown, .unknown:

            if let interfaceOrientation = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.windowScene?.interfaceOrientation {
                
                switch interfaceOrientation {
                    
                case .portrait, .unknown:
                    videoOrientation = .portrait
                    
                case .portraitUpsideDown:
                    
                    videoOrientation = .portraitUpsideDown
                case .landscapeLeft:
                    videoOrientation = .landscapeRight
                case .landscapeRight:
                    videoOrientation = .landscapeLeft
                @unknown default:
                    videoOrientation = .portrait
                }
            }
            
        case .portrait :
            videoOrientation = .portrait
            
        case  .portraitUpsideDown:
            videoOrientation = .portraitUpsideDown
        case .landscapeLeft:
            videoOrientation = .landscapeRight
        case .landscapeRight:
            videoOrientation = .landscapeLeft
        @unknown default:
            videoOrientation = .portrait
        }
        
        return videoOrientation
    }

}

//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
import SwiftUI

class Toast {
    
    class func displayToast(message:String) {
        
        DispatchQueue.main.async {
            if let window = UIApplication.shared.keyWindow {
                
                let viewToShow = ToastView(message: message)
                
                let hostingController = UIHostingController(rootView: viewToShow)
                hostingController.view.frame = ( window.bounds)
                hostingController.view.backgroundColor = UIColor.clear
                window.addSubview(hostingController.view)
                
                UIView.animate(withDuration: 0.5, delay: 3.0, options: UIView.AnimationOptions.curveLinear, animations: {
                    hostingController.view.alpha = 0.0
                }) { _ in
                    hostingController.view.removeFromSuperview()
                }
            }
        }
    }
}

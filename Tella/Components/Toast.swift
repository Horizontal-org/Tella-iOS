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
                hostingController.view.backgroundColor = UIColor.clear
                window.addSubview(hostingController.view)

                hostingController.view.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    hostingController.view.leftAnchor.constraint(equalTo: window.safeAreaLayoutGuide.leftAnchor),
                    hostingController.view.rightAnchor.constraint(equalTo: window.safeAreaLayoutGuide.rightAnchor),
                    hostingController.view.bottomAnchor.constraint(equalTo: window.safeAreaLayoutGuide.bottomAnchor),
                ])

                UIView.animate(withDuration: 0.5, delay: 3.0, options: UIView.AnimationOptions.curveLinear, animations: {
                    hostingController.view.alpha = 0.0
                }) { _ in
                    hostingController.view.removeFromSuperview()
                }
            }
        }
    }
}

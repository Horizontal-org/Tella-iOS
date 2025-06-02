//
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import SwiftUI

struct Toast {
    
    static func displayToast(message: String, delay: TimeInterval = 3.0 ) {
        
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
                
                UIView.animate(withDuration: 0.5, delay: delay, options: UIView.AnimationOptions.curveLinear, animations: {
                    hostingController.view.alpha = 0.0
                }) { _ in
                    hostingController.view.removeFromSuperview()
                }
            }
        }
    }
}

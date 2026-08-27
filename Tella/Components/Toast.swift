//
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import SwiftUI

struct Toast {
    static let defaultDuration: TimeInterval = 3.0
    static let fadeDuration: TimeInterval = 0.5
    
    static func displayToast(message: String, delay: TimeInterval = Toast.defaultDuration) {
        guard !message.isEmpty else { return }
        
        DispatchQueue.main.async {
            
            if let window = UIApplication.shared.keyWindow {
                
                let viewToShow = ToastMessageView(message: message)
                
                let hostingController = UIHostingController(rootView: viewToShow)
                hostingController.view.backgroundColor = UIColor.clear
                window.addSubview(hostingController.view)
                
                hostingController.view.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    hostingController.view.leftAnchor.constraint(equalTo: window.safeAreaLayoutGuide.leftAnchor),
                    hostingController.view.rightAnchor.constraint(equalTo: window.safeAreaLayoutGuide.rightAnchor),
                    hostingController.view.bottomAnchor.constraint(equalTo: window.safeAreaLayoutGuide.bottomAnchor),
                ])
                
                UIView.animate(withDuration: Toast.fadeDuration, delay: delay, options: UIView.AnimationOptions.curveLinear, animations: {
                    hostingController.view.alpha = 0.0
                }) { _ in
                    hostingController.view.removeFromSuperview()
                }
            }
        }
    }
}

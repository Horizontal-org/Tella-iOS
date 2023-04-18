//
//  UIApplicationExtension.swift
//  Tella
//
//  
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func openSettings() {
        open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    }
    
    var keyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .map { $0 as? UIWindowScene }
            .compactMap { $0 }
            .first?.windows
            .filter { $0.isKeyWindow }
            .first
    }
    
    func topNavigationController(_ viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UINavigationController? {
        let window = keyWindow
        return window?.rootViewController?.children.last as? UINavigationController
    }
    
    func popToRootView() {
        let window = keyWindow
        let nvc = window?.rootViewController?.children.last as? UINavigationController
        nvc?.popToRootViewController(animated: true)
    }
    
    func popTo(_ classType: AnyClass) {
        
        let window = keyWindow
        
        let nvc = window?.rootViewController?.children.last as? UINavigationController
        
        nvc?.viewControllers.forEach({ vc in
            if vc.isKind(of: classType) {
                nvc?.popToViewController(vc, animated: true)
            }
        })
    }
}

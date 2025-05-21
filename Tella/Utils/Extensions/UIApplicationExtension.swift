//
//  UIApplicationExtension.swift
//  Tella
//
//
//  Copyright © 2021 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
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
    
    func popToRootView(animated:Bool = true) {
        let window = keyWindow
        let nvc = window?.rootViewController?.children.last as? UINavigationController
        nvc?.popToRootViewController(animated: animated)
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
    
    func navigationHasClassType(_ classType: AnyClass) -> Bool {
        
        let window = keyWindow
        
        let nvc = window?.rootViewController?.children.last as? UINavigationController
        
        if let matchingVC = nvc?.viewControllers.first(where: { $0.isKind(of: classType) }) {
            return true
        }
        
        return false
    }
    
    class func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController ?? nav.topViewController)
        }
        if let tab = base as? UITabBarController {
            return getTopViewController(base: tab.selectedViewController)
        }
        if let split = base as? UISplitViewController {
            return getTopViewController(base: split.viewControllers.last)
        }
        if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }

        private class func topRootViewController() -> UIViewController? {
            // For multi-scene apps
            guard let scene = UIApplication.shared.connectedScenes
                    .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
                return nil
            }

            return scene.windows
                .first(where: { $0.isKeyWindow })?.rootViewController
        }

    func setupApperance(with backgroundColor: UIColor = Styles.uiColor.backgroundMain) {
        
        UITabBar.appearance().unselectedItemTintColor = UIColor.white.withAlphaComponent(0.38)
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().isTranslucent = true
        UITabBar.appearance().backgroundColor = backgroundColor
        
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithTransparentBackground()
        coloredAppearance.backgroundColor = backgroundColor
        
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
        UINavigationBar.appearance().backgroundColor = backgroundColor
        
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
    }
    
    var rootViewController: UIViewController? {
        return keyWindow?.rootViewController
    }
    
    func topNavigationController() -> UINavigationController? {
        guard let root = keyWindow?.rootViewController else { return nil }
        
        // 1) If the top VC is inside a nav
        if let nav = UIApplication.getTopViewController()?.navigationController { return nav }
        
        // 2) If the top VC itself is a nav
        if let nav = UIApplication.getTopViewController() as? UINavigationController { return nav }
        
        // 3) Recursive search from root (tabs/modals/split/children)
        if let nav = findNav(from: root) { return nav }
        
        // 4) Fallback (your working case): root.children.last as UINavigationController
        if let lastChildNav = (root.children.last { $0 is UINavigationController }) as? UINavigationController,
           lastChildNav.isViewLoaded, lastChildNav.view.window != nil {
            return lastChildNav
        }
        
        return nil
    }
    
    private func findNav(from vc: UIViewController?) -> UINavigationController? {
        switch vc {
        case let nav as UINavigationController:
            return nav
        case let tab as UITabBarController:
            return findNav(from: tab.selectedViewController)
        case let split as UISplitViewController:
            return findNav(from: split.viewControllers.last)
        default:
            if let presented = vc?.presentedViewController { return findNav(from: presented) }
            for child in vc?.children ?? [] {
                if let found = findNav(from: child) { return found }
            }
            return vc?.navigationController
        }
    }
    
}

//
//  SceneDelegate.swift
//  Tella
//
//  Created by Anessa Petteruti on 1/30/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    private var appViewState = AppViewState()
    private var homeViewModel = MainAppModel()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        // TODO: Use CryptoManager instead
//        if CryptoManagerV1.keysInitialized() {
//            appViewState.resetToMain()
//        } else {
//            appViewState.resetToAuth()
//        }
        
        // Create the SwiftUI view that provides the window contents.
//        let contentView = ContentView().environmentObject(appViewState)
        let contentView = AppView().environmentObject(homeViewModel)

        // override incorrect defaults
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
        
        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = HostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        if let imageView : UIImageView = UIApplication.shared.windows.first?.subviews.last?.viewWithTag(101) as? UIImageView {
            imageView.removeFromSuperview()
        }
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        let imageView = UIImageView(frame: UIScreen.main.bounds)
        imageView.tag = 101
        imageView.backgroundColor = UIColor.white
        imageView.contentMode = .center
        imageView.image = UIImage (named: "splash")
        UIApplication.shared.windows.first?.subviews.last?.addSubview(imageView)
    }
}


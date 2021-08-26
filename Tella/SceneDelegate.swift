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
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        if CryptoManager.shared.keysInitialized() {
            appViewState.resetToMain()
        } else {
            appViewState.resetToAuth()
        }
        
        let contentView = ContentView().environmentObject(appViewState)
        
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
        removeSplashscreen()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        addSplashscreen()
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        removeSplashscreen()
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        appViewState.homeViewModel.saveSettings()
        addSplashscreen()
    }

    func removeSplashscreen() {
        if let splashView = UIApplication.shared.windows.first?.subviews.last?.viewWithTag(101) {
            splashView.removeFromSuperview()
        }
    }
    
    func addSplashscreen() {
        let splashView = UIImageView(frame: UIScreen.main.bounds)
        splashView.tag = 101
        splashView.backgroundColor = Styles.uiColor.backgroundMain
        splashView.contentMode = .center
        UIApplication.shared.windows.first?.subviews.last?.addSubview(splashView)
    }
    
}

//  Tella
//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import UIKit
import SwiftyDropbox
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    
    var backgroundSessionCompletionHandler: (() -> Void)?
    static private(set) var instance: AppDelegate! = nil
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        AppDelegate.instance = self
        
        setupDropbox()
        configureGoogleSignIn()
        return true
    }
    
    func application (_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
            backgroundSessionCompletionHandler = completionHandler
        }

    private func setupDropbox() {
        guard let dropboxAppKey = ConfigurationManager.getValue(DropboxAuthConstants.dropboxAppKey) else  {
            debugLog("Dropbox App Key not found")
            return
        }
        DropboxClientsManager.setupWithAppKey(dropboxAppKey)
    }
    
    func configureGoogleSignIn() {
        guard let clientID = ConfigurationManager.getValue(GoogleAuthConstants.gDriveClientID) else  {
            debugLog("Google Drive Client ID not found")
            return
        }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
    }
}

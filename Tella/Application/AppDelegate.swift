//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    
    var backgroundSessionCompletionHandler: (() -> Void)?
    static private(set) var instance: AppDelegate! = nil
    @Published var shouldHandleTimeout : Bool = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        AppDelegate.instance = self
        return true
    }
    
    func application(
        _ application: UIApplication,
        handleEventsForBackgroundURLSession
        handleEventsForBackgroundURLSessionidentifier: String,
        completionHandler: @escaping () -> Void) {
            backgroundSessionCompletionHandler = completionHandler
            shouldHandleTimeout = true
        }
}

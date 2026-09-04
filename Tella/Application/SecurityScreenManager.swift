//
//  SecurityScreenManager.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 4/9/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import UIKit
import Combine

/// Shows a blank screen on top of everything the app displays, so that the app switcher
/// snapshot and screen recordings never expose the user's content.

final class SecurityScreenManager {
    
    static let shared = SecurityScreenManager()
    
    private var window: UIWindow?
    private var isSecurityScreenNeeded = false
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    /// Shows or hides the screen when the app state changes.
    /// Updates are synchronous, so the window is up before iOS snapshots the app.
    func bind(to mainAppModel: MainAppModel) {
        cancellables.removeAll()
        
        let isScreenSecurityEnabled = mainAppModel.$settings
            .flatMap { $0.$screenSecurity }
        
        Publishers.CombineLatest3(mainAppModel.$shouldShowSecurityScreen,
                                  mainAppModel.$shouldShowRecordingSecurityScreen,
                                  isScreenSecurityEnabled)
        .map { isAppInactive, isScreenCaptured, isEnabled in
            isEnabled && (isAppInactive || isScreenCaptured)
        }
        .removeDuplicates()
        .sink { [weak self] isNeeded in
            self?.isSecurityScreenNeeded = isNeeded
            self?.refresh()
        }
        .store(in: &cancellables)
        
        // The window scene needed to show the screen does not exist yet during launch. Retry
        // once the app is active, in case the screen was already being recorded at launch.
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in self?.refresh() }
            .store(in: &cancellables)
    }
    
    private func refresh() {
        isSecurityScreenNeeded ? show() : hide()
    }
    
    private func show() {
        guard window == nil, let windowScene = foregroundWindowScene else { return }
        
        let window = UIWindow(windowScene: windowScene)
        window.windowLevel = UIWindow.Level(UIWindow.Level.alert.rawValue + 1)
        window.backgroundColor = .white
        window.rootViewController = SecurityScreenViewController()
        window.isHidden = false
        window.layoutIfNeeded()
        
        self.window = window
    }
    
    private func hide() {
        window?.isHidden = true
        window = nil
    }
    
    /// The scene that hosts the security window. Inactive scenes still render and are
    /// accepted, since the app is usually inactive when the screen is needed.
    private var foregroundWindowScene: UIWindowScene? {
        let windowScenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        
        return windowScenes.first { $0.activationState == .foregroundActive }
        ?? windowScenes.first { $0.activationState == .foregroundInactive }
        ?? windowScenes.first
    }
}

private class SecurityScreenViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
}

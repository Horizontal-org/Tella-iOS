//
//  LockViewModel.swift
//  Tella
//
//   
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class LockViewModel: ObservableObject {
    
    @Published var loginPassword : String = ""
    @Published var password : String = ""
    @Published var confirmPassword : String = ""
    @Published var oldPassword : String = ""
    @Published var shouldShowUnlockError : Bool = false
    @Published var unlockAttempts : Int
    var maxAttempts : Int

    private var settingsCancellable: AnyCancellable?

    var unlockType : UnlockType = .new
    var shouldDismiss = CurrentValueSubject<Bool, Never>(false)
    var appModel:MainAppModel
    var shouldShowErrorMessage : Bool {
        return password != confirmPassword
    }
    
    var shouldShowAttemptsWarning : Bool {
        if(maxAttempts - unlockAttempts <= 3 && maxAttempts > 0) {
            return true
        } else {
            return false
        }
    }
    
    func remainingAttempts () -> Int {
        return maxAttempts - unlockAttempts
    }
    
    init(unlockType: UnlockType, appModel:MainAppModel) {
        self.unlockType = unlockType
        self.appModel = appModel
        
        self.maxAttempts = appModel.settings.deleteAfterFail.numberOfAttempts
        self.unlockAttempts = UserDefaults.standard.integer(forKey: "com.tella.lock.attempts")
            
        self.settingsCancellable = appModel.settings.$deleteAfterFail
            .map{ $0.numberOfAttempts }
            .assign(to: \.maxAttempts, on: self)
    }
    
    func login() {
        let authorized = appModel.login(password: loginPassword)
        shouldShowUnlockError = !authorized
    }
    
    func initKeys(passwordTypeEnum:PasswordTypeEnum) {
        appModel.initKeys(passwordTypeEnum,
                          password: password)
    }
    
    func updateKeys(passwordTypeEnum:PasswordTypeEnum) {
        appModel.updateKeys(passwordTypeEnum,
                            newPassword: password,
                            oldPassword: loginPassword)
    }
    
    func initUnlockData() {
        loginPassword = ""
        password = ""
        confirmPassword = ""
        shouldShowUnlockError = false
        self.shouldDismiss.send(false)
    }
    
    func initLockData() {
        password = ""
        confirmPassword = ""
        shouldShowUnlockError = false
    }
    
    func warningText() -> String {
        if(unlockAttempts >= maxAttempts) {
            return LocalizableLock.unlockDeleteAfterFailContentDeleted.localized
        }
        return String.init(format: LocalizableLock.unlockDeleterAfterFailRemainingAttempts.localized, self.remainingAttempts())
    }
    
    func removeFilesAndConnections () -> Void {
        unlockAttempts = 0
        UserDefaults.standard.set(unlockAttempts, forKey: "com.tella.lock.attempts")
        
        appModel.deleteAfterMaxAttempts()
    }
}

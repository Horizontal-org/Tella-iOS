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
    
    var appModel: MainAppModel
    
    @Published var loginPassword : String = ""
    @Published var password : String = ""
    @Published var confirmPassword : String = ""
    @Published var oldPassword : String = ""
    @Published var shouldShowUnlockError : Bool = false
    @Published var unlockAttempts : Int = 0
    @Published var maxAttempts : Int
    
    var privateKey : SecKey?
    var unlockType : UnlockType = .new
    var shouldDismiss = CurrentValueSubject<Bool, Never>(false)
    
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
        
    init(unlockType: UnlockType, appModel: MainAppModel) {
        self.unlockType = unlockType
        self.appModel = appModel
        
        maxAttempts = appModel.settings.deleteAfterFail.numberOfAttempts
    }
    
    func login() {
        self.privateKey = CryptoManager.shared.recoverKey(.PRIVATE, password: loginPassword)
        shouldShowUnlockError = privateKey == nil
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
        appModel.removeAllFiles()
        appModel.deleteAllServersConnection()
    }
}

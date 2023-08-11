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
    @Published var unlockAttempts : Int = 0
    var maxAttempts : Int = 5
    
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
        
    init(unlockType: UnlockType) {
        self.unlockType = unlockType
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
        let fileManager = FileManager.default
                
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                
            print("Directory: \(paths)")
                
            do {
                let fileName = try fileManager.contentsOfDirectory(atPath: paths)
                    
                for file in fileName {
                    // For each file in the directory, create full path and delete the file
                    let filePath = URL(fileURLWithPath: paths).appendingPathComponent(file).absoluteURL
                    try fileManager.removeItem(at: filePath)
                }
            } catch let error {
                print(error)
            }
    }
}

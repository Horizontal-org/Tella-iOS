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
    
    @Published var loginPassword : String = "0"
    @Published var password : String = "0"
    @Published var confirmPassword : String = "0"
    @Published var oldPassword : String = ""
    @Published var shouldShowUnlockError : Bool = false
    
    var privateKey : SecKey?
    var unlockType : UnlockType = .new
    var shouldDismiss = CurrentValueSubject<Bool, Never>(false)
    
    var shouldShowErrorMessage : Bool {
        return password != confirmPassword
    }
    
    init() {
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
        password = "0"
        confirmPassword = "0"
        shouldShowUnlockError = false
        self.shouldDismiss.send(false)
    }
    
    func initLockData() {
        password = "0"
        confirmPassword = "0"
        shouldShowUnlockError = false
     }
}

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
    
    var privateKey : SecKey?
    var unlockType : UnlockType = .new
    var shouldDismiss = CurrentValueSubject<Bool, Never>(false)
    

    var unlockKeyboardNumbers: [PinKeyboardModel] = { return [
        PinKeyboardModel(text: "1", type: .number),
        PinKeyboardModel(text: "2", type: .number),
        PinKeyboardModel(text: "3", type: .number),
        PinKeyboardModel(text: "4",  type: .number),
        PinKeyboardModel(text: "5", type: .number),
        PinKeyboardModel(text: "6",  type: .number),
        PinKeyboardModel(text: "7", type: .number),
        PinKeyboardModel(text: "8",  type: .number),
        PinKeyboardModel(text: "9",  type: .number),
        PinKeyboardModel(imageName:"lock.backspace", type: .delete),
        PinKeyboardModel(text: "0",  type: .number),
        PinKeyboardModel(text: LocalizableLock.unlockPinActionOk.localized, type: .done)] }()

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
}

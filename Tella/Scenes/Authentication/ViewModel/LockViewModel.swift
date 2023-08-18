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

    private var cancellables = Set<AnyCancellable>()

    var unlockType : UnlockType = .new
    var shouldDismiss = CurrentValueSubject<Bool, Never>(false)
    var appModel:MainAppModel
    

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
        
        self.unlockAttempts = appModel.settings.unlockAttempts
        self.maxAttempts = appModel.settings.deleteAfterFail.numberOfAttempts
        
        setupSettingsObservations()
    }
    
    private func setupSettingsObservations() {
        appModel.settings.$deleteAfterFail
            .map({ $0.numberOfAttempts })
            .assign(to: \.maxAttempts, on: self)
            .store(in: &cancellables)
        
        appModel.settings.$unlockAttempts
            .assign(to: \.unlockAttempts, on: self)
            .store(in: &cancellables)
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
    
    func resetUnlockAttempts () -> Void {
        appModel.settings.unlockAttempts = 0
        appModel.saveSettings()
    }
    
    func increaseUnlockAttempts () -> Void {
        appModel.settings.unlockAttempts = appModel.settings.unlockAttempts + 1
        appModel.saveSettings()
    }
    
    func removeFilesAndConnections () -> Void {
        appModel.deleteAfterMaxAttempts()
    }
}

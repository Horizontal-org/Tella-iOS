//
//  LockViewModel.swift
//  Tella
//
//
//  Copyright © 2021 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
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
    var appViewState: AppViewState
    
    @Published var isLoading : Bool = false
    @Published var presentingLockChoice : Bool = false
    
    
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
        PinKeyboardModel(text: "OK", type: .done)] }()
    
    var shouldShowErrorMessage : Bool {
        return password != confirmPassword
    }
    
    var shouldShowAttemptsWarning : Bool {
        return maxAttempts - unlockAttempts <= 3 && appModel.settings.showUnlockAttempts && appModel.settings.deleteAfterFail != .off
    }
    
    func remainingAttempts () -> Int {
        return maxAttempts - unlockAttempts
    }
    
    init(unlockType: UnlockType, appViewState:AppViewState) {
        self.unlockType = unlockType
        self.appModel = appViewState.homeViewModel
        self.appViewState = appViewState
        
        self.unlockAttempts = appModel.settings.unlockAttempts
        self.maxAttempts = appModel.settings.deleteAfterFail.numberOfAttempts
        
        setupSettingsObservations()
    }
    
    func resetMaxAttempts() {
        self.unlockAttempts = appModel.settings.unlockAttempts
        self.maxAttempts = appModel.settings.deleteAfterFail.numberOfAttempts
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
        isLoading = true
        
        self.appModel.vaultManager.login(password: self.loginPassword)
            .subscribe(on: DispatchQueue.global(qos: .userInteractive))
            .receive(on: DispatchQueue.main)
            .sink { authorized in
                
                if authorized {
                    self.successLogin()
                } else {
                    self.checkUnlockAttempts()
                }
                
            }.store(in: &self.cancellables)
        
    }
    
    private func successLogin() {
        resetUnlockAttempts()
        if  unlockType == .new {
            loadData()
        } else {
            isLoading = false
            presentingLockChoice = true
            presentingLockChoice = false
        }
    }
    
    private func checkUnlockAttempts() {
        isLoading = false
        shouldShowUnlockError = true
        increaseUnlockAttempts()
        
        if(unlockAttempts ==  maxAttempts) {
            removeFilesAndConnections()
            appViewState.resetApp()
        }
    }
    
    private func loadData() {
        appViewState.homeViewModel.loadData()
            .subscribe(on: DispatchQueue.global(qos: .userInteractive))
            .receive(on: DispatchQueue.main)
            .sink { recoverResult in
                self.isLoading = false
                self.appViewState.showMainView()
            }.store(in: &self.cancellables)
    }
    
    func initKeys(passwordTypeEnum:PasswordTypeEnum) {
        appModel.vaultManager.initKeys(passwordTypeEnum,
                                       password: password)
    }
    
    func updateKeys(passwordTypeEnum:PasswordTypeEnum) {
        appModel.vaultManager.updateKeys(passwordTypeEnum,
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
        DispatchQueue.main.async {
            self.appModel.settings.unlockAttempts = 0
            self.appModel.saveSettings()
        }
    }
    
    func increaseUnlockAttempts () -> Void {
        appModel.settings.unlockAttempts = appModel.settings.unlockAttempts + 1
        appModel.saveSettings()
    }
    
    func removeFilesAndConnections () -> Void {
        appModel.deleteAfterMaxAttempts()
    }
}

extension LockViewModel {
    static func stub() -> LockViewModel {
        return LockViewModel(unlockType: .new, appViewState: AppViewState())
    }
}

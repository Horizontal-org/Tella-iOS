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

enum LockType {
    case pin
    case password
    case none
}

@MainActor
class LockViewModel: ObservableObject {
    
    @Published var loginPassword : String = ""
    @Published var password : String = ""
    @Published var confirmPassword : String = ""
    @Published var oldPassword : String = ""
    @Published var shouldShowUnlockError : Bool = false
    @Published var unlockAttempts : Int
    var maxAttempts : Int
    
    private var subscribers = Set<AnyCancellable>()
    
    var lockFlow: LockFlow = .new
    var lockType: LockType = .none
    
    var shouldDismiss = CurrentValueSubject<Bool, Never>(false)
    var mainAppModel:MainAppModel
    var appViewState: AppViewState
    
    @Published var isLoading : Bool = false
    @Published var presentingLockChoice : Bool = false
    
    
    var unlockKeyboardNumbers: [PinKeyboardModel] = { [
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
        password != confirmPassword
    }
    
    var shouldShowAttemptsWarning : Bool {
        maxAttempts - unlockAttempts <= 3 && mainAppModel.settings.showUnlockAttempts && mainAppModel.settings.deleteAfterFail != .off
    }
    
    func remainingAttempts() -> Int {
        maxAttempts - unlockAttempts
    }
    
    init(lockFlow: LockFlow, appViewState:AppViewState) {
        self.lockFlow = lockFlow
        self.mainAppModel = appViewState.homeViewModel
        self.appViewState = appViewState
        
        self.unlockAttempts = mainAppModel.settings.unlockAttempts
        self.maxAttempts = mainAppModel.settings.deleteAfterFail.numberOfAttempts
        
        setupSettingsObservations()
    }
    
    func resetMaxAttempts() {
        self.unlockAttempts = mainAppModel.settings.unlockAttempts
        self.maxAttempts = mainAppModel.settings.deleteAfterFail.numberOfAttempts
    }
    
    private func setupSettingsObservations() {
        mainAppModel.settings.$deleteAfterFail
            .map({ $0.numberOfAttempts })
            .assign(to: \.maxAttempts, on: self)
            .store(in: &subscribers)
        
        mainAppModel.settings.$unlockAttempts
            .assign(to: \.unlockAttempts, on: self)
            .store(in: &subscribers)
    }
    
    func login() {
        isLoading = true
        
        self.mainAppModel.vaultManager.login(password: self.loginPassword)
            .subscribe(on: DispatchQueue.global(qos: .userInteractive))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] authorized in
                guard let self = self else { return }
                self.isLoading = false
                if authorized {
                    self.successLogin()
                } else {
                    self.checkUnlockAttempts()
                }
            }.store(in: &self.subscribers)
    }
    
    private func successLogin() {
        resetUnlockAttempts()
        if  lockFlow == .new {
            loadData()
        } else {
            presentingLockChoice = true
            DispatchQueue.main.async() {
                self.presentingLockChoice = false
            }
        }
    }
    
    private func checkUnlockAttempts() {
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
            }.store(in: &self.subscribers)
    }
    
    func initKeys(passwordTypeEnum:PasswordTypeEnum) {
        mainAppModel.vaultManager.initKeys(passwordTypeEnum,
                                           password: password)
    }
    
    func updateKeys(passwordTypeEnum:PasswordTypeEnum) {
        mainAppModel.vaultManager.updateKeys(passwordTypeEnum,
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
    
    func resetUnlockAttempts () {
        DispatchQueue.main.async {
            self.mainAppModel.settings.unlockAttempts = 0
            self.mainAppModel.saveSettings()
        }
    }
    
    func increaseUnlockAttempts () {
        mainAppModel.settings.unlockAttempts = mainAppModel.settings.unlockAttempts + 1
        mainAppModel.saveSettings()
    }
    
    func removeFilesAndConnections () {
        mainAppModel.deleteAfterMaxAttempts()
    }
}

extension LockViewModel {
    static func stub() -> LockViewModel {
        return LockViewModel(lockFlow: .new, appViewState: AppViewState())
    }
}

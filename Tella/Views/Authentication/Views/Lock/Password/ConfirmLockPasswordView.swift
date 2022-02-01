//
//  ConfirmLPasswordView.swift
//  Tella
//
//   
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct ConfirmLockPasswordView: View {
    
    @EnvironmentObject private var appViewState: AppViewState
    @State var shouldShowErrorMessage : Bool = false
    @EnvironmentObject var lockViewModel: LockViewModel
    
    
    var body: some View {
        
        PasswordView(lockViewData: LockConfirmPasswordData(),
                     nextButtonAction: .action,
                     fieldContent: $lockViewModel.confirmPassword,
                     shouldShowErrorMessage: $shouldShowErrorMessage,
                     destination: EmptyView()) {
            
            if lockViewModel.shouldShowErrorMessage {
                shouldShowErrorMessage = true
            } else {
                lockViewModel.unlockType == .new ? lockWithPassword() :  updatePassword()
            }
        }
    }

    func lockWithPassword() {
        do {
            try CryptoManager.shared.initKeys(.TELLA_PASSWORD, password: lockViewModel.password)
            _ = CryptoManager.shared.recoverKey(.PRIVATE, password: lockViewModel.password)
            self.appViewState.resetToMain()
        } catch {
            
        }
    }
    
    func updatePassword() {
        do {
            print(lockViewModel.password)
            guard let privateKey = lockViewModel.privateKey else { return }
            try CryptoManager.shared.updateKeys(privateKey, .TELLA_PASSWORD, newPassword: lockViewModel.password, oldPassword: lockViewModel.loginPassword)
            lockViewModel.shouldDismiss.send(true)
            
        } catch {
            
        }
    }
    
}

struct ConfirmLPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmLockPasswordView()
    }
}

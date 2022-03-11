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
    @State var shouldShowOnboarding : Bool = false
    
    
    var body: some View {
        ZStack {
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
            
            onboardingLink
        }
    }
    
    func lockWithPassword() {
        do {
            try CryptoManager.shared.initKeys(.TELLA_PASSWORD, password: lockViewModel.password)
            _ = CryptoManager.shared.recoverKey(.PRIVATE, password: lockViewModel.password)
            
            shouldShowOnboarding = true
            
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
    
    private var onboardingLink: some View {
        NavigationLink(destination:
                        
                        OnboardingEndView() ,
                       isActive: $shouldShowOnboarding) {
            EmptyView()
        }.frame(width: 0, height: 0)
            .hidden()
    }
}

struct ConfirmLPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmLockPasswordView()
    }
}

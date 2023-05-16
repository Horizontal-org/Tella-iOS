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
        }.navigationBarBackButtonHidden(true)
    }
    
    func lockWithPassword() {
        do {
            try AuthenticationManager().initKeys(.tellaPassword, password: lockViewModel.password)

            shouldShowOnboarding = true
            
        } catch {
            
        }
    }
    
    func updatePassword() {
        do {
            guard let privateKey = lockViewModel.privateKey else { return }
            try AuthenticationManager().updateKeys(privateKey, .tellaPassword, newPassword: lockViewModel.password, oldPassword: lockViewModel.loginPassword)
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

//
//  ConfirmLPasswordView.swift
//  Tella
//
//   
//  Copyright © 2021 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct ConfirmLockPasswordView: View {

    @State var shouldShowErrorMessage : Bool = false
    @ObservedObject var lockViewModel: LockViewModel
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
        }
    }
    
    func lockWithPassword() {
        lockViewModel.initKeys(passwordTypeEnum: .tellaPassword)
        lockViewModel.shouldDismiss.send(true)
    }
    
    func updatePassword() {
        lockViewModel.updateKeys(passwordTypeEnum: .tellaPassword)
        lockViewModel.shouldDismiss.send(true)
    }
}

struct ConfirmLPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmLockPasswordView(lockViewModel: LockViewModel.stub())
    }
}

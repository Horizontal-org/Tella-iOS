//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct LockConfirmPinView: View {
    
    @EnvironmentObject private var appViewState: AppViewState
    @EnvironmentObject var lockViewModel: LockViewModel
    @State var shouldShowErrorMessage : Bool = false
    
    var body: some View {
        ZStack {
            CustomPinView(lockViewData: LockConfirmPinData(),
                          nextButtonAction: .action,
                          fieldContent: $lockViewModel.confirmPassword,
                          shouldShowErrorMessage: $shouldShowErrorMessage,
                          destination: EmptyView()) {
                
                if lockViewModel.shouldShowErrorMessage {
                    shouldShowErrorMessage = true
                } else {
                    lockViewModel.unlockType == .new ? self.lockWithPin() : self.updatePin()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    func lockWithPin() {
        do {
            try AuthenticationManager().initKeys(.tellaPin,
                                                 password: lockViewModel.password)
            navigateTo(destination: OnboardingEndView())
            
        } catch {
            
        }
    }
    
    func updatePin() {
        do {
            guard let privateKey = lockViewModel.privateKey else { return }
            try AuthenticationManager().updateKeys(privateKey, .tellaPin,
                                                   newPassword: lockViewModel.password,
                                                   oldPassword: lockViewModel.loginPassword)
            lockViewModel.shouldDismiss.send(true)
        } catch {
            
        }
    }
    
}

struct LockConfirmPinView_Previews: PreviewProvider {
    static var previews: some View {
        LockConfirmPinView().environmentObject(AppViewState())
    }
}

//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct LockConfirmPinView: View {
    
    @EnvironmentObject private var appViewState: AppViewState
    @EnvironmentObject var lockViewModel: LockViewModel
    
    @State var shouldShowOnboarding : Bool = false
    @State var shouldShowErrorMessage : Bool = false
    @State var message : String = Localizable.Lock.confirmPinFirstMessage
    
    var body: some View {
        ZStack {
            CustomPinView(nextButtonAction: .action,
                          fieldContent: $lockViewModel.confirmPassword,
                          shouldShowErrorMessage: $shouldShowErrorMessage,
                          message: $message,
                          destination: EmptyView()) {
                
                if lockViewModel.shouldShowErrorMessage {
                    message = Localizable.Lock.confirmPinError
                } else {
                    lockViewModel.unlockType == .new ? self.lockWithPin() : self.updatePin()
                }
            }
            onboardingLink
        }
    }
    
    func lockWithPin() {
        do {
            try AuthenticationManager().initKeys(.tellaPin,
                                                 password: lockViewModel.password)
            shouldShowOnboarding = true
            
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
    
    private var onboardingLink: some View {
        NavigationLink(destination: OnboardingEndView() ,
                       isActive: $shouldShowOnboarding) {
            EmptyView()
        }.frame(width: 0, height: 0)
            .hidden()
    }
    
}

struct LockConfirmPinView_Previews: PreviewProvider {
    static var previews: some View {
        LockConfirmPinView().environmentObject(AppViewState())
    }
}

//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct LockConfirmPinView: View {
    
    @EnvironmentObject private var appViewState: AppViewState
    @State var shouldShowErrorMessage : Bool = false
    @EnvironmentObject var lockViewModel: LockViewModel
    @State var shouldShowOnboarding : Bool = false
    
    var body: some View {
        
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
        
        onboardingLink
    }
    
    func lockWithPin() {
        do {
            try CryptoManager.shared.initKeys(.TELLA_PIN,
                                              password: lockViewModel.password)
            _ = CryptoManager.shared.recoverKey(.PRIVATE, password: lockViewModel.password)

            shouldShowOnboarding = true

        } catch {
            
        }
    }
    
    func updatePin() {
        do {
            guard let privateKey = lockViewModel.privateKey else { return }
            try CryptoManager.shared.updateKeys(privateKey, .TELLA_PIN,
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

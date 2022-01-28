//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct LockConfirmPinView: View {
    
    @EnvironmentObject private var appViewState: AppViewState
    @State var shouldShowErrorMessage : Bool = false
    @EnvironmentObject var lockViewModel: LockViewModel
    
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
    }
    
    func lockWithPin() {
        do {
            try CryptoManager.shared.initKeys(.TELLA_PIN,
                                              password: lockViewModel.password)
            self.appViewState.resetToMain()
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
}

struct LockConfirmPinView_Previews: PreviewProvider {
    static var previews: some View {
        LockConfirmPinView().environmentObject(AppViewState())
    }
}

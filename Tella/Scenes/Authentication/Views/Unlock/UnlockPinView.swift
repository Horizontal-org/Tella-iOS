//  Tella
//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct UnlockPinView: View {
    
    @EnvironmentObject private var appViewState: AppViewState
    @EnvironmentObject private var lockViewModel: LockViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var message = ""

    @State private var presentingPinView : Bool = false
    
    var body: some View {
        ZStack {
            CustomCalculatorView(fieldContent: $lockViewModel.loginPassword,
                                 message: $message,
                                 isValid: $lockViewModel.isValid,
                                 nextButtonAction: .action,
                                 destination: EmptyView(),
                                 shouldValidateField: lockViewModel.shouldValidateField) {
                
                lockViewModel.login()
                updateMessage()
                if !lockViewModel.shouldShowUnlockError {
                    if lockViewModel.unlockType == .new {
                        appViewState.resetToMain()
                    } else {
                        presentingPinView = true
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $presentingPinView) {
            self.presentationMode.wrappedValue.dismiss()
            
        } content: {
            LockPinView(message: Localizable.Lock.lockUnlockLockPinUpdateBannerExpl)
        }
        
        .onReceive(lockViewModel.shouldDismiss) { shouldDismiss in
            if shouldDismiss {
                self.presentingPinView = false
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        .onAppear {
            updateMessage()
            lockViewModel.initUnlockData()
        }
    }
    
    func updateMessage()  {
        if lockViewModel.shouldValidateField   {
            if lockViewModel.shouldShowUnlockError {
                message = Localizable.Lock.errorIncorrectPINBannerExpl
            } else {
                message = Localizable.Lock.lockUnlockUnlockPinUpdateBannerExpl
            }
        }
    }
}

struct UnlockPinView_Previews: PreviewProvider {
    static var previews: some View {
        UnlockPinView()
    }
}

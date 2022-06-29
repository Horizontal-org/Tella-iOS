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
            CustomCalculatorView(value: $lockViewModel.calculatorValue,
                                 result: $lockViewModel.loginPassword,
                                 message: $message,
                                 isValid: lockViewModel.unlockType == .update ? $lockViewModel.isValid : .constant(true),
                                 operationArray: $lockViewModel.operationArray,
                                 calculatorType: lockViewModel.unlockType == .new ? .calculator : .pin,
                                 nextButtonAction: .action,
                                 destination: EmptyView()) {
                
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
            LockPinView(message: LocalizableLock.lockUnlockLockPinUpdateBannerExpl.localized)
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
        if lockViewModel.unlockType == .update   {
            if lockViewModel.shouldShowUnlockError {
                message = LocalizableLock.errorIncorrectPINBannerExpl.localized
            } else {
                message = LocalizableLock.lockUnlockUnlockPinUpdateBannerExpl.localized
            }
        }
    }
}

struct UnlockPinView_Previews: PreviewProvider {
    static var previews: some View {
        UnlockPinView()
    }
}

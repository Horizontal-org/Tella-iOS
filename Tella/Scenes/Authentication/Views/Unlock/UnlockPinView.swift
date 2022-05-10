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
    @State private var isValid : Bool = true
    @State private var presentingLockChoice : Bool = false

    var body: some View {
        ZStack {
            CustomCalculatorView(fieldContent: $lockViewModel.loginPassword,
                          message: $message,
                          isValid: $isValid,
                          nextButtonAction: .action,
                          destination: EmptyView()) {
                
                lockViewModel.login()
                updateMessage()
                if !lockViewModel.shouldShowUnlockError {
                    if lockViewModel.unlockType == .new   {
                        appViewState.resetToMain()
                    } else {
                        presentingLockChoice = true
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $presentingLockChoice) {
            self.presentationMode.wrappedValue.dismiss()
            
        } content: {
            LockPinView(message: Localizable.Lock.updatePinFirstMessage)
        }
        
        .onReceive(lockViewModel.shouldDismiss) { shouldDismiss in
            if shouldDismiss {
                self.presentingLockChoice = false
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        .onAppear {
            updateMessage()
            lockViewModel.initUnlockData()
        }
    }
    
    func updateMessage()  {
        if lockViewModel.shouldShowUnlockError {
            message =  Localizable.Lock.unlockPinError
        } else {
            message = lockViewModel.unlockType == .new ? "" : Localizable.Lock.unlockUpdatePinFirstMessage
        }
    }
}

struct UnlockPinView_Previews: PreviewProvider {
    static var previews: some View {
        UnlockPinView()
    }
}

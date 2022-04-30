//
//  UnlockPinView.swift
//  Tella
//
//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct UnlockPinView: View {
    
    @State private var presentingLockChoice : Bool = false
    
    @EnvironmentObject private var appViewState: AppViewState
    @EnvironmentObject private var lockViewModel: LockViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var message = ""
    
    
    var body: some View {
        ZStack {
            CustomPinView(nextButtonAction: .action,
                          fieldContent: $lockViewModel.loginPassword,
                          shouldShowErrorMessage: .constant(false),
                          message: $message,
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

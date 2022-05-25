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
    @EnvironmentObject private var viewModel: LockViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    
    var body: some View {
        ContainerView {
            VStack(alignment: .center) {
                Spacer(minLength: 30)
                
                Image("tella.logo")
                    .frame(width: 65, height: 72)
                    .aspectRatio(contentMode: .fit)
                
                Spacer(minLength: 23)
                
                Text(titleString)
                    .font(.custom(Styles.Fonts.semiBoldFontName, size: 18))
                    .foregroundColor(.white)
                    .lineSpacing(7)
                    .multilineTextAlignment(.center)
                    .padding(EdgeInsets(top: 0, leading: 67, bottom: 0, trailing: 67))
                
                Spacer()
                
                PasswordTextFieldView(fieldContent: $viewModel.loginPassword,
                                      isValid: .constant(true),
                                      shouldShowErrorMessage: .constant(false),
                                      shouldShowError: $viewModel.shouldShowUnlockError,
                                      disabled: true)
                
                Spacer(minLength: 20)
                
                PinView(fieldContent: $viewModel.loginPassword,
                        keyboardNumbers: UnlockKeyboardNumbers) {
                    viewModel.login()
                    if !viewModel.shouldShowUnlockError {
                        if viewModel.unlockType == .new   {
                            appViewState.resetToMain()
                        } else {
                            presentingLockChoice = true
                        }
                    }
                }
                
                Spacer()
            }
        }
        .fullScreenCover(isPresented: $presentingLockChoice) {
            self.presentationMode.wrappedValue.dismiss()
            
        } content: {
            LockChoiceView( isPresented: $presentingLockChoice)
        }
        
        .onReceive(viewModel.shouldDismiss) { shouldDismiss in
            if shouldDismiss {
                self.presentingLockChoice = false
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        .onAppear {
            viewModel.initUnlockData()
        }
    }
    
    var titleString : String {
        if viewModel.shouldShowUnlockError {
            return  Localizable.Lock.unlockUpdatePinErrorIncorrectPIN
        } else {
            return viewModel.unlockType == .new ? Localizable.Lock.unlockPinSubhead : Localizable.Lock.unlockUpdatePinSubhead
        }
    }
}

struct UnlockPinView_Previews: PreviewProvider {
    static var previews: some View {
        UnlockPinView()
    }
}

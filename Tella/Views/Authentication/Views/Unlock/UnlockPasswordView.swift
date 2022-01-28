//
//  UnlockPasswordView.swift
//  Tella
//
//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

enum UnlockType {
    case new
    case update
}

struct UnlockPasswordView: View {
    
    @EnvironmentObject private var viewModel: LockViewModel

    @EnvironmentObject private var appViewState: AppViewState
    @State private var presentingLockChoice : Bool = false
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        ContainerView {
            VStack(alignment: .center) {
                Spacer(minLength: 56)
                
                Image("tella.logo")
                    .frame(width: 65, height: 72)
                    .aspectRatio(contentMode: .fit)
                
                Spacer()
                    .frame(height: 50)
                
                Text(titleString)
                    .font(.custom(Styles.Fonts.regularFontName, size: 18))
                    .foregroundColor(.white)
                    .lineSpacing(7)
                    .multilineTextAlignment(.center)
                    .padding(EdgeInsets(top: 0, leading: 67, bottom: 0, trailing: 67))
                
                Spacer()
                    .frame(height: 73)
                
                PasswordTextFieldView(fieldContent: $viewModel.loginPassword,
                                      isValid: .constant(true),
                                      shouldShowErrorMessage: .constant(false),
                                      shouldShowError: $viewModel.shouldShowUnlockError) {
                    viewModel.login()
                    if !viewModel.shouldShowUnlockError {
                        if viewModel.unlockType == .new {
                            appViewState.resetToMain()
                        } else {
                            presentingLockChoice = true
                        }
                    }
                }
                Spacer()
            }
            
            .fullScreenCover(isPresented: $presentingLockChoice) {
                self.presentationMode.wrappedValue.dismiss()
            } content: {
                LockChoiceView( isPresented: $presentingLockChoice)
            }
            
        }
        .onReceive(viewModel.shouldDismiss) { shouldDismiss in
            if shouldDismiss {
                self.presentingLockChoice = false
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        .onAppear {
            viewModel.initData()
        }
    }
    
    var titleString : String {
        if viewModel.shouldShowUnlockError {
            return  LocalizableLock.unlockPasswordError.localized
        } else {
            return viewModel.unlockType == .new ? LocalizableLock.unlockPasswordTitle.localized : LocalizableLock.unlockUpdatePasswordTitle.localized
        }
        
    }
}



struct UnlockPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        UnlockPasswordView()
    }
}

//
//  UnlockPinView.swift
//  Tella
//
//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct UnlockPinView: View {
    
    @StateObject var viewModel = LockViewModel()
    @EnvironmentObject private var appViewState: AppViewState
    
    var body: some View {
        ContainerView {
            VStack(alignment: .center) {
                Spacer(minLength: 56)
                
                Image("lock.tella.logo")
                    .frame(width: 65, height: 72)
                    .aspectRatio(contentMode: .fit)
                
                Spacer()
                    .frame(height: 50)
                
                Text(viewModel.shouldShowUnlockError ? LocalizableLock.unlockPinError.localized : LocalizableLock.unlockPinTitle.localized)
                    .font(.custom(Styles.Fonts.regularFontName, size: 18))
                    .foregroundColor(.white)
                    .lineSpacing(7)
                    .multilineTextAlignment(.center)
                    .padding(EdgeInsets(top: 0, leading: 67, bottom: 0, trailing: 67))
                
                Spacer()
                    .frame(height: 53)
                
                PasswordTextFieldView(fieldContent: $viewModel.password,
                                      isValid: .constant(true),
                                      shouldShowErrorMessage: .constant(false),
                                      shouldShowError: $viewModel.shouldShowUnlockError,
                                      disabled: true)
                
                Spacer(minLength: 20)
                
                PinView(fieldContent: $viewModel.password,
                        keyboardNumbers: UnlockKeyboardNumbers) {
                    viewModel.login()
                    if !viewModel.shouldShowUnlockError {
                        appViewState.resetToMain()
                    }
                    
                }
                
                Spacer()
            }
        }
    }}

struct UnlockPinView_Previews: PreviewProvider {
    static var previews: some View {
        UnlockPinView()
    }
}

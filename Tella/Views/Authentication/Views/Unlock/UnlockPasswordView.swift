//
//  UnlockPasswordView.swift
//  Tella
//
//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct UnlockPasswordView: View {
    
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
                
                Text(viewModel.shouldShowUnlockError ? LocalizableLock.unlockPasswordError.localized : LocalizableLock.unlockPasswordTitle.localized)
                    .font(.custom(Styles.Fonts.regularFontName, size: 18))
                    .foregroundColor(.white)
                    .lineSpacing(7)
                    .multilineTextAlignment(.center)
                    .padding(EdgeInsets(top: 0, leading: 67, bottom: 0, trailing: 67))
                
                Spacer()
                    .frame(height: 73)
                
                PasswordTextFieldView(fieldContent: $viewModel.password,
                                      isValid: .constant(true),
                                      shouldShowErrorMessage: .constant(false),
                                      shouldShowError: $viewModel.shouldShowUnlockError) {
                    viewModel.login()
                    if !viewModel.shouldShowUnlockError {
                        appViewState.resetToMain()
                    }
                }
                Spacer()
            }
        }
    }}

struct UnlockPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        UnlockPasswordView()
    }
}

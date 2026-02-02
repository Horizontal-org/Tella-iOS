//
//  AuthenticationView.swift
//  Tella
//
//
//  Copyright © 2021 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct LockChoiceView: View {
    
    var lockViewModel : LockViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        Group {
            if lockViewModel.lockFlow == .update {
                ContainerViewWithHeader {
                    navigationBarView
                } content: {
                    contentView
                }
            } else {
                contentView
            }
        }
    }
    
    var navigationBarView: some View {
        NavigationHeaderView(title: LocalizableLock.lockSelectTitle.localized,
                             backButtonType: .close,
                             backButtonAction: {self.popTo(ViewClassType.securitySettingsView)})
    }
    
    var contentView: some View {
        VStack {
            
            VStack(alignment: .center, spacing: 24) {
                Spacer()
                Image("lock.phone")
                    .frame(width: 60, height: 100)
                    .aspectRatio(contentMode: .fit)
                
                Text(LocalizableLock.lockSelectSubhead.localized)
                    .font(.custom(Styles.Fonts.boldFontName, size: 18))
                    .foregroundColor(.white)
                
                VStack(spacing: 15) {
                    
                    IconTextButton(buttonConfig: PasswordLockButton(),
                                   destination: LoseFilesWarningOnboardingView(lockViewModel: lockViewModel)) {
                        lockViewModel.lockType = .password
                    }
                    
                    IconTextButton(buttonConfig: PINLockButton(),
                                   destination: LoseFilesWarningOnboardingView(lockViewModel: lockViewModel)) {
                        lockViewModel.lockType = .pin
                    }
                }
                Spacer()
            }
            .padding(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24))
        }
    }
}

struct LockChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        LockChoiceView(lockViewModel: LockViewModel.stub())
    }
}

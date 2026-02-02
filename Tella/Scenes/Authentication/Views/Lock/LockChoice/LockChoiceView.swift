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

struct LockButtonView<Destination:View> : View {
    
    var lockButtonProtocol : LockButtonProtocol
    var destination : Destination
    var presentationType : ViewPresentationType = .push
    var action: (() -> ())?
    
    var body: some View {
        
        Button {
            if let action {
                action()
            }
            if presentationType == .present {
                self.present(style: .fullScreen, transitionStyle: .crossDissolve) {
                    CustomNavigation() {
                        destination
                    }
                }
            } else {
                navigateTo(destination: destination)
            }
            
        } label: {
            HStack(spacing: 20) {
                
                Image(lockButtonProtocol.imageName)
                    .frame(width: 42, height: 42)
                    .aspectRatio(contentMode: .fit)
                
                VStack(alignment:.leading, spacing: 3 ) {
                    Text(lockButtonProtocol.title)
                        .font(.custom(Styles.Fonts.boldFontName, size: 16))
                        .foregroundColor(.white)
                    
                    Text(lockButtonProtocol.description)
                        .font(.custom(Styles.Fonts.regularFontName, size: 13.5))
                        .foregroundColor(.white)
                }
                Spacer()
            } .padding(16)
                .background( Color.white.opacity(0.16))
                .cornerRadius(20)
                .buttonStyle(LockButtonStyle())
        }
    }
}

struct LockButtonStyle : ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.white.opacity(0.32) : Color.white.opacity(0.16))
            .cornerRadius(20)
            .overlay(
                configuration.isPressed ? RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.8), lineWidth: 3) :  RoundedRectangle(cornerRadius: 20).stroke(Color.clear, lineWidth: 0)
            )
    }
}

struct LockChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        LockChoiceView(lockViewModel: LockViewModel.stub())
    }
}

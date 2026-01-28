//
//  PasswordView.swift
//  Tella
//
//
//  Copyright © 2021 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI
import UIKit
import Combine

enum NextButtonAction {
    case action
    case destination
}

struct PasswordView<T:LockViewProtocol, Destination:View>: View   {
    var shouldEnableBackButton : Bool = true
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var isValid : Bool = false
    
    var lockViewData : T
    var nextButtonAction: NextButtonAction
    @Binding var fieldContent : String
    @Binding var shouldShowErrorMessage : Bool
    var destination: Destination?
    var action : (() -> Void)?
    
    var body: some View {
        ContainerView {
            VStack(alignment: .center) {
                Spacer(minLength: 56)
                
                Image("lock.password.B")
                    .frame(width: 120, height: 37)
                    .aspectRatio(contentMode: .fit)
                
                Spacer()
                    .frame(height: 50)
                
                LockDescriptionView(title: lockViewData.title,
                                    description: lockViewData.description,
                                    alignement: lockViewData.alignement)
                
                Spacer()
                
                PasswordTextFieldView(fieldContent: $fieldContent,
                                      isValid: $isValid,
                                      shouldShowError: .constant(false))
                Spacer()
                
                BottomLockView(isValid: $isValid,
                               shouldEnableBackButton: shouldEnableBackButton,
                               nextButtonAction: nextButtonAction,
                               destination:destination,
                               nextAction: action, backAction: {
                    self.presentationMode.wrappedValue.dismiss()
                })
            }
        }.navigationBarHidden(true)
            .onChange(of: shouldShowErrorMessage) { newValue in
                guard newValue else { return }
                Toast.displayToast(message: LocalizableLock.lockPasswordConfirmErrorPasswordsDoNotMatch.localized)
                shouldShowErrorMessage = false
            }
            .onChange(of: fieldContent) { _ in
                shouldShowErrorMessage = false
            }
    }
}

struct PasswordView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordView(lockViewData: LockPasswordData(action: {}),
                     nextButtonAction: .action,
                     fieldContent: .constant(""),
                     shouldShowErrorMessage: .constant(false),
                     destination: EmptyView())
    }
}

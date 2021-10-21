//
//  PasswordView.swift
//  Tella
//
//   
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI
import UIKit

enum NextButtonAction {
    case action
    case destination
}

struct PasswordView<T:LockViewProtocol, Destination:View>: View   {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var isValid : Bool = false
    @State private var shouldResetView : Bool = false
    
    var lockViewData : T
    var nextButtonAction: NextButtonAction
    @Binding var fieldContent : String
    @Binding var shouldShowError : Bool
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
                
                LockDescriptionView(title: lockViewData.title, description: lockViewData.description)
                
                Spacer()
                
                PasswordTextFieldView(fieldContent: $fieldContent,
                                      isValid: $isValid,
                                      shouldShowError: $shouldShowError)
                Spacer()
                
                if shouldShowError {
                    ConfirmPasswordErrorView()
                }
                
                BottomLockView(isValid: $isValid,
                               nextButtonAction: nextButtonAction,
                               destination:destination,
                               nextAction: action, backAction: {
                    self.presentationMode.wrappedValue.dismiss()
                })
            }        
        }
    }
}

struct PasswordView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordView(lockViewData: LockPasswordData(action: {}),
                     nextButtonAction: .action,
                     fieldContent: .constant(""),
                     shouldShowError: .constant(false),
                     destination: EmptyView())
    }
}

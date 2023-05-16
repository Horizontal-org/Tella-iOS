//
//  CustomPinView.swift
//  Tella
//
//  
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct CustomPinView<T:LockViewProtocol, Destination:View>: View   {
    
    var shouldEnableBackButton : Bool  = true

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
                Spacer(minLength: 20)
                
                Image("lock.pin.B")
                    .frame(width: 64, height: 64)
                    .aspectRatio(contentMode: .fit)
                
                Spacer()
                
                LockDescriptionView(title: lockViewData.title,
                                    description: lockViewData.description,
                                    alignement: lockViewData.alignement)
                
                Spacer()
                PasswordTextFieldView(fieldContent: $fieldContent,
                                      isValid: $isValid,
                                      shouldShowError: .constant(false),
                                      disabled: true)
                
                Spacer(minLength: 20)

                PinView(fieldContent: self.$fieldContent,
                        keyboardNumbers: LockKeyboardNumbers)
                
                Spacer()
                
                VStack {
                    if shouldShowErrorMessage   {
                        ConfirmPasswordErrorView(errorMessage: LocalizableLock.lockPinConfirmErrorPINsDoNotMatch.localized)
                        Spacer()
                    }
                    
                    BottomLockView(isValid: $isValid,
                                   shouldEnableBackButton: shouldEnableBackButton,
                                   nextButtonAction: nextButtonAction,
                                   destination:destination,
                                   nextAction: action, backAction: {
                        self.presentationMode.wrappedValue.dismiss()
                    })
                }
            }
        }
    }
}

struct CustomPinView_Previews: PreviewProvider {
    static var previews: some View {
        CustomPinView(lockViewData: LockPinData(),
                      nextButtonAction: .action,
                      fieldContent: .constant(""),
                      shouldShowErrorMessage: .constant(false),
                      destination: EmptyView()
        )
    }
}


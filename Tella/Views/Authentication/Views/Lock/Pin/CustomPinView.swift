//
//  CustomPinView.swift
//  Tella
//
//  
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct CustomPinView<T:LockViewProtocol, Destination:View>: View   {
    
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
                Spacer(minLength: 20)
                
                Image("lock.pin.B")
                    .frame(width: 64, height: 64)
                    .aspectRatio(contentMode: .fit)
                
                Spacer()
                    .frame(height: 25)
                
                LockDescriptionView(title: lockViewData.title,
                                    description: lockViewData.description)
                
                Spacer()
                PasswordTextFieldView(fieldContent: $fieldContent,
                                      isValid: $isValid,
                                      shouldShowError: $shouldShowError,
                                      disabled: true)
                
                Spacer(minLength: 20)

                PinView(fieldContent: self.$fieldContent,
                        keyboardNumbers: LockKeyboardNumbers)
                
                Spacer()
                VStack {
                    if shouldShowError   {
                        ConfirmPasswordErrorView()
                        Spacer()
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
}

struct CustomPinView_Previews: PreviewProvider {
    static var previews: some View {
        CustomPinView(lockViewData: LockPinData(),
                      nextButtonAction: .action,
                      fieldContent: .constant(""),
                      shouldShowError: .constant(false),
                      destination: EmptyView()
        )
    }
}


//
//  CustomCalculatorView.swift
//  Tella
//
//  
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

enum NextButtonAction {
    case action
    case destination
}

struct CustomCalculatorView<Destination:View>: View   {
    
    @State private var shouldShowLockConfirmPinView = false
    
    @Binding var fieldContent : String
    @Binding var message : String
    @Binding var isValid : Bool
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var nextButtonAction: NextButtonAction
    var destination: Destination?
    var shouldValidateField: Bool = true
    
    var action : (() -> Void)?
    
    var body: some View {
        
        NavigationContainerView(backgroundColor: .white) {
            
            VStack(alignment: .center) {
                
                Spacer()
                    .frame(height: 22)
                
                topCalculatorMessageView
                
                Spacer()
                
                passwordTextView
                
                Spacer()
                    .frame(height: 22)
                
                pinView
                
                Spacer()
                    .frame(height: 25)
            }
            
            confirmPinViewLink
        }
    }
    
    @ViewBuilder
    private var topCalculatorMessageView : some View {
        if !message.isEmpty {
            TopCalculatorMessageView(text: message)
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        }
    }
    
    private var passwordTextView : some View {
        PasswordTextView(fieldContent: $fieldContent,
                         isValid: $isValid,
                         shouldValidateField: shouldValidateField,
                         disabled: true)
        .padding(EdgeInsets(top: 0, leading: 13, bottom: 0, trailing: 13))
    }
    
    private var pinView : some View {
        CalculatorView(fieldContent: $fieldContent,
                       message: $message,
                       isValid: $isValid,
                       shouldValidateField: shouldValidateField,
                       action: {
            
            if nextButtonAction == .destination {
                shouldShowLockConfirmPinView = true
            } else {
                action?()
            }
        })
    }
    
    private var confirmPinViewLink: some View {
        NavigationLink(destination: LockConfirmPinView() ,
                       isActive: $shouldShowLockConfirmPinView) {
            EmptyView()
        }.frame(width: 0, height: 0)
            .hidden()
    }
}

struct CustomPinView_Previews: PreviewProvider {
    static var previews: some View {
        CustomCalculatorView(fieldContent: .constant("ACn"),
                             message: .constant(Localizable.Lock.lockPinSetBannerExpl),
                             isValid: .constant(false),
                             nextButtonAction: .action,
                             destination: EmptyView())
    }
}

//
//  CustomPinView.swift
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

struct CustomPinView<Destination:View>: View   {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var isValid : Bool = false
    @State private var shouldShowLockConfirmPinView = false
    var nextButtonAction: NextButtonAction
    
    @Binding var fieldContent : String
    @Binding var shouldShowErrorMessage : Bool
    @Binding var message : String
    
    var destination: Destination?
    var action : (() -> Void)?
    
    
    var body: some View {
        NavigationContainerView(backgroundColor: .white) {
            
            VStack(alignment: .center) {
                
                Spacer()
                    .frame( height: 22)
                
                if !message.isEmpty {
                    TopCalculatorMessageView(text: message)
                        .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                }
                
                Spacer()
                
                PasswordTextView(fieldContent: $fieldContent,
                                 isValid: $isValid,
                                 shouldShowErrorMessage: $shouldShowErrorMessage,
                                 shouldShowError: .constant(false),
                                 disabled: true)
                .padding(EdgeInsets(top: 0, leading: 13, bottom: 0, trailing: 13))
                
                Spacer( )
                    .frame(height: 25)
                
                PinView(fieldContent: $fieldContent,
                        message: $message,
                        isValid: $isValid,
                        action: {
                    
                    if nextButtonAction == .destination {
                        shouldShowLockConfirmPinView = true
                    } else {
                        action?()
                    }
                    
                })
                
                Spacer()
                    .frame(height: 25)
            }
            
            confirmPinViewLink
        }
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
        CustomPinView(nextButtonAction: .action,
                      fieldContent: .constant("ACn"),
                      shouldShowErrorMessage: .constant(false),
                      message: .constant(Localizable.Lock.pinFirstMessage),
                      destination: EmptyView())
    }
}

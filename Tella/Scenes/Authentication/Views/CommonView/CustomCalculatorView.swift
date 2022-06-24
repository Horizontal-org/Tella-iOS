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

struct CustomCalculatorView<Destination:View>: View {
    
    @State private var shouldShowLockConfirmPinView = false
    
    @Binding var value : String
    @Binding var result : String
    @Binding var message : String
    @Binding var isValid : Bool
    @Binding var operationArray : [String]

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var calculatorType : CalculatorType
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

                Text(value)
                    .font(.custom(Styles.Fonts.lightFontName, size: 24))
                    .foregroundColor(Color.init(red: 0.331, green: 0.348, blue: 0.339))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(EdgeInsets(top: 0, leading: 13, bottom: 0, trailing: 13))
                    .lineLimit(3)

                Spacer()
                    .frame(height: 5)
                
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
        PasswordTextView(fieldContent: $result,
                         isValid: $isValid,
                         shouldValidateField: shouldValidateField,
                         disabled: true)
        .padding(EdgeInsets(top: 0, leading: 13, bottom: 0, trailing: 13))
    }
    
    private var pinView : some View {
        CalculatorView(currentOperation: $value,
                       resultToshow: $result,
                       message: $message,
                       isValid: $isValid,
                       operationArray: $operationArray,
                       shouldValidateField: shouldValidateField,
                       calculatorType: calculatorType, action: {
            
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
        CustomCalculatorView(value: .constant("12 + 45"),
                             result: .constant("0"),
                             message: .constant(Localizable.Lock.lockPinSetBannerExpl),
                             isValid: .constant(false),
                             operationArray: .constant(["1 + 3"]),
                             calculatorType: .lockCalculator,
                             nextButtonAction: .action,
                             destination: EmptyView())
    }
}

//
//  PasswordTextFieldView.swift
//  Tella
//
//  
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct PasswordTextFieldView : View {
    
    @State var shouldHidePassword : Bool = true
    @Binding var fieldContent : String
    @Binding var isValid : Bool
    @Binding var shouldShowErrorMessage : Bool
    @Binding var shouldShowError : Bool
    
    var disabled : Bool = false
    var onCommit : (() -> Void)? =  ({})
    
    var body: some View {
        
        VStack(spacing: 13) {
            HStack {
                Spacer()
                    .frame(width: 32)
                
                PasswordTextField(text: $fieldContent,
                                isFirstResponder: .constant(true),
                                shouldShowError: $shouldShowError,
                                isSecure : $shouldHidePassword)
                    .textFieldStyle(PasswordStyle(shouldShowError: shouldShowError))
                    .onChange(of: fieldContent, perform: { value in
                        validateField(value: value)
                    })
                    .disabled(disabled)
                    .frame( height: 22)
                
                Spacer()
                    .frame(width: 10)
                
                Button {
                    shouldHidePassword.toggle()
                } label: {
                    Image(shouldHidePassword ? "lock.hide" : "lock.show")
                        .frame(width: 22, height: 20)
                        .aspectRatio(contentMode: .fit)
                }
            }
            Divider()
                .frame(height: 2)
                .background(Styles.Colors.yellow)
        }.padding(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24))
    }
    private func validateField(value:String) {
        self.isValid = value.passwordValidator()
        shouldShowErrorMessage = false
        self.shouldShowError = false
        
    }
}

struct PasswordStyle: TextFieldStyle {
    
    var shouldShowError : Bool = false
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.custom(Styles.Fonts.regularFontName, size: 20))
            .foregroundColor(shouldShowError ? Color.red : Color.white)
            .accentColor(Styles.Colors.yellow)
            .multilineTextAlignment(.center)
            .disableAutocorrection(true)
            .textContentType(UITextContentType.oneTimeCode)
            .keyboardType(.alphabet)
    }
}

struct SecurePasswordStyle: TextFieldStyle {
    
    var shouldShowError : Bool = false
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.custom(Styles.Fonts.regularFontName, size: 26))
            .foregroundColor(shouldShowError ? Color.red : Color.white)
            .accentColor(Styles.Colors.yellow)
            .multilineTextAlignment(.center)
            .disableAutocorrection(true)
            .textContentType(UITextContentType.oneTimeCode)
            .keyboardType(.alphabet)
        
    }
}


struct PasswordTextFieldView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordTextFieldView(fieldContent: .constant(""),
                              isValid: .constant(true),
                              shouldShowErrorMessage: .constant(true),
                              shouldShowError: .constant(false))
    }
}

//
//  PasswordTextFieldView.swift
//  Tella
//
//
//  Copyright © 2021 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct PasswordTextFieldView : View {
    
    @State var shouldShowPassword : Bool = false
    @Binding var fieldContent : String
    @Binding var isValid : Bool
    @Binding var shouldShowError : Bool
    
    var disabled : Bool = false
    var onCommit : (() -> Void)? =  ({})
    @FocusState var isFocused : Bool
    var body: some View {
        
        VStack(spacing: 13) {
            HStack {
                Spacer()
                    .frame(width: 32)
                
                if shouldShowPassword {
                    TextField("", text: $fieldContent).focused($isFocused)
                        .textFieldStyle(PasswordStyle(shouldShowError: shouldShowError))
                        .onChange(of: fieldContent, perform: { value in
                            validateField(value: value)
                        })
                        .onSubmit {
                            self.onCommit?()
                        }
                        .disabled(disabled)
                        .frame( height: 22)
                    
                } else {
                    SecureField("", text: $fieldContent).focused($isFocused)
                        .textFieldStyle(SecurePasswordStyle(shouldShowError: shouldShowError))
                        .onChange(of: fieldContent, perform: { value in
                            validateField(value: value)
                        }).onSubmit {
                            self.onCommit?()
                        }
                        .disabled(disabled)
                        .frame( height: 22)
                }
                
                Spacer()
                    .frame(width: 10)
                
                Button {
                    shouldShowPassword.toggle()
                } label: {
                    Image(shouldShowPassword ? "lock.hide" : "lock.show")
                        .frame(width: 22, height: 20)
                        .aspectRatio(contentMode: .fit)
                }
            }
            Divider()
                .frame(height: 2)
                .background(Styles.Colors.yellow)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                isFocused = true
            })
        }
    }
    private func validateField(value:String) {
        self.isValid = value.passwordValidator()
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
                              shouldShowError: .constant(false))
    }
}

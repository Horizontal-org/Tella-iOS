//
//  PasswordTextFieldView.swift
//  Tella
//
//  
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct PasswordTextFieldView : View {
    
    @State var shouldShowPassword : Bool = false
    @Binding var fieldContent : String
    @Binding var isValid : Bool
    @Binding var shouldShowError : Bool
    
    var disabled : Bool = false
    
    var body: some View {
        
        VStack(spacing: 13) {
            HStack {
                if shouldShowPassword {
                    TextField("", text: $fieldContent)
                        .textFieldStyle(PasswordStyle())
                        .onChange(of: fieldContent, perform: { value in
                            self.isValid = value.passwordValidator()
                            shouldShowError = false
                        })
                        .disabled(disabled)
                    
                } else {
                    SecureField("", text: $fieldContent)
                        .textFieldStyle(PasswordStyle())
                        .onChange(of: fieldContent, perform: { value in
                            self.isValid = value.passwordValidator()
                            self.shouldShowError = false
                        })
                        .disabled(disabled)
                }
                
                Spacer()
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
                .background(Styles.Colors.buttonAdd)
        }.padding(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24))
    }
}

struct PasswordStyle: TextFieldStyle {
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.custom(Styles.Fonts.regularFontName, size: 18))
            .foregroundColor(Color.white)
            .accentColor(Styles.Colors.buttonAdd)
            .multilineTextAlignment(.center)
            .disableAutocorrection(true)
    }
}

struct PasswordTextFieldView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordTextFieldView(fieldContent: .constant(""),
                              isValid: .constant(true),
                              shouldShowError: .constant(true))
    }
}

//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI
import Combine
enum FieldType {
    case url
    case username
    case text
    case password
    case code
}
struct TextfieldView : View {
    
    @Binding var fieldContent : String
    @State private var pfieldContent : String = ""
    
    @Binding var isValid : Bool
    @Binding var shouldShowError : Bool

    var errorMessage : String?
    var fieldType : FieldType
    var placeholder : String = ""
    var shouldShowTitle : Bool = false
    var onCommit : (() -> Void)? =  ({})
    var keyboardType: UIKeyboardType = .default
    
    @State private var shouldShowPassword : Bool = false
    
    var body: some View {
        
        VStack(spacing: 10) {
            
            Spacer()
                .frame(height: 10)
            
            ZStack {
                Text(placeholder)
                    .offset(y: fieldContent.isEmpty ? 0 : -22)
                    .font(.custom(Styles.Fonts.regularFontName, size: 14))
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .contentShape(Rectangle())

                    .foregroundColor(fieldContent.isEmpty ? .white : .white.opacity(0.8))
                    .scaleEffect(fieldContent.isEmpty ? 1 : 0.88, anchor: .leading)
                    .transaction { transaction in
                        if pfieldContent != fieldContent {
                            transaction.animation =  .default
                        } else {
                            
                        }
                    }

                // Textfield
                if fieldType == .password || fieldType == .code {
                    passwordTextfieldView
                } else {
                    textfieldView
                }
            }
            
            // Divider view
            dividerView
            
            // Error message
            errorMessageView
            
        }
        
        
        
    }
    
    var textfieldView : some View {
        
        TextField("", text: $fieldContent,onCommit: {
            self.onCommit?()
        })
        .keyboardType(keyboardType)
        .onChange(of: fieldContent, perform: { value in
            validateField(value: value)
            self.pfieldContent = value
        })
        .textFieldStyle(TextfieldStyle(shouldShowError: shouldShowError))
        .frame( height: 22)
        
    }
    
    var passwordTextfieldView : some View {
        HStack {
            
            Group {
                if shouldShowPassword {
                    TextField("", text: $fieldContent,onCommit: {
                        self.onCommit?()
                    })
                } else {
                    SecureField("", text: $fieldContent,onCommit: {
                        self.onCommit?()
                    })
                }}
            .keyboardType(keyboardType)
            .textFieldStyle(TextfieldStyle(shouldShowError: shouldShowError))
            .onChange(of: fieldContent, perform: { value in
                validateField(value: value)
            })
            .frame( height: 22)
            
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
    }
    
    var dividerView : some View {
        Divider()
            .frame(height: 1)
            .background(shouldShowError ? Color(UIColor(hexValue: 0xFF2D2D)) : Color.white)
    }
    
    @ViewBuilder
    var errorMessageView : some View {
        if let errorMessage = errorMessage, shouldShowError == true {
            Text(errorMessage)
                .font(.custom(Styles.Fonts.regularFontName, size: 12))
                .foregroundColor(Color(UIColor(hexValue: 0xFF2D2D)))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        
    }
    
    private func validateField(value:String) {
        
        switch fieldType {
        case .url:
            self.isValid = value.urlValidator()
            
        case .username:
            self.isValid = value.usernameValidator()
            
        case .text:
            self.isValid = value.textValidator()
            
        case .password:
            self.isValid = value.passwordValidator()
            
        case .code:
            self.isValid = value.codeValidator()
        }
        self.shouldShowError = false
    }
}

struct TextfieldStyle: TextFieldStyle {
    
    var shouldShowError : Bool = false
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.custom(Styles.Fonts.regularFontName, size: 14))
            .foregroundColor(Color.white)
            .accentColor(.white)
            .multilineTextAlignment(.leading)
            .disableAutocorrection(true)
            .autocapitalization(.none)
    }
}

struct TextfieldView_Previews: PreviewProvider {
    static var previews: some View {
        TextfieldView(fieldContent: .constant(""),
                      isValid: .constant(true),
                      shouldShowError: .constant(false),
                      fieldType: .text)
    }
}


//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct TextfieldView : View {
    
    @Binding var fieldContent : String
    @Binding var isValid : Bool
    @Binding var shouldShowError : Bool
    var errorMessage : String?
    var fieldType : FieldType
    var onCommit : (() -> Void)? =  ({})
    
    var body: some View {
        
        TextFieldView( fieldContent: $fieldContent,
                       isValid: $isValid,
                       shouldShowError: $shouldShowError,
                       errorMessage: errorMessage,
                       fieldType: fieldType,
                       onCommit: onCommit)
    }
    private func validateField(value:String) {
        self.isValid = value.passwordValidator()
        self.shouldShowError = false
        
    }
}

struct TextFieldView : View {
    
    @State var shouldShowPassword : Bool = false
    @Binding var fieldContent : String
    @Binding var isValid : Bool
    @Binding var shouldShowError : Bool
    var errorMessage : String?
    var fieldType : FieldType
    
    var onCommit : (() -> Void)? =  ({})
    var body: some View {
        
        VStack(spacing: 13) {
            
            if fieldType == .password {
                passwordTextfieldView
            } else {
                textfieldView
            }
            
            dividerView
            
            errorMessageView
            
        }.padding(EdgeInsets(top: 0, leading: 25, bottom: 0, trailing: 10))
    }
    
    var textfieldView : some View {
        
        TextField("", text: $fieldContent,onCommit: {
            self.onCommit?()
        }).textFieldStyle(TextfieldStyle(shouldShowError: shouldShowError))
            .onChange(of: fieldContent, perform: { value in
                validateField(value: value)
            })
            .frame( height: 22)
        
    }
    
    var passwordTextfieldView : some View {
        HStack {
            Spacer()
                .frame(width: 32)
            
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
            .frame(height: 2)
            .background(shouldShowError ? Color(UIColor(hexValue: 0xFF2D2D)) : Color.white)
        
    }

    @ViewBuilder
    var errorMessageView : some View {
        if shouldShowError, let errorMessage = errorMessage {
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
            .keyboardType(.alphabet)
    }
}

//struct TextfieldView_Previews: PreviewProvider {
//    static var previews: some View {
//        TextFieldView(fieldContent: .constant(""),
//                              isValid: .constant(true),
//                              shouldShowError: .constant(false))    }
//}


enum FieldType {
    case url
    case username
    case text
    case password
}

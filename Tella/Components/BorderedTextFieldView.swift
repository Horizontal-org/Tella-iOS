//
//  Copyright © 2023 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct BorderedTextFieldView: View {
    var placeholder: String
    var shouldShowTitle: Bool = false
    
    @Binding var fieldContent: String
    @Binding var isValid: Bool
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            
            Group {
                if shouldShowTitle {
                    Text(placeholder)
                        .offset(x: fieldContent.isEmpty ? 0 : -15, y: fieldContent.isEmpty ? 0 : -50)
                        .scaleEffect(fieldContent.isEmpty ? 1 : 0.88, anchor: .leading)
                        .animation(.default)
                } else {
                    Text(placeholder)
                        .opacity(fieldContent.isEmpty ? 1 : 0)
                }
            }
            .font(.custom(Styles.Fonts.regularFontName, size: 14))
            .contentShape(Rectangle())
            .foregroundColor(fieldContent.isEmpty ? .white : .white.opacity(0.8))
            
            textField
            
        }
        .padding(16)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(.white.opacity(0.64), lineWidth: 0.8)
        )
        .frame(height: 53)

    }
    
    private var textField: some View {
        
        TextField("", text: $fieldContent)
            .font(.custom(Styles.Fonts.regularFontName, size: 14))
            .foregroundColor(Color.white)
            .accentColor(.white)
            .disableAutocorrection(true)
            .keyboardType(.alphabet)
            .autocapitalization(.none)
            .onChange(of: fieldContent, perform: { value in
                validateField(value: value)
            })
    }
    
    private func validateField(value: String) {
        isValid = value.textValidator()
    }
}

#Preview {
    ContainerView {
        BorderedTextFieldView(placeholder: "Placeholder",
                              shouldShowTitle: true,
                              fieldContent: .constant(""),
                              isValid: .constant(true))
        .padding()
    }
}

//
//  TextEditorView.swift
//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct TextEditorView : View {
    
    var placeholder : String
    @Binding var fieldContent : String
    @Binding var isValid : Bool
    @Binding var shouldShowError : Bool
    
    var errorMessage : String?
    var onCommit : (() -> Void)? =  ({})
    
    @State var textEditorHeight : CGFloat = 36
    
    var body: some View {
        
        VStack(spacing: 13) {
            TextEditorView
            
            dividerView
            
            errorMessageView
        }
    }
    
    var TextEditorView : some View {
        
        ZStack(alignment: .leading) {
            
            if fieldContent.isEmpty {
                Text(placeholder)
                    .font(.custom(Styles.Fonts.regularFontName, size: 14))
                    .foregroundColor(Color.white)
                Spacer()
            }
            
            Text(fieldContent)
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(.clear)
                .background(GeometryReader {
                    Color.clear.preference(key: ViewHeightKey.self,
                                           value: $0.frame(in: .local).size.height)
                })
            
            if #available(iOS 16.0, *) {
                tellaTextEditor
                    .scrollContentBackground(.hidden)
            } else {
                tellaTextEditor
                    .onAppear {
                        UITextView.appearance().backgroundColor = .clear
                    }
            }
        }
        
        .onPreferenceChange(ViewHeightKey.self) { textEditorHeight = $0 }
    }
    
    var tellaTextEditor : some View {
        
        TextEditor(text: $fieldContent)
            .font(.custom(Styles.Fonts.regularFontName, size: 14))
            .foregroundColor(Color.white)
            .accentColor(.white)
            .background(Color.clear)
            .multilineTextAlignment(.leading)
            .disableAutocorrection(true)
            .keyboardType(.alphabet)
            .frame(height: max(36,textEditorHeight + 15))
            .padding(EdgeInsets(top: -7, leading: -5, bottom: -5, trailing: -5))
            .onChange(of: fieldContent, perform: { value in
                validateField(value: value)
            })
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
        self.isValid = value.textValidator()
        self.shouldShowError = false
    }
}

struct TextEditorView_Previews: PreviewProvider {
    static var previews: some View {
        ContainerView {
            TextEditorView(placeholder: "Placeholder",
                           fieldContent: .constant(""),
                           isValid: .constant(true),
                           shouldShowError: .constant(false))
            .padding()
        }
    }
}

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = value + nextValue()
    }
}

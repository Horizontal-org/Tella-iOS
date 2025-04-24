//
//  TextEditorView.swift
//  Tella
//
//  Copyright © 2022 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct UnderlinedTextEditorView : View {
    
    var placeholder : String
    
    @Binding var fieldContent : String
    @Binding var isValid : Bool
    @Binding var shouldShowError : Bool
    
    var errorMessage : String?
    var shouldShowTitle : Bool = false
    var onCommit : (() -> Void)? =  ({})
    
    @State var textEditorHeight : CGFloat = 65
    
    var body: some View {
        
        VStack(spacing: 13) {
            TextEditorView
            
            dividerView
            
            errorMessageView
        }
    }
    
    var TextEditorView : some View {
        
        ZStack(alignment: .leading) {
            
            VStack(spacing: -20) {
                Group {
                    if shouldShowTitle {
                        Text(placeholder)
                            .frame(maxWidth: .infinity,alignment: .leading)
                        
                            .padding(.bottom, fieldContent.isEmpty ? 0 : 15)
                        
                            .background(Styles.Colors.backgroundMain)
                            .offset(y: fieldContent.isEmpty ? 0 : -20)
                            .scaleEffect(fieldContent.isEmpty ? 1 : 0.88, anchor: .leading)
                            .animation(.default)
                        
                    } else {
                        Text(placeholder)
                            .opacity(fieldContent.isEmpty ? 1 : 0 )
                    }
                    
                } .font(.custom(Styles.Fonts.regularFontName, size: 14))
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .contentShape(Rectangle())
                    .foregroundColor(fieldContent.isEmpty ? .white : .white.opacity(0.8) )
                
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
        }
        
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
            .frame(height: textEditorHeight)
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
        if let errorMessage, shouldShowError {
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
            UnderlinedTextEditorView(placeholder: "Placeholder",
                           fieldContent: .constant(""),
                           isValid: .constant(true),
                           shouldShowError: .constant(false))
            .padding()
        }
    }
}


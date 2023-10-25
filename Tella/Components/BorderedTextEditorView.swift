//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct BorderedTextEditorView: View {
    
    var placeholder : String
    
    @Binding var fieldContent : String
    @Binding var isValid : Bool
    
    var shouldShowTitle : Bool = false
    
    @State var textEditorHeight : CGFloat = 120
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            
            Group {
                if shouldShowTitle {
                    Text(placeholder)
                        .padding(.bottom, fieldContent.isEmpty ? 0 : 15)
                        .offset(x: fieldContent.isEmpty ? 0 : -15, y: fieldContent.isEmpty ? 0 : -50)
                        .scaleEffect(fieldContent.isEmpty ? 1 : 0.88, anchor: .leading)
                        .animation(.default)
                    
                } else {
                    Text(placeholder)
                        .opacity(fieldContent.isEmpty ? 1 : 0 )
                }
                
            } .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .contentShape(Rectangle())
                .foregroundColor(fieldContent.isEmpty ? .white : .white.opacity(0.8) )
            
            if #available(iOS 16.0, *) {
                textEditor
                    .scrollContentBackground(.hidden)
            } else {
                textEditor
                    .onAppear {
                        UITextView.appearance().backgroundColor = .clear
                    }
            }
        }
        .padding(16)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(.white.opacity(0.64), lineWidth: 0.8)
        )
        .padding(EdgeInsets(top: 24, leading: 16, bottom: 24, trailing: 16))
    }
    
    var textEditor : some View {
        
        ZStack(alignment: .leading) {
            Text($fieldContent.wrappedValue)
                .font(.system(.body))
                .foregroundColor(.clear)
                .padding(14)
                .background(GeometryReader {
                    Color.clear.preference(key: ViewHeightKey.self,
                                           value: $0.frame(in: .local).size.height)
                })
            
            TextEditor(text: $fieldContent)
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(Color.white)
                .accentColor(.white)
                .multilineTextAlignment(.leading)
                .disableAutocorrection(true)
                .keyboardType(.alphabet)
                .frame(height: max(120,textEditorHeight))
                .padding(EdgeInsets(top: -7, leading: -5, bottom: -5, trailing: -5))
                .onChange(of: fieldContent, perform: { value in
                    validateField(value: value)
                })
            
        }        .onPreferenceChange(ViewHeightKey.self) { textEditorHeight = $0 }
    }
    
    
    private func validateField(value:String) {
        self.isValid = value.textValidator()
    }
}

#Preview {
    ContainerView {
        BorderedTextEditorView(placeholder: "Placeholder",
                               fieldContent: .constant(""),
                               isValid: .constant(true))
        .padding()
    }
}

struct ViewHeightKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value + nextValue()
    }
}

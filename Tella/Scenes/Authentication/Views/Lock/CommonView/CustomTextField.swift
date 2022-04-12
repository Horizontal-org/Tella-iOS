//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import SwiftUI


struct PasswordTextField: UIViewRepresentable {
   
    @Binding public var isFirstResponder: Bool
    @Binding public var text: String
    @Binding public var shouldShowError: Bool
    @Binding public var isSecure: Bool

    public var configuration = { (view: UITextField) in }
    
    public init(text: Binding<String>, isFirstResponder: Binding<Bool>, configuration: @escaping (UITextField) -> () = { _ in },  shouldShowError : Binding<Bool> , isSecure : Binding<Bool>) {
        self.configuration = configuration
        self._text = text
        self._isFirstResponder = isFirstResponder
        self._shouldShowError = shouldShowError
        self._isSecure = isSecure
    }
    
    public func makeUIView(context: Context) -> UITextField {
        let view = UITextField()
        view.addTarget(context.coordinator, action: #selector(Coordinator.textViewDidChange), for: .editingChanged)
        view.delegate = context.coordinator
        return view
    }
    
    public func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text

        uiView.font = UIFont(name: Styles.Fonts.regularFontName, size: 20)
        uiView.textColor = (shouldShowError ? UIColor.red : UIColor.white)
        uiView.tintColor = Styles.uiColor.yellow
        uiView.textAlignment = .center
        uiView.autocorrectionType = .no
        uiView.textContentType = .oneTimeCode
        uiView.keyboardType = .alphabet
        uiView.isSecureTextEntry = isSecure
        
        switch isFirstResponder {
        case true: uiView.becomeFirstResponder()
        case false: uiView.resignFirstResponder()
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator($text, isFirstResponder: $isFirstResponder)
    }
    
    public class Coordinator: NSObject, UITextFieldDelegate {
        var text: Binding<String>
        var isFirstResponder: Binding<Bool>
        
        init(_ text: Binding<String>, isFirstResponder: Binding<Bool>) {
            self.text = text
            self.isFirstResponder = isFirstResponder
        }
        
        @objc public func textViewDidChange(_ textField: UITextField) {
            self.text.wrappedValue = textField.text ?? ""
        }
        
        public func textFieldDidBeginEditing(_ textField: UITextField) {
            self.isFirstResponder.wrappedValue = true
        }
        
        public func textFieldDidEndEditing(_ textField: UITextField) {
            self.isFirstResponder.wrappedValue = false
        }
    }
}

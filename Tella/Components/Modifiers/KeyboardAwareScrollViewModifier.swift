//
//  KeyboardAwareScrollViewModifier.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 13/7/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

/// Wraps the content in a ScrollView that can only scroll while the keyboard
/// is visible.
struct KeyboardAwareScrollViewModifier: ViewModifier {
    
    @State private var isKeyboardVisible: Bool = false
    
    func body(content: Content) -> some View {
        ScrollView {
            content
        }
        .scrollEnabled(isKeyboardVisible)
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            isKeyboardVisible = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            isKeyboardVisible = false
        }
    }
}

extension View {
    func scrollableWhenKeyboardShown() -> some View {
        modifier(KeyboardAwareScrollViewModifier())
    }
}

//
//  BackBottomView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 23/4/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct BackBottomView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var backAction : (() -> Void)?
    
    var body: some View {
        HStack {
            BottomButtonActionView(title: LocalizableLock.actionBack.localized, isValid: .constant(true)) {
                self.backAction?()
                self.presentationMode.wrappedValue.dismiss()
            }
            Spacer()
        }
    }
}

#Preview {
    BackBottomView()
}

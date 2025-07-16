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
            BottomButtonActionView(title: LocalizableLock.actionBack.localized, isValid: true) {
                self.backAction?()
                self.presentationMode.wrappedValue.dismiss()
            }
            Spacer()
        }
        .frame(height: 44)
    }
    
    func BottomButtonActionView(title:String,isValid:Bool, action: (() -> Void)?) -> some View {
        Button {
            UIApplication.shared.endEditing()
            action?()
        } label: {
            Text(title)
        }
        .style(.link1Style)
        .foregroundColor(isValid ? Color.white : Color.gray)
        .padding(EdgeInsets(top: 17, leading: 34, bottom: 45, trailing: 34))
        .disabled(!isValid)
    }
    
}

#Preview {
    BackBottomView()
}




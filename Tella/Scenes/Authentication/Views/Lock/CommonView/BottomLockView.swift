//
//  BottomLockView.swift
//  Tella
//
//  
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct BottomLockView<Destination:View>:View {
    
    @Binding  var isValid : Bool
    var shouldEnableBackButton :  Bool  = true

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var nextButtonAction: NextButtonAction
    var destination: Destination?
    var shouldHideNext : Bool = false
    var shouldHideBack: Bool = false
    var nextAction : (() -> Void)?
    var backAction : (() -> Void)?
    
    var body: some View {
        HStack {
            if !shouldHideBack{
                BottomButtonActionView(title: LocalizableLock.actionBack.localized, isValid: true) {
                    self.backAction?()
                    self.presentationMode.wrappedValue.dismiss()

                }
            }
            Spacer()
            if !shouldHideNext {
                BottomButtonActionView(title: LocalizableLock.actionNext.localized,isValid: isValid) {
                    self.nextAction?()
                }
            }
        }
        .frame(height: 44)
    }
    
    func BottomButtonActionView(title:String,isValid:Bool, action: (() -> Void)?) -> some View {
        Button {
            UIApplication.shared.endEditing()
            if nextButtonAction == .action {
                action?()
            }
            
            if (nextButtonAction == .destination) {
                navigateTo(destination: destination)
            }
            
        } label: {
            Text(title)
        }
        .font(.custom(Styles.Fonts.lightFontName, size: 16))
        .foregroundColor(isValid ? Color.white : Color.gray)
        .padding(EdgeInsets(top: 17, leading: 34, bottom: 17, trailing: 34))
        .disabled(!isValid)
    }
}

struct BottomLockView_Previews: PreviewProvider {
    static var previews: some View {
        BottomLockView(isValid: .constant(true),
                       nextButtonAction: .action,
                       destination: EmptyView(),
                       nextAction: {},
                       backAction: {})
    }
}

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
    
    var nextButtonAction: NextButtonAction
    var destination: Destination?
    var nextAction : (() -> Void)?
    var backAction : (() -> Void)?
    
    var body: some View {
        HStack {
            BottomButtonActionView(title: Localizable.Common.back,
                                   shouldEnable: true) {
                self.backAction?()
            }
            
            Spacer()
            
            if  nextButtonAction == .destination {
                BottomButtonDestinationView(title: Localizable.Common.next,
                                            shouldEnable: isValid,
                                            destination: destination)
            } else {
                BottomButtonActionView(title: Localizable.Common.next,
                                       shouldEnable: isValid) {
                    self.nextAction?()
                }
            }
        }
        .frame(height: 44)
    }
}

struct BottomButtonActionView : View  {
    
    var title : String
    var shouldEnable : Bool
    var action: (() -> Void)
    
    var body: some View {
        
        Button(title) {
            UIApplication.shared.endEditing()
            action()
        }
        .font(.custom(Styles.Fonts.lightFontName, size: 16))
        .foregroundColor(shouldEnable ? Color.white : Color.gray)
        .padding(EdgeInsets(top: 17, leading: 34, bottom: 17, trailing: 34))
        .disabled(!shouldEnable)
    }
}

struct BottomButtonDestinationView<Destination:View> : View  {
    var title : String
    var shouldEnable : Bool
    var destination: Destination
    
    var body: some View {
        return Text(title)
            .font(.custom(Styles.Fonts.lightFontName, size: 16))
            .foregroundColor(shouldEnable ? Color.white : Color.gray )
            .padding(EdgeInsets(top: 17, leading: 34, bottom: 17, trailing: 34))
            .navigateTo(destination: destination )
            .disabled(!shouldEnable)
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

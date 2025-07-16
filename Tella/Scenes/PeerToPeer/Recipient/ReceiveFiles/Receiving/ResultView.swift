//
//  ResultView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 14/7/2025.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct ResultView: View {
    
    var imageName: String
    var title: String
    var subTitle: String
    var buttonTitle: String?
    var buttonAction: (()->()) = { }

    var body: some View {
        ContainerView {
            
            VStack {
                
                Spacer()
                
                topview
                
                Spacer()
                    .frame(height: 48)
                if let buttonTitle {
                    TellaButtonView(title: buttonTitle,
                                    nextButtonAction: .action,
                                    buttonType: .yellow,
                                    isValid: .constant(true)) {
                        buttonAction()
                    }
                }
                
                Spacer()
                
            } .padding(EdgeInsets(top: 0, leading: 26, bottom: 0, trailing: 26))
        }
    }
    
    var topview: some View {
        
        VStack {
            Image(imageName)
            
            Spacer()
                .frame(height: 16)
            
            CustomText(title,
                       style: .heading1Style,
                       alignment: .center)
            Spacer()
                .frame(height: 16)
            CustomText(subTitle,
                       style: .body1Style,
                       alignment: .center)
        }
    }
}

//#Preview {
//    ResultView()
//}

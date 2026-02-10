//
//  ResultView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 14/7/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct ResultView: View {
    
    var imageName: ImageResource
    var title: String
    var subTitle: String
    var showViewFilesButton: Bool
    var showBackToHomeButton: Bool
    var viewFilesAction: (()->()) = { }
    
    var body: some View {
        ContainerView {
            
            VStack {
                
                Spacer()
                
                topview
                
                Spacer()
                    .frame(height: 48)
                if showViewFilesButton {
                    TellaButtonView(title: LocalizableNearbySharing.viewFilesAction.localized.uppercased(),
                                    nextButtonAction: .action,
                                    buttonType: .yellow,
                                    isValid: .constant(true)) {
                        viewFilesAction()
                    }
                }
                
                if showBackToHomeButton {
                    TellaButtonView(title: LocalizableNearbySharing.backToHomeAction.localized.uppercased(),
                                    nextButtonAction: .action,
                                    buttonType: .clear,
                                    isValid: .constant(true)) {
                        popToRoot()
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

#Preview {
    ResultView(imageName: .checkedCircle,
               title: "Title",
               subTitle: LocalizableNearbySharing.successFilesReceivedExpl.localized,
               showViewFilesButton: false, showBackToHomeButton: true) {
        
    }
}

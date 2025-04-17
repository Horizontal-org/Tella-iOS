//
//  RecipientFilesRequestView.swift
//  Tella
//
//  Created by RIMA on 14.02.25.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct RecipientFilesRequestView: View {
    var body: some View {
        ContainerViewWithHeader {
            navigationBarView
        } content: {
            contentView
        }
    }
    
    var contentView: some View {
        VStack{
            Spacer().frame(height: 100)
            ResizableImage("folders.icon").frame(width: 109, height: 109)
            
            CustomText(String(format: LocalizablePeerToPeer.senderRequestFilesNumberDesc.localized, 7), style: .heading1Font)
                .padding(.bottom, 16)//Number should be dynamic

            CustomText(LocalizablePeerToPeer.requestQuestion.localized, style: .body1Font)

                .padding(.bottom, 48)
            VStack(spacing: 16) {
                TellaButtonView(title: LocalizablePeerToPeer.accept.localized.uppercased(),
                                nextButtonAction: .destination,
                                buttonType: .yellow,
                                destination: RecipientWaitingView(),
                                isValid: .constant(true))
                TellaButtonView(title: LocalizablePeerToPeer.reject.localized.uppercased(),
                                nextButtonAction: .destination,
                                destination: RecipientWaitingView(),
                                isValid: .constant(true))
            }.frame(height: 125)
            Spacer()
        }
        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
    
    var navigationBarView: some View {
        NavigationHeaderView(title: LocalizablePeerToPeer.receiveFiles.localized,
                             navigationBarType: .inline,
                             backButtonAction: {self.popToRoot()},
                             rightButtonType: .none)
    }
}

#Preview {
    RecipientFilesRequestView()
}

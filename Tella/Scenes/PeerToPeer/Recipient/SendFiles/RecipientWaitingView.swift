//
//  RecipientWaitingView.swift
//  Tella
//
//  Created by RIMA on 14.02.25.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct RecipientWaitingView: View {
    var body: some View {
        ContainerViewWithHeader {
            navigationBarView
        } content: {
            contentView
        }
    }
    var contentView: some View {
        VStack {
            CustomText(LocalizablePeerToPeer.waitingForSenderDesc.localized, style: .heading1Style)

            ResizableImage("clock").frame(width: 48, height: 48)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)

    }
    
    var navigationBarView: some View {
        NavigationHeaderView(title: LocalizablePeerToPeer.receiveFiles.localized,
                             navigationBarType: .inline,
                             backButtonAction: {self.popToRoot()},
                             rightButtonType: .none)
    }

}

#Preview {
    RecipientWaitingView()
}

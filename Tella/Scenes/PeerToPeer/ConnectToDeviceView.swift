//
//  ConnectToDeviceView.swift
//  Tella
//
//  Created by RIMA on 05.02.25.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct ConnectToDeviceView: View {
    var body: some View {
        ContainerViewWithHeader {
            navigationBarView
        } content: {
            VStack {
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        }
    }
    var navigationBarView: some View {
        NavigationHeaderView(title: LocalizablePeerToPeer.connectToDevice.localized,
                             navigationBarType: .inline,
                             backButtonAction: {self.popToRoot()},
                             rightButtonType: .none)
    }
    
}

#Preview {
    ConnectToDeviceView()
}

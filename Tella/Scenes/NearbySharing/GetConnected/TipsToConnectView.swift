//
//  TipsToConnectView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 8/9/2025.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct TipsToConnectView: View {
    var body: some View {
        ContainerViewWithHeader {
            navigationBarView
        } content: {
            contentView
        }
    }
    
    private var contentView: some View {
        VStack(alignment: .center, spacing: 24) {
            
            titleSubtitleView(title: LocalizableNearbySharing.settingUp.localized,
                              subtitle: LocalizableNearbySharing.settingUpExpl.localized)
            
            DividerView()
            
            titleSubtitleView(title: LocalizableNearbySharing.joining.localized,
                              subtitle: LocalizableNearbySharing.joiningExpl.localized)
            
            DividerView()
            
            titleSubtitleView(title: LocalizableNearbySharing.moreTips.localized,
                              subtitle: LocalizableNearbySharing.moreTipsExpl.localized)
            
            Spacer()
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding([.leading, .trailing], 20)
    }
    
    var navigationBarView: some View {
        NavigationHeaderView(title: LocalizableNearbySharing.tipsToConnect.localized ,
                             navigationBarType: .inline,
                             rightButtonType: .none)
    }
    
    func titleSubtitleView(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            CustomText(title,
                       style: .subheading1Style)
            
            CustomText(subtitle,
                       style: .body1Style)
        }
    }
}

#Preview {
    TipsToConnectView()
}

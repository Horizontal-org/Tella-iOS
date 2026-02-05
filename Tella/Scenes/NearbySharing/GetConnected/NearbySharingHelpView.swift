//
//  NearbySharingHelpView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 8/9/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct NearbySharingHelpView: View {
    var body: some View {
        ContainerViewWithHeader {
            navigationBarView
        } content: {
            contentView
        }
    }
    
    private var contentView: some View {
        VStack(alignment: .center, spacing: 24) {
            
            connectDeviceView()
            
            DividerView()
            
            needInternetTitle()
            
            DividerView()
            
            moreTipsView()
            Spacer()
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding([.leading, .trailing], 20)
    }
    
    var navigationBarView: some View {
        NavigationHeaderView(title: LocalizableNearbySharing.helpAppBar.localized ,
                             navigationBarType: .inline,
                             rightButtonType: .none)
    }
    
    func titleSubtitleView(title: String,
                           subtitleString: String? = nil,
                           subtitleAttributed: NSAttributedString? = nil) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            CustomText(title, style: .subheading1Style)
            
            if let subtitleAttributed {
                CustomAttributedText(subtitleAttributed, style: .body1Style)
            } else if let subtitleString {
                CustomText(subtitleString, style: .body1Style)
            }
        }
    }
    
    
    func connectDeviceView() -> some View {
        
        let subtitle = LocalizableNearbySharing.helpConnectDevicePart1.localized.numbered(1).addline +
        LocalizableNearbySharing.helpConnectDevicePart2.localized.numbered(2).addline +
        LocalizableNearbySharing.helpConnectDevicePart3.localized.numbered(3)
        
        return titleSubtitleView(title: LocalizableNearbySharing.helpConnectDeviceTitle.localized,
                                 subtitleString: subtitle)
    }
    
    func needInternetTitle() -> some View {
        titleSubtitleView(title: LocalizableNearbySharing.helpNeedInternetTitle.localized,
                          subtitleString: LocalizableNearbySharing.helpNeedInternetExpl.localized)
    }
    
    func moreTipsView() -> some View {
        
        let subtitle =
        NSAttributedString(string: LocalizableNearbySharing.helpMoreTipsPart1.localized.bulleted().addline) +
        NSAttributedString(string: LocalizableNearbySharing.helpMoreTipsPart2.localized.bulleted().addline) +
        helpMoreTipsPart3()
        
        return titleSubtitleView(
            title: LocalizableNearbySharing.moreTips.localized,
            subtitleAttributed: subtitle
        )
    }
    
    func helpMoreTipsPart3() -> NSAttributedString {
        let text = LocalizableNearbySharing.helpMoreTipsPart3.localized.bulleted()
        let linkText = LocalizableNearbySharing.helpMoreTipsDocumentation.localized
        let url = TellaUrls.nearbySharingLearnMore.url()
        
        if #available(iOS 15, *) {
            var attributed = AttributedString(text)
            attributed.link(
                text: linkText,
                url: url
            )
            return NSAttributedString(attributed)
        } else {
            let attributed = NSMutableAttributedString(string: text)
            attributed.link(
                text: linkText,
                url: url)
            return attributed
        }
    }
}

#Preview {
    NearbySharingHelpView()
}

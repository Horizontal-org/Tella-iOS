//
//  P2PResultView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 14/7/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct P2PResultView: View {
    
    var viewModel: P2PResultVM
    var buttonAction: (()->()) = { }
    
    var body: some View {
        
        ZStack {
            
            ContainerViewWithHeader {
                navigationBarView
            } content: {
                contentView
            }
        }
    }
    
    var navigationBarView: some View {
        NavigationHeaderView(title: LocalizableNearbySharing.resultsAppBar.localized ,
                             backButtonType: .close,
                             backButtonAction: {self.popToRoot()})
    }
    
    var contentView : some View {
        ResultView(imageName: viewModel.imageName,
                   title: viewModel.title,
                   subTitle: viewModel.subTitle,
                   buttonTitle: viewModel.buttonTitle,
                   buttonAction: buttonAction)
    }
    
}

//#Preview {
//    P2PResultView()
//}


//
//  ReportListView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 2/7/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

import SwiftUI

struct CommonReportListView: View {
    
    var message: String
    var emptyMessage: String
    var emptyIcon: String

    @Binding var cardsViewModel: [CommonCardViewModel]
    var showDetails: ((CommonCardViewModel) -> Void)
    var showBottomSheet: ((CommonCardViewModel) -> Void)
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 0) {
            
            if cardsViewModel.isEmpty {
                ConnectionEmptyView(message: emptyMessage, iconName: emptyIcon)
            } else {
                
                Text(message)
                    .font(.custom(Styles.Fonts.regularFontName, size: 14))
                    .foregroundColor(.white.opacity(0.64))
                    .padding(.all, 15)
                
                ScrollView {
                    ForEach($cardsViewModel, id: \.id) { itemViewModel in
                        CommonItemView(cardViewModel: itemViewModel ,
                                       showDetails: {showDetails(itemViewModel.wrappedValue)},
                                       showBottomSheet: {showBottomSheet(itemViewModel.wrappedValue)})
                    }
                }
            }
        }
    }
}

struct CommonItemView: View {
    
    @EnvironmentObject var mainAppModel: MainAppModel
    
    @EnvironmentObject var sheetManager: SheetManager
    @Binding var cardViewModel: CommonCardViewModel
    
    var showDetails: (() -> Void)
    var showBottomSheet: (() -> Void)
    
    var body: some View {
        
        CardFrameView(padding: EdgeInsets(top: 6, leading: 0, bottom: 0, trailing: 0)) {
            
            Button(action: showDetails ) {
                
                HStack {
                    
                    if (cardViewModel.iconImageName != nil) {
                        Image(cardViewModel.iconImageName!)
                        Spacer()
                            .frame(width: 12)
                    }
                    
                    ConnectionCardDetailsView(title: cardViewModel.title,
                                          subtitle: cardViewModel.subtitle)
                    
                    Spacer()
                    
                    ImageButtonView(imageName: "reports.more",
                                    action: showBottomSheet)
                    
                }.padding(.all, 16)
            }
        }
    }
    
    
    
}



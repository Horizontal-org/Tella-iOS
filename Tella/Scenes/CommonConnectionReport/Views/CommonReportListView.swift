//
//  ReportListView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 2/7/2024.
//  Copyright © 2024 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
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
                
                CustomText(message,
                           style: .body1Style,
                           alignment: .center,
                           color: .white.opacity(0.64))
                .padding(.all, .extraNormal)
                
                
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
                    
                    ImageButtonView(imageName: .reportsMore,
                                    action: showBottomSheet)
                    
                }.padding(.all, .normal)
            }
        }
    }
}

#Preview("Item") {
    CommonItemView(cardViewModel: .constant(CommonCardViewModel.stub()),
                   showDetails: {},
                   showBottomSheet: {})
    .padding(.horizontal, 20)
    .background(Styles.Colors.backgroundMain)
}

#Preview("List") {
    CommonReportListView(message: LocalizableReport.draftListExpl.localized,
                         emptyMessage: LocalizableReport.reportsDraftEmpty.localized,
                         emptyIcon: ServerConnectionType.tella.emptyIcon,
                         cardsViewModel: .constant([CommonCardViewModel.stub()]),
                         showDetails: { _ in },
                         showBottomSheet: { _ in })
    .padding(.horizontal, 20)
    .background(Styles.Colors.backgroundMain)
}

#Preview("Empty") {
    CommonReportListView(message: LocalizableReport.draftListExpl.localized,
                         emptyMessage: LocalizableReport.reportsDraftEmpty.localized,
                         emptyIcon: ServerConnectionType.tella.emptyIcon,
                         cardsViewModel: .constant([]),
                         showDetails: { _ in },
                         showBottomSheet: { _ in })
    .background(Styles.Colors.backgroundMain)
}

//
//  EntityInstancesListView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 27/3/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import SwiftUI

struct UwaziListView: View {
    
    var message: String
    var emptyMessage: String
    
    @Binding var cardsViewModel: [UwaziCardViewModel]
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 0) {
            
            if cardsViewModel.isEmpty {
                
                UwaziEmptyView(message: emptyMessage)
                
            } else {
                
                Text(message)
                    .font(.custom(Styles.Fonts.regularFontName, size: 14))
                    .foregroundColor(.white.opacity(0.64))
                    .padding(.all, 15)
                
                ScrollView {
                    ForEach($cardsViewModel, id: \.id) { itemViewModel in
                        
                        EntityInstanceItemView(cardViewModel: itemViewModel)
                    }
                }
            }
            
        }
    }
}

struct EntityInstanceItemView: View {
    
    @EnvironmentObject var mainAppModel: MainAppModel
    
    @EnvironmentObject var sheetManager: SheetManager
    @Binding var cardViewModel: UwaziCardViewModel
    
    var body: some View {
        
        CardFrameView(padding: EdgeInsets(top: 6, leading: 0, bottom: 0, trailing: 0)) {
            
            Button(action: {
                showEntityView()
            }) {
                
                HStack {
                    
                    if (cardViewModel.iconImageName != nil) {
                        Image(cardViewModel.iconImageName!)
                        Spacer()
                            .frame(width: 12)
                    }
                    
                    ConnectionCardDetail(title: cardViewModel.title,
                                         subtitle: cardViewModel.serverName)
                    
                    Spacer()
                    
                    ImageButtonView(imageName: "reports.more",
                                    action: { showBottomSheet()})
                    
                }.padding(.all, 16)
            }
        }
    }
    
    private func showBottomSheet() {
        sheetManager.showBottomSheet(modalHeight: 176) {
            ActionListBottomSheet(items: cardViewModel.listActionSheetItem,
                                  headerTitle: cardViewModel.title,
                                  action:  {item in
                guard let type = item.type as? UwaziActionType else {return}
                
                switch type {
                case .delete:
                    showDeleteTemplateConfirmationView()
                case .createEntity:
                    showCreateEntityView()
                    sheetManager.hide()
                case .viewEntity:
                    showSummaryEntityView()
                    sheetManager.hide()
                }
            })
        }
    }
    
    private func showEntityView() {
        switch cardViewModel.status {
        case .unknown, .draft:
            showCreateEntityView()
            sheetManager.hide()
        default:
            showSummaryEntityView()
            sheetManager.hide()
        }
    }
    
    private func showCreateEntityView() {
        navigateTo(destination: CreateEntityView(appModel: mainAppModel,
                                                 templateId: cardViewModel.templateId,
                                                 entityInstanceID: cardViewModel.entityInstanceID))
    }
    
    private func showSummaryEntityView() {
        navigateTo(destination: SummaryEntityView(mainAppModel: mainAppModel,
                                                  entityInstanceId: cardViewModel.entityInstanceID))
    }
    
    private func showDeleteTemplateConfirmationView() {
        
        sheetManager.showBottomSheet(modalHeight: 200) {
            return ConfirmBottomSheet(titleText: cardViewModel.deleteTitle,
                                      msgText: cardViewModel.deleteMessage,
                                      cancelText: LocalizableUwazi.noSheetAction.localized,
                                      actionText: LocalizableUwazi.yesSheetAction.localized) {
                cardViewModel.deleteAction()
            }
        }
    }
}

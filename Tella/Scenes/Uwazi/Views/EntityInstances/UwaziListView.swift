//
//  EntityInstancesListView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 27/3/2024.
//  Copyright © 2024 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
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
                
                ConnectionEmptyView(message: emptyMessage, iconName: ServerConnectionType.uwazi.emptyIcon)
                
            } else {
                
                CustomText(message,
                           style: .body1Style,
                           alignment: .center,
                           color: .white.opacity(0.64))
                .padding(.all, .extraNormal)
                
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
                    
                    ConnectionCardDetailsView(title: cardViewModel.title,
                                              subtitle: cardViewModel.serverName)
                    
                    Spacer()
                    
                    ImageButtonView(imageName: .reportsMore,
                                    action: { showBottomSheet()})
                    
                }.padding(.all, 16)
            }
        }
    }
    
    private func showBottomSheet() {
        sheetManager.showBottomSheet() {
            ActionListBottomSheet(items: cardViewModel.listActionSheetItem,
                                  headerTitle: cardViewModel.title,
                                  action:  {item in
                guard let type = item.type as? ConnectionActionType else {return}
                
                switch type {
                case .delete:
                    showDeleteTemplateConfirmationView()
                case .editDraft:
                    showCreateEntityView()
                    sheetManager.hide()
                case .editOutbox:
                    showSummaryEntityView()
                    sheetManager.hide()
                case .viewSubmitted:
                    showSubmittedEntityView()
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
        case .submitted:
            showSubmittedEntityView()
            sheetManager.hide()
        default:
            showSummaryEntityView()
            sheetManager.hide()
        }
    }
    
    private func showCreateEntityView() {
        navigateTo(destination: CreateEntityView(mainAppModel: cardViewModel.mainAppModel,
                                                 templateId: cardViewModel.templateId,
                                                 entityInstanceID: cardViewModel.entityInstanceID))
    }
    
    private func showSummaryEntityView() {
        navigateTo(destination: SummaryEntityView(mainAppModel: cardViewModel.mainAppModel,
                                                  entityInstanceId: cardViewModel.entityInstanceID))
    }
    
    private func showSubmittedEntityView() {
        navigateTo(destination: SubmittedEntityView(mainAppModel: cardViewModel.mainAppModel,
                                                    entityInstanceId: cardViewModel.entityInstanceID))
    }
    
    private func showDeleteTemplateConfirmationView() {
        
        sheetManager.showBottomSheet() {
            return ConfirmBottomSheet(titleText: cardViewModel.deleteReportStrings.deleteTitle,
                                      msgText: cardViewModel.deleteReportStrings.deleteMessage,
                                      cancelText: LocalizableCommon.commonNo.localized,
                                      actionText: LocalizableCommon.commonYes.localized) {
                cardViewModel.deleteAction()
            }
        }
    }
}

#Preview("List") {
    UwaziListView(message: LocalizableUwazi.draftListExpl.localized,
                  emptyMessage: LocalizableUwazi.emptyDraftListExpl.localized,
                  cardsViewModel: .constant([UwaziCardViewModel.stub()]))
    .padding(.horizontal, 20)
    .background(Styles.Colors.backgroundMain)
    .environmentObject(SheetManager())
}

#Preview("Empty") {
    UwaziListView(message: LocalizableUwazi.draftListExpl.localized,
                  emptyMessage: LocalizableUwazi.emptyDraftListExpl.localized,
                  cardsViewModel: .constant([]))
    .background(Styles.Colors.backgroundMain)
}

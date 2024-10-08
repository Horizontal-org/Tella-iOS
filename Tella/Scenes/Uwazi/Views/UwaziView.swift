//
//  UwaziView.swift
//  Tella
//
//  Created by Gustavo on 27/07/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct UwaziView: View {
    @EnvironmentObject var uwaziViewModel: UwaziViewModel
    
    var body: some View {
        contentView
            .navigationBarTitle(LocalizableUwazi.uwaziTitle.localized, displayMode: .large)
            .environmentObject(uwaziViewModel)
    }
    
    private var contentView :some View {
        
        ContainerView {
            VStack(alignment: .center) {
                
                PageView(selectedOption: $uwaziViewModel.selectedCell, pageViewItems: uwaziViewModel.pageViewItems)
                    .frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
                
                VStack (spacing: 0) {
                    Spacer()
                    
                    switch self.uwaziViewModel.selectedCell {
                        
                    case .template:
                        UwaziListView(message: LocalizableUwazi.uwaziTemplateListExpl.localized,
                                                emptyMessage: LocalizableUwazi.uwaziTemplateListEmptyExpl.localized,
                                                cardsViewModel: $uwaziViewModel.templateCardsViewModel)
                    case .draft:
                        UwaziListView(message: LocalizableUwazi.draftListExpl.localized,
                                                emptyMessage: LocalizableUwazi.emptyDraftListExpl.localized,
                                                cardsViewModel: $uwaziViewModel.draftEntitiesViewModel)

                    case .outbox:
                        UwaziListView(message: LocalizableUwazi.outboxListExpl.localized,
                                                emptyMessage: LocalizableUwazi.emptyOutboxListExpl.localized,
                                                cardsViewModel: $uwaziViewModel.outboxedEntitiesViewModel)
                        
                    case .submitted:
                        UwaziListView(message: LocalizableUwazi.submittedListExpl.localized,
                                                emptyMessage: LocalizableUwazi.emptySubmittedListExpl.localized,
                                                cardsViewModel: $uwaziViewModel.submittedEntitiesViewModel)
                    }
                    
                    Spacer()
                }
                
                AddFileYellowButton(action: {
                    navigateTo(destination: AddTemplatesView()
                        .environmentObject(AddTemplateViewModel(mainAppModel: uwaziViewModel.mainAppModel, serverId: uwaziViewModel.server?.id)))
                }).frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
                
            }.background(Styles.Colors.backgroundMain)
                .padding(EdgeInsets(top: 15, leading: 20, bottom: 16, trailing: 20))
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .onReceive(uwaziViewModel.$shouldShowToast) { shouldShowToast in
            if shouldShowToast {
                Toast.displayToast(message: uwaziViewModel.toastMessage)
            }
        }
        
    }
    
    var backButton : some View {
        Button {
            self.popToRoot()
        } label: {
            Image("back")
                .flipsForRightToLeftLayoutDirection(true)
                .padding(EdgeInsets(top: -3, leading: -8, bottom: 0, trailing: 12))
        }
    }
    
    
}

struct UwaziView_Previews: PreviewProvider {
    static var previews: some View {
        UwaziView()
    }
}

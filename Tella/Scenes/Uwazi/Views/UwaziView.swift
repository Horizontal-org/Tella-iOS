//
//  UwaziView.swift
//  Tella
//
//  Created by Gustavo on 27/07/2023.
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct UwaziView: View {
    
    @ObservedObject var uwaziViewModel: UwaziViewModel
    
    var body: some View {
        
        ContainerViewWithHeader {
            navigationBarView
        } content: {
            contentView
                .environmentObject(uwaziViewModel)
        }
        .onReceive(uwaziViewModel.$shouldShowToast) { shouldShowToast in
            if shouldShowToast {
                Toast.displayToast(message: uwaziViewModel.toastMessage)
            }
        }
        
    }
    
    private var navigationBarView: some View {
        NavigationHeaderView(title: LocalizableUwazi.uwaziTitle.localized,
                             navigationBarType: .large,
                             backButtonAction: {self.popToRoot()})
    }
    
    private var contentView :some View {
        
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
            
            Spacer()
                .frame(height: 20)
            
            AddFileYellowButton(action: {
                let addTemplateViewModel = AddTemplateViewModel(mainAppModel: uwaziViewModel.mainAppModel,
                                                                serverId: uwaziViewModel.server?.id)
                navigateTo(destination: AddTemplatesView(uwaziTemplateViewModel: addTemplateViewModel))
            }).frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
        }
        .padding(EdgeInsets(top: 15, leading: 20, bottom: 16, trailing: 20))
    }
}

struct UwaziView_Previews: PreviewProvider {
    static var previews: some View {
        UwaziView(uwaziViewModel: UwaziViewModel.stub())
    }
}

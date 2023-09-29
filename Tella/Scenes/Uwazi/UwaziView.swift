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
                
                PageView(selectedOption: $uwaziViewModel.selectedCell, pageViewItems: $uwaziViewModel.pageViewItems)
                    .frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
                
                VStack (spacing: 0) {
                    Spacer()
                    switch UwaziPages(rawValue:uwaziViewModel.selectedCell) {
                        
                    case .templates:
                        TemplateListView(
                            message: LocalizableUwazi.uwaziTemplateListEmptyExpl.localized)
                        .environmentObject(DownloadedTemplatesViewModel(mainAppModel: uwaziViewModel.mainAppModel))
                    case .draft:
                        ReportListView(reportArray: $uwaziViewModel.draftEntities,
                                       message: LocalizableReport.reportsDraftEmpty.localized)
                        
                    case .outbox:
                        
                        ReportListView(reportArray: $uwaziViewModel.outboxedEntities,
                                       message: LocalizableReport.reportsOutboxEmpty.localized)
                        
                    case .submitted:
                        ReportListView(reportArray: $uwaziViewModel.submittedEntities,
                                       message: LocalizableReport.reportsSubmitedEmpty.localized)
                    case .none:
                        EmptyView()
                    }
                    
                    Spacer()
                }
                
                AddFileYellowButton(action: {
                    navigateTo(destination: AddTemplatesView()
                        .environmentObject(AddTemplateViewModel(mainAppModel: uwaziViewModel.mainAppModel)))
                }).frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
                
            }.background(Styles.Colors.backgroundMain)
                .padding(EdgeInsets(top: 15, leading: 20, bottom: 16, trailing: 20))
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        
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

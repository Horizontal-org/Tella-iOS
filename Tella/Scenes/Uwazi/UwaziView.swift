//
//  UwaziView.swift
//  Tella
//
//  Created by Gustavo on 27/07/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct UwaziView: View {
    @EnvironmentObject var uwaziTemplateViewModel: UwaziTemplateViewModel
    
    var body: some View {
        contentView
            .navigationBarTitle(LocalizableUwazi.uwaziTitle.localized, displayMode: .large)
            .environmentObject(uwaziTemplateViewModel)
    }
    
    private var contentView :some View {
            
            ContainerView {
                VStack(alignment: .center) {
                        
                    PageView(selectedOption: $uwaziTemplateViewModel.selectedCell, pageViewItems: $uwaziTemplateViewModel.pageViewItems)
                        .frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
                            
                    VStack (spacing: 0) {
                        Spacer()
                        switch uwaziTemplateViewModel.selectedCell {
                        
                        case .templates:
                            TemplateListView(
                                             message: LocalizableUwazi.uwaziTemplateListEmptyExpl.localized, serverName: uwaziTemplateViewModel.serverName)
                            .environmentObject(uwaziTemplateViewModel)
                        case .draft:
                            ReportListView(reportArray: $uwaziTemplateViewModel.draftReports,
                                           message: LocalizableReport.reportsDraftEmpty.localized)
                                        
                        case .outbox:
                                        
                            ReportListView(reportArray: $uwaziTemplateViewModel.outboxedReports,
                                           message: LocalizableReport.reportsOutboxEmpty.localized)
                                        
                        case .submitted:
                            ReportListView(reportArray: $uwaziTemplateViewModel.submittedReports,
                                           message: LocalizableReport.reportsSubmitedEmpty.localized)
                        }
                                    
                        Spacer()
                    }
                    
                    AddFileYellowButton(action: {
                        navigateTo(destination: AddTemplatesView(downloadTemplateAction: uwaziTemplateViewModel.downloadTemplate)
                            .environmentObject(uwaziTemplateViewModel))
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

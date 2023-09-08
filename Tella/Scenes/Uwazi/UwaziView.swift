//
//  UwaziView.swift
//  Tella
//
//  Created by Gustavo on 27/07/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct UwaziView: View {
    @EnvironmentObject var mainAppModel : MainAppModel
    @EnvironmentObject var sheetManager : SheetManager
    @EnvironmentObject var uwaziReportsViewModel: UwaziTemplateViewModel
    
    var body: some View {
        contentView
            .navigationBarTitle(LocalizableUwazi.uwaziTitle.localized, displayMode: .large)
            .environmentObject(uwaziReportsViewModel)
    }
    
    private var contentView :some View {
            
            ContainerView {
                VStack(alignment: .center) {
                            
                    PageView(selectedOption: $uwaziReportsViewModel.selectedCell, pageViewItems: $uwaziReportsViewModel.pageViewItems)
                        .frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
                            
                    VStack (spacing: 0) {
                        Spacer()
                        switch uwaziReportsViewModel.selectedCell {
                        
                        case .templates:
                            TemplateListView(
                                             message: LocalizableUwazi.uwaziTemplateListEmptyExpl.localized, serverName: uwaziReportsViewModel.serverName)
                            .environmentObject(uwaziReportsViewModel)
                        case .draft:
                            ReportListView(reportArray: $uwaziReportsViewModel.draftReports,
                                           message: LocalizableReport.reportsDraftEmpty.localized)
                                        
                        case .outbox:
                                        
                            ReportListView(reportArray: $uwaziReportsViewModel.outboxedReports,
                                           message: LocalizableReport.reportsOutboxEmpty.localized)
                                        
                        case .submitted:
                            ReportListView(reportArray: $uwaziReportsViewModel.submittedReports,
                                           message: LocalizableReport.reportsSubmitedEmpty.localized)
                        }
                                    
                        Spacer()
                    }
                    
                    AddFileYellowButton(action: {
                        navigateTo(destination: AddTemplatesView(
                            downloadTemplateAction: uwaziReportsViewModel.downloadTemplate, deleteTemplateAction: {
                                print($0)
                            }
                        ).environmentObject(uwaziReportsViewModel))
                    }).frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
                            
                    }.background(Styles.Colors.backgroundMain)
                    .padding(EdgeInsets(top: 15, leading: 20, bottom: 16, trailing: 20))
            }
            .onAppear(perform: {
                //uwaziReportsViewModel.getTemplates()
            })
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

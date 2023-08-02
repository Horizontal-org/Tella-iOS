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
    @StateObject private var uwaziReportsViewModel : UwaziReportsViewModel
    @EnvironmentObject var sheetManager : SheetManager
    
    let server : Server
    
    init(mainAppModel: MainAppModel, server: Server) {
        _uwaziReportsViewModel = StateObject(wrappedValue: UwaziReportsViewModel(mainAppModel: mainAppModel, server: server))
        self.server = server
    }
    var body: some View {
        contentView
            .navigationBarTitle("Uwazi", displayMode: .large)
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
                            TemplateListView(templateArray: $uwaziReportsViewModel.templates,
                                           message: "Templates")
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
                        // this should navigate to download template
                    })
                            
                    }.background(Styles.Colors.backgroundMain)
                    .padding(EdgeInsets(top: 15, leading: 20, bottom: 16, trailing: 20))
            }
            .onAppear(perform: {
                uwaziReportsViewModel.getTemplates()
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
        UwaziView(mainAppModel: MainAppModel.stub(), server: Server(autoUpload: false, autoDelete: false) )
    }
}

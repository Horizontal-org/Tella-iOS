//
//  ReportsPageView.swift
//  Tella
//
//  Created by Gustavo on 31/07/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct ReportsPageView: View {
    @Binding var selectedCell : Pages
    @Binding var pageViewItems : [PageViewItem]
    @Binding var draftReports : [Report]
    @Binding var outboxedReports : [Report]
    @Binding var submittedReports : [Report]
    var navigateToAction : () -> Void
    
    var body: some View {
                    
            VStack(alignment: .center) {
                        
                PageView(selectedOption: $selectedCell, pageViewItems: $pageViewItems)
                    .frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
                        
                VStack (spacing: 0) {
                    Spacer()
                                
                    switch selectedCell {
                    
                    case .templates:
                        ReportListView(reportArray: $draftReports,
                                       message: "Templates")
                    case .draft:
                        ReportListView(reportArray: $draftReports,
                                       message: LocalizableReport.reportsDraftEmpty.localized)
                                    
                    case .outbox:
                                    
                        ReportListView(reportArray: $outboxedReports,
                                       message: LocalizableReport.reportsOutboxEmpty.localized)
                                    
                    case .submitted:
                        ReportListView(reportArray: $submittedReports,
                                       message: LocalizableReport.reportsSubmitedEmpty.localized)
                    }
                                
                    Spacer()
                }
                
                TellaButtonView<AnyView> (title: LocalizableReport.reportsCreateNew.localized,
                                          nextButtonAction: .action,
                                          buttonType: .yellow,
                                          isValid: .constant(true)) {
                            navigateToAction()
                } .padding(EdgeInsets(top: 30, leading: 0, bottom: 0, trailing: 0))
                        
                }.background(Styles.Colors.backgroundMain)
                .padding(EdgeInsets(top: 15, leading: 20, bottom: 16, trailing: 20))

    }
}

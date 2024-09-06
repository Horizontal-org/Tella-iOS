//
//  TellaServerReportsMainView.swift
//  Tella
//
//  Created by RIMA on 6/9/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI
struct TellaServerReportsMainView: View {
    
    @ObservedObject var reportsMainViewModel: ReportsViewModel
    
    var body: some View {
        ReportMainView(reportsMainViewModel: reportsMainViewModel) { id in
            var destination: any View
            destination = TellaServerDraftView(mainAppModel: reportsMainViewModel.mainAppModel, reportId: id,reportsViewModel: reportsMainViewModel)
            self.navigateTo(destination: destination)
        } showSubmittedViewAction: { id in
            let vm = SubmittedReportVM(mainAppModel: reportsMainViewModel.mainAppModel, reportId: id)
            let destination = SubmittedDetailsView(submittedReportVM: vm, reportsViewModel: reportsMainViewModel)
            self.navigateTo(destination: destination)
        } showOutboxViewAction: { id in
            let outboxViewModel = OutboxReportVM(mainAppModel: reportsMainViewModel.mainAppModel,
                                                 reportsViewModel: reportsMainViewModel,
                                                 reportId: id)
            let destination = OutboxDetailsView(outboxReportVM: outboxViewModel,
                                                reportsViewModel: reportsMainViewModel)
            self.navigateTo(destination: destination)
        }
    }
}

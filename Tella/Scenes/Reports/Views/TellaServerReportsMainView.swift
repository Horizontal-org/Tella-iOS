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
            showDraftView(id)
        } showSubmittedViewAction: { id in
            showSubmittedView(id)
        } showOutboxViewAction: { id in
            showOutboxView(id)
        }
    }
    
    private func showDraftView(_ id: Int?) {
        var destination: any View
        destination = TellaServerDraftView(reportId: id,reportsViewModel: reportsMainViewModel)
        self.navigateTo(destination: destination)
    }
    
    private func showSubmittedView(_ id: Int?) {
        let vm = SubmittedReportVM(reportsMainViewModel: reportsMainViewModel, reportId: id)
        let destination = TellaServerSubmittedDetailsView(submittedMainViewModel: vm)
        self.navigateTo(destination: destination)
    }
    
    private func showOutboxView(_ id: Int?) {
        let outboxViewModel = OutboxReportVM(reportsViewModel: reportsMainViewModel,
                                             reportId: id)
        let destination = TellaServerOutboxDetailsView(outboxReportVM: outboxViewModel)
        self.navigateTo(destination: destination)
    }
}

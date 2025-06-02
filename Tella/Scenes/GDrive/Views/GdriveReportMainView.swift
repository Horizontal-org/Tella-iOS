//
//  GdriveReportMainView.swift
//  Tella
//
//  Created by RIMA on 6/9/2024.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI
struct GdriveReportMainView: View {
    
    @ObservedObject var reportsMainViewModel: GDriveViewModel
    
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
        var destination : any View
        destination = GDriveDraftView(gDriveDraftVM: GDriveDraftViewModel(repository: reportsMainViewModel.gDriveRepository, reportId: id, reportsMainViewModel: reportsMainViewModel))
        self.navigateTo(destination: destination)
    }
    
    private func showSubmittedView(_ id: Int?) {
        let vm = GDriveSubmittedViewModel(reportsMainViewModel: reportsMainViewModel, reportId: id)
        let destination = GDriveSubmittedDetailsView(submittedMainViewModel: vm)
        self.navigateTo(destination: destination)
    }
    
    private func showOutboxView(_ id: Int?) {
        let outboxViewModel = GDriveOutboxViewModel(reportsViewModel: reportsMainViewModel,
                                                    reportId: id,
                                                    repository: reportsMainViewModel.gDriveRepository)
        let destination = GdriveOutboxDetailsView(outboxReportVM: outboxViewModel)
        self.navigateTo(destination: destination)
    }
}

//
//  GdriveReportMainView.swift
//  Tella
//
//  Created by RIMA on 6/9/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI
struct GdriveReportMainView: View {
    
    @ObservedObject var reportsMainViewModel: GDriveViewModel
    
    var body: some View {
        ReportMainView(reportsMainViewModel: reportsMainViewModel) { id in
            var destination : any View
            destination = GDriveDraftView(gDriveDraftVM: GDriveDraftViewModel(repository: reportsMainViewModel.gDriveRepository, reportId: id, reportsMainViewModel: reportsMainViewModel))
            self.navigateTo(destination: destination)
        } showSubmittedViewAction: { id in
            let vm = GDriveSubmittedViewModel(reportsMainViewModel: reportsMainViewModel, reportId: id)
            let destination = GDriveSubmittedDetailsView(submittedMainViewModel: vm)
            self.navigateTo(destination: destination)
        } showOutboxViewAction: { id in
            let outboxViewModel = GDriveOutboxViewModel(reportsViewModel: reportsMainViewModel,
                                                        reportId: id,
                                                        repository: reportsMainViewModel.gDriveRepository)
            let destination = GdriveOutboxDetailsView(outboxReportVM: outboxViewModel)
            self.navigateTo(destination: destination)
        }
        
    }
}

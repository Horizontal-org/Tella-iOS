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
            destination = GDriveDraftView(gDriveDraftVM: GDriveDraftViewModel(mainAppModel: reportsMainViewModel.mainAppModel,
                                                                              repository: reportsMainViewModel.gDriveRepository, reportId: id), reportsViewModel: reportsMainViewModel)
            self.navigateTo(destination: destination)
        } showSubmittedViewAction: { id in
            let vm = GDriveSubmittedViewModel(mainAppModel: reportsMainViewModel.mainAppModel, reportId: id)
            let destination = GDriveSubmittedDetailsView(submittedMainViewModel: vm, reportsMainViewModel: reportsMainViewModel)
            self.navigateTo(destination: destination)
        } showOutboxViewAction: { id in
            let outboxViewModel = GDriveOutboxViewModel(mainAppModel: reportsMainViewModel.mainAppModel,
                                                        reportsViewModel: reportsMainViewModel,
                                                        reportId: id,
                                                        repository: reportsMainViewModel.gDriveRepository)
            let destination = GdriveOutboxDetailsView(outboxReportVM: outboxViewModel,
                                                reportsViewModel: reportsMainViewModel)
            self.navigateTo(destination: destination)
        }
        
    }
}

//
//  NextcloudReportMainView.swift
//  Tella
//
//  Created by RIMA on 5/9/2024.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI
struct NextcloudReportMainView: View {
    
    @ObservedObject var reportsMainViewModel: NextcloudReportViewModel
    
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
        destination = NextcloudDraftView(nextcloudDraftViewModel: NextcloudDraftViewModel(repository: reportsMainViewModel.nextcloudRepository, reportId: id, reportsMainViewModel: reportsMainViewModel))
        self.navigateTo(destination: destination)
    }
    
    private func showSubmittedView(_ id: Int?) {
        let vm = NextcloudSubmittedViewModel(reportsMainViewModel: reportsMainViewModel, reportId: id)
        let destination = NextcloudSubmittedDetailsView(submittedMainViewModel: vm)
        self.navigateTo(destination: destination)
    }
    
    private func showOutboxView(_ id: Int?) {
        let outboxViewModel = NextcloudOutboxViewModel(reportsViewModel: reportsMainViewModel,
                                                       reportId: id,
                                                       repository:reportsMainViewModel.nextcloudRepository)
        let destination = NextcloutOutboxDetailsView(outboxReportVM: outboxViewModel)
        self.navigateTo(destination: destination)
    }
}

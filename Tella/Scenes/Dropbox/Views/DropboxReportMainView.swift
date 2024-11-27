//
//  DropboxReportMainView.swift
//  Tella
//
//  Created by gus valbuena on 9/12/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct DropboxReportMainView: View {
    @ObservedObject var reportsMainViewModel: DropboxViewModel
    
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
        let draftVM = DropboxDraftViewModel(DropboxRepository: reportsMainViewModel.dropboxRepository,
                                            reportId: id,
                                            reportsMainViewModel: reportsMainViewModel)
        
        let destination = DropboxDraftView(dropboxDraftVM: draftVM)
        self.navigateTo(destination: destination)
    }
    
    private func showOutboxView(_ id: Int?) {
        let outboxVM = DropboxOutboxViewModel(reportsViewModel: reportsMainViewModel,
                                                     reportId: id,
                                                     repository: reportsMainViewModel.dropboxRepository)
        
        let destination = DropboxOutboxDetailsView(outboxReportVM: outboxVM)
        self.navigateTo(destination: destination)
    }
    
    private func showSubmittedView(_ id: Int?) {
        let submittedVM = DropboxSubmittedViewModel(reportsMainViewModel: reportsMainViewModel, reportId: id)
        
        let destination = DropboxSubmittedDetailsView(submittedMainViewModel: submittedVM)
        self.navigateTo(destination: destination)
    }
}

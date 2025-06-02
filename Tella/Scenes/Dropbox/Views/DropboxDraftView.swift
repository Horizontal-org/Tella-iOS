//
//  DropboxDraftView.swift
//  Tella
//
//  Created by gus valbuena on 9/12/24.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct DropboxDraftView: View {
    @StateObject var dropboxDraftVM: DropboxDraftViewModel
    
    var body: some View {
        DraftView(viewModel: dropboxDraftVM, showOutboxDetailsViewAction: { showOutboxDetailsView() })
    }
    
    private func showOutboxDetailsView() {
        let outboxVM = DropboxOutboxViewModel(reportsViewModel: dropboxDraftVM.reportsMainViewModel, reportId: dropboxDraftVM.reportId, repository: dropboxDraftVM.dropboxRepository)
        navigateTo(destination: DropboxOutboxDetailsView(outboxReportVM: outboxVM))
    }
}

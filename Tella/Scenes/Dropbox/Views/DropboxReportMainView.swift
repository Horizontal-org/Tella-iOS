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
            
        } showOutboxViewAction: { id in
            
        }
    }
    
    private func showDraftView(_ id: Int?) {
        let draftVM = DropboxDraftViewModel(DropboxRepository: reportsMainViewModel.dropboxRepository,
                                            reportId: id,
                                            reportsMainViewModel: reportsMainViewModel)
        
        let destination = DropboxDraftView(dropboxDraftVM: draftVM, reportsViewModel: reportsMainViewModel)
        self.navigateTo(destination: destination)
    }
}

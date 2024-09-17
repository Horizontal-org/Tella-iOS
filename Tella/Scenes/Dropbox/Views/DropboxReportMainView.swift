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
        ReportMainView(reportsMainViewModel: reportsMainViewModel,
                       showDraftViewAction: navigateToDraftView
        )
    }
    
    private func navigateToDraftView(_ id: Int?) {
        let draftVM = DropboxDraftViewModel(DropboxRepository: reportsMainViewModel.dropboxRepository,
                                            reportId: 0,
                                            reportsMainViewModel: reportsMainViewModel)
        
        let destination = DropboxDraftView(dropboxDraftVM: draftVM, reportsViewModel: reportsMainViewModel)
        navigateTo(destination: destination)
    }
}

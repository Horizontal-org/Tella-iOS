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
        let draftVM = DropboxDraftViewModel(mainAppModel: reportsMainViewModel.mainAppModel, DropboxRepository: reportsMainViewModel.dropboxRepository, reportId: 0)
        
        navigateTo(destination: DropboxDraftView(dropboxDraftVM: draftVM, reportsViewModel: reportsMainViewModel))
    }
}

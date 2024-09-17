//
//  GDriveDraftView.swift
//  Tella
//
//  Created by gus valbuena on 6/13/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct GDriveDraftView: View {
    @StateObject var gDriveDraftVM: GDriveDraftViewModel
    
    var body: some View {
        DraftView(viewModel: gDriveDraftVM, showOutboxDetailsViewAction: { showOutboxDetailsView()
        })
    }
    
    private func showOutboxDetailsView() {
        let outboxVM = GDriveOutboxViewModel(reportsViewModel: gDriveDraftVM.reportsMainViewModel, reportId: gDriveDraftVM.reportId, repository: gDriveDraftVM.gDriveRepository)
        navigateTo(destination: GdriveOutboxDetailsView(outboxReportVM: outboxVM))
    }
}

//
//#Preview {
//    GDriveDraftView(mainAppModel: MainAppModel.stub()) //TOFix
//}


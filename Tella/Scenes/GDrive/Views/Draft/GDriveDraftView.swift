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
    @EnvironmentObject var mainAppModel : MainAppModel
    @EnvironmentObject var reportsViewModel : ReportMainViewModel
    let gDriveDIContainer: GDriveDIContainer
    
    init(mainAppModel: MainAppModel, gDriveDIContainer: GDriveDIContainer, reportId: Int? = nil) {
        self.gDriveDIContainer = gDriveDIContainer
        _gDriveDraftVM = StateObject(wrappedValue: GDriveDraftViewModel(
            mainAppModel: mainAppModel,
            repository: gDriveDIContainer.gDriveRepository,
            reportId: reportId)
        )
    }
    
    var body: some View {
        DraftView(viewModel: gDriveDraftVM, reportsViewModel: reportsViewModel)
    }
}

#Preview {
    GDriveDraftView(mainAppModel: MainAppModel.stub(), gDriveDIContainer: GDriveDIContainer())
}

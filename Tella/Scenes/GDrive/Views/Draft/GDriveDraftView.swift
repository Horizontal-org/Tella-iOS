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
    @EnvironmentObject var reportsViewModel : BaseReportsViewModel
    let gDriveDIContainer: GDriveDIContainer
    
    init(mainAppModel: MainAppModel, gDriveDIContainer: GDriveDIContainer, reportId: Int? = nil) {
        self.gDriveDIContainer = gDriveDIContainer
        _gDriveDraftVM = StateObject(wrappedValue: GDriveDraftViewModel(
            mainAppModel: mainAppModel,
            repository: gDriveDIContainer.gDriveRepository,
            reportID: reportId)
        )
    }
    
    var body: some View {
        Text("")

//        DraftView<GDriveDraftViewModel>(viewModel: gDriveDraftVM, reportsViewModel: <#ReportMainViewModel#>)
//            .environmentObject(mainAppModel)
//            .environmentObject(reportsViewModel)
    }
}

#Preview {
    GDriveDraftView(mainAppModel: MainAppModel.stub(), gDriveDIContainer: GDriveDIContainer())
}

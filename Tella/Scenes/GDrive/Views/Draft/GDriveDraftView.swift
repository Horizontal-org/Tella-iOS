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
    
    init(mainAppModel: MainAppModel, gDriveDIContainer: GDriveDIContainer) {
        self.gDriveDIContainer = gDriveDIContainer
        _gDriveDraftVM = StateObject(wrappedValue: GDriveDraftViewModel(
            mainAppModel: mainAppModel,
            repository: gDriveDIContainer.gDriveRepository)
        )
    }
    
    var body: some View {
        DraftView<GDriveDraftViewModel>(viewModel: gDriveDraftVM)
            .environmentObject(mainAppModel)
            .environmentObject(reportsViewModel)
    }
}

#Preview {
    GDriveDraftView(mainAppModel: MainAppModel.stub(), gDriveDIContainer: GDriveDIContainer())
}
//
//  CreateDriveFolderView.swift
//  Tella
//
//  Created by gus valbuena on 5/21/24.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI


struct CreateDriveFolderView: View {
    
    @StateObject var gDriveServerViewModel: GDriveServerViewModel
    
    var body: some View {
        ServerCreateFolderView(createFolderViewModel: gDriveServerViewModel.serverCreateFolderVM, navigateToSuccessLogin: navigateToSuccessLogin)
    }
    
    private func navigateToSuccessLogin() {
        if gDriveServerViewModel.serversSourceView == .onboarding {
                self.popTo(ViewClassType.serverOnboardingView)
            } else {

            navigateTo(destination: SuccessLoginView(navigateToAction: {navigateTo(destination: reportsView)},
                                                     type: .gDrive))
        }
    }
    private var reportsView: GdriveReportMainView {
        GdriveReportMainView(reportsMainViewModel: GDriveViewModel(mainAppModel: gDriveServerViewModel.mainAppModel, gDriveRepository: GDriveRepository()))
    }

}

#Preview {
    CreateDriveFolderView(gDriveServerViewModel: GDriveServerViewModel(repository: GDriveRepository(), mainAppModel: MainAppModel.stub()))
}

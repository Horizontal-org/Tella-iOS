//
//  CreateDriveFolderView.swift
//  Tella
//
//  Created by gus valbuena on 5/21/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI


struct CreateDriveFolderView: View {
    
    @StateObject var gDriveServerViewModel: GDriveServerViewModel
    
    var body: some View {
        ServerCreateFolderView(createFolderViewModel: gDriveServerViewModel.serverCreateFolderVM, navigateToSuccessLogin: navigateToSuccessLogin)
    }
    
    private func navigateToSuccessLogin() {
        navigateTo(destination: SuccessLoginView(navigateToAction: {navigateTo(destination: reportsView)},
                                                 type: .gDrive))
    }
    private var reportsView: GdriveReportMainView {
        GdriveReportMainView(reportsMainViewModel: GDriveViewModel(mainAppModel: gDriveServerViewModel.mainAppModel, gDriveRepository: GDriveRepository()))
    }

}

#Preview {
    CreateDriveFolderView(gDriveServerViewModel: GDriveServerViewModel(repository: GDriveRepository(), mainAppModel: MainAppModel.stub()))
}

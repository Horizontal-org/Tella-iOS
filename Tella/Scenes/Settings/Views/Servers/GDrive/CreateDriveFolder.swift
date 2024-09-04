//
//  CreateDriveFolderView.swift
//  Tella
//
//  Created by gus valbuena on 5/21/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct CreateDriveFolderView: View {
    
    @EnvironmentObject var gDriveServerViewModel: GDriveServerViewModel
    
    var body: some View {
        ServerCreateFolderView(createFolderViewModel: gDriveServerViewModel.serverCreateFolderVM, navigateToSuccessLogin: navigateToSuccessLogin)
    }
    
    private func navigateToSuccessLogin() {
        navigateTo(destination: SuccessLoginView(navigateToAction: {self.popToRoot()}, type: .gDrive))
    }
    // Should navigate to reports view
    private var reportsView: some View {
        ReportMainView(reportMainViewModel: GDriveViewModel(mainAppModel: gDriveServerViewModel.mainAppModel)/*, diContainer: GDriveDIContainer()*/) //Must be checked again
    }

}

#Preview {
    CreateDriveFolderView()
}

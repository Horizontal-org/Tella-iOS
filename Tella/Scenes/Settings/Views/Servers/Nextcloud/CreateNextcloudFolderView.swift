//
//  CreateNextcloudFolderView.swift
//  Tella
//
//  Created by RIMA on 5/7/2024.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct CreateNextcloudFolderView: View {
    
    @StateObject var nextcloudVM: NextcloudServerViewModel
    
    var body: some View {
        ServerCreateFolderView(createFolderViewModel: nextcloudVM.serverCreateFolderVM, navigateToSuccessLogin: navigateToSuccessLogin)
    }
    
    private func navigateToSuccessLogin() {
        navigateTo(destination: SuccessLoginView(navigateToAction: {self.popToRoot()}, type: .nextcloud))
    }
}

#Preview {
    CreateNextcloudFolderView(nextcloudVM: NextcloudServerViewModel(nextcloudRepository: NextcloudRepository(), mainAppModel: MainAppModel.stub()))
}

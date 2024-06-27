//
//  UwaziAddServerURLView.swift
//  Tella
//
//  Created by Robert Shrestha on 4/18/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct UwaziAddServerURLView: View {
    @EnvironmentObject var serversViewModel : ServersViewModel
    @StateObject var uwaziServerViewModel : UwaziServerViewModel
    
    var body: some View {
        AddServerURLView(viewModel: uwaziServerViewModel)
            .onAppear {
                self.uwaziServerViewModel.fillUwaziServer()
            }
            .onReceive(uwaziServerViewModel.$isPublicInstance) { isPublicInstance in
                guard let isPublicInstance = isPublicInstance else { return }
                handleNavigation(isPublicInstance: isPublicInstance)
            }
    }
    
    func handleNavigation(isPublicInstance: Bool) {
        if isPublicInstance {
            let serverAccess = UwaziServerAccessSelectionView()
                .environmentObject(uwaziServerViewModel)
                .environmentObject(serversViewModel)
            navigateTo(destination: serverAccess)
        } else {
            let loginView = UwaziLoginView()
                .environmentObject(serversViewModel)
                .environmentObject(uwaziServerViewModel)
            navigateTo(destination: loginView)
        }
    }
}

struct UwaziAddServerURLView_Previews: PreviewProvider {
    static var previews: some View {
        UwaziAddServerURLView(uwaziServerViewModel: UwaziServerViewModel(mainAppModel: MainAppModel.stub(), currentServer: nil))
    }
}

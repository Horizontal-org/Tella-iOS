//
//  UwaziAddServerURLView.swift
//  Tella
//
//  Created by Robert Shrestha on 4/18/23.
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct UwaziAddServerURLView: View {
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
            let serverAccess = UwaziServerAccessSelectionView(uwaziServerViewModel: uwaziServerViewModel)
            navigateTo(destination: serverAccess)
        } else {
            let loginView = UwaziLoginView(uwaziServerViewModel: uwaziServerViewModel)
            navigateTo(destination: loginView)
        }
    }
}

struct UwaziAddServerURLView_Previews: PreviewProvider {
    static var previews: some View {
        UwaziAddServerURLView(uwaziServerViewModel: UwaziServerViewModel.stub())
    }
}

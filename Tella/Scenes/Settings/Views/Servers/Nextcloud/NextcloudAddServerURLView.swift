//
//  NextcloudAddServerURLView.swift
//  Tella
//
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct NextcloudAddServerURLView: View {
    var nextcloudVM: NextcloudServerViewModel
    
    var body: some View {
        AddServerURLView(viewModel: nextcloudVM,
                         successCheckServerAction: {
            navigateToLoginView()
        })
    }
    
    func navigateToLoginView() {
        navigateTo(destination: NextcloudServerLoginView(nextcloudVM: nextcloudVM))
    }
}

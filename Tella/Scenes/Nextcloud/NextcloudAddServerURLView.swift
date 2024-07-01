//
//  NextcloudAddServerURLView.swift
//  Tella
//
//  Copyright © 2024 HORIZONTAL. All rights reserved.
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
        
    }
}

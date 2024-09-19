//
//  NextcloudServerLoginView.swift
//  Tella
//
//  Created by RIMA on 2/7/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct NextcloudServerLoginView: View {
    
    var nextcloudVM: NextcloudServerViewModel
    
    var body: some View {
        ServerLoginView(viewModel: nextcloudVM) {
            navigateTo(destination: CreateNextcloudFolderView(nextcloudVM: nextcloudVM))
        }
    }
}

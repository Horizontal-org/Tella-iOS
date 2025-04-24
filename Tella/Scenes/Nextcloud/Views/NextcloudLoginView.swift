//
//  NextcloudLoginView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 13/8/2024.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import SwiftUI

struct NextcloudLoginView: View {
    
    var nextcloudVM: NextcloudServerViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        ServerLoginView(viewModel: nextcloudVM) {
            self.presentationMode.wrappedValue.dismiss()
        }
    }
}

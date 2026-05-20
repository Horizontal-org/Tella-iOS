//
//  AddFileCameraView.swift
//  Tella
//
//  Created by RIMA on 26.02.25.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI
struct AddFileCameraView: View {
    @ObservedObject var viewModel: AddFilesViewModel
    
    var sourceView = SourceView.addFile
    
    var body: some View {
        viewModel.showingCamera ?
        CameraView(sourceView: sourceView,
                   showingCameraView: $viewModel.showingCamera,
                   resultFile: $viewModel.resultFile,
                   mainAppModel: viewModel.mainAppModel) : nil
    }
}


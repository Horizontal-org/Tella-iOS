//
//  AddFilePhotoVideoPickerView.swift
//  Tella
//
//  Created by RIMA on 26.02.25.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct AddFilePhotoVideoPickerView: View {
    
    @ObservedObject var viewModel: AddFilesViewModel
    
    var body: some View {
        PhotoVideoPickerView(showingImagePicker: $viewModel.showingImagePicker,
                             showingImportDocumentPicker: $viewModel.showingImportDocumentPicker,
                             mainAppModel: viewModel.mainAppModel,
                             resultFile: $viewModel.resultFile)
        
    }
}

//
//  AddFilePhotoVideoPickerView.swift
//  Tella
//
//  Created by RIMA on 26.02.25.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct AddFilePhotoVideoPickerView: View {
    
    @ObservedObject var viewModel: AddFilesViewModel
    
    var body: some View {
        PhotoVideoPickerView(showingImagePicker: $viewModel.showingImagePicker,
                             showingImportDocumentPicker: $viewModel.showingImportDocumentPicker,
                             appModel: viewModel.mainAppModel,
                             resultFile: $viewModel.resultFile)
        
    }
}

//
//  AddFileRecordView.swift
//  Tella
//
//  Created by RIMA on 26.02.25.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI
struct AddFileRecordView: View {
    
    @ObservedObject var viewModel: AddFilesViewModel
    
    var body: some View {
        viewModel.showingRecordView ?
        RecordView(mainAppModel: viewModel.mainAppModel,
                   sourceView: .addReportFile,
                   showingRecoredrView: $viewModel.showingRecordView,
                   resultFile: $viewModel.resultFile) : nil
        
    }
}

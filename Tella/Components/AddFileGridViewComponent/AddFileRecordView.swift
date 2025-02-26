//
//  AddFileRecordView.swift
//  Tella
//
//  Created by RIMA on 26.02.25.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import SwiftUI
struct AddFileRecordView: View {
    
    @ObservedObject var viewModel: AddFilesViewModel
    
    var body: some View {
        viewModel.showingRecordView ?
        RecordView(appModel: viewModel.mainAppModel,
                   sourceView: .addReportFile,
                   showingRecoredrView: $viewModel.showingRecordView,
                   resultFile: $viewModel.resultFile) : nil
        
    }
}

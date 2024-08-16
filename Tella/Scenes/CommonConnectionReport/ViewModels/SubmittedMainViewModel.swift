//
//  SubmittedMainViewModel.swift
//  Tella
//
//  Created by gus valbuena on 7/11/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

class SubmittedMainViewModel: ObservableObject {
    
    var mainAppModel : MainAppModel
    
    var report: BaseReport? {
        return nil
    }
    // Report
    @Published var id : Int?
    @Published var title : String = ""
    @Published var description : String = ""
    @Published var files :  [VaultFileDB] = []
    
    @Published var progressFileItems : [ProgressFileItemViewModel] = []
    @Published var uploadedDate : String = ""
    @Published var uploadedFiles : String = ""
    
    var reportHasFile: Bool {
        return !files.isEmpty
    }
    
    var reportHasDescription: Bool {
        return !description.isEmpty
    }
    
    init(mainAppModel: MainAppModel, reportId: Int?) {
        self.mainAppModel = mainAppModel
        fillReportVM(reportId: reportId)
    }

    func fillReportVM(reportId: Int?) {
        
        guard let reportId else {return}
        self.id = reportId

        guard let report else {return}

        self.id = report.id
        self.title = report.title ?? ""
        self.description = report.description ?? ""
        
        let vaultFileResult = mainAppModel.vaultFilesManager?.getVaultFiles(ids: report.reportFiles?.compactMap{$0.fileId} ?? []) ?? []
        self.files = Array(vaultFileResult)
        
        // todo -> progress bar
        progressFileItems = self.files.compactMap{ProgressFileItemViewModel(file: $0, progression:$0.size.getFormattedFileSize() + "/" + $0.size.getFormattedFileSize())}
        let totalSize = self.files.reduce(0) { $0 + $1.size }
        
        if let date = report.createdDate {
            let formattedDate = date.getFormattedDateString(format: DateFormat.submittedReport.rawValue)
            self.uploadedDate = String(format: LocalizableReport.uploadedDate.localized, formattedDate)
        }
        
        let fileNumber = self.files.count
        let fileString = fileNumber == 1 ? LocalizableReport.reportFile.localized : LocalizableReport.reportFiles.localized
        self.uploadedFiles = "\(fileNumber) \(fileString), \(totalSize.getFormattedFileSize())"
        
    }

    func deleteReport() {}
}

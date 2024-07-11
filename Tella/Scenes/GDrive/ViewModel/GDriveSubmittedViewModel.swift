//
//  GDriveSubmittedViewModel.swift
//  Tella
//
//  Created by gus valbuena on 7/11/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

class GDriveSubmittedViewModel: SubmittedMainViewModel {
    override init(mainAppModel: MainAppModel, shouldStartUpload: Bool = false, reportId: Int?) {
        super.init(mainAppModel: mainAppModel, shouldStartUpload: shouldStartUpload, reportId: reportId)
        fillReportVM(reportId: reportId)
    }
    
    override func fillReportVM(reportId: Int?) {
        if let reportId, let report = self.mainAppModel.tellaData?.getDriveReport(id: reportId) {
            self.id = report.id
            self.title = report.title ?? ""
            self.description = report.description ?? ""
            
            let vaultFileResult = mainAppModel.vaultFilesManager?.getVaultFiles(ids: report.reportFiles?.compactMap{$0.fileId} ?? []) ?? []
            self.files = Array(vaultFileResult)
            
            // todo -> progress bar
            progressFileItems = self.files.compactMap{ProgressFileItemViewModel(file: $0, progression:$0.size.getFormattedFileSize() + "/" + $0.size.getFormattedFileSize())}
            let totalSize = self.files.reduce(0) { $0 + $1.size }
            
            if let date = report.createdDate {
                self.uploadedDate = "Uploaded on \(date.getFormattedDateString(format: DateFormat.submittedReport.rawValue))"
            }
            
            let fileNumber = self.files.count
            let fileString = fileNumber == 1 ? "file" : "files"
            self.uploadedFiles = "\(fileNumber) \(fileString), \(totalSize.getFormattedFileSize())"
        }
    }
    
    override func deleteReport() {
        let _ = mainAppModel.tellaData?.deleteDriveReport(reportId: id)
    }
}

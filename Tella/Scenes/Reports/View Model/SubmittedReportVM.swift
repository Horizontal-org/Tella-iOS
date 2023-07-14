//
//  Copyright © 2023 INTERNEWS. All rights reserved.
//

import Foundation
import Combine

class SubmittedReportVM: ObservableObject {
    
    var mainAppModel : MainAppModel
    
    // Report
    @Published var id : Int?
    @Published var title : String = ""
    @Published var description : String = ""
    @Published var files :  [VaultFile] = []
    
    @Published var progressFileItems : [ProgressFileItemViewModel] = []
    @Published var uploadedDate : String = ""
    @Published var uploadedFiles : String = ""
    
    var reportHasFile: Bool {
        return !files.isEmpty
    }
    
    var reportHasDescription: Bool {
        return !description.isEmpty
    }
    
    init(mainAppModel: MainAppModel, shouldStartUpload: Bool = false, reportId: Int?) {
        self.mainAppModel = mainAppModel
        fillReportVM(reportId: reportId)
    }
    
    func fillReportVM(reportId:Int?) {
        
        if let reportId ,let report = self.mainAppModel.vaultManager.tellaData.getReport(reportId: reportId) {
            
            // Init file
            var vaultFileResult : Set<VaultFile> = []
            
            self.id = report.id
            self.title = report.title ?? ""
            self.description = report.description ?? ""
            
            mainAppModel.vaultManager.root.getFile(root: mainAppModel.vaultManager.root,
                                                   vaultFileResult: &vaultFileResult,
                                                   ids: report.reportFiles?.compactMap{$0.fileId} ?? [])
            self.files = Array(vaultFileResult)
            
            // Initialize progression Infos
            progressFileItems = self.files.compactMap{ProgressFileItemViewModel(file: $0, progression:$0.size.getFormattedFileSize() + "/" + $0.size.getFormattedFileSize())}
            let totalSize = self.files.reduce(0) { $0 + $1.size}
            
            // Display "Uploaded on 12.10.2021, 3:45 AM"
            if let date = report.createdDate {
                self.uploadedDate = "Uploaded on \(date.getFormattedDateString(format: DateFormat.submittedReport.rawValue))"
            }
            
            // Display 11 files, 89MB
            let fileNumber = self.files.count
            let fileString = fileNumber == 1 ? "file" : "files"
            self.uploadedFiles = "\(fileNumber) \(fileString), \(totalSize.getFormattedFileSize())"
        }
    }
    
    func deleteReport() {
        mainAppModel.deleteReport(reportId: id)
    }
}

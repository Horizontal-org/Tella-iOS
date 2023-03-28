//  Tella
//
//  Copyright © 2023 INTERNEWS. All rights reserved.
//

import Foundation
import Combine

class AutoUpload: BaseUploadOperation {
    
    var files : [VaultFile] = []
    fileprivate var file : VaultFile?
    
    override init(urlSession:URLSession, mainAppModel :MainAppModel,type: OperationType) {
        super.init(urlSession: urlSession, mainAppModel: mainAppModel, type:.autoUpload)
    }
    
    override func main() {
        handleResponse()
    }
    
    func addFile(file:VaultFile) {
        self.files.append(file)
        startUploadReportAndFiles()
    }
    
    func startUploadReportAndFiles() {
        
        self.file = files.first
        
        if let currentReport = self.mainAppModel.vaultManager.tellaData.getCurrentReport(), let reportId = currentReport.id, let file = self.file {
            
            do {
                
                if let reportFile = try self.mainAppModel.vaultManager.tellaData.addReportFile(fileId: file.id, reportId: reportId) {
                    currentReport.reportFiles?.append(reportFile)
                }
                
                if currentReport.apiID != nil { // Has API ID
                    self.prepareReportToSend(report: currentReport)
                    uploadFiles()
                    
                } else if currentReport.status != .submissionInProgress { //reportFile to ReportVaultFile
                    self.prepareReportToSend(report: currentReport)
                    self.sendReport()
                }
            } catch {
                
            }
        } else {
            createNewReport()
        }
    }
    
    func createNewReport() {
        guard let file else { return}
        
        let reportToAdd = Report(title: "Auto-report" + Date().getFormattedDateString(format: DateFormat.autoReportNameName.rawValue),
                                 description: "",
                                 status: .finalized,
                                 server: self.mainAppModel.vaultManager.tellaData.getAutoUploadServer(),
                                 vaultFiles: [ReportFile(fileId: file.id,
                                                         status: .notSubmitted,
                                                         bytesSent: 0,
                                                         createdDate: Date(),
                                                         updatedDate: Date())],
                                 currentUpload:true)
        
        do {
            // files
            let report = try self.mainAppModel.vaultManager.tellaData.addCurrentUploadReport(report: reportToAdd)
            self.prepareReportToSend(report: report)
            self.sendReport()
        } catch {
            
        }
    }
    
    func prepareReportToSend(report:Report?) {
        guard let file else { return}
        
        self.report = report
        
        self.updateReport(reportStatus: .submissionInProgress)
        
        var reportVaultFiles : [ReportVaultFile] = []
        
        report?.reportFiles?.forEach({ reportFile in
            let reportVaultFile = ReportVaultFile(reportFile: reportFile, vaultFile: file)
            reportVaultFiles.append(reportVaultFile)
        })
        
        self.reportVaultFiles = reportVaultFiles
    }
    
    func handleResponse() {
        self.response.sink { completion in
            
        } receiveValue: { uploadResponse in
            switch uploadResponse {
            case .progress(let progressInfo):
                
                if progressInfo.status == .submitted || progressInfo.status == .submissionError {
                    self.files.removeAll(where: {$0.id == progressInfo.fileId})
                    self.startUploadReportAndFiles()
                }
                
            default:
                break
            }
        }.store(in: &subscribers)
        
    }
}

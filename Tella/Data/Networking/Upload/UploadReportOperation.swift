//
//  Copyright © 2023 INTERNEWS. All rights reserved.
//

import Foundation


class UploadReportOperation: BaseUploadOperation {
    
    init(report:Report, urlSession:URLSession, mainAppModel :MainAppModel,type: OperationType) {
        super.init(urlSession: urlSession, mainAppModel: mainAppModel, type:type)
        self.report = report
        
        self.mainAppModel.networkMonitor.connexionDidChange.sink(receiveValue: { value in
            if self.report != nil {
                if value && self.report?.status == .submissionPending  {
                    self.startUploadReportAndFiles()
                } else if value == false && self.report?.status != .submissionPending {
                    self.updateReport(reportStatus: .submissionPending)
                    self.stopConnexion()
                    self.response.send(UploadResponse.initial)
                }
            }
        }).store(in: &subscribers)
    }
    
    override func main() {
        super.main()
        startUploadReportAndFiles()
    }
    
    func startUploadReportAndFiles() {
        guard let currentReport = report else { return }
        
        if mainAppModel.networkMonitor.isConnected {
            
            self.updateReport(reportStatus: .submissionInProgress)
            
            self.prepareReportToSend(report: currentReport)
            
            if currentReport.apiID != nil { // Has API ID
                uploadFiles()
                
            } else {
                self.sendReport()
            }
        } else {
            self.updateReport(reportStatus: .submissionPending)

        }
    }
    
    func prepareReportToSend(report:Report?) {
        
        var reportVaultFiles : [ReportVaultFile] = []
        
        var vaultFileResult : Set<VaultFile> = []
        
        mainAppModel.vaultManager.root.getFile(root: mainAppModel.vaultManager.root,
                                               vaultFileResult: &vaultFileResult,
                                               ids: report?.reportFiles?.compactMap{$0.fileId} ?? [])
        
        
        report?.reportFiles?.forEach({ reportFile in
            if let vaultFile = vaultFileResult.first(where: {reportFile.fileId == $0.id}) {
                let reportVaultFile = ReportVaultFile(reportFile: reportFile, vaultFile: vaultFile)
                reportVaultFiles.append(reportVaultFile)
            }
        })
        
        self.reportVaultFiles = reportVaultFiles
    }
    
}

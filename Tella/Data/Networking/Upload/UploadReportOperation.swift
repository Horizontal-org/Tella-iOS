//
//  Copyright © 2023 INTERNEWS. All rights reserved.
//

import Foundation
import UIKit


class UploadReportOperation: BaseUploadOperation {
    
    init(report:Report, urlSession:URLSession, mainAppModel :MainAppModel,type: OperationType) {
        super.init(urlSession: urlSession, mainAppModel: mainAppModel, type:type)
        self.report = report
        setupNetworkMonitor()
    }
    
    override func main() {
        super.main()
        startUploadReportAndFiles()
    }
    
    private func setupNetworkMonitor() {
        self.mainAppModel.networkMonitor.connectionDidChange.sink(receiveValue: { isConnected in
            if self.report != nil {
                if isConnected && self.report?.status == .submissionPending  {
                    self.startUploadReportAndFiles()
                } else if !isConnected && self.report?.status != .submissionPending {
                    self.updateReport(reportStatus: .submissionPending)
                    self.stopConnection()
                    self.response.send(UploadResponse.initial)
                    debugLog("No internet connection")
                }
            }
        }).store(in: &subscribers)
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

        let vaultFileResult = mainAppModel.vaultFilesManager?.getVaultFiles(ids: report?.reportFiles?.compactMap{$0.fileId} ?? [])

        report?.reportFiles?.forEach({ reportFile in
            if let vaultFile = vaultFileResult?.first(where: {reportFile.fileId == $0.id}) {
                let reportVaultFile = ReportVaultFile(reportFile: reportFile, vaultFile: vaultFile)
                reportVaultFiles.append(reportVaultFile)
            }
        })
        
        self.reportVaultFiles = reportVaultFiles
    }
    
}

//  Tella
//
//  Copyright © 2023 INTERNEWS. All rights reserved.
//

import Foundation
import Combine

class AutoUpload: BaseUploadOperation {
    
    override init(urlSession:URLSession, mainAppModel :MainAppModel,type: OperationType) {
        super.init(urlSession: urlSession, mainAppModel: mainAppModel, type:.autoUpload)
        
        setupNetworkMonitor()
    }
    
    override func main() {
        handleResponse()
        super.main()
    }
    
   private func setupNetworkMonitor() {
        mainAppModel.networkMonitor.connexionDidChange.sink(receiveValue: { value in
            if self.report != nil {
                if value && self.report?.status == .submissionPending  {
                    self.checkReport()
                } else if value == false && self.report?.status != .submissionPending {
                    self.stopConnexion()
                }
            }
        }).store(in: &subscribers)
    }
    
    func addFile(file:VaultFile) {
        self.response.send(UploadResponse.initial)
        self.autoPauseReport()
        self.filesToUpload.removeAll()
        startUploadReportAndFiles(file: file)
    }
    
    func startUploadReportAndFiles(file:VaultFile) {
        
        if let currentReport = self.mainAppModel.vaultManager.tellaData.getCurrentReport(), let reportId = currentReport.id {
            
            do {
                
                if let reportFile = try self.mainAppModel.vaultManager.tellaData.addReportFile(fileId: file.id, reportId: reportId) {
                    currentReport.reportFiles?.append(reportFile)
                }
                self.report = currentReport
                self.checkReport()
                
            } catch {
                
            }
        } else {
            createNewReport(file: file)
        }
    }
    
    func createNewReport(file:VaultFile) {
        
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
            self.report = report
            self.checkReport()
        } catch {
            
        }
    }
    
    private func checkReport() {
        if mainAppModel.networkMonitor.isConnected {
            
            if report?.apiID != nil { // Has API ID
                self.prepareReportToSend(report: report)
                uploadFiles()
            } else if report?.status != .submissionInProgress { //reportFile to ReportVaultFile
                self.prepareReportToSend(report: report)
                self.sendReport()
            }
        } else {
            self.updateReport(reportStatus: .submissionPending)
        }
    }
    
    func prepareReportToSend(report:Report?) {
        
        var vaultFileResult : Set<VaultFile> = []
        
        mainAppModel.vaultManager.root.getFile(root: mainAppModel.vaultManager.root,
                                               vaultFileResult: &vaultFileResult,
                                               ids: report?.reportFiles?.compactMap{$0.fileId} ?? [])
        
        self.report = report
        
        self.updateReport(reportStatus: .submissionInProgress)
        
        var reportVaultFiles : [ReportVaultFile] = []
        
        report?.reportFiles?.forEach({ reportFile in
            
            if let vaultFile = vaultFileResult.first(where: {reportFile.fileId == $0.id}) {
                let reportVaultFile = ReportVaultFile(reportFile: reportFile, vaultFile: vaultFile)
                reportVaultFiles.append(reportVaultFile)
            }
        })
        
        self.reportVaultFiles = reportVaultFiles
    }
    
    func handleResponse() {
        self.response.sink { completion in
            
        } receiveValue: { uploadResponse in
            switch uploadResponse {
            case .progress(_):
                break
                
            default:
                break
            }
        }.store(in: &subscribers)
    }
}

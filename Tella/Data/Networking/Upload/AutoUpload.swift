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
        mainAppModel.networkMonitor.connectionDidChange.sink(receiveValue: { isConnected in
            if self.report != nil {
                if isConnected && self.report?.status == .submissionPending  {
                    self.checkReport()
                } else if !isConnected && self.report?.status != .submissionPending {
                    self.stopConnection()
                    debugLog("No internet connection")
                }
            }
        }).store(in: &subscribers)
    }
    
    
    func startUploadReportAndFiles() {
        
        self.response.send(UploadResponse.initial)

        let currentReport = self.mainAppModel.vaultManager.tellaData?.getCurrentReport()
        
        if let currentReport  {
            self.report = currentReport
            self.checkReport()
        }
    }
    
    func addFile(file:VaultFileDB) {
        self.response.send(UploadResponse.initial)
        self.autoPauseReport()
        self.filesToUpload.removeAll()
        startUploadReportAndFiles(file: file)
    }
    
    func startUploadReportAndFiles(file:VaultFileDB) {
        
        let currentReport = self.mainAppModel.vaultManager.tellaData?.getCurrentReport()
        
        if let currentReport {
            self.addReportFile(file: file, report: currentReport)
            self.checkReport()
        } else {
            createNewReport(file: file)
        }
    }
    
    func addReportFile(file:VaultFileDB, report:Report) {
        do {
            guard let reportId = report.id else { return  }
            self.report = report

            let addedReportFile = try self.mainAppModel.vaultManager.tellaData?.addReportFile(fileId: file.id, reportId: reportId)
            
            if let addedReportFile {
                report.reportFiles?.append(addedReportFile)
            }
        } catch {
        }
    }
    
    func createNewReport(file:VaultFileDB) {
        
        let reportToAdd = Report(title: "Auto-report" + Date().getFormattedDateString(format: DateFormat.autoReportNameName.rawValue),
                                 description: "",
                                 status: .finalized,
                                 server: self.mainAppModel.vaultManager.tellaData?.getAutoUploadServer(),
                                 vaultFiles: [ReportFile(fileId: file.id,
                                                         status: .notSubmitted,
                                                         bytesSent: 0,
                                                         createdDate: Date(),
                                                         updatedDate: Date())],
                                 currentUpload:true)
        
        do {
            // files
            let report = try self.mainAppModel.vaultManager.tellaData?.addCurrentUploadReport(report: reportToAdd)
            self.report = report
            self.checkReport()
        } catch {
            
        }
    }
    
    private func checkReport() {
        if mainAppModel.networkMonitor.isConnected {
            
            guard let isNotFinishUploading = self.report?.reportFiles?.filter({$0.status != .submitted}) else {return}
            
            if (!(isNotFinishUploading.isEmpty)) {
                
                if report?.apiID != nil { // Has API ID
                    self.prepareReportToSend(report: report)
                    uploadFiles()
                    // } else if report?.status != .submissionInProgress {
                } else {
                    self.prepareReportToSend(report: report)
                    self.sendReport()
                }
            }
        } else {
            self.updateReport(reportStatus: .submissionPending)
        }
    }
    
    func prepareReportToSend(report:Report?) {
        
//        var vaultFileResult : Set<VaultFileDB> = []
//        
//        mainAppModel.vaultManager.root?.getFile(root: mainAppModel.vaultManager.root,
//                                               vaultFileResult: &vaultFileResult,
//                                               ids: report?.reportFiles?.compactMap{$0.fileId} ?? [])
        
       
        
        let vaultFileResult  = mainAppModel.getVaultFiles(ids: report?.reportFiles?.compactMap{$0.fileId} ?? [])
        
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

//  Tella
//
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import Combine

class AutoUpload: BaseUploadOperation {
    
    override init(urlSession: URLSession, mainAppModel: MainAppModel, reportRepository: ReportRepository, type: OperationType) {
        super.init(urlSession: urlSession, mainAppModel: mainAppModel, reportRepository: reportRepository, type: .autoUpload)
        
        setupNetworkMonitor()
    }
    
    override func main() {
        handleResponse()
        super.main()
        startUploadReportAndFiles()

    }
    
    private func setupNetworkMonitor() {
        mainAppModel.networkMonitor.connectionDidChange.sink { [weak self] isConnected in
            guard let self else { return }
            guard let report = self.report else { return }
            if isConnected && report.status == .submissionPending {
                self.checkReport()
            } else if !isConnected && report.status != .submissionPending {
                self.stopConnection()
                debugLog("No internet connection")
            }
        }.store(in: &subscribers)
    }
    
    
    func startUploadReportAndFiles() {
        
        self.response.send(UploadResponse.initial)

        let currentReport = self.mainAppModel.tellaData?.getCurrentReport()
        
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
        
        let currentReport = self.mainAppModel.tellaData?.getCurrentReport()
        
        if let currentReport {
            self.addReportFile(file: file, report: currentReport)
            self.checkReport()
        } else {
            createNewReport(file: file)
        }
    }
    
    func addReportFile(file:VaultFileDB, report:Report) {
        guard let reportId = report.id else { return }
        self.report = report
        
        let addedReportFile = self.mainAppModel.tellaData?.addReportFile(fileId: file.id, reportId: reportId)
        
        if let addedReportFile{
            report.reportFiles?.append(addedReportFile)
        }
    }
    
    func createNewReport(file:VaultFileDB) {
        
        let reportToAdd = Report(title: "Auto-report" + Date().getFormattedDateString(format: DateFormat.autoReportNameName.rawValue),
                                 description: "",
                                 status: .finalized,
                                 server: self.mainAppModel.tellaData?.getAutoUploadServer(),
                                 vaultFiles: [ReportFile(fileId: file.id,
                                                         status: .notSubmitted,
                                                         bytesSent: 0,
                                                         createdDate: Date(),
                                                         updatedDate: Date())],
                                 currentUpload:true)
        
        // files
        let report = self.mainAppModel.tellaData?.addCurrentUploadReport(report: reportToAdd)
        self.report = report
        self.checkReport()
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
    
    override func prepareReportToSend(report: Report?) {
        self.report = report
        updateReport(reportStatus: .submissionInProgress)
        super.prepareReportToSend(report: report)
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

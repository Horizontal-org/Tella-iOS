//
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import UIKit


class UploadReportOperation: BaseUploadOperation {
    
    init(report: Report, urlSession: URLSession, mainAppModel: MainAppModel, reportRepository: ReportRepository, type: OperationType) {
        super.init(urlSession: urlSession, mainAppModel: mainAppModel, reportRepository: reportRepository, type: type)
        self.report = report
        setupNetworkMonitor()
    }
    
    override func main() {
        super.main()
        startUploadReportAndFiles()
    }
    
    private func setupNetworkMonitor() {
        mainAppModel.networkMonitor.connectionDidChange.sink { [weak self] isConnected in
            guard let self else { return }
            guard let report = self.report else { return }
            if isConnected && report.status == .submissionPending {
                self.startUploadReportAndFiles()
            } else if !isConnected && report.status != .submissionPending {
                self.updateReport(reportStatus: .submissionPending)
                self.stopConnection()
                self.response.send(UploadResponse.initial)
                debugLog("No internet connection")
            }
        }.store(in: &subscribers)
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
    
}

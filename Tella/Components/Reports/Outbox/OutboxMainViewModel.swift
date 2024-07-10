//
//  OutboxMainViewModel.swift
//  Tella
//
//  Created by gus valbuena on 7/10/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class OutboxMainViewModel: ObservableObject {

    var mainAppModel : MainAppModel
    var reportsViewModel : ReportMainViewModel
    
    @Published var reportViewModel : ReportViewModel = ReportViewModel()
    @Published var progressFileItems : [ProgressFileItemViewModel] = []
    @Published var percentUploaded : Float = 0.0
    @Published var percentUploadedInfo : String = LocalizableReport.waitingConnection.localized
    @Published var uploadedFiles : String = ""
    
    @Published var isLoading : Bool = false
    var isSubmissionInProgress: Bool {
        return reportViewModel.status == .submissionInProgress
        
    }
    @Published var shouldShowSubmittedReportView : Bool = false
    @Published var shouldShowMainView : Bool = false
    
    var subscribers = Set<AnyCancellable>()
    var filesToUpload : [FileToUpload] = []
    var reportRepository = ReportRepository()
    
    var uploadButtonTitle: String {
        
        switch reportViewModel.status {
        case .finalized:
            return "Submit"
        case .submissionInProgress:
            return "Pause"
        default:
            return "Resume"
        }
    }
    
    var reportHasFile: Bool {
        return !reportViewModel.files.isEmpty
    }
    
    var reportHasDescription: Bool {
        return !reportViewModel.description.isEmpty
    }
    
    var reportIsNotAutoDelete: Bool {
        return !(reportViewModel.server?.autoDelete ?? true)
    }
    
    
    init(mainAppModel: MainAppModel, reportsViewModel : ReportMainViewModel, reportId : Int?, shouldStartUpload: Bool = false) {
        self.mainAppModel = mainAppModel
        self.reportsViewModel = reportsViewModel

        initVaultFile(reportId: reportId)
        
        initializeProgressionInfos()
        
        if shouldStartUpload {
            self.submitReport()
        } else {
            treat(uploadResponse:reportRepository.checkUploadReportOperation(reportId: self.reportViewModel.id))
        }
    }
    
    func treat(uploadResponse: CurrentValueSubject<UploadResponse?,APIError>?) {

    }
    
    func initVaultFile(reportId: Int?) {}
    
    func initializeProgressionInfos() {}
    
    func pauseSubmission() {}
    
    func submitReport() {}
    
    func showSubmittedReport() {}
    
    func showMainView() {}
    
    func updateProgressInfos(uploadProgressInfo : UploadProgressInfo) {}
    
    // MARK: Update Local database
    
    func updateReportStatus(reportStatus:ReportStatus) {}
    
    func deleteReport() {}
}

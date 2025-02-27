//
//  DraftViewModelProtocol.swift
//  Tella
//
//  Created by gus valbuena on 6/24/24.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import Combine

class DraftMainViewModel: ObservableObject {
    var mainAppModel: MainAppModel
    @Published var reportsMainViewModel: ReportsMainViewModel

    // Report
    @Published var reportId : Int?
    @Published var title : String = ""
    @Published var description : String = ""
    @Published var server :  Server?
    @Published var status : ReportStatus?
    @Published var apiID : String?
    
    // Fields validation
    @Published var isValidTitle : Bool = false
    @Published var isValidDescription : Bool = false
    @Published var shouldShowError : Bool = false
    @Published var reportIsValid : Bool = false
    @Published var reportIsDraft : Bool = false
    
    @Published var successSavingReport : Bool = false
    @Published var failureSavingReport : Bool = false
    
    //MARK: -AddFilesViewModel
    @Published var addFilesViewModel: AddFilesViewModel

    var successSavingReportPublisher: Published<Bool>.Publisher { $successSavingReport }
    var failureSavingReportPublisher: Published<Bool>.Publisher { $failureSavingReport }
    
    var serverArray : [Server] = []
    
    var cancellable : Cancellable? = nil
    var subscribers = Set<AnyCancellable>()
    var delayTime = 2.0
    
    var serverName : String {
        guard let serverName = server?.name else { return LocalizableReport.selectProject.localized }
        return serverName
    }
    
    var hasMoreServer: Bool {
        return serverArray.count > 1
    }
    
    var isNewDraft: Bool {
        return reportId == nil
    }
    

    var addFileToDraftItems : [ListActionSheetItem] { return [
        
        ListActionSheetItem(imageName: "report.camera-filled",
                            content: LocalizableReport.cameraFilled.localized,
                            type: ManageFileType.camera),
        ListActionSheetItem(imageName: "report.mic-filled",
                            content: LocalizableReport.micFilled.localized,
                            type: ManageFileType.recorder),
        ListActionSheetItem(imageName: "report.gallery",
                            content: LocalizableReport.galleryFilled.localized,
                            type: ManageFileType.tellaFile),
        ListActionSheetItem(imageName: "report.phone",
                            content: LocalizableReport.phoneFilled.localized,
                            type: ManageFileType.fromDevice)
    ]}
    
    init(reportId:Int? = nil, reportsMainViewModel: ReportsMainViewModel) {
        
        self.mainAppModel = reportsMainViewModel.mainAppModel
        self.reportsMainViewModel = reportsMainViewModel
        self.addFilesViewModel = AddFilesViewModel(mainAppModel: reportsMainViewModel.mainAppModel)

        self.validateReport()
        
        self.getServers()
        
        self.initcurrentReportVM(reportId: reportId)
        
        self.bindVaultFileTaken()
        
        fillReportVM()
    }

    func validateReport() {
        Publishers.CombineLatest4($server,$isValidTitle, $isValidDescription, addFilesViewModel.$files)
            .map { server, isValidTitle, isValidDescription, files in
                ((server != nil) && isValidTitle && (isValidDescription || !files.isEmpty))
            }
            .assign(to: \.reportIsValid, on: self)
            .store(in: &subscribers)
        
        $isValidTitle
            .map { $0 == true }
            .assign(to: \.reportIsDraft, on: self)
            .store(in: &subscribers)
    }
    
    func getServers() {}

    func bindVaultFileTaken() {}
    
    func publishUpdates() {}
    
    func fillReportVM() {}

    func saveReport() {}
    
    func deleteFile(fileId: String?) {}
    
    func deleteReport() {}
    
    func initcurrentReportVM(reportId:Int?) {
       if serverArray.count == 1 {
           server = serverArray.first
       }
       self.reportId = reportId
   }

    func saveDraftReport() {
        self.status = .draft
        self.saveReport()
    }
    
    func saveFinalizedReport() {
        self.status = .finalized
        self.saveReport()
    }
    
    func saveSubmittedReport() {
        self.status = .submitted
        self.saveReport()
    }
    func submitReport() {
        self.status = .submissionScheduled
        self.saveReport()
    }
    
    func validateTitleAndDescription() {
        self.isValidTitle =  self.title.textValidator()
        self.isValidDescription = self.description.textValidator()
        self.objectWillChange.send()
    }
}

extension DraftMainViewModel {
    static func stub() -> DraftMainViewModel {
        return DraftMainViewModel(reportsMainViewModel: ReportsMainViewModel.stub())
    }
}

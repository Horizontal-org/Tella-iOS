//
//  DraftViewModelProtocol.swift
//  Tella
//
//  Created by gus valbuena on 6/24/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class DraftMainViewModel: ObservableObject {
    var mainAppModel: MainAppModel
    // Report
    @Published var reportId : Int?
    @Published var title : String = ""
    @Published var description : String = ""
    @Published var files :  Set <VaultFileDB> = []
    @Published var server :  Server?
    @Published var status : ReportStatus?
    @Published var apiID : String?
    
    // Fields validation
    @Published var isValidTitle : Bool = false
    @Published var isValidDescription : Bool = false
    @Published var shouldShowError : Bool = false
    @Published var reportIsValid : Bool = false
    @Published var reportIsDraft : Bool = false
    
    @Published var resultFile : [VaultFileDB]?
    
    @Published var showingImagePicker : Bool = false
    @Published var showingImportDocumentPicker : Bool = false
    @Published var showingFileList : Bool = false
    @Published var showingRecordView : Bool = false
    @Published var showingCamera : Bool = false
    
    @Published var successSavingReport : Bool = false
    @Published var failureSavingReport : Bool = false
    
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
    
    init(mainAppModel : MainAppModel, reportId:Int? = nil) {
        
        self.mainAppModel = mainAppModel
        
        self.validateReport()
        
        self.getServers()
        
        self.initcurrentReportVM(reportId: reportId)
        
        self.bindVaultFileTaken()
        
        fillReportVM()
    }
    
    func validateReport() {}
    
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
    
}

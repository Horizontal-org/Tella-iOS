//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class DraftReportVM: ObservableObject {
    
    var mainAppModel : MainAppModel
    
    // Report
    @Published var reportId : Int?
    @Published var title : String = ""
    @Published var description : String = ""
    @Published var files :  Set <VaultFileDB> = []
    @Published var server :  TellaServer?
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
    
    var serverArray : [TellaServer] = []
    
    var cancellable : Cancellable? = nil
    private var subscribers = Set<AnyCancellable>()
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
    
    private func validateReport() {
        $server.combineLatest( $isValidTitle, $isValidDescription, $files)
            .sink(receiveValue: { server, isValidTitle, isValidDescription, files in
                self.reportIsValid = ((server != nil) && isValidTitle && isValidDescription) || ((server != nil) && isValidTitle && !files.isEmpty)
            }).store(in: &subscribers)
        
        $isValidTitle.combineLatest($isValidDescription, $files)
            .sink(receiveValue: { isValidTitle, isValidDescription, files in
                DispatchQueue.main.async {
                    self.reportIsDraft = isValidTitle
                }
            }).store(in: &subscribers)
    }
    
    private func getServers() {
        serverArray = mainAppModel.tellaData?.tellaServers.value ?? []
    }
    
    private func initcurrentReportVM(reportId:Int?) {
        if serverArray.count == 1 {
            server = serverArray.first
        }
        self.reportId = reportId
    }
    
    private func bindVaultFileTaken() {
        $resultFile.sink(receiveValue: { value in
            guard let value else { return }
            self.files.insert(value)
            self.publishUpdates()
        }).store(in: &subscribers)
    }
    
    private func publishUpdates() {
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    func fillReportVM() {
        if let reportId = self.reportId ,let report = self.mainAppModel.tellaData?.getReport(reportId: reportId) {
            
            self.title = report.title ?? ""
            self.description = report.description ?? ""
            self.server = report.server
            
            if let  vaultFileResult = mainAppModel.vaultFilesManager?.getVaultFiles(ids: report.reportFiles?.compactMap{$0.fileId} ?? [] ) {
                let vaultFileResult  = Set(vaultFileResult)
                self.files = vaultFileResult
            }
            self.objectWillChange.send()
        }
        DispatchQueue.main.async {
            self.isValidTitle =  self.title.textValidator()
            self.isValidDescription = self.description.textValidator()
            self.reportIsValid = ((self.server != nil) && self.isValidTitle && self.isValidDescription) || ((self.server != nil) && self.isValidTitle && !self.files.isEmpty)
            self.reportIsDraft = self.isValidTitle
            self.objectWillChange.send()
        }
    }
    
    func saveDraftReport()  {
        self.status = .draft
        self.saveReport()
    }
    
    func saveFinalizedReport()  {
        self.status = .finalized
        self.saveReport()
    }
    
    func saveReportForSubmission()  {
        self.status = .submissionScheduled
        self.saveReport()
    }
    
    func saveReport() {
        
        let report = Report(id: reportId,
                            title: title,
                            description: description,
                            status: status,
                            server: server,
                            vaultFiles: self.files.compactMap{ ReportFile(fileId: $0.id,
                                                                          status: .notSubmitted,
                                                                          bytesSent: 0,
                                                                          createdDate: Date())},
                            apiID: apiID)
        
        !isNewDraft ? updateReport(report: report) : addReport(report: report)
    }
    
    func updateReport(report:Report) {
        let updateReportResult = mainAppModel.tellaData?.updateReport(report: report)
        switch updateReportResult {
        case .success:
            self.successSavingReport = true
        default:
            self.failureSavingReport = true
        }
    }
    
    func addReport(report:Report) {
        let idResult =  mainAppModel.tellaData?.addReport(report: report)
        switch idResult {
        case .success(let id ):
            self.reportId = id
            self.successSavingReport = true
        default:
            self.failureSavingReport = true
        }
    }
    
    func deleteFile(fileId: String?) {
        guard let index = files.firstIndex(where: { $0.id == fileId})  else  {return }
        files.remove(at: index)
    }
    
    func deleteReport() {
        mainAppModel.deleteReport(reportId: reportId)
        mainAppModel.deleteReport(reportId: reportId)
    }
}

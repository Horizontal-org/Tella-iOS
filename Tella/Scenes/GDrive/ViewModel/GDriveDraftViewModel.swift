//
//  GDriveDraftViewModel.swift
//  Tella
//
//  Created by gus valbuena on 6/13/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class GDriveDraftViewModel: ObservableObject, DraftViewModelProtocol {
    var mainAppModel: MainAppModel
    private let gDriveRepository: GDriveRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    var server: GDriveServer?
    
    @Published var reportId : Int?
    @Published var title: String = ""
    @Published var description: String = ""
    
    @Published var isValidTitle : Bool = false
    @Published var isValidDescription : Bool = false
    @Published var shouldShowError : Bool = false
    @Published var reportIsValid : Bool = false
    @Published var reportIsDraft : Bool = false
    
    @Published var status: ReportStatus?
    @Published var successSavingReport: Bool = false
    @Published var failureSavingReport: Bool = false
    var successSavingReportPublisher: Published<Bool>.Publisher { $successSavingReport }
    var failureSavingReportPublisher: Published<Bool>.Publisher { $failureSavingReport }
    
    // files
    @Published var files :  Set <VaultFileDB> = []
    @Published var resultFile : [VaultFileDB]?
    
    @Published var showingImagePicker : Bool = false
    @Published var showingImportDocumentPicker : Bool = false
    @Published var showingFileList : Bool = false
    @Published var showingRecordView : Bool = false
    @Published var showingCamera : Bool = false
    
    private var subscribers = Set<AnyCancellable>()
    
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
    
    init(mainAppModel: MainAppModel, repository: GDriveRepositoryProtocol) {
        self.mainAppModel = mainAppModel
        self.gDriveRepository = repository
        self.validateReport()
        self.getServer()
        
        self.bindVaultFileTaken()
    }
    
    private func validateReport() {
        Publishers.CombineLatest($title, $description)
            .map { !$0.0.isEmpty && !$0.1.isEmpty }
            .assign(to: \.reportIsValid, on: self)
            .store(in: &subscribers)
        
        $title
            .map { !$0.isEmpty }
            .assign(to: \.reportIsDraft, on: self)
            .store(in: &subscribers)
    }
    
    func submitReport() {
        self.status = .submissionScheduled
        performSubmission()
    }
    
    
    func performSubmission() {
        gDriveRepository.createDriveFolder(
            folderName: self.title,
            parentId: server?.rootFolder,
            description: self.description
        )
            .receive(on: DispatchQueue.main)
            .flatMap { folderId in
                self.uploadFiles(to: folderId)
            }
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        self.saveFinalizedReport()
                        break
                    case .failure(let error):
                        debugLog(error)
                    }
                },
                receiveValue: { result in
                    dump(result)
                }
            ).store(in: &cancellables)
    }
    
    func saveDraftReport() {
        self.status = .draft
        self.successSavingReport = true
    }
    
    func saveFinalizedReport() {
        self.status = .finalized
        self.successSavingReport = true
    }
    
    private func getServer() {
        self.server = mainAppModel.tellaData?.gDriveServers.value.first
    }
    
    private func uploadFiles(to folderId: String) -> AnyPublisher<Void, Error> {
        let uploadPublishers = files.map { file -> AnyPublisher<String, Error> in
            guard let fileUrl = self.mainAppModel.vaultManager.loadVaultFileToURL(file: file) else {
                return Fail(error: APIError.unexpectedResponse).eraseToAnyPublisher()
            }
            return gDriveRepository.uploadFile(fileURL: fileUrl, mimeType: file.mimeType ?? "", folderId: folderId)
        }
        
        return Publishers.MergeMany(uploadPublishers)
            .collect()
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    
    private func bindVaultFileTaken() {
        $resultFile.sink(receiveValue: { value in
            guard let value else { return }
            self.files.insert(value)
        }).store(in: &subscribers)
    }
}

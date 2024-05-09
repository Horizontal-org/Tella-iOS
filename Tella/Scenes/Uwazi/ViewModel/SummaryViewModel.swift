//
//  SummaryViewModel.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 3/4/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class SummaryViewModel: ObservableObject {
    
    var mainAppModel : MainAppModel
    var entityInstance: UwaziEntityInstance?
    var uwaziSubmissionViewModel: UwaziSubmissionViewModel?
    private var subscribers = Set<AnyCancellable>()
    
    @Published var isLoading: Bool = false
    @Published var shouldHideView : Bool = false
    
    var entityTitle : String {
        guard let stringValue = self.entityInstance?.title else { return "" }
        return stringValue
    }
    
    
    var serverName : String {
        return  String(format: "%@ %@", LocalizableUwazi.uwaziEntitySummaryDetailServerTitle.localized, entityInstance?.server?.name ?? "")
    }
    
    var templateName : String {
        String(format: "%@ %@", LocalizableUwazi.uwaziEntitySummaryDetailTemplateTitle.localized, entityInstance?.collectedTemplate?.entityRow?.name ?? "")
    }
    
    var shouldHideBottomActionView: Bool {
         return entityInstance?.status != .submitted
    }
    
    var tellaData: TellaData? {
        return self.mainAppModel.tellaData
    }


    init(mainAppModel : MainAppModel,
         entityInstance: UwaziEntityInstance? = nil,
         entityInstanceId: Int? = nil) {
        self.mainAppModel = mainAppModel
        
        if let entityInstance {
            self.entityInstance = entityInstance
        } else {
            self.entityInstance = tellaData?.getUwaziEntityInstance(entityId: entityInstanceId)
        }

        uwaziSubmissionViewModel = UwaziSubmissionViewModel(entityInstance: entityInstance, mainAppModel: mainAppModel)
    }
    
    func getEntityResponseSize() -> String {
        return uwaziSubmissionViewModel?.getEntityResponseSize() ?? ""
    }
    
    func getUwaziVaultFiles() -> [UwaziVaultFile] {
        var uwaziVaultFiles : [UwaziVaultFile] = []
        let vaultFileResult  = mainAppModel.vaultFilesManager?.getVaultFiles(ids: entityInstance?.files.compactMap{$0.vaultFileInstanceId} ?? [])

        self.entityInstance?.files.forEach({ file in
            if let vaultFile = vaultFileResult?.first(where: {file.vaultFileInstanceId == $0.id}) {
                let uwaziVaultFile = UwaziVaultFile(uwaziFile: file, vaultFile: vaultFile)
                uwaziVaultFiles.append(uwaziVaultFile)
            }
        })

        return uwaziVaultFiles
    }

    func submitLater() {
        
        guard let entityInstance = entityInstance else { return }
        entityInstance.status = .finalized
        
        let result = tellaData?.addUwaziEntityInstance(entityInstance: entityInstance)
        
        if case .success = result {
             self.shouldHideView = true
        } else {
            Toast.displayToast(message: LocalizableCommon.commonError.localized)
        }
    }
    
    func submitEntity() {
        
        self.isLoading = true
        
        guard let entityInstance = entityInstance else { return }
        entityInstance.status = .submissionInProgress
        
        let result = tellaData?.addUwaziEntityInstance(entityInstance: entityInstance)
       
        if case .success(let id) = result {
            entityInstance.id = id
            uwaziSubmissionViewModel?.submitEntity()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    
                    self?.isLoading = false
                    self?.shouldHideView = true
                    
                    switch completion {
                    case .finished:
                        Toast.displayToast(message: LocalizableUwazi.uwaziEntitySubmitted.localized)
                        entityInstance.status = .submitted
                        
                    case .failure(let error):
                        debugLog(error.localizedDescription)
                        Toast.displayToast(message: LocalizableUwazi.uwaziEntityFailedSubmission.localized)
                        entityInstance.status = .submissionError
                    }
                    _ = entityInstance.files.compactMap({$0.status = .submitted})
                    self?.tellaData?.addUwaziEntityInstance(entityInstance: entityInstance)
                    
                } receiveValue: { value in
                    debugLog(value)
                }
                .store(in: &subscribers)

        }
    }
}

//
//  SubmittedEntityViewModel.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 10/5/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class SubmittedEntityViewModel: ObservableObject {
    
    var mainAppModel : MainAppModel
    var entityInstance: UwaziEntityInstance?
    var uwaziSubmissionViewModel: UwaziSubmissionViewModel?
    private var subscribers = Set<AnyCancellable>()
    var uwaziVaultFiles : [UwaziVaultFile] = []
    @Published var shouldShowToast : Bool = false
    @Published var toastMessage : String = ""

    var entityTitle : String {
        guard let stringValue = self.entityInstance?.title else { return "" }
        return stringValue
    }
    
    var templateName : String {
        String(format: "%@ %@", LocalizableUwazi.uwaziEntitySummaryDetailTemplateTitle.localized, entityInstance?.collectedTemplate?.entityRow?.name ?? "")
    }
    
    var uploadedOn : String {
        guard let updatedDate = entityInstance?.updatedDate else { return "" }
        return String(format: LocalizableUwazi.uploadedOn.localized, updatedDate.getFormattedDateString(format: DateFormat.submittedReport.rawValue))
    }
    
    var filesDetails : String {
        if uwaziVaultFiles.count > 1 {
            let totalSize = self.uwaziVaultFiles.reduce(0) { $0 + $1.size}
            let fileString = uwaziVaultFiles.count > 1 ? LocalizableUwazi.submittedFiles.localized : LocalizableUwazi.submittedFile.localized
            return String(format: fileString,  uwaziVaultFiles.count, totalSize.getFormattedFileSize() )
        }  else {
            return ""
        }
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
        
        uwaziVaultFiles = self.getUwaziVaultFiles()
    }
    
    func getEntityResponseSize() -> String {
        return uwaziSubmissionViewModel?.getEntityResponseSize() ?? ""
    }
    
    private func getUwaziVaultFiles() -> [UwaziVaultFile] {
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
    
    func deleteEntityInstance() {
         
 
        guard let entityId = entityInstance?.id else { return }
            
            let resultDeletion = self.tellaData?.deleteUwaziEntityInstance(entityId: entityId)
            
            var message = ""
            if case .success = resultDeletion {
                message = String.init(format: LocalizableUwazi.uwaziDeletedToast.localized, entityInstance?.title ?? "")
                
            } else {
                message = LocalizableCommon.commonError.localized
            }
            
            self.shouldShowToast = true
            self.toastMessage = message
        }

 }

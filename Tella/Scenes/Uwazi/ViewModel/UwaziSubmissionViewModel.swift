//
//  UwaziSubmissionViewModel.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 5/4/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class UwaziSubmissionViewModel {
    
    var entityInstance: UwaziEntityInstance?
    var mainAppModel : MainAppModel
    private var subscribers = Set<AnyCancellable>()
    
    init(entityInstance: UwaziEntityInstance? = nil, mainAppModel: MainAppModel) {
        self.entityInstance = entityInstance
        self.mainAppModel = mainAppModel
    }
    
    func submitEntity(onCompletion: @escaping () -> Void) {
        //        self.isLoading = true
        guard let server = entityInstance?.server else { return  }
        let isPublic = server.accessToken == nil
        // Extract entity data and metadata
        let entityData = extractEntityDataAndMetadata()
        
        // Submit the entity data
        let (body, contentTypeHeader) = UwaziMultipartFormDataBuilder.createBodyWith(
            keyValues: entityData,
            attachments: UwaziFileUtility(files: entityInstance?.attachments, mainAppModel: mainAppModel).getFilesInfo(),
            documents: UwaziFileUtility(files: entityInstance?.documents, mainAppModel: mainAppModel).getFilesInfo()
        )
        
        let response = UwaziServerRepository().submitEntity(
            serverURL: server.url ?? "",
            cookie: server.cookie ?? "",
            multipartHeader: contentTypeHeader,
            multipartBody: body,
            isPublic: isPublic
        )
        response
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                // self?.isLoading = false
                switch completion {
                case .finished:
                    debugLog("Finished")
                    Toast.displayToast(message: LocalizableUwazi.uwaziEntitySubmitted.localized)
                    onCompletion()
                case .failure(let error):
                    debugLog(error.localizedDescription)
                    Toast.displayToast(message: LocalizableUwazi.uwaziEntityFailedSubmission.localized)
                }
            } receiveValue: { value in
                debugLog(value)
            }
            .store(in: &subscribers)
    }
    
    private func extractEntityDataAndMetadata() -> ([String: Any]) {
        
        let attachments = UwaziFileUtility(files: Set(entityInstance?.attachments ?? [])).extractFilesAsAttachments()
        let documents = UwaziFileUtility(files: Set(entityInstance?.documents ?? [])).extractFilesAsAttachments()
        
        var entityData: [String: Any?] = [
            UwaziEntityMetadataKeys.attachments: attachments ,
            UwaziEntityMetadataKeys.documents: documents,
            UwaziEntityMetadataKeys.template: entityInstance?.collectedTemplate?.templateId,
            UwaziEntityMetadataKeys.title: entityInstance?.title
        ]
        
        var metadata = entityInstance?.metadata
        
        entityData[UwaziEntityMetadataKeys.metadata] = metadata

        return [UwaziEntityMetadataKeys.entity: entityData]
    }

    func getEntityResponseSize() -> String {
        do {
            let entityData = extractEntityDataAndMetadata()
            let jsonData = try JSONSerialization.data(withJSONObject: entityData, options: [])
            let sizeInBytes = Int(jsonData.count)
            let sizeInMB = sizeInBytes.getFormattedFileSize()
            return sizeInMB
        } catch {
            debugLog(error)
            return "\(error)"
        }
    }
}

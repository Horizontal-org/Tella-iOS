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
        
        let attachments =  entityInstance?.attachments.compactMap({EntityAttachment(vaultFile: $0)})
        let documents = entityInstance?.documents.compactMap({EntityAttachment(vaultFile: $0)})
        let template = entityInstance?.collectedTemplate?.templateId
        let title = entityInstance?.title
        let metadata = entityInstance?.metadata
        
        let entityInstanceToSend = EntityInstanceToSend(attachments: attachments,
                                                        documents: documents,
                                                        template: template,
                                                        title: title,
                                                        metadata: metadata)
        
        var entityData = entityInstanceToSend.dictionary
        entityData[UwaziEntityMetadataKeys.metadata] = metadata
        return [UwaziEntityMetadataKeys.entity: entityData]
    }
    
    func getEntityResponseSize() -> String {
        let sizeInBytes = extractEntityDataAndMetadata().jsonData?.count
        guard let sizeInMB = sizeInBytes?.getFormattedFileSize() else { return "" }
        return sizeInMB
    }
}




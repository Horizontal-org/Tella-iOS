//
//  SummaryViewModel.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 3/4/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

class SummaryViewModel: ObservableObject {
    
    var mainAppModel : MainAppModel
    var entityInstance: UwaziEntityInstance?
    var uwaziSubmissionViewModel: UwaziSubmissionViewModel?
    
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
    
    var tellaData: TellaData? {
        return self.mainAppModel.tellaData
    }
    
    init(mainAppModel : MainAppModel, entityInstance: UwaziEntityInstance? = nil) {
        self.mainAppModel = mainAppModel
        self.entityInstance = entityInstance
        uwaziSubmissionViewModel = UwaziSubmissionViewModel(entityInstance: entityInstance, mainAppModel: mainAppModel)
    }
    
    func getEntityResponseSize() -> String {
        return uwaziSubmissionViewModel?.getEntityResponseSize() ?? ""
    }
    
    func submitLater() {
        
        guard let entityInstance = entityInstance else { return }
        entityInstance.status = .finalized
       
        let isSaved = tellaData?.addUwaziEntityInstance(entityInstance: entityInstance) ?? false
        
        if isSaved {
            self.shouldHideView = true
        } else {
            Toast.displayToast(message: "Error")
        }
    }
    
    func submitEntity() {
        
        self.isLoading = true
        
        guard let entityInstance = entityInstance else { return }
        entityInstance.status = .submissionInProgress
        
        tellaData?.addUwaziEntityInstance(entityInstance: entityInstance)
        
        uwaziSubmissionViewModel?.submitEntity(onCompletion: {
            self.isLoading = false
            self.shouldHideView = true
            entityInstance.status = .submitted
            self.tellaData?.addUwaziEntityInstance(entityInstance: entityInstance)

        })
    }
}

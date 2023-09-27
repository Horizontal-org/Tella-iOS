//
//  TemplateItemViewModel.swift
//  Tella
//
//  Created by Robert Shrestha on 9/23/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

class TemplateItemViewModel {
   
    var name: String
    var isDownloaded : Bool
    var downloadTemplate : (() -> Void)
    var deleteTemplate: (() -> Void)

    init(template : CollectedTemplate, downloadTemplate: @escaping (() -> Void)  , deleteTemplate: @escaping (() -> Void) ) {
        self.name = template.entityRow?.name ?? ""
        self.isDownloaded = template.isDownloaded ?? false
        self.downloadTemplate = downloadTemplate
        self.deleteTemplate = deleteTemplate
    }
}

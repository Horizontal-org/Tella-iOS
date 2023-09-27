//
//  TemplateItemViewModel.swift
//  Tella
//
//  Created by Robert Shrestha on 9/23/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

class TemplateItemViewModel: Hashable {
    
    var id : Int?
    var name: String
    var isDownloaded : Bool
    var downloadTemplate : (() -> Void)
    var deleteTemplate: (() -> Void)

    init(template : CollectedTemplate,
         downloadTemplate: @escaping (() -> Void),
         deleteTemplate: @escaping (() -> Void) ) {
        self.id = template.id
        self.name = template.entityRow?.name ?? ""
        self.isDownloaded = template.isDownloaded ?? false
        self.downloadTemplate = downloadTemplate
        self.deleteTemplate = deleteTemplate
    }

    static func == (lhs: TemplateItemViewModel, rhs: TemplateItemViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

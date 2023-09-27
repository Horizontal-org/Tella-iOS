//
//  TemplateCardViewModel.swift
//  Tella
//
//  Created by Robert Shrestha on 9/23/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

class TemplateCardViewModel: Hashable {
    
    var id : Int?
    var serverName: String
    var translatedName: String
    var deleteTemplate: (() -> Void)
   
    init(template : CollectedTemplate,
         deleteTemplate: @escaping (() -> Void) ) {
        self.id = template.id
        self.serverName = template.serverName ?? ""
        self.translatedName = template.entityRow?.translatedName ?? ""
        self.deleteTemplate = deleteTemplate
    }
    
    static func == (lhs: TemplateCardViewModel, rhs: TemplateCardViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}

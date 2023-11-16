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
    var translatedName: String
    var deleteTemplate: (() -> Void)
    var serverName: String
    var serverId: Int
   
    init(template : CollectedTemplate,
         deleteTemplate: @escaping (() -> Void),
         serverName: String,
         serverId: Int
    ) {
        self.id = template.id
        self.translatedName = template.entityRow?.translatedName ?? ""
        self.deleteTemplate = deleteTemplate
        self.serverId = serverId
        self.serverName = serverName
    }
    
    static func == (lhs: TemplateCardViewModel, rhs: TemplateCardViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}

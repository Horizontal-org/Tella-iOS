//
//  TemplateCardViewModel.swift
//  Tella
//
//  Created by Robert Shrestha on 9/23/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

class TemplateCardViewModel {
    var id = UUID()
    var serverName: String
    var translatedName: String
    var deleteTemplate: ()
    init(serverName: String, translatedName: String, deleteTemplate: ()) {
        self.serverName = serverName
        self.translatedName = translatedName
        self.deleteTemplate = deleteTemplate
    }
}

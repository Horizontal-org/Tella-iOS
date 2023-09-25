//
//  TemplateCardViewModel.swift
//  Tella
//
//  Created by Robert Shrestha on 9/23/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

class TemplateCardViewModel {
    var serverName: String
    var translatedName: String
    var deleteTemplate: () -> Void
    init(serverName: String, translatedName: String, deleteTemplate: @escaping () -> Void) {
        self.serverName = serverName
        self.translatedName = translatedName
        self.deleteTemplate = deleteTemplate
    }
}

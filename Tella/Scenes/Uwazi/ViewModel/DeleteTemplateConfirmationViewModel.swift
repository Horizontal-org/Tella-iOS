//
//  DeleteTemplateConfirmationViewModel.swift
//  Tella
//
//  Created by Robert Shrestha on 9/23/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

class DeleteTemplateConfirmationViewModel {
    var title : String
    var message : String
    var confirmAction : () -> ()
    init(title: String, message: String, confirmAction: @escaping () -> Void) {
        self.title = title
        self.message = message
        self.confirmAction = confirmAction
    }
}

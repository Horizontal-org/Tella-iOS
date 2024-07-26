//
//  CommonCardViewModel.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 3/7/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

class CommonCardViewModel: Hashable {
    
    var id : Int?
    var title: String
    var iconImageName: String?
    var serverName: String?
    var updatedAt: String?
    var listActionSheetItem: [ListActionSheetItem]
    var connectionType: ServerConnectionType
    var deleteReportStrings : ConfirmDeleteConnectionStrings
    var deleteAction: (() -> Void)
    
    init(id: Int?, 
         title: String,
         iconImageName: String?,
         serverName: String?,
         updatedAt: String? = nil,
         listActionSheetItem: [ListActionSheetItem],
         connectionType: ServerConnectionType,
         deleteReportStrings: ConfirmDeleteConnectionStrings,
         deleteAction: @escaping (() -> Void)) {
        
        self.id = id
        self.title = title
        self.iconImageName = iconImageName
        self.serverName = serverName
        self.updatedAt = updatedAt
        self.listActionSheetItem = listActionSheetItem
        self.connectionType = connectionType
        self.deleteReportStrings = deleteReportStrings
        self.deleteAction = deleteAction
    }
    
    static func == (lhs: CommonCardViewModel, rhs: CommonCardViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}

extension CommonCardViewModel {
    var subtitle: String {
        switch connectionType {
        case .uwazi:
            return self.serverName ?? ""
        default:
            return self.updatedAt ?? ""
        }
    }
}

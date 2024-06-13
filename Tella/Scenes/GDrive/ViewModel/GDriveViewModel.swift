//
//  GDriveViewModel.swift
//  Tella
//
//  Created by gus valbuena on 6/12/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

class GDriveViewModel: ObservableObject {
    var mainAppModel: MainAppModel
    var pageViewItems: [PageViewItem] {
        [
            PageViewItem(title: LocalizableReport.draftTitle.localized,
                         page: .draft,
                        number: 0),
            PageViewItem(title: LocalizableReport.outboxTitle.localized,
                        page: .outbox,
                        number: 0),
            PageViewItem(title: LocalizableReport.submittedTitle.localized,
                        page: .submitted,
                        number: 0)]
    }
    @Published var selectedCell = Pages.draft
    
    init(mainAppModel: MainAppModel) {
        self.mainAppModel = mainAppModel
    }
}

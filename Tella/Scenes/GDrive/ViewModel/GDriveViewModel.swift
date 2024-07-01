//
//  GDriveViewModel.swift
//  Tella
//
//  Created by gus valbuena on 6/12/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

class GDriveViewModel: BaseReportsViewModel {
    var draftReports: [GDriveReport] = []
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
    
    override init(mainAppModel: MainAppModel) {
        super.init(mainAppModel: mainAppModel)
        
        self.mainAppModel.tellaData?.getDraftGDriveReport()
    }
}

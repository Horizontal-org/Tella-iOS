//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import Foundation

class ReportViewModel: ObservableObject {
    @Published var reports = ReportModel()
}

class ReportModel: Identifiable {
    var id = UUID()
    var reports: [ReportDetailsModel] = [ReportDetailsModel()]
}

struct ReportDetailsModel: Identifiable {
    var id = UUID()
    var title: String = ""
    var description: String = ""
    var filePath: String = ""
    var isDraft: Bool = false
}

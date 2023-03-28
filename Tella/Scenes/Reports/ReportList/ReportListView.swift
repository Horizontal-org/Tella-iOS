//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct ReportListView: View {
    
    @Binding var reportArray : [Report]
    var message : String
    
    var body: some View {
        ZStack {
            if $reportArray.wrappedValue.count > 0 {
                
                ScrollView {
                    
                    VStack(alignment: .center, spacing: 0) {
                        
                        ForEach($reportArray, id: \.self) { report in
                            ReportCardView(report: report)
                        }
                    }
                }
            } else {
                EmptyReportView(message: message)
            }
        }
    }
}

struct ReportListView_Previews: PreviewProvider {
    static var previews: some View {
        ContainerView {
            ReportListView(reportArray: .constant([Report(title: "Title",
                                                          description: "Description",
                                                          status: ReportStatus.draft,
                                                          server: Server(), vaultFiles: [])]),
                           message: "Message")
        }
    }
}



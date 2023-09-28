//
//  TemplateList.swift
//  Tella
//
//  Created by Gustavo on 02/08/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct TemplateList: View {
    @Binding var templateArray : [Report]
    var message : String
    
    var body: some View {
        ZStack {
            if $templateArray.wrappedValue.count > 0 {
                
                ScrollView {
                    
                    VStack(alignment: .center, spacing: 0) {
                        
                        ForEach($templateArray, id: \.self) { template in
                            ReportCardView(report: template)
                        }
                    }
                }
            } else {
                EmptyReportView(message: message)
            }
        }
    }
}

//struct TemplateList_Previews: PreviewProvider {
//    static var previews: some View {
//        TemplateList()
//    }
//}

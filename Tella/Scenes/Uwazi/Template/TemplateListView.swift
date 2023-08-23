//
//  TemplateListView.swift
//  Tella
//
//  Created by Gustavo on 02/08/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct TemplateListView: View {
    @Binding var templateArray : [UwaziTemplateRow]
    var message : String
    var serverName : String
    
    var body: some View {
        ZStack {
            if $templateArray.wrappedValue.count > 0 {
                ScrollView {
                    VStack(alignment: .center, spacing: 0) {
                        Text(LocalizableUwazi.uwaziTemplateListExpl.localized)
                            .font(.custom(Styles.Fonts.semiBoldFontName, size: 14))
                            .foregroundColor(.white.opacity(0.64))
                            .padding(.all, 14)
                        ForEach($uwaziViewModel.downloadedTemplates, id: \.self) { template in
                            TemplateCardView(template: template, serverName: serverName) { template in
                                self.showtemplateActionBottomSheet(template: template)
                            }
                        }
                    }
                }
            } else {
                EmptyReportView(message: message)
            }
        }
    }
}

struct TemplateListView_Previews: PreviewProvider {
    @State static var templates: [UwaziTemplateRow] = []
    static var previews: some View {
        TemplateListView(templateArray: $templates, message: "", serverName: "")
    }
}

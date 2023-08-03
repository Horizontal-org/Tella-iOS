//
//  AddTemplatesView.swift
//  Tella
//
//  Created by Gustavo on 03/08/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct AddTemplatesView: View {
    @Binding var templates:[UwaziTemplateRow]
    @Binding var downloadedTemplates: [UwaziTemplateRow]
    var serverName : String
    var downloadTemplateAction : (UwaziTemplateRow) -> Void

    var body: some View {
        ContainerView {
            VStack(spacing: 0) {
                Text("These are the templates available on the Uwazi instances you are connected to. You can manage your Uwazi instances here.")
                    .font(.custom(Styles.Fonts.semiBoldFontName, size: 14))
                    .foregroundColor(.white)
                    .padding(.all, 18)
                
                if $templates.wrappedValue.count > 0 {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(serverName)
                                .font(.custom(Styles.Fonts.boldFontName, size: 18))
                                .foregroundColor(.white)
                                .padding(.all, 14)
                            ForEach(Array(templates.enumerated()), id: \.element) { index, template in
                                //move this to a viewModel
                                let isDownloaded = downloadedTemplates.contains { downloadedTemplate in
                                        downloadedTemplate.id == template.id
                                    }
                                TemplateItemView(
                                    template: $templates[index],
                                    serverName: serverName,
                                    isDownloaded: isDownloaded,
                                    downloadTemplate:downloadTemplateAction
                                )
                                
                                if index < (templates.count - 1) {
                                    DividerView()
                                }
                            }
                        }
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(15)
                        .padding(.all, 18)
                        .padding(.top, 0)
                    }
                } else {
                    EmptyReportView(message: "There are no templates")
                }
            }.padding(.top, 0)
            
        }
        
        .toolbar {
            LeadingTitleToolbar(title: "Add templates")
        }
    }
}

//struct AddTemplatesView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddTemplatesView()
//    }
//}

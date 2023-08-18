//
//  TemplateItemView.swift
//  Tella
//
//  Created by Gustavo on 03/08/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct TemplateItemView: View {
    @Binding var template : CollectedTemplate
    var serverName : String
    var isDownloaded : Bool
    var downloadTemplate : (CollectedTemplate) -> Void
    var deleteTemplate: (CollectedTemplate) -> Void
    
    var body: some View {
        Button {
                    
                } label: {
                        
                    HStack {
                        if(isDownloaded) {
                            Image("report.submitted")
                                .padding(.leading, 8)
                        }
                        Text(template.entityRow?.name ?? "")
                            .font(.custom(Styles.Fonts.regularFontName, size: 16))
                            .foregroundColor(.white)
                            .padding(.leading, 8)
                            
                        Spacer()
                            
                        if(!isDownloaded) {
                            MoreButtonView(imageName: "template.add", action: {
                                //add template to download array
                                downloadTemplate(template)
                            })
                        } else {
                            MoreButtonView(imageName: "reports.more", action: {
                                //
                                deleteTemplate(template)
                            })
                        }
                            
                    }.padding(.all, 8)
                        
                }
    }
}

//struct TemplateItemView_Previews: PreviewProvider {
//    @State static var template: UwaziTemplateRow = UwaziTemplateRow(id: "1", name: "Sample Template", properties: nil, commonProperties: nil, v: 1, defaultVal: true, color: "blue")
//    static var previews: some View {
//        TemplateCardView(template: $template, serverName: "")
//    }
//}

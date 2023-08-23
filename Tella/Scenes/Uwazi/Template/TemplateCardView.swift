//
//  TemplateCardView.swift
//  Tella
//
//  Created by Gustavo on 02/08/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct TemplateCardView: View {
    @Binding var template : CollectedTemplate
    var serverName : String
    @EnvironmentObject var uwaziReportsViewModel : UwaziReportsViewModel
    var deleteTemplate: (CollectedTemplate) -> Void
    
    var body: some View {
        Button {
                    
                    
                } label: {
                    VStack(spacing: 0) {
                        
                        HStack {
                            MoreButtonView(imageName: "uwazi.star", action: {
                                //add this template to favorie
                            })
                            
                            ReportCardDetail(title: template.entityRow?.translatedName ?? "", subtitle: template.serverName ?? "")
                            
                            Spacer()
                            
                            MoreButtonView(imageName: "reports.more", action: {
                                //show detail
                                deleteTemplate(template)
                            })
                            
                        }.padding(.all, 16)
                        
                    } .background(Color.white.opacity(0.08))
                        .cornerRadius(15)
                        .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                }
    }
}



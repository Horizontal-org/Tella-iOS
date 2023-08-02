//
//  TemplateCardView.swift
//  Tella
//
//  Created by Gustavo on 02/08/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct TemplateCardView: View {
    @Binding var template : UwaziTemplateRow
    @EnvironmentObject var uwaziReportsViewModel : UwaziReportsViewModel
    
    var body: some View {
        Button {
                    
                    
                } label: {
                    VStack(spacing: 0) {
                        
                        HStack {
                            MoreButtonView(imageName: "uwazi.star", action: {
                                //add this template to favorie
                            })
                            
                            ReportCardDetail(title: template.name ?? "", subtitle: uwaziReportsViewModel.serverName)
                            
                            Spacer()
                            
                            MoreButtonView(imageName: "reports.more", action: {
                                //show detail
                            })
                            
                        }.padding(.all, 16)
                        
                    } .background(Color.white.opacity(0.08))
                        .cornerRadius(15)
                        .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                }
    }
}

//struct TemplateCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        TemplateCardView()
//    }
//}

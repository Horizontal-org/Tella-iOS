//
//  TemplateCardView.swift
//  Tella
//
//  Created by Gustavo on 02/08/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct TemplateCardView: View {
    var viewModel: TemplateCardViewModel
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                MoreButtonView(imageName: "uwazi.star", action: {
                    //add this template to favorie
                })
                ConnectionCardDetail(title: viewModel.translatedName, subtitle: viewModel.serverName)
                Spacer()
                MoreButtonView(imageName: "reports.more", action: {
                    //show detail
                    viewModel.deleteTemplate()
                })
            }.padding(.all, 16)
        }
        .background(Color.white.opacity(0.08))
        .cornerRadius(15)
        .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
    }
}



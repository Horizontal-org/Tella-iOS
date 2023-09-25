//
//  TemplateItemView.swift
//  Tella
//
//  Created by Gustavo on 03/08/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct TemplateItemView: View {
    internal init(viewModel: TemplateItemViewModel) {
        self.viewModel = viewModel
    }
    
    var viewModel: TemplateItemViewModel
    var body: some View {
        HStack {
            if(viewModel.isDownloaded) {
                Image("report.submitted")
                    .padding(.leading, 8)
            }
            Text(viewModel.name)
                .font(.custom(Styles.Fonts.regularFontName, size: 16))
                .foregroundColor(.white)
                .padding(.horizontal, 8)

            Spacer()

            if(!viewModel.isDownloaded) {
                MoreButtonView(imageName: "template.add", action: {
                    viewModel.downloadTemplate()
                })
            } else {
                MoreButtonView(imageName: "reports.more", action: {
                    viewModel.deleteTemplate()
                }).padding(.trailing, 8)
            }

        }.padding(.all, 4)
    }
}

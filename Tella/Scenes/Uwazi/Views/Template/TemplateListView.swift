//
//  TemplateListView.swift
//  Tella
//
//  Created by Gustavo on 02/08/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct TemplateListView: View {
    @EnvironmentObject var uwaziViewModel : UwaziTemplateViewModel
    var message : String
    var serverName : String

    var body: some View {
        ZStack {
            if !uwaziViewModel.templateCardsViewModel.isEmpty {
                VStack(alignment: .center, spacing: 0) {
                    Text(LocalizableUwazi.uwaziTemplateListExpl.localized)
                        .font(.custom(Styles.Fonts.semiBoldFontName, size: 14))
                        .foregroundColor(.white.opacity(0.64))
                        .padding(.all, 14)
                    ScrollView {
                        ForEach(uwaziViewModel.templateCardsViewModel, id: \.id) { cardViewModel in
                            TemplateCardView(templateCardViewModel: cardViewModel)
                        }
                    }
                }
            } else {
                EmptyReportView(message: message)
            }
        }
        .onAppear {
            self.uwaziViewModel.getDownloadedTemplates()
        }
    }
}

struct TemplateListView_Previews: PreviewProvider {
    static var previews: some View {
        TemplateListView( message: "", serverName: "")
    }
}

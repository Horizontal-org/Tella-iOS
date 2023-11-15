//
//  CreateDraftHeaderView.swift
//  Tella
//
//  Created by Gustavo on 24/08/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct CreateDraftHeaderView: View {
    var title: String
    var isDraft: Bool
    var closeAction: () -> Void
    var saveAction: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            closeButton()
            titleText()
            Spacer()
//            saveButton()
        }.frame(height: 56)
    }
    fileprivate func closeButton() -> Button<some View> {
        return Button {
            closeAction()
        } label: {
            Image("close")
                .padding(EdgeInsets(top: 10, leading: 12, bottom: 5, trailing: 16))
        }
    }

    fileprivate func saveButton() -> some View {
        return Button {
            saveAction()
        } label: {
            Image("reports.save")
                .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                .opacity(isDraft ? 1 : 0.4)
        }.disabled(!isDraft)
    }

    fileprivate func titleText() -> Text {
        return Text(title)
            .font(.custom(Styles.Fonts.semiBoldFontName, size: 18))
            .foregroundColor(Color.white)
    }
}

struct CreateDraftHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        CreateDraftHeaderView(title: "new draft", isDraft: true, closeAction: {}, saveAction: {})
    }
}

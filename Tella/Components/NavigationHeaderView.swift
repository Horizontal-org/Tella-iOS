//
//  NavigationHeaderView.swift
//  Tella
//
//  Created by gus valbuena on 4/10/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

enum NavigationType {
    case save
    case reload

    var imageName: String {
        switch self {
        case .save: return "report.select-files"
        case .reload: return "arrow.clockwise"
        }
    }
}

struct NavigationHeaderView: View {
    var backButtonAction : () -> Void
    var reloadAction: () -> Void
    var title: String = ""
    var type: NavigationType
    var showRightButton: Bool

    var body: some View {
        HStack(spacing: 0) {
            backButton
            headerTitleView
            Spacer()
            if(showRightButton) {
                rightButton
            }
        }.frame(height: 56)
    }

    private var backButton: some View {
        Button {
            backButtonAction()
        } label: {
            Image("back")
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 5, trailing: 12))
        }
    }

    private var headerTitleView: some View {
        Text(title)
            .font(.custom(Styles.Fonts.semiBoldFontName, size: 18))
            .foregroundColor(Color.white)
    }

    private var rightButton: some View {
        Button(action: { reloadAction() }) {
            Image(type.imageName)
                .resizable()
                .frame(width: 24, height: 24)
        }
    }
}

#Preview {
    NavigationHeaderView(backButtonAction: {}, reloadAction: {}, type: .save, showRightButton: false)
}

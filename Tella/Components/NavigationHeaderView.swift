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
    case validate
    case reload
    case none
    case delete

    var imageName: String {
        switch self {
        case .save: return "reports.save"
        case .validate: return "report.select-files"
        case .reload: return "arrow.clockwise"
        case .delete: return "report.delete-outbox"
        case .none: return ""
        }
    }
    
    var backButtonIcon: String {
        switch self {
        case .save: return "close"
        default: return "back"
        }
    }
}

struct NavigationHeaderView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var backButtonAction : (() -> Void)? = nil
    var rightButtonAction: (() -> Void)? = nil
    var title: String = ""
    var type: NavigationType

    var body: some View {
        HStack(spacing: 0) {
            backButton
            headerTitleView
            Spacer()
            if(type != .none) {
                rightButton
            }
        }.frame(height: 56)
        .padding(.horizontal, 18)
    }

    private var backButton: some View {
        Button {
            if((backButtonAction) != nil) {
                backButtonAction?()
            } else {
                presentationMode.wrappedValue.dismiss()
            }
            
        } label: {
            Image(type.backButtonIcon)
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 5, trailing: 12))
        }
    }

    private var headerTitleView: some View {
        Text(title)
            .font(.custom(Styles.Fonts.semiBoldFontName, size: 18))
            .foregroundColor(Color.white)
    }

    private var rightButton: some View {
        Button(action: { rightButtonAction?() }) {
            Image(type.imageName)
                .resizable()
                .frame(width: 24, height: 24)
        }
    }
}

#Preview {
    NavigationHeaderView(backButtonAction: {}, rightButtonAction: {}, type: .save)
}

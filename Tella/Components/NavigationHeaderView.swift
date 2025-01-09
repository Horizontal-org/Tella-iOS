//
//  NavigationHeaderView.swift
//  Tella
//
//  Created by gus valbuena on 4/10/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct NavigationHeaderView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
   
    var title: String = ""
    
    var backButtonAction : (() -> Void)?
    var middleButtonAction: (() -> Void)?
    var trailingButtonAction: (() -> Void)?
    
    var backButtonType: BackButtonType = .back
    var middleButton: TrailingButtonType = .none
    var trailingButton: TrailingButtonType = .none
    
    var isTrailingButtonEnabled: Bool = true
    
    var body: some View {
        HStack(spacing: 0) {
            backButton
            headerTitleView
            Spacer()
            if(!trailingButton.imageName.isEmpty) {
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
            Image(backButtonType.imageName)
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 5, trailing: 12))
        }
    }
    
    private var headerTitleView: some View {
        Text(title)
            .font(.custom(Styles.Fonts.semiBoldFontName, size: 18))
            .foregroundColor(Color.white)
    }
    
    private var rightButton: some View {
        Button(action: { trailingButtonAction?() }) {
            Image(trailingButton.imageName)
                .resizable()
                .frame(width: 24, height: 24)
                .opacity(isTrailingButtonEnabled ? 1 : 0.4)
        }
        .disabled(!isTrailingButtonEnabled)
    }
}

//#Preview {
//    NavigationHeaderView(backButtonAction: {}, rightButtonAction: {}, trailingButton: .save)
//}




enum TrailingButtonType  {
    
    case save
     case validate
    case reload
    case delete
    case none
    
    var imageName: String {
        switch self {
        case .save: return "reports.save"
        case .validate: return "report.select-files"
        case .reload: return "arrow.clockwise"
        case .delete: return "report.delete-outbox"
        case .none : return ""
        }
    }
}

enum MiddleButtonType  {
    
    case fileEdit
    case share
    case none
    
    var imageName: String {
        switch self {
        case .fileEdit: return "file.edit"
        case .share: return "report.select-files"
        case .none: return ""
        }
    }
}

enum BackButtonType {
    
    case back
    case close
    
    var imageName: String {
        switch self {
        case .close: return "close"
        case .back: return "back"
        }
    }
}

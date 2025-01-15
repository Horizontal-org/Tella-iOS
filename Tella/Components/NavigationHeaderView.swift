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
    var backButtonType: BackButtonType = .back
    var backButtonAction : (() -> Void)?
    
    var middleButtonType: MiddleButtonType = .none
    var middleButtonAction: (() -> Void)?
    
    var isMiddleButtonEnabled: Bool = true
    
    var trailingButton: TrailingButtonType = .none
    var trailingButtonAction: (() -> Void)?
    
    var trailingButtonView: (AnyView)? = nil
    
    var isTrailingButtonEnabled: Bool = true
    
    var body: some View {
        HStack(spacing: 0) {
            backButton
            headerTitleView
            Spacer()
            if middleButtonType != .none {
                middleButton
            }
            trailingView
            
        }.frame(height: 56)
            .padding(.horizontal, 16)
            .background(Color.green)
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
    
    private var trailingView : some View {
        switch trailingButton {
            
        case .custom:
            trailingButtonView!
        case .none:
            AnyView( EmptyView())
            
        default:
            AnyView(rightButton)
        }
    }
    
    private var middleButton: some View {
        Button(action: { middleButtonAction?() }) {
            Image(middleButtonType.imageName)
                .resizable()
                .frame(width: 24, height: 24)
                .opacity(isMiddleButtonEnabled ? 1 : 0.4)
                .padding()
        }.disabled(!isMiddleButtonEnabled)
    }

    private var rightButton: some View {
        Button(action: { trailingButtonAction?() }) {
            Image(trailingButton.imageName)
                .opacity(isTrailingButtonEnabled ? 1 : 0.4)
                .padding()
        }.disabled(!isTrailingButtonEnabled)
            .background(Color.red)
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
    case editFile
    case more
    case custom
    case none
    
    var imageName: String {
        switch self {
        case .save: return "reports.save"
        case .validate: return "report.select-files"
        case .reload: return "arrow.clockwise"
        case .delete: return "delete-icon-bin"
        case .editFile: return "edit.audio.cut"
        case .more: return "files.more"
        case .custom, .none : return ""
        }
    }
}

enum MiddleButtonType  {
    
    case editFile
    case share
    case none
    
    var imageName: String {
        switch self {
        case .editFile: return "file.edit"
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

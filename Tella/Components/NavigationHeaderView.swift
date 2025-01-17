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
    
    var navigationBarType: NavigationBarType = .inline
    
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
        VStack(alignment: .leading) {
            HStack(spacing: 0) {
                backButton
                if navigationBarType == .inline {
                    inlineTitleView
                }
                Spacer()
                if middleButtonType != .none {
                    middleButton
                }
                trailingView
                
            }.frame(height: 57)
                .padding(.horizontal, 16)
            
            if navigationBarType == .large {
                largeTitleView
                    .padding(.horizontal, 16)
            }
        }
    }
    
    private var backButton: some View {
        Button {
            if((backButtonAction) != nil) {
                backButtonAction?()
            } else {
                presentationMode.wrappedValue.dismiss()
            }
            
        } label: {
            if backButtonType != .none {
                Image(backButtonType.imageName)
                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 5, trailing: 12))
            }
        }
    }
    
    private var inlineTitleView: some View {
        Text(title)
            .font(.custom(Styles.Fonts.semiBoldFontName, size: 18))
            .foregroundColor(Color.white)
    }
    
    private var largeTitleView: some View {
        Text(title)
            .font(.custom(Styles.Fonts.boldFontName, size: 36))
            .foregroundColor(Color.white)
            .frame(height: 50)
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
                .opacity(isMiddleButtonEnabled ? 1 : 0.4)
                .padding()
        }.disabled(!isMiddleButtonEnabled)
    }
    
    private var rightButton: some View {
        Button(action: { trailingButtonAction?() }) {
            
            switch trailingButton {
            case .text(let text):
                Text(text)
                    .font(.custom(Styles.Fonts.regularFontName, size: 14))
                    .foregroundColor(Color.white)
                    .frame(height:25,alignment:.trailing)
                
            default:
                Image(trailingButton.imageName)
                    .opacity(isTrailingButtonEnabled ? 1 : 0.4)
                    .padding()
            }
        }.disabled(!isTrailingButtonEnabled)
    }
}

//#Preview {
//    NavigationHeaderView(backButtonAction: {}, rightButtonAction: {}, trailingButton: .save)
//}

enum TrailingButtonType {
    
    case save
    case validate
    case reload
    case delete
    case editFile
    case more
    case text(text:String)
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
        case .text, .custom, .none : return ""
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
        case .share: return "share-icon"
        case .none: return ""
        }
    }
}

enum BackButtonType {
    
    case back
    case close
    case none

    var imageName: String {
        switch self {
        case .close: return "close"
        case .back: return "back"
        case .none: return ""

        }
    }
}


enum NavigationBarType {
    case inline
    case large
}

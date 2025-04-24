//
//  NavigationHeaderView.swift
//  Tella
//
//  Created by gus valbuena on 4/10/24.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
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
    
    var rightButtonType: RightButtonType = .none
    var rightButtonAction: (() -> Void)?
    
    var rightButtonView: (AnyView)? = nil
    
    var isRightButtonEnabled: Bool = true
    
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
                rightView
                
            }.frame(height: 57)
                .padding(.horizontal, 16)
            
            if navigationBarType == .large {
                largeTitleView
                    .padding(.horizontal, 16)
            }
        }.navigationBarHidden(true)
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
    
    private var rightView : some View {
        switch rightButtonType {
            
        case .custom:
            rightButtonView!
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
        Button(action: { rightButtonAction?() }) {
            
            switch rightButtonType {
            case .text(let text):
                Text(text)
                    .font(.custom(Styles.Fonts.regularFontName, size: 14))
                    .foregroundColor(Color.white)
                    .frame(height:25,alignment:.trailing)
                
            default:
                Image(rightButtonType.imageName)
                    .opacity(isRightButtonEnabled ? 1 : 0.4)
                    .padding()
            }
        }.disabled(!isRightButtonEnabled)
    }
}

#Preview {
    NavigationHeaderView( title: "Title",
                          navigationBarType: .inline,
                          backButtonType: .back,
                          middleButtonType: .editFile,
                          rightButtonType: .editFile)
}

//
//  CameraOptionsCard.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 7/10/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct CameraOptionsCard<Content: View>: View {
    let title: String
    var rotation: CameraControlRotation
    let onBack: () -> Void
    let content: Content
    
    init(title: String,
         rotation: CameraControlRotation = CameraControlRotation(),
         onBack: @escaping () -> Void,
         @ViewBuilder content: () -> Content) {
        self.title = title
        self.rotation = rotation
        self.onBack = onBack
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: .normal) {
            header
            content
                .padding(.vertical, .small)
        }
        .frame(maxWidth: .infinity)
        .padding(.all, .normal)
        .background(CameraOptionsBackground())
    }
    
    private var header: some View {
        ZStack {
            CustomText(title.uppercased(),
                       style: .body1Style,
                       alignment: .center)
            .rotate(rotation)
            .accessibilityAddTraits(.isHeader)
            
            HStack {
                Button(action: onBack) {
                    Image(.chevronBackward)
                        .background(Circle().fill(Styles.Colors.backgroundGrey1))
                        .frame(width: .smallMediumIconSize, height: .smallMediumIconSize)
                        .contentShape(Rectangle())
                }
                .rotate(rotation)
                .accessibilityLabel(LocalizableLock.actionBack.localized)
                
                Spacer(minLength: 0)
            }
        } .frame(height: .mediumIconSize)
        
    }
}

struct CameraOptionsBackground: View {
    private let shape = RoundedRectangle(cornerRadius: .medium,
                                         style: .continuous)
    
    @ViewBuilder
    var body: some View {
        if #available(iOS 26.0, *) {
            Color.clear
                .glassEffect(.clear.tint(Styles.Colors.black.opacity(0.8)),
                             in: shape)
        } else {
            BlurEffectView()
                .overlay(Styles.Colors.black.opacity(0.8))
                .clipShape(shape)
        }
    }
}

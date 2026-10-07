//
//  CameraFlashOptionsView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 7/10/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct CameraFlashIcon: View {
    
    let mode: CameraFlashMode
    var isHighlighted: Bool = false
    var iconSize: CGFloat = .tinyIconSize
    
    var body: some View {
        Image(mode.imageName)
            .renderingMode(.template)
            .foregroundColor(isHighlighted ? Styles.Colors.yellowBrighter : .white)
    }
}

struct CameraFlashOptionsView: View {
    
    @ObservedObject var viewModel: CameraViewModel
    var rotation = CameraControlRotation()
    
    private static let modes: [CameraFlashMode] = [.off, .on, .auto]
    
    var body: some View {
        CameraOptionsCard(title: LocalizableCamera.moreActionFlash.localized,
                          rotation: rotation,
                          onBack: viewModel.goBackFromFlashOptions) {
            HStack(spacing: .mediumlarge) {
                ForEach(Self.modes, id: \.self) { mode in
                    optionButton(mode)
                }
            }
        }
    }
    
    private func optionButton(_ mode: CameraFlashMode) -> some View {
        let isSelected = mode == viewModel.flashMode
        let color = isSelected ? Styles.Colors.yellowBrighter : .white
        let style: TypographyStyle = isSelected ? .buttonDetailBoldStyle : .buttonDetailRegularStyle
        
        return Button {
            viewModel.selectFlashMode(mode)
        } label: {
            VStack(spacing: .tiny) {
                CameraFlashIcon(mode: mode, isHighlighted: isSelected)
                    .frame(width: .tinyIconSize,
                           height: .tinyIconSize)
                
                CustomText(mode.title,
                           style: style,
                           alignment: .center,
                           color: color)
            }
            .frame(minWidth: .mediumIconSize)
            .contentShape(Rectangle())
            .rotate(rotation)
        }
        .accessibilityLabel(mode.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct CameraFlashOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            preview(mode: .off).previewDisplayName("Off")
            preview(mode: .on).previewDisplayName("On")
            preview(mode: .auto).previewDisplayName("Auto")
        }
    }
    
    private static func preview(mode: CameraFlashMode) -> some View {
        let viewModel = CameraViewModel.stub()
        viewModel.flashMode = mode
        return CameraFlashOptionsView(viewModel: viewModel)
            .padding()
            .background(Color.gray)
    }
}

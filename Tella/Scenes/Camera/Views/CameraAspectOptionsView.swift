//
//  CameraAspectOptionsView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 7/10/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct CameraAspectOptionsView: View {
    
    @ObservedObject var viewModel: CameraViewModel
    var rotation = CameraControlRotation()
    
    var body: some View {
        CameraOptionsCard(title: LocalizableCamera.moreActionAspect.localized,
                          rotation: rotation,
                          onBack: viewModel.goBackFromAspectOptions) {
            HStack(spacing: .mediumlarge) {
                ForEach(CameraAspectRatio.allCases, id: \.self) { ratio in
                    optionButton(ratio)
                }
            }
        }
    }
    
    private func optionButton(_ ratio: CameraAspectRatio) -> some View {
        let isSelected = ratio == viewModel.photoAspectRatio
        
        return Button {
            viewModel.selectPhotoAspectRatio(ratio)
        } label: {
            CustomText(ratio.title,
                       style: .cameraTabStyle,
                       alignment: .center,
                       color: isSelected ? Styles.Colors.yellowBrighter : .white)
            .rotate(rotation)
            .contentShape(Rectangle())
        }
        .accessibilityLabel(ratio.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct CameraAspectOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            preview(ratio: .threeByFour).previewDisplayName("3:4")
            preview(ratio: .nineBySixteen).previewDisplayName("9:16")
            preview(ratio: .oneByOne).previewDisplayName("1:1")
            preview(ratio: .full).previewDisplayName("Full")
        }
    }
    
    private static func preview(ratio: CameraAspectRatio) -> some View {
        let viewModel = CameraViewModel.stub()
        viewModel.photoAspectRatio = ratio
        return CameraAspectOptionsView(viewModel: viewModel)
            .padding()
            .background(Color.gray)
    }
}

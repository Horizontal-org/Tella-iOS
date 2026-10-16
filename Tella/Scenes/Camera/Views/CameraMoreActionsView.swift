//
//  CameraMoreActionsView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 7/10/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct CameraMoreActionsView: View {
    
    @ObservedObject var viewModel: CameraViewModel
    var rotation = CameraControlRotation()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if viewModel.showingMoreActions {
                actionsCard
                    .padding(.horizontal, .normal)
                    .padding(.bottom, .normal)
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .allowsHitTesting(viewModel.showingMoreActions)
    }
    
    private var actionsCard: some View {
        VStack(spacing: .smallMedium) {
            HStack(spacing: 0) {
                flashButton
                gridButton
                captureFormatButton
            }
            settingsButton
        }
        .padding(.horizontal, .extraSmall)
        .padding(.vertical, .normal)
        .background(CameraOptionsBackground())
    }
    
    private var flashButton: some View {
        actionButton(title: LocalizableCamera.moreActionFlash.localized,
                     isEnabled: viewModel.isFlashAvailable,
                     action: viewModel.showFlashOptions) {
            CameraFlashIcon(mode: viewModel.flashMode,
                            isHighlighted: viewModel.flashMode != .off,
                            iconSize: .large)
        }
    }
    
    private var gridButton: some View {
        actionButton(title: LocalizableCamera.moreActionGrid.localized,
                     action: viewModel.toggleGrid) {
            CameraGridIcon(isOn: viewModel.gridIsOn, iconSize: .large)
        }
    }
    
    private var captureFormatButton: some View {
        actionButton(title: captureFormatTitle,
                     value: captureFormatValue,
                     isEnabled: viewModel.cameraState.cameraType == .image,
                     action: captureFormatAction) {
            CustomText(captureFormatValue,
                       style: .heading2Style,
                       alignment: .center)
        }
    }
    
    private var settingsButton: some View {
        actionButton(title: LocalizableCommon.commonSettings.localized,
                     isEnabled: false,
                     dimsWhenDisabled: false,
                     action: viewModel.moreActionsSettingsTapped) {
            Image(.settings)
                .renderingMode(.template)
                .foregroundColor(.white)
        }
    }
    
    private var captureFormatTitle: String {
        viewModel.cameraState.cameraType == .image
        ? LocalizableCamera.moreActionAspect.localized
        : LocalizableCommon.commonResolution.localized
    }
    
    private var captureFormatValue: String {
        viewModel.cameraState.cameraType == .image
        ? viewModel.aspectRatioTitle
        : viewModel.videoResolutionTitle
    }
    
    private var captureFormatAction: () -> Void {
        viewModel.cameraState.cameraType == .image
        ? viewModel.moreActionsAspectTapped
        : viewModel.moreActionsResolutionTapped
    }
    
    private func actionButton<Icon: View>(title: String,
                                          value: String? = nil,
                                          isEnabled: Bool = true,
                                          dimsWhenDisabled: Bool = true,
                                          action: @escaping () -> Void,
                                          @ViewBuilder icon: () -> Icon) -> some View {
        Button(action: action) {
            icon()
        }
        .rotate(rotation)
        .buttonStyle(MoreActionPressStyle(title: title))
        .disabled(!isEnabled)
        .opacity(isEnabled || !dimsWhenDisabled ? 1 : 0.4)
        .frame(maxWidth: .infinity)
        .accessibilityLabel(title)
        .accessibilityValue(value ?? "")
    }
}

struct CameraGridIcon: View {
    
    let isOn: Bool
    var iconSize: CGFloat = .tinyIconSize
    
    var body: some View {
        Image(isOn ? .cameraGridOn : .cameraGridOff)
            .renderingMode(.template)
            .frame(width: iconSize, height: iconSize)
            .foregroundColor(isOn ? Styles.Colors.yellowBrighter : .white)
    }
}

private struct MoreActionPressStyle: ButtonStyle {
    let title: String
    
    func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: .tiny) {
            configuration.label
                .frame(width: .largeIconSize, height: .largeIconSize)
                .background {
                    Circle()
                        .fill(configuration.isPressed
                              ? Color.white.opacity(0.2)
                              : Styles.Colors.backgroundGrey1)
                }
            
            CustomText(title,
                       style: .body2SemiBoldStyle,
                       alignment: .center,
                       color: .white.opacity(0.88))
        }
        .contentShape(Rectangle())
    }
}

struct CameraMoreActionsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CameraMoreActionsView(viewModel: previewViewModel(state: .readyTakingImage))
                .previewDisplayName("Photo")
            CameraMoreActionsView(viewModel: previewViewModel(state: .readyRecordingVideo))
                .previewDisplayName("Video")
        }
        .background(Color.gray)
    }
    
    private static func previewViewModel(state: CameraState) -> CameraViewModel {
        let viewModel = CameraViewModel.stub(state: state)
        viewModel.showingMoreActions = true
        return viewModel
    }
}

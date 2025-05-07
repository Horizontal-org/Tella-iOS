//
//  EditVideoView.swift
//  Tella
//
//  Created by RIMA on 11.11.24.
//  Copyright © 2024 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI
import AVFoundation

struct EditVideoView: View {
    
    @ObservedObject var viewModel: EditVideoViewModel
    @State private var thumbnail: UIImage? = nil
    
    var body: some View {
        ZStack {
            VStack {
                
                EditMediaHeaderView(viewModel: viewModel,
                                    showRotate: {showRotateVideo()})
                CustomVideoPlayer(player: viewModel.player,
                                  rotationAngle: .constant(0))
                .frame(maxWidth: .infinity, maxHeight:  UIScreen.screenHeight / 0.6)
                
                EditMediaControlButtonsView(viewModel: viewModel)
                    .padding(.top, 16)
                trimView
                    .padding(EdgeInsets(top: 16, leading: 16, bottom: 40, trailing: 16))
                Spacer()
            }
            if viewModel.trimState == .loading {
                CircularActivityIndicatory()
            }
        }
        .onAppear {
            viewModel.onAppear()
            viewModel.trailingGestureValue = viewModel.editMedia.trailingPadding
            
        }
        .onDisappear {
            viewModel.onDisappear()
        }
        .onReceive(viewModel.$trimState) { value in
            handleTrimState(value: value)
        }
        .background(Color.black.ignoresSafeArea())
    }
    
    var thumbnailsView: some View {
        GeometryReader { geometry in
            HStack(alignment: .center, spacing: 0) {
                ForEach(viewModel.thumbnails, id: \.self) { image in
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(
                            width: geometry.size.width / CGFloat(viewModel.thumbnails.count),
                            height: 36
                        )
                        .clipped()
                }
            }
            .border(Color.white.opacity(0.8), width: 1)
        }
        .frame(height: 36)
    }
    
    // The trim view with all sliders
    var trimView: some View {
        GeometryReader { geometry in
            
            ZStack(alignment: .center) {
                
                thumbnailsView
                    .padding(EdgeInsets(top: 2, leading: 18, bottom: 2, trailing: 18))
                
                ZStack {
                    
                    leadingSliderView()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    trailingSliderView()
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                if !viewModel.isDraggingLeft && !viewModel.isDraggingRight {
                    
                    tapeLineSliderView
                        .padding(EdgeInsets(top: 0,
                                            leading: viewModel.leadingGestureValue + viewModel.editMedia.sliderWidth + 3,
                                            bottom: 0,
                                            trailing: UIScreen.screenWidth - viewModel.trailingGestureValue - viewModel.editMedia.sliderWidth - viewModel.editMedia.horizontalPadding + 4))
                }
            }
        }
        .frame(height: 40)
    }
    
    private var tapeLineSliderView: some View {
        CustomThumbnailSlider(
            value: $viewModel.currentPosition,
            range: viewModel.startTime...viewModel.endTime,
            sliderHeight: 36,
            sliderWidth: 5.0,
            sliderImage: viewModel.editMedia.playImageName
        ) { isEditing in
            viewModel.onPause()
        }
        .frame(height: 40)
    }
    private func leadingSliderView() -> some View {
        TrimMediaSliderView(value: $viewModel.startTime,
                            range: 0...viewModel.timeDuration,
                            currentRange: viewModel.startTime...viewModel.endTime,
                            editMedia: viewModel.editMedia,
                            sliderType: .leading,
                            gestureValue: $viewModel.leadingGestureValue,
                            isDragging: $viewModel.isDraggingLeft)
        .frame(height: 36)
        .onReceive(viewModel.$startTime, perform: { value in
            viewModel.didReachSliderLimit()
        })
        .onReceive(viewModel.$isDraggingLeft) { isDragging in
            self.viewModel.currentPosition = viewModel.startTime
        }
    }
    
    private func trailingSliderView() -> some View {
        TrimMediaSliderView(value: $viewModel.endTime,
                            range: 0...viewModel.timeDuration,
                            currentRange: viewModel.startTime...viewModel.endTime,
                            editMedia: viewModel.editMedia,
                            sliderType: .trailing,
                            gestureValue: $viewModel.trailingGestureValue,
                            isDragging: $viewModel.isDraggingRight)
        .frame(height: 36)
        .onReceive(viewModel.$endTime, perform: { value in
            viewModel.didReachSliderLimit()
        })
        .onReceive(viewModel.$isDraggingRight) { isDragging in
            self.viewModel.currentPosition = viewModel.endTime
        }
    }
    
    private func handleTrimState(value:ViewModelState<Bool>) {
        switch value {
        case .loaded(let isSaved):
            if isSaved {
                self.dismiss()
                Toast.displayToast(message: LocalizableVault.editFileSavedToast.localized)
            }
        case .error(let message):
            Toast.displayToast(message: message)
        default:
            break
        }
    }
    
    private func showRotateVideo() {
        self.present(style: .fullScreen) {
            RotateVideoView(viewModel: viewModel)
        }
    }
    
}

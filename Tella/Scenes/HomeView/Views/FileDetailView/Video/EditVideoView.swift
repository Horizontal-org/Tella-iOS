//
//  EditVideoView.swift
//  Tella
//
//  Created by RIMA on 11.11.24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI
import AVFoundation

struct EditVideoView: View {
    
    @ObservedObject var viewModel: EditVideoViewModel
    
    
    @State private var thumbnail: UIImage? = nil
 
    var body: some View {
        ZStack {
            VStack {
                
                EditMediaHeaderView(viewModel: viewModel)
                CustomVideoPlayer(player: viewModel.player)
                    .frame(maxWidth: .infinity, maxHeight:  UIScreen.screenHeight / 0.6)
                
                EditMediaControlButtonsView(viewModel: viewModel)
                    .padding(.top, 16)
                trimView
                    .padding(.bottom, 40)
                    .padding(.top, 16)

                Spacer()
            }
        }
        .onAppear {
            viewModel.onAppear()
            viewModel.trailingGestureValue = viewModel.kTrimViewWidth
        }
        .onDisappear {
            viewModel.onDisappear()
        }
        .onReceive(viewModel.$trimState) { value in
            handleTrimState(value: value)
        }
        .navigationBarHidden(true)
        .background(Color.black.ignoresSafeArea())
    }
    
    var thumbnailsView: some View {
        HStack(spacing: 0) {
            ForEach(viewModel.thumbnails, id: \.self) { image in
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 36)
                    .clipped()
                    .frame(maxWidth: .infinity)
            }
        }.border(Color.white.opacity(0.8), width: 1)
        .padding(0)
        .frame(maxWidth: viewModel.kTrimViewWidth, maxHeight: 36)
        .padding(.bottom, 20)
    }
    
    var trimView: some View {
        VStack {
            ZStack(alignment: .trailing) {
                ZStack(alignment: .leading) {
                    thumbnailsView
                    // This image is for the playing view
                    tapeLineSliderView
                    leadingSliderView()
                }.frame(maxWidth: viewModel.kTrimViewWidth)
                trailingSliderView()
            }
        }.frame(maxWidth: viewModel.kTrimViewWidth)
    }
    
    private var tapeLineSliderView: some View {
        CustomThumbnailSlider(value: $viewModel.currentPosition,
                              range: 0...viewModel.timeDuration,
                              sliderHeight: 36,
                              sliderWidth: 5.0,
                              sliderImage: "edit.video.play.line") { isEditing in
            viewModel.isSeekInProgress = true
            viewModel.shouldSeekVideo = isEditing
        }.frame(height: 40)
    }
    
    private func leadingSliderView() -> some View {
        TrimMediaSliderView(value: $viewModel.startTime,
                            range: 0...viewModel.timeDuration,
                            gestureValue: $viewModel.leadingGestureValue,
                            shouldLimitScrolling: $viewModel.shouldStopLeftScroll,
                            sliderHeight: 36,
                            isRightSlider: false,
                            sliderImage: "edit.video.left.icon",
                            imageWidth: 18)
        .frame(height: 36)
        .onReceive(viewModel.$startTime, perform: { value in
            viewModel.shouldStopLeftScroll = viewModel.startTime + viewModel.minimumAudioDuration >= viewModel.endTime
        })
    }
    
    private func trailingSliderView() -> some View {
        TrimMediaSliderView(value: $viewModel.endTime,
                            range: 0...viewModel.timeDuration,
                            gestureValue: $viewModel.trailingGestureValue,
                            shouldLimitScrolling: $viewModel.shouldStopRightScroll,
                            sliderHeight: 36, isRightSlider: true,
                            sliderImage: "edit.video.right.icon",
                            imageWidth: 18)
        .frame(height: 36)
        .onReceive(viewModel.$endTime, perform: { value in
            viewModel.shouldStopRightScroll = viewModel.startTime + viewModel.minimumAudioDuration >= viewModel.endTime
        })
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
    
}

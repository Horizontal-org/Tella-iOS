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
    
    @State var trailingGestureValue: Double = 0.0
    @State var leadingGestureValue: Double = 0.0
    @State var shouldStopLeftScroll = false
    @State var shouldStopRightScroll = false
    
    @State private var thumbnail: UIImage? = nil
 
    var body: some View {
        ZStack {
            VStack {
                
                EditMediaHeaderView(viewModel: viewModel)
                CustomVideoPlayer(player: viewModel.player)
                    .frame(maxWidth: .infinity, maxHeight: 450)
                
                controlButtonsView
                trimView
                Spacer()
            }
        }
        .onAppear {
            viewModel.onAppear()
            trailingGestureValue = viewModel.kTrimViewWidth
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
        }
        .padding(0)
        .frame(maxWidth: viewModel.kTrimViewWidth, maxHeight: 36)
        .padding(.bottom, 20)
    }
    var controlButtonsView: some View {
        HStack(spacing: 64) {
            Button(action: {  }) {
                ResizableImage("cancel.edit.file")
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray)
            }
            
            Button(action: {
                viewModel.handlePlayButton()
                
            }) {
                ResizableImage(viewModel.playButtonImageName)
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray)
            }
        }.padding(16)
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
            .padding(.bottom, 41)
    }
    
    private var tapeLineSliderView: some View {
        CustomThumbnailSlider(value: $viewModel.currentPosition,
                              range: 0...viewModel.timeDuration,
                              sliderHeight: 36,
                              sliderWidth: 5.0,
                              sliderImage: "edit.video.play.line") { isEditing in
            viewModel.isSeekInProgress = true
            viewModel.shouldSeekVideo = isEditing
        }.frame(height: 36)
    }
    
    private func leadingSliderView() -> some View {
        TrimAudioSliderView(value: $viewModel.startTime,
                            range: 0...viewModel.timeDuration,
                            gestureValue: $leadingGestureValue,
                            shouldLimitScrolling: $shouldStopLeftScroll,
                            sliderHeight: 36,
                            isRightSlider: false,
                            sliderImage: "edit.video.left.icon")
        .frame(height: 36)
        .onReceive(viewModel.$startTime, perform: { value in
            shouldStopLeftScroll = viewModel.startTime + viewModel.minimumAudioDuration >= viewModel.endTime
        })
    }
    
    private func trailingSliderView() -> some View {
        TrimAudioSliderView(value: $viewModel.endTime,
                            range: 0...viewModel.timeDuration,
                            gestureValue: $trailingGestureValue,
                            shouldLimitScrolling: $shouldStopRightScroll,
                            sliderHeight: 36, isRightSlider: true,
                            sliderImage: "edit.video.right.icon")
        .frame(height: 36)
        .onReceive(viewModel.$endTime, perform: { value in
            shouldStopRightScroll = viewModel.startTime + viewModel.minimumAudioDuration >= viewModel.endTime
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

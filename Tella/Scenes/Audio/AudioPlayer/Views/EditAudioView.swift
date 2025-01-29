//
//  EditAudioView.swift
//  Tella
//
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine
import SwiftUI



struct EditAudioView: View {
    
    @ObservedObject var viewModel: EditAudioViewModel
    
    var body: some View {
        ZStack {
            VStack {
                EditMediaHeaderView(viewModel: viewModel)
                timeLabelsView
                trimView
                displayTimeLabels
                EditMediaControlButtonsView(viewModel: viewModel) .padding(.top, 64)
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
        
        .background(Color.black.ignoresSafeArea())
    }
    
    
    var trimView: some View {
        VStack {
            ZStack(alignment: .trailing) {
                ZStack(alignment: .leading) {
                    // This image is for the playing view
                    trimBackgroundView()
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
                              sliderHeight: 210,
                              sliderWidth: 5.0,
                              sliderImage: "edit.audio.play.line") { isEditing in
            viewModel.onPause()
            if !isEditing {
                viewModel.currentTime = viewModel.currentPosition.formattedAsHHMMSS()
            }
        }.frame(height: 210)
            .offset(x: 5, y: 10 )
        -…
    }
    
    private func trimBackgroundView() -> some View {
        Group {
            // The image is for the soundwaves View
            Image("edit.audio.soundwaves")
                .resizable()
                .frame(height: 180)
                .background(Color.white.opacity(0.08))
            // Adding a background yellow to indicate the trimmed part View
            Rectangle().fill(Styles.Colors.yellow.opacity(0.16))
                .offset(x: viewModel.leadingGestureValue)
                .frame(width: abs(viewModel.leadingGestureValue - viewModel.trailingGestureValue ), height: 180 )
        }
    }
    
    private func leadingSliderView() -> some View {
        TrimMediaSliderView(value: $viewModel.startTime,
                            range: 0...viewModel.timeDuration,
                            gestureValue: $viewModel.leadingGestureValue,
                            shouldLimitScrolling: $viewModel.shouldStopLeftScroll,
                            isRightSlider: false,
                            sliderImage: "edit.audio.trim.line")
        .frame(height: 220)
        .offset(y: 20)
        .onReceive(viewModel.$startTime, perform: { value in
            viewModel.shouldStopLeftScroll = viewModel.startTime + viewModel.minimumAudioDuration >= viewModel.endTime
            viewModel.didReachSliderLimit()
         })
    }
    
    private func trailingSliderView() -> some View {
        TrimMediaSliderView(value: $viewModel.endTime,
                            range: 0...viewModel.timeDuration,
                            gestureValue: $viewModel.trailingGestureValue,
                            shouldLimitScrolling: $viewModel.shouldStopRightScroll,
                            isRightSlider: true,
                            sliderImage: "edit.audio.trim.line")
        .frame(height: 220)
        .offset(y:20)
        .onReceive(viewModel.$endTime, perform: { value in
            viewModel.shouldStopRightScroll = viewModel.startTime + viewModel.minimumAudioDuration >= viewModel.endTime
            viewModel.didReachSliderLimit()
         })
    }
    
    var timeLabelsView: some View {
        HStack(spacing: 0) {
            ForEach(viewModel.timeSlots) { time in
                Text(time)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.32))
                if time != viewModel.timeSlots.last {
                    Spacer()
                }
            }
        }.frame(width: viewModel.kTrimViewWidth, height: 40)
            .padding([.top], 70)
    }
    
    var displayTimeLabels: some View {
        VStack {
            Text(viewModel.currentTime)
                .font(.custom(Styles.Fonts.regularFontName, size: 50))
                .foregroundColor(.white)
            Text(viewModel.timeDuration.formattedAsHHMMSS())
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(.gray)
        }  .padding(.top, 70)
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



struct EditAudioView_Previews: PreviewProvider {
    static var previews: some View {
        EditAudioView(viewModel: EditAudioViewModel(file: nil, rootFile: nil,
                                                             appModel: MainAppModel.stub(),
                                                             shouldReloadVaultFiles: .constant(true)) )
    }
}

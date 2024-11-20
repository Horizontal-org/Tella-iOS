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
    
    @StateObject var editAudioViewModel: EditAudioViewModel
    @State var trailingGestureValue: Double = 0.0
    @State var leadingGestureValue: Double = 0.0
    @State var shouldStopLeftScroll = false
    @State var shouldStopRightScroll = false
    
    var body: some View {
        ZStack {
            VStack {
                EditMediaHeaderView(viewModel: editAudioViewModel)
                timeLabelsView
                trimView
                displayTimeLabels
                controlButtonsView
                Spacer()
            }
        }
        .onAppear {
            editAudioViewModel.onAppear()
            trailingGestureValue = editAudioViewModel.kTrimViewWidth
        }
        .onDisappear {
            editAudioViewModel.onDisappear()
        }
        .onReceive(editAudioViewModel.$trimState) { value in
            handleTrimState(value: value)
        }
        
        .navigationBarHidden(true)
        .background(Color.black.ignoresSafeArea())
    }
    
    
    var trimView: some View {
        VStack {
            ZStack(alignment: .trailing) {
                ZStack(alignment: .leading) {
                    // This image is for the playing view
                    trimBackgroundView()
                    Image("edit.audio.play.line")
                        .frame(height: 220)
                        .offset(x: editAudioViewModel.playingOffset)
                    
                    leadingSliderView()
                }.frame(maxWidth: editAudioViewModel.kTrimViewWidth)
                trailingSliderView()
            }
            
        }.frame(maxWidth: editAudioViewModel.kTrimViewWidth)
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
                .offset(x: leadingGestureValue)
                .frame(width: abs(leadingGestureValue - trailingGestureValue ), height: 180 )
        }
    }
    
    private func leadingSliderView() -> some View {
        TrimAudioSliderView(value: $editAudioViewModel.startTime,
                            range: 0...editAudioViewModel.timeDuration,
                            gestureValue: $leadingGestureValue,
                            shouldLimitScrolling: $shouldStopLeftScroll, isRightSlider: false)
        .frame(height: 220)
        .offset(y: 20)
        .onReceive(editAudioViewModel.$startTime, perform: { value in
            shouldStopLeftScroll = editAudioViewModel.startTime + editAudioViewModel.minimumAudioDuration >= editAudioViewModel.endTime
        })
    }
    
    private func trailingSliderView() -> some View {
        TrimAudioSliderView(value: $editAudioViewModel.endTime,
                            range: 0...editAudioViewModel.timeDuration,
                            gestureValue: $trailingGestureValue,
                            shouldLimitScrolling: $shouldStopRightScroll, isRightSlider: true)
        .frame(height: 220)
        .offset(y:20)
        .onReceive(editAudioViewModel.$endTime, perform: { value in
            shouldStopRightScroll = editAudioViewModel.startTime + editAudioViewModel.minimumAudioDuration >= editAudioViewModel.endTime
        })
    }
    
    var timeLabelsView: some View {
        HStack(spacing: 0) {
            ForEach(editAudioViewModel.timeSlots) { time in
                Text(time)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.32))
                if time != editAudioViewModel.timeSlots.last {
                    Spacer()
                }
            }
        }.frame(width: editAudioViewModel.kTrimViewWidth, height: 40)
            .padding([.top], 70)
    }
    
    var displayTimeLabels: some View {
        VStack {
            Text(editAudioViewModel.currentTime)
                .font(.custom(Styles.Fonts.regularFontName, size: 50))
                .foregroundColor(.white)
            Text(editAudioViewModel.timeDuration.formattedAsHHMMSS())
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(.gray)
        }  .padding(.top, 70)
    }
    
    
    var controlButtonsView: some View {
        HStack(spacing: 64) {
            Button(action: { self.undo() }) {
                Image("cancel.edit.file")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray)
            }
            
            Button(action: { editAudioViewModel.handlePlayButton() }) {
                Image(editAudioViewModel.playButtonImageName)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray)
            }
            
        }
        .padding(.top, 64)
    }
    
    private func undo() {
        editAudioViewModel.startTime = 0.0
        editAudioViewModel.endTime = editAudioViewModel.timeDuration
        leadingGestureValue = 0.0
        trailingGestureValue = editAudioViewModel.kTrimViewWidth
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
        EditAudioView(editAudioViewModel: EditAudioViewModel(file: nil, rootFile: nil,
                                                             appModel: MainAppModel.stub(),
                                                             shouldReloadVaultFiles: .constant(true)) )
    }
}

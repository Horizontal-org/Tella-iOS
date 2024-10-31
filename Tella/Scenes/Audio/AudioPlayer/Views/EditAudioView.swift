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
    @EnvironmentObject var sheetManager: SheetManager
    
    @StateObject var editAudioViewModel: EditAudioViewModel
    @State var isBottomSheetShown : Bool = false
    let kTrimViewWidth = UIScreen.screenWidth - 40
    
    @State var trailingGestureValue: Double = 0.0
    @State var leadingGestureValue: Double = 0.0
    @State var shouldStopLeftScroll = false
    @State var shouldStopRightScroll = false
    
    var body: some View {
        ZStack {
            VStack {
                headerView
                timeLabelsView
                trimView
                displayTimeLabels
                controlButtonsView
                Spacer()
            }
            EditFileCancelBottomSheet(isShown: $isBottomSheetShown, saveAction: { editAudioViewModel.trimAudio() })
        }
        .onAppear {
            editAudioViewModel.onAppear()
            trailingGestureValue = kTrimViewWidth
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
                }.frame(maxWidth: kTrimViewWidth)
                trailingSliderView()
            }
            
        }.frame(maxWidth: kTrimViewWidth)
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
            shouldStopLeftScroll = editAudioViewModel.startTime + editAudioViewModel.gapTime >= editAudioViewModel.endTime
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
            shouldStopRightScroll = editAudioViewModel.startTime + editAudioViewModel.gapTime >= editAudioViewModel.endTime
        })
    }
    
    var headerView: some View {
        HStack {
            Button(action: { self.closeView()}) {
                Image("file.edit.close")
            }
            
            Text(LocalizableVault.editAudioTitle.localized)
                .foregroundColor(.white)
            
            Spacer()
            if editAudioViewModel.isDurationHasChanged()  {
                Button(action: {
                    editAudioViewModel.trimAudio()
                }) {
                    Image("edit.audio.cut")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
            }
            
        }
        .frame(height: 30)
        .padding(16)
    }
    
    var timeLabelsView: some View {
        HStack(spacing: 0) {
            ForEach(editAudioViewModel.generateTimeLabels(), id: \.self) { time in
                Text(time)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.32))
                if time != editAudioViewModel.generateTimeLabels().last {
                    Spacer()
                }
            }
        }.frame(width: kTrimViewWidth)
            .padding([.top], 70)
    }
    
    var displayTimeLabels: some View {
        VStack {
            Text(editAudioViewModel.currentTime)
                .font(.custom(Styles.Fonts.regularFontName, size: 50))
                .foregroundColor(.white)
            Text(editAudioViewModel.duration)
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
        trailingGestureValue = kTrimViewWidth
    }
    private func closeView() {
        editAudioViewModel.isPlaying = false
        if editAudioViewModel.isDurationHasChanged() {
            isBottomSheetShown = true
        }else  {
            self.dismiss()
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
    
}



struct EditAudioView_Previews: PreviewProvider {
    static var previews: some View {
        EditAudioView(editAudioViewModel: EditAudioViewModel(fileListViewModel: FileListViewModel(appModel: MainAppModel.stub())))
    }
}

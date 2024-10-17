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
    @Binding var isPresented : Bool
    @State var isBottomSheetShown : Bool = false
    let kTrimViewWidth = 340.0
    
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
            EditFileCancelBottomSheet(isShown: $isBottomSheetShown, saveAction: { handleSaveAction() })
        }
        .onAppear {
            editAudioViewModel.onAppear()
            trailingGestureValue = kTrimViewWidth
        }
        .navigationBarHidden(true)
        .background(Color.black.ignoresSafeArea())
    }
    
    
    var trimView: some View {
        VStack {
            ZStack(alignment: .trailing) {
                ZStack(alignment: .leading) {
                    Image("audio.soundwaves")
                        .resizable()
                        .frame(height: 180)
                        .background(Styles.Colors.yellow.opacity(0.16))
                    
                    Image("edit.audio.play.line")
                        .frame(height: 220)
                        .offset(x: editAudioViewModel.offset)
                    
                    TrimAudioSliderView(value: $editAudioViewModel.startTime,
                                        range: 0...editAudioViewModel.timeDuration,
                                        gestureValue: $leadingGestureValue,
                                        shouldLimitScrolling: $shouldStopLeftScroll)
                        .frame(height: 220)
                        .offset(y: 20)
                        .onReceive(editAudioViewModel.$startTime, perform: { value in
                            shouldStopLeftScroll = editAudioViewModel.startTime + editAudioViewModel.gapTime >= editAudioViewModel.endTime
                        })

                    Rectangle().fill(Color.white.opacity(0.08))
                        .frame(maxWidth: kTrimViewWidth - trailingGestureValue )
                        .offset(x: trailingGestureValue)
                        .frame(height: 180)
                    Rectangle().fill(Color.white.opacity(0.08))
                        .frame(maxWidth: leadingGestureValue)
                        .frame(height: 180)
                    
                }.frame(maxWidth: kTrimViewWidth)
                
                TrimAudioSliderView(value: $editAudioViewModel.endTime,
                                    range: 0...editAudioViewModel.timeDuration,
                                    gestureValue: $trailingGestureValue,
                                    shouldLimitScrolling: $shouldStopRightScroll)
                    .frame(height: 220)
                    .offset(y:20)
                    .onReceive(editAudioViewModel.$endTime, perform: { value in
                        shouldStopRightScroll = editAudioViewModel.startTime + editAudioViewModel.gapTime >= editAudioViewModel.endTime
                    })



            }.frame(maxWidth: kTrimViewWidth)
            
        }.frame(maxWidth: kTrimViewWidth)
    }
    
    var headerView: some View {
        HStack {
            Button(action: {
                isBottomSheetShown = true
            }) {
                Image("file.edit.close")
            }
            
            Text(LocalizableVault.editAudioTitle.localized)
                .foregroundColor(.white)
            
            Spacer()
            if editAudioViewModel.endTime != editAudioViewModel.timeDuration || editAudioViewModel.startTime != 0.0 {
                Button(action: {
                    isPresented = true
                }) {
                    Image("file.edit.done")
                }
            }

        }.padding(16)
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
            Text(editAudioViewModel.audioPlayerViewModel.duration)
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(.gray)
        }  .padding(.top, 70)
    }
    
    
    var controlButtonsView: some View {
        HStack(spacing: 40) {
            Button(action: { self.undo() }) {
                Image("cancel.edit.file")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.gray)
            }
            
            Button(action: { editAudioViewModel.handlePlayButton() }) {
                Image(editAudioViewModel.playButtonImageName)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.gray)
            }
            
            Button(action: { editAudioViewModel.trimAudio()}) {
                Image("cut.file")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.orange)
            }
        }
        .padding(.top, 64)
    }
    func handleSaveAction() {
        isPresented = false
    }
    
    private func undo() {
        editAudioViewModel.startTime = 0.0
        editAudioViewModel.endTime = editAudioViewModel.timeDuration
        leadingGestureValue = 0.0
        trailingGestureValue = kTrimViewWidth
    }
}



private struct TrimAudioSliderView: View {
    @Binding var value: Double
    var range: ClosedRange<Double>
    @Binding var gestureValue: Double
    @Binding var shouldLimitScrolling: Bool
    
    @State private var isRightSlider = false //This variable to check if the slider starts from the left or the right side
    private let kOffset = 3.0 //This is added to adjust the difference of the elipse in the trim line image
    private let kLabelOffset = 15.0 //This constant is added to center the value label in the trim line
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Custom thumb with image
                Image("edit.audio.trim.line").resizable()
                    .frame(width: 10, height: 190)
                    .offset(x: CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * geometry.size.width - kOffset) // Center thumb
                    .gesture(DragGesture(minimumDistance: 0).onChanged { dragValue in
                        // Calculate new value based on drag position
                        let newValue = Double(dragValue.location.x / geometry.size.width) * (range.upperBound - range.lowerBound) + range.lowerBound
                        self.gestureValue = CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * geometry.size.width //- kOffset
                        if shouldLimitScrolling {
                            if isRightSlider {
                                guard newValue >= value else { return }
                            } else {
                                guard newValue <= value else { return }
                            }
                        }
                        self.value = min(max(newValue, range.lowerBound), range.upperBound)

                    }.onEnded({ dragValue in
                        
                        self.gestureValue = CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * geometry.size.width //- kOffset
                    }))
                Text("\(TimeInterval(self.value).toHHMMString())")
                    .foregroundColor(Styles.Colors.yellow)
                    .font(.custom(Styles.Fonts.regularFontName, size: 12))
                    .offset(x: CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * geometry.size.width - kLabelOffset
                            ,y: 105)
                
            }
        }
        .onAppear {
            self.isRightSlider = range.upperBound == value
        }

    }
}

struct EditAudioView_Previews: PreviewProvider {
    static var previews: some View {
        EditAudioView(editAudioViewModel: EditAudioViewModel(audioPlayerViewModel: AudioPlayerViewModel(currentData: nil, currentFile: nil, mainAppModel: MainAppModel.stub())),
                      isPresented: .constant(true))
    }
}

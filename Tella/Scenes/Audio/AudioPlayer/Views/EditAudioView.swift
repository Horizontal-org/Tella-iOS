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
    
    var body: some View {
        ZStack {
            
            VStack {
                headerView
                timeLabelsView
                trimView
                VStack {
                    Text(editAudioViewModel.currentTime)
                        .font(.custom(Styles.Fonts.regularFontName, size: 50))
                        .foregroundColor(.white)
                    Text(editAudioViewModel.audioPlayerViewModel.duration)
                        .font(.custom(Styles.Fonts.regularFontName, size: 14))
                        .foregroundColor(.gray)
                }  .padding(.top, 70)
                controlButtonsView
                Spacer()
            }
            EditFileCancelBottomSheet(isShown: $isBottomSheetShown, saveAction: { handleSaveAction() })
        }
        .onAppear {
            editAudioViewModel.onAppear()
        }
        .navigationBarHidden(true)
        .background(Color.black.ignoresSafeArea())
    }
    
    
    var headerView: some View {
        HStack {
            Button(action: {
                
                isBottomSheetShown = true
            }) {
                Image("file.edit.close")
                    .foregroundColor(.white)
                    .padding()
            }
            
            Text("Edit audio")
                .foregroundColor(.white)
                .padding()
            
            Spacer()
        }
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
        }.frame(width: 340)
            .padding([.top], 70)
    }
    
    var trimView: some View {
        VStack {
            ZStack(alignment: .trailing) {
                ZStack(alignment: .leading) {
                    
                    Image("audio.soundwaves")
                        .resizable()
                        .frame(height: 180)
                        .aspectRatio(contentMode: .fill)
                        .background(Styles.Colors.yellow.opacity(0.16))

                    Image("edit.audio.play.line")
                        .frame(height: 220)
                        .offset(x: editAudioViewModel.offset)
                    
                    CustomSliderView(value: $editAudioViewModel.startTime, range: 0...editAudioViewModel.timeDuration)
                        .frame(height: 220)
                    
                }
                CustomSliderView(value: $editAudioViewModel.endTime, range: 0...editAudioViewModel.timeDuration)
                    .frame(height: 220)
            }.frame(maxWidth: 340)
            
        }.padding(30)
    }
    
    var controlButtonsView: some View {
        HStack(spacing: 40) {
            Button(action: { editAudioViewModel.undo() }) {
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
    
}



struct CustomSliderView: View {
    @Binding var value: Double
    var range: ClosedRange<Double>
    
    private let kHeight = 180.0
    private let kOffset = 3.0 //This is added to adjust the difference of the elipse in the trim line image
    private let kLabelOffset = 30.0 //15
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
                        self.value = min(max(newValue, range.lowerBound), range.upperBound)
                    })
                Text("\(TimeInterval(self.value).toHHMMString())")
                    .foregroundColor(Styles.Colors.yellow)
                    .font(.custom(Styles.Fonts.regularFontName, size: 12))
                    .offset(x: CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * geometry.size.width - kLabelOffset
                            , y: 105) // Center thumb
                
            }
        }
    }
}

struct EditAudioView_Previews: PreviewProvider {
    static var previews: some View {
        EditAudioView(editAudioViewModel: EditAudioViewModel(audioPlayerViewModel: AudioPlayerViewModel(currentData: nil, currentFile: nil, mainAppModel: MainAppModel.stub())),
                      isPresented: .constant(true))
    }
}


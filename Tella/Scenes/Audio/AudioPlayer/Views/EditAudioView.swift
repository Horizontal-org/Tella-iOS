//
//  EditAudioView.swift
//  Tella
//
//  Copyright © 2024 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import Combine
import SwiftUI



struct EditAudioView: View {
    
    @ObservedObject var viewModel: EditAudioViewModel
    
    var body: some View {
        ZStack {
            VStack {
                EditMediaHeaderView(viewModel: viewModel, isMiddleButtonEnabled: .constant(true))
                timeLabelsView
                trimView
                    .padding(EdgeInsets(top: 0, leading: viewModel.editMedia.horizontalPadding, bottom: 0, trailing:  viewModel.editMedia.horizontalPadding))
                
                displayTimeLabels
                EditMediaControlButtonsView(viewModel: viewModel) .padding(.top, 64)
                Spacer()
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
    
    var trimView: some View {
        GeometryReader { geometry in
            
            ZStack(alignment: .center) {
                
                trimBackgroundView()
                //                    .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                
                Rectangle().fill(Styles.Colors.yellow.opacity(0.16))
                    .padding(EdgeInsets(top: 0,
                                        leading: viewModel.leadingGestureValue - 3,
                                        bottom: 0,
                                        trailing: UIScreen.screenWidth - viewModel.trailingGestureValue - viewModel.editMedia.sliderWidth - viewModel.editMedia.horizontalPadding - 23))
                ZStack {
                    leadingSliderView()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    trailingSliderView()
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                
                if !viewModel.isDraggingLeft && !viewModel.isDraggingRight {
                    
                    tapeLineSliderView
                        .padding(EdgeInsets(top: 0,
                                            leading: viewModel.leadingGestureValue + viewModel.editMedia.sliderWidth + viewModel.editMedia.extraLeadingSpace,
                                            bottom: 0,
                                            trailing: UIScreen.screenWidth - viewModel.trailingGestureValue - viewModel.editMedia.sliderWidth - viewModel.editMedia.horizontalPadding - viewModel.editMedia.extraTrailingSpace))
                }
            }
        }
        .frame(height: 196)
    }
    
    private var tapeLineSliderView: some View {
        CustomThumbnailSlider(value: $viewModel.currentPosition,
                              range: viewModel.startTime...viewModel.endTime,
                              sliderHeight: 210,
                              sliderWidth: 5.0,
                              sliderImage: viewModel.editMedia.playImageName) {
            viewModel.updateCurrentPosition()
        }.frame(height: 196)
    }
    
    private func trimBackgroundView() -> some View {
        Image("edit.audio.soundwaves")
            .resizable()
            .frame(height: 180)
            .background(Color.white.opacity(0.08))
    }
    
    private func leadingSliderView() -> some View {
        TrimMediaSliderView(currentValue: $viewModel.startTime,
                            gestureValue: $viewModel.leadingGestureValue,
                            isDragging: $viewModel.isDraggingLeft,
                            range: 0...viewModel.timeDuration,
                            currentRange: viewModel.startTime...viewModel.endTime,
                            editMedia: viewModel.editMedia,
                            sliderType: .leading)
        .frame(height: 196)
        .onReceive(viewModel.$isDraggingLeft) { isDragging in
            viewModel.resetSliderToStart()
        }
    }
    
    private func trailingSliderView() -> some View {
        TrimMediaSliderView(currentValue: $viewModel.endTime,
                            gestureValue: $viewModel.trailingGestureValue,
                            isDragging: $viewModel.isDraggingRight,
                            range: 0...viewModel.timeDuration,
                            currentRange: viewModel.startTime...viewModel.endTime,
                            editMedia: viewModel.editMedia,
                            sliderType: .trailing)
        .frame(height: 196)
        .onReceive(viewModel.$endTime, perform: { value in
            viewModel.resetSliderToStart()
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
        }.frame(width: viewModel.editMedia.trailingPadding, height: 40)
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
                Toast.displayToast(message: LocalizableVault.editFileSavedToast.localized, delay: 5.0)
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
                                                    mainAppModel: MainAppModel.stub(),
                                                    editMedia: EditAudioParameters()))
    }
}

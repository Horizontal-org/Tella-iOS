//
//  RotateVideoView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 25/4/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct RotateVideoView: View {
    
    @ObservedObject var viewModel: EditVideoViewModel
    @State private var thumbnail: UIImage? = nil
    
    var body: some View {
        ZStack {
            VStack {
                NavigationHeaderView(
                    backButtonType: .close,
                    backButtonAction: closeView,
                    rightButtonType: viewModel.isVideoRotated() ? .validate : .none,
                    rightButtonAction: viewModel.rotate
                )
                
                Spacer()
                videoPlayerView
                Spacer()
                rotateButton
            }
            
            if viewModel.rotateState == .loading {
                CircularActivityIndicatory()
            }
        }
        .onAppear {
            viewModel.observeVideoSize()
        }
        .onReceive(viewModel.$rotateState, perform: handleRotateState)
        .background(Color.black.ignoresSafeArea())
    }
    
    // MARK: - Video Player View
    private var videoPlayerView: some View {
        let videoPlayerSize = viewModel.videoPlayerSize
        return CustomVideoPlayer(player: viewModel.player,
                                 rotationAngle: $viewModel.rotationAngle)
        .frame(width: videoPlayerSize.width, height: videoPlayerSize.height)
        .clipped()
        .border(Color.white, width: 2)
    }
    
    // MARK: - Rotate Button
    private var rotateButton: some View {
        Button(action: {
            viewModel.rotationAngle -= 90
            if viewModel.rotationAngle == -360 { viewModel.rotationAngle = 0 } // Reset after -360 degrees
        },label: {
            Image("edit.rotate")
        })
        .padding(.bottom, 24)
    }
    
    // MARK: - Close View
    private func closeView() {
        self.dismiss()
    }
    
    // MARK: - Handle Rotate State Changes
    private func handleRotateState(value:ViewModelState<Bool>) {
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



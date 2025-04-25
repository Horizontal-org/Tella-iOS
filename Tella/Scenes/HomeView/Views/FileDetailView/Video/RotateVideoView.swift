//
//  RotateVideoView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 25/4/2025.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//
import SwiftUI

struct RotateVideoView: View {
    
    @ObservedObject var viewModel: EditVideoViewModel
    @State private var thumbnail: UIImage? = nil
    
    var body: some View {
        ZStack {
            VStack {
                
                NavigationHeaderView(backButtonType: .close,
                                     backButtonAction: {self.closeView()},
                                     rightButtonType: viewModel.isVideoRotated() ? .validate : .none,
                                     rightButtonAction: { viewModel.rotate() })
                Spacer()
                CustomVideoPlayer(player: viewModel.player,
                                  rotationAngle: $viewModel.rotationAngle)
                .frame(maxWidth: .infinity, maxHeight:  UIScreen.screenHeight / 0.6)
                
                Spacer()
                
                rotateButton
                
                Spacer()
            }
        }
        .onAppear {
        }
        .onDisappear {
        }
        .background(Color.black.ignoresSafeArea())
    }
    
    private var rotateButton: some View {
        Button(action: {
            viewModel.rotationAngle -= 90
            if viewModel.rotationAngle == -360 { viewModel.rotationAngle = 0 } // Reset after -360 degrees
        },label: {
            Image("edit.rotate")
        })
        .padding(.bottom, 24)
    }
    
    private func closeView() {
        self.dismiss()
    }
    
    private func showRotateVideo() {
        self.present(style: .fullScreen) {
            EditVideoView(viewModel: viewModel)
        }
    }
    
}

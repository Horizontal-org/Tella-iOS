//
//  AudioPlayerView.swift
//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct AudioPlayerView: View {
    
    @StateObject var viewModel = AudioPlayerViewModel()
    @EnvironmentObject private var homeViewModel: MainAppModel
    
    var audioData : Data?
    
    var body: some View {
        
        ContainerView {
            
            VStack {
                
                Spacer()
                    .frame( height: 85)
                
                VStack {
                    Text("\(self.viewModel.currentTime)")
                        .font(.custom(Styles.Fonts.lightFontName, size: 50))
                        .foregroundColor(.white)

                    Text(self.viewModel.duration)
                        .font(.custom(Styles.Fonts.regularFontName, size: 14))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                self.getContentView()
                
                Spacer()
            }
        }
        .onAppear {
            self.viewModel.audioPlayerManager.currentAudioData = audioData
            self.viewModel.audioPlayerManager.initPlayer()
        }
    }
    
    private func getContentView() -> AnyView {
        
        switch self.viewModel.state {
        case .ready: return AnyView ( self.getReadyView() )
        case .playing: return AnyView ( getPlayingView() )
        }
    }
    
    private func getReadyView() -> some View {
        
        HStack(spacing: 34) {
            
            Button(action: {
                self.viewModel.onrewindBack()
            }) {
                
                Image("mic.rewind-back")
                    .frame(width: 40, height: 40)
            }.disabled(self.viewModel.shouldDisableRewindBackButton)
            
            Button(action: {
                
                self.viewModel.onStartPlaying()
            }) {
                
                Image("mic.play-audio")
                    .frame(width: 75, height: 75)
            }
            
            Button(action: {
                self.viewModel.onFastForward()
            }) {
                
                Image("mic.fast-forward")
                    .frame(width: 40, height: 40)
            }.disabled(self.viewModel.shouldDisableFastForwardButton)
            
        }
        .padding()
        
    }
    
    private func getPlayingView() -> some View {
        
        HStack(spacing: 34) {
            
            
            Button(action: {
                self.viewModel.onrewindBack()
            }) {
                
                Image("mic.rewind-back")
                    .frame(width: 40, height: 40)
            }
            
            Button(action: {
                
                self.viewModel.onStopPlaying()
            }) {
                
                Image("mic.pause-audio")
                    .frame(width: 75, height: 75)
            }
            
            Button(action: {
                self.viewModel.onFastForward()
            }) {
                
                Image("mic.fast-forward")
                    .frame(width: 40, height: 40)
            }
        }
        .padding()
    }
    
}

struct AudioPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        AudioPlayerView(audioData: nil)
    }
}




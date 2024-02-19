//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct AudioPlayerView: View {
    
    @StateObject var viewModel = AudioPlayerViewModel()
    @EnvironmentObject private var homeViewModel: MainAppModel
    
    var vaultFile : VaultFileDB
    
    var body: some View {
        
        ContainerView {
            
            VStack {
                
                Spacer()
                    .frame( height: 70)
                
                getTimeView()
                
                Spacer()
                
                self.getContentView()
                    .frame(height: 75)
                
                Spacer()
                    .frame( height: 108)
            }
        }
        .onAppear {
            self.viewModel.audioPlayerManager.currentAudioData = homeViewModel.vaultManager.loadFileData(file: vaultFile)
            self.viewModel.audioPlayerManager.initPlayer()
        }
        .onDisappear {
            self.viewModel.onStopPlaying()
        }
    }
    
    private func getContentView() -> AnyView {
        
        switch self.viewModel.state {
        case .ready:
            return AnyView ( self.getReadyView() )
        case .playing:
            return AnyView ( getPlayingView() )
        }
    }
    
    private func getReadyView() -> some View {
        
        HStack(spacing: 34) {
            
            Button(action: {
                self.viewModel.onrewindBack()
            }) {
                getRewindBackView()
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
                getFastForwardView()
            }.disabled(self.viewModel.shouldDisableFastForwardButton)
            
        }.padding()
        
    }
    
    private func getPlayingView() -> some View {
        
        HStack(spacing: 34) {
            
            Button(action: {
                self.viewModel.onrewindBack()
            }) {
                getRewindBackView()
            }
            
            Button(action: {
                self.viewModel.onPausePlaying()
            }) {
                Image("mic.pause-audio")
                    .frame(width: 75, height: 75)
            }
            
            Button(action: {
                self.viewModel.onFastForward()
            }) {
                getFastForwardView()
            }
        }
        .padding()
    }
    
    private func getRewindBackView() -> some View {
        VStack() {
            Spacer()
            Image(self.viewModel.shouldDisableFastForwardButton ? "mic.rewind-back" : "mic.rewind-back-on")
                .frame(width: 40, height: 40)
            
            Text(String.init(format: LocalizableVault.fileAudioUpdateSecondTime.localized, "-15"))
                .font(.custom(Styles.Fonts.regularFontName, size: 11))
                .foregroundColor(self.viewModel.shouldDisableRewindBackButton ? .gray : .white)
        }
    }
    
    private func getFastForwardView() -> some View {
        VStack {
            Spacer()
            Image(self.viewModel.shouldDisableFastForwardButton ? "mic.fast-forward" : "mic.fast-forward-on")
                .frame(width: 40, height: 40)
            Text(String.init(format: LocalizableVault.fileAudioUpdateSecondTime.localized, "+15"))
                .font(.custom(Styles.Fonts.regularFontName, size: 11))
                .foregroundColor(self.viewModel.shouldDisableFastForwardButton ? .gray : .white)
        }
    }
    
    private func getTimeView() -> some View {
        VStack {
            Text("\(self.viewModel.currentTime)")
                .font(.custom(Styles.Fonts.lightFontName, size: 50))
                .foregroundColor(.white)
            
            Text(self.viewModel.duration)
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(.white)
        }
    }
}

struct AudioPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        AudioPlayerView(vaultFile: VaultFileDB.stub())
    }
}




//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct CustomVideoControlsView: View {
    
    @ObservedObject var playerVM: PlayerViewModel
    
    var body: some View {
        VStack  {
            
            ZStack {
                Color.black.opacity(0.8)
                
                VStack {
                    HStack {
                        Button(action: {
                            playerVM.showPreviousVideo()
                        }, label: {
                            Image("video.skip-previous")
                        })
                        
                        Spacer()
                        
                        Button(action: {
                            playerVM.rewind()
                        }, label: {
                            Image( playerVM.shouldDisableRewind ? "video.rewind-back-off" : "video.rewind-back-on")
                        }).disabled(playerVM.shouldDisableRewind)
                        
                        Spacer()
                        
                        if playerVM.isPlaying == false {
                            Button(action: {
                                playerVM.playVideo()
                            }, label: {
                                Image("video.play")
                            })
                        } else {
                            Button(action: {
                                playerVM.player.pause()
                            }, label: {
                                Image("video.pause")
                            })
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            playerVM.fastForward()
                        }, label: {
                            Image(playerVM.shouldDisableFastForward ? "video.fast-forward-off" : "video.fast-forward-on")
                        }).disabled(playerVM.shouldDisableFastForward)
                        
                        Spacer()
                        
                        Button(action: {
                            playerVM.showNextVideo()
                        }, label: {
                            Image("video.skip-next")
                        })
                    }
                    
                    HStack {
                        Text(playerVM.formattedCurrentPosition)
                            .font(.custom(Styles.Fonts.regularFontName, size: 11))
                            .foregroundColor(.white)
                        Spacer()
                            .frame(width: 12)
                        
                        Slider(value: $playerVM.currentPosition, in: 0...(playerVM.videoDuration ?? 0), onEditingChanged: { isEditing in
                            playerVM.isSeekInProgress = true
                            playerVM.shouldSeekVideo = isEditing
                        }).accentColor(Styles.Colors.yellow)
                        
                        Spacer()
                            .frame(width: 12)
                        
                        Text(playerVM.formattedVideoDuration)
                            .font(.custom(Styles.Fonts.regularFontName, size: 11))
                            .foregroundColor(.white)
                        
                    }.disabled(!playerVM.videoIsReady)
                    
                }
                .padding(EdgeInsets(top: 32, leading: 28, bottom: 35, trailing: 28))
                
            }
            .frame(height: 95)
            Spacer()

        }.frame(height: 115)
        .edgesIgnoringSafeArea(.all)
    }
}

struct CustomVideoControlsView_Previews: PreviewProvider {
    static var previews: some View {
        CustomVideoControlsView(playerVM: PlayerViewModel(mainAppModel: MainAppModel.stub(),
                                                          currentFile: VaultFileDB.stubFiles().first,
                                                          playList: VaultFileDB.stubFiles(),
                                                          rootFile: nil))
    }
}

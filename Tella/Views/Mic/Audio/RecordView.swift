//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

/*
 This class will handle the recording functionality of the app. Functionality should allow users to record audio which will automatically be saved and encrypted in the Tella app but not on the users phone
 */

import SwiftUI
import Foundation
import Combine
import UIKit

struct RecordView: View {
    
    @ObservedObject var viewModel = RecordViewModel()
    @EnvironmentObject private var appViewState: AppViewState
    @State private var showingSaveAudioConfirmationView : Bool = false
    @EnvironmentObject private var homeViewModel: MainAppModel
    
    
    let modalHeight = 173.0
    
    func goBack() {
        self.appViewState.navigateBack()
    }
    
    var body: some View {
        ContainerView {
            
            VStack {
                
                Spacer()
                    .frame( height: 30)
                
                Text("Recorder")
                    .font(.custom(Styles.Fonts.boldFontName, size: 35))
                    .foregroundColor(.white)
                
                Spacer()
                    .frame( height: 70)
                
                VStack {
                    Text("Recording 2020.06.24-16.45")
                        .font(.custom(Styles.Fonts.boldFontName, size: 16))
                        .foregroundColor(Styles.Colors.buttonAdd)
                    
                    Text("0:00")
                        .font(.custom(Styles.Fonts.lightFontName, size: 50))
                        .foregroundColor(.white)
                    
                    Text("2 hours 46 min (452 MB) left")
                        .font(.custom(Styles.Fonts.regularFontName, size: 14))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                self.getContentView()
                
                Spacer()
            }
        }
    }
    
    private func getContentView() -> AnyView {
        
        switch self.viewModel.state {
        case .ready: return AnyView ( self.getReadyView() )
        case .recording: return AnyView ( getRecordingView() )
        case .paused: return AnyView ( getPausedView() )
        case .done: return AnyView ( getDoneView() )
        }
    }
    
    private func getReadyView() -> some View {
        
        
        GeometryReader { size in
            
            
            //
            HStack(spacing: 35) {
                Spacer()
                Button(action: {
                    self.viewModel.onStartRecording()
                }) {
                    Image("mic.record")
                        .frame(width: 83, height: 83)
                }
                
                Button(action: {
                    self.listenAudiFiles()
                }) {
                    
                    Image("mic.listen")
                        .frame(width: 40, height: 40)
                }
            }.padding(EdgeInsets(top: 0, leading: ((size.size.width/2) - 112), bottom:0 , trailing: ((size.size.width/2) - 112)))
            
        }
        
    }
    private func getRecordingView() -> some View {
        
        GeometryReader { size in
            
            HStack(spacing: 35) {
                
                
                Button(action: {
                    self.viewModel.onPauseRecord()
                }) {
                    
                    Image("mic.pause")
                        .frame(width: 40, height: 40)
                }
                
                
                
                Button(action: {
                    self.viewModel.onPauseRecord()

                    showSaveAudioConfirmationView()
                    
                }) {
                    
                    Image("mic.stop")
                        .frame(width: 83, height: 83)
                }
                
            }.padding(EdgeInsets(top: 0, leading: ((size.size.width/2) - 112), bottom:0 , trailing: ((size.size.width/2) - 112)))
            
        }
    }
    
    private func getDoneView() -> some View {
        VStack {
            
            bigLabeledImageButton(.PLUS, "SAVE") {
                self.viewModel.onSaveRecording()
            }
            HStack {
                Button (action: self.viewModel.onPlayRecord) {
                    largeImg(.PLAY)
                }
                Button (action: self.viewModel.onPauseRecord) {
                    largeImg(.PAUSE)
                }
            }
            
            bigLabeledImageButton(.SHUTDOWN, "DISCARD") {
                self.viewModel.onDiscardRecord()
            }
        }
    }
    
    
    private func getPausedView() -> some View {
             HStack(spacing: 34) {
                
 
                Button(action: {
                    self.viewModel.onPlayRecord()
                }) {
                    
                    Image("mic.play")
                        .frame(width: 40, height: 40)
                }

                 Button(action: {
                    
                    self.viewModel.onStartRecording()
                }) {
                    
                    Image("mic.record")
                        .frame(width: 83, height: 83)
                }

                 Button(action: {
                    self.listenAudiFiles()
                }) {
                    
                    Image("mic.listen")
                        .frame(width: 40, height: 40)
                }
                
         }
             .padding()
    }
    
    private func listenAudiFiles() {
        appViewState.resetToAudio()
    }
    
    private func showSaveAudioConfirmationView() {
        showingSaveAudioConfirmationView = true
        
        homeViewModel.content = DragViewData(modalHeight: modalHeight, isPresented: $showingSaveAudioConfirmationView, content: AnyView (saveAudioConfirmationView))
    }
    
    private var saveAudioConfirmationView : some View {
        
        return SaveAudioConfirmationView(showingSaveAudioConfirmationView: $showingSaveAudioConfirmationView ) {
           
            self.viewModel.onStopRecording()
            guard let url = self.viewModel.url else {return}
            homeViewModel.add(files: [url], to: homeViewModel.vaultManager.root, type: .audio)
            self.viewModel.onSaveRecording()
            
        } didCancel: {
            self.viewModel.onStopRecording()
            self.viewModel.onDiscardRecord()
        }
    }
    
}

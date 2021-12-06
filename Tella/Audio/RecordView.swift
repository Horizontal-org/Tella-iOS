//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

/*
 This class will handle the recording functionality of the app. Functionality should allow users to record audio which will automatically be saved and encrypted in the Tella app but not on the users phone
 */

import SwiftUI
import Foundation
import Combine

struct RecordView: View {
    
    @ObservedObject var viewModel = RecordViewModel()
    @EnvironmentObject private var appViewState: AppViewState
    
    func goBack() {
        self.appViewState.navigateBack()
    }
    
    var body: some View {
        HStack {
            VStack {
                VStack(alignment: .leading) {
                    BackButton {
                        self.goBack()
                    }
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
        Button(action: {
            self.viewModel.onStartRecording()
        }) {
            largeImg(.RECORD)
        }
    }
    private func getRecordingView() -> some View {
        Button(action: {
            self.viewModel.onStopRecording()
        }) {
            largeImg(.PAUSE)
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
    
    
    private func getPausedView() -> some View { Text("TODO") }
    
    
}

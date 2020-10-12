//
//  RecordView.swift
//  Tella
//
//  Created by Oliphant, Samuel on 2/17/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

/*
 This class will handle the recording functionality of the app. Functionality should allow users to record audio which will automatically be saved and encrypted in the Tella app but not on the users phone
 */

import SwiftUI
import Foundation
import Combine

struct RecordView: View {
    
    @ObservedObject var viewModel = RecordViewModel()
    
    let back: Button<AnyView>
    
    var body: some View {
        HStack {
            VStack<AnyView> {
                
                switch self.viewModel.state {
                    case .ready: return AnyView ( self.getReadyView() )
                    case .recording: return AnyView ( getRecordingView() )
                    case .paused: return AnyView ( getPausedView() )
                    case .done: return AnyView ( getDoneView() )
                }
            }
        }
    }
    
    private func getReadyView() -> some View {
        Button(action: {
            self.viewModel.onStartRecording()
        }) {
            Image(systemName: "circle.fill")
        }
    }
    private func getRecordingView() -> some View {
        Button(action: {
            self.viewModel.onStopRecording()
        }) {
            Image(systemName: "stop.fill")
        }
    }
    private func getDoneView() -> some View {
        VStack {
            Button(action: self.viewModel.onDiscardRecord) {
                Image(systemName: "trash")
            }
            HStack {
                HStack {
                    Button (action: self.viewModel.onPlayRecord) {
                        largeImg(.PLAY)
                    }
                    Button (action: self.viewModel.onPauseRecord) {
                        largeImg(.PAUSE)
                    }
                }
            }
            Button(action: self.viewModel.onSaveRecording ) {
                Image(systemName: "checkmark")
            }
        }
    }
    
    
    private func getPausedView() -> some View { Text("TODO") }
    
    
}

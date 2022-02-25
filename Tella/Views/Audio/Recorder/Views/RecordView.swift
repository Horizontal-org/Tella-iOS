//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

/*
 This class will handle the recording functionality of the app. Functionality should allow users to record audio which will automatically be saved and encrypted in the Tella app but not on the users phone
 */

import SwiftUI
import Foundation

struct RecordView: View {
    
    @ObservedObject var viewModel = RecordViewModel()
    
    @Binding  var showingRecoredrView : Bool

    @EnvironmentObject private var mainAppModel: MainAppModel
    @EnvironmentObject private var appViewState: AppViewState
    
    @State private var showingSaveAudioConfirmationView : Bool = false
    @State private var showingSaveSuccessView : Bool = false
    
    @State private var showingRenameFileConfirmationSheet : Bool = false
    @State private var fileName : String = ""


    let modalHeight = 173.0
    
    func goBack() {
        self.appViewState.navigateBack()
    }
    
    var body: some View {
        
        ContainerView {
            
            VStack {
                
                getRecorderHeaderView()
                
                Spacer()
                    .frame( height: 70)
                
                getTimeView()
                
                Spacer()
                
                getContentView()
                
                Spacer()
                    .frame(height: 113)
            }
            
            renameFileView
            
            
            DragView(modalHeight: modalHeight,
                     isShown: $showingSaveAudioConfirmationView) {
                saveAudioConfirmationView
            }
            
            saveSuccessView

            
        }.onAppear {
            self.viewModel.mainAppModel = mainAppModel
        }
        .navigationBarHidden(mainAppModel.selectedTab == .home ? false : true)
    }
    
    private func getContentView() -> AnyView {
        
        switch self.viewModel.state {
        case .ready:
            return AnyView ( self.getReadyView())
        case .recording:
            return AnyView ( getRecordingView())
        case .paused:
            return AnyView ( getPausedView())
        }
    }
    
    private func getReadyView() -> some View {
        
        HStack(spacing: 35) {
            
            Rectangle()
                .frame(width: 40, height: 40)
                .hidden()
            
            Button(action: {
                self.viewModel.mainAppModel = mainAppModel
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
    }
    
    private func getRecordingView() -> some View {
        
        HStack(spacing: 35) {
            
            Button(action: {
                self.viewModel.onPauseRecord()
            }) {
                Image("mic.pause")
                    .frame(width: 40, height: 40)
            }
            
            Button(action: {
                self.viewModel.onStopRecording()
            }) {
                Image("mic.stop")
                    .frame(width: 83, height: 83)
            }
            
            Rectangle()
                .frame(width: 40, height: 40)
                .hidden()
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
                self.viewModel.onResumeRecording()
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
    
    private func getTimeView() -> some View {
        VStack {
            
            Button {
                showingRenameFileConfirmationSheet = true
                
            } label: {
                
                HStack {
                    Text(viewModel.fileName)
                        .font(.custom(Styles.Fonts.boldFontName, size: 16))
                        .foregroundColor(Styles.Colors.buttonAdd)
                    
                    Image("mic.edit")
                        .frame(width: 24, height: 24)
                }
            }
            
            Text(viewModel.time)
                .font(.custom(Styles.Fonts.lightFontName, size: 50))
                .foregroundColor(.white)
            
            Text(DiskStatus().getRemainingTime())
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(.white)
        }
    }
    
    private func getRecorderHeaderView() -> some View {
        HStack {
            Button {
                if  viewModel.state == .paused || viewModel.state == .recording  {
                    showingSaveAudioConfirmationView = true
                    
                } else {
                    mainAppModel.selectedTab = .home
                }
            } label: {
                Image("close")
            }.padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 12))
            
            Text(LocalizableAudio.recorderTitle.localized)
                .font(.custom(Styles.Fonts.semiBoldFontName, size: 16))
                .foregroundColor(Color.white)
            Spacer()
        }.frame(height: 56)
    }
    
    private func listenAudiFiles() {
        appViewState.resetToAudio()
    }
    
    private var saveAudioConfirmationView : some View {
        
        return SaveAudioConfirmationView(showingSaveAudioConfirmationView: $showingSaveAudioConfirmationView ) {
           
            self.viewModel.onStopRecording()
           
            DispatchQueue.main.async {
                showingSaveSuccessView = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showingSaveSuccessView = false
            }
            
            mainAppModel.selectedTab = .home
            
        } didCancel: {
            self.viewModel.onResetRecording()
            mainAppModel.selectedTab = .home
        }
    }
    
    private var renameFileView : some View {
        TextFieldBottomSheet(titleText: LocalizableAudio.renameFileTitle.localized,
                             validateButtonText: "SAVE",
                             isPresented: $showingRenameFileConfirmationSheet,
                             fieldContent: $fileName,
                             fileName: viewModel.fileName,
                             fieldType: FieldType.fileName,
                             didConfirmAction: {
            viewModel.fileName =  fileName
        })
    }
    
    @ViewBuilder
    private var saveSuccessView : some View {
        if showingSaveSuccessView {
                VStack {
                    Spacer()

                    Text(LocalizableAudio.recordingSavedMessage.localized)
                        .font(.custom(Styles.Fonts.regularFontName, size: 14))
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(4)
                }

        }
    }
    
}

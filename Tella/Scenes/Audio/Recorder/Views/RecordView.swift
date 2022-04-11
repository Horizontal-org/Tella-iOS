//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

/*
 This class will handle the recording functionality of the app. Functionality should allow users to record audio which will automatically be saved and encrypted in the Tella app but not on the users phone
 */

import SwiftUI
import Foundation

struct RecordView: View {
    
    @StateObject var viewModel : RecordViewModel
  
    var sourceView : SourceView
    var showingRecoredrView : Binding<Bool>
    
    @EnvironmentObject private var mainAppModel: MainAppModel
    @EnvironmentObject private var appViewState: AppViewState
    
    @State private var showingSaveAudioConfirmationView : Bool = false
    @State private var showingSaveSuccessView : Bool = false
    
    @State private var showingRenameFileConfirmationSheet : Bool = false
    @State private var fileName : String = ""
    
    
    let modalHeight = 173.0
    
    init(appModel: MainAppModel, rootFile: VaultFile, sourceView : SourceView, showingRecoredrView: Binding<Bool> ) {
        _viewModel = StateObject(wrappedValue: RecordViewModel(mainAppModel: appModel, rootFile: rootFile))
        self.sourceView = sourceView
        self.showingRecoredrView = showingRecoredrView
    }
    

    func goBack() {
        self.appViewState.navigateBack()
    }
    
    var body: some View {
        
        NavigationContainerView {
            
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
            
            if showingSaveAudioConfirmationView {
                DragView(modalHeight: modalHeight,
                         isShown: $showingSaveAudioConfirmationView) {
                    saveAudioConfirmationView
                }
            }
            
            saveSuccessView
            
        }.onAppear {
//            self.viewModel.mainAppModel = mainAppModel
        }
        .alert(isPresented: self.$viewModel.shouldShowSettingsAlert) {
            getSettingsAlertView()
        }
    }
    
    private func getSettingsAlertView() -> Alert {
        Alert(title: Text(""),
              message: Text(LocalizableAudio.deniedPermissionMessage.localized),
              primaryButton: .default(Text("Cancel"), action: {
            self.viewModel.shouldShowSettingsAlert = false
        }), secondaryButton: .default(Text(LocalizableAudio.deniedPermissionButtonTitle.localized), action: {
            UIApplication.shared.openSettings()
        }))
        
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
                .frame(width: 52, height: 52)
                .hidden()
            
            Button(action: {
//                self.viewModel.mainAppModel = mainAppModel
                self.viewModel.checkCameraAccess()
            }) {
                Image("mic.record")
                    .frame(width: 83, height: 83)
            }
            
 
            Button(action: {
//                self.listenAudiFiles()
            }) {
                Image("mic.listen")
                    .resizable()
                    .frame(width: 52, height: 52)
                    .navigateTo(destination:FileListView(appModel: mainAppModel,
                                                                   rootFile: mainAppModel.vaultManager.root,
                                                                        fileType: [.audio],
                                                                        title: "Audio"))

            }
            
            .navigateTo(destination:FileListView(appModel: mainAppModel,
                                                           rootFile: mainAppModel.vaultManager.root,
                                                                fileType: [.audio],
                                                                title: "Audio")
            )
                
//            }
        }
    }
    
    private func getRecordingView() -> some View {
        
        HStack(spacing: 35) {
            
            Button(action: {
                self.viewModel.onPauseRecord()
            }) {
                Image("mic.pause")
                    .resizable()
                    .frame(width: 52, height: 52)
            }
            
            Button(action: {
                self.viewModel.onStopRecording()
            }) {
                Image("mic.stop")
                    .frame(width: 83, height: 83)
            }
            
            Rectangle()
            
                .frame(width: 52, height: 52)
                .hidden()
        }
    }
    
    private func getPausedView() -> some View {
        
        HStack(spacing: 34) {
            
            Button(action: {
                self.viewModel.onPlayRecord()
            }) {
                Image("mic.play")
                    .resizable()
                    .frame(width: 52, height: 52)
            }
            
            Button(action: {
                self.viewModel.onResumeRecording()
            }) {
                Image("mic.record")
                    .frame(width: 83, height: 83)
            }
            
//            Button(action: {
//                self.listenAudiFiles()
//            }) {
//                Image("mic.listen")
//                    .resizable()
//                    .frame(width: 52, height: 52)
//            }
            
            
            Button(action: {
//                self.listenAudiFiles()
            }) {
                Image("mic.listen")
                    .resizable()
                    .frame(width: 52, height: 52)
                    .navigateTo(destination:getFileListView()) // For iOS 15
            }
            .navigateTo(destination:getFileListView()) // For iOS 14
        }
    }
    
    private func getTimeView() -> some View {
        VStack {
            
            Button {
                showingRenameFileConfirmationSheet = true
                
            } label: {
                
                HStack {
                    Text(viewModel.fileName)
                        .font(.custom(Styles.Fonts.boldFontName, size: 16))
                        .foregroundColor(Styles.Colors.yellow)
                    
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
                    if sourceView == .tab {
                        mainAppModel.selectedTab = .home
                    } else {
                        showingRecoredrView.wrappedValue = false
                    }
                }
            } label: {
                Image("close")
            }.padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 12))
            
            Text(LocalizableAudio.recorderTitle.localized)
                .font(.custom(Styles.Fonts.semiBoldFontName, size: 18))
                .foregroundColor(Color.white)
            Spacer()
        }.frame(height: 56)
    }
    
    private func listenAudiFiles() {
        appViewState.resetToAudio()
    }
    
    private func getFileListView() -> some View {
        FileListView(appModel: mainAppModel,
                     rootFile: mainAppModel.vaultManager.root,
                     fileType: [.audio],
                     title: "Audio")
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
    @ViewBuilder
    private var renameFileView : some View {
        if showingRenameFileConfirmationSheet {
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

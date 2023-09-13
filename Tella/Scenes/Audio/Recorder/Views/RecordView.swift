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
    
    @EnvironmentObject private var mainAppModel: MainAppModel
    @EnvironmentObject private var appViewState: AppViewState
    @EnvironmentObject var sheetManager: SheetManager
    
    @State private var showingSaveSuccessView : Bool = false
    @State private var fileName : String = ""
    
    let modalHeight = 173.0
    
    init(appModel: MainAppModel,
         rootFile: VaultFile?,
         sourceView : SourceView,
         showingRecoredrView: Binding<Bool>,
         resultFile : Binding<[VaultFile]?>? = nil) {
        
        _viewModel = StateObject(wrappedValue: RecordViewModel(mainAppModel: appModel,
                                                               rootFile: rootFile,
                                                               resultFile: resultFile,
                                                               sourceView: sourceView,
                                                               showingRecoredrView: showingRecoredrView))
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
            
            saveSuccessView
            
        }
        .onReceive(mainAppModel.$shouldSaveCurrentData) { value in
            if(value) {
                self.viewModel.onStopRecording()
            }
        }
        
        .alert(isPresented: self.$viewModel.shouldShowSettingsAlert) {
            getSettingsAlertView()
        }
        .onDisappear {
            mainAppModel.vaultManager.clearTmpDirectory()
        }
    }
    
    private func getSettingsAlertView() -> Alert {
        Alert(title: Text(""),
              message: Text(LocalizableRecorder.deniedAudioPermissionExpl.localized),
              primaryButton: .default(Text(LocalizableRecorder.deniedAudioPermissionActionCancel.localized), action: {
            self.viewModel.shouldShowSettingsAlert = false
        }), secondaryButton: .default(Text(LocalizableRecorder.deniedAudioPermissionActionSettings.localized), action: {
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
                self.viewModel.checkCameraAccess()
            }) {
                Image("mic.record")
                    .frame(width: 83, height: 83)
            }
            
            Button(action: {
                navigateTo(destination: getFileListView())
            }) {
                Image("mic.listen")
                    .resizable()
                    .frame(width: 52, height: 52)
            }
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
                
                // if self.viewModel.sourceView == .addSingleFile{
                // viewModel.showingRecoredrView.wrappedValue = false
                // }
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
            
            Button(action: {
                navigateTo(destination: getFileListView())
            }) {
                Image("mic.listen")
                    .resizable()
                    .frame(width: 52, height: 52)
            }
        }
    }
    
    private func getTimeView() -> some View {
        VStack {
            
            Button {
                showRenameFileSheet()
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
                    showSaveAudioConfirmationView()
                } else {
                    if viewModel.sourceView == .tab {
                        mainAppModel.selectedTab = .home
                    } else {
                        viewModel.showingRecoredrView.wrappedValue = false
                    }
                }
            } label: {
                Image("close")
            }.padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 12))
            
            Text(LocalizableRecorder.appBar.localized)
                .font(.custom(Styles.Fonts.semiBoldFontName, size: 18))
                .foregroundColor(Color.white)
            Spacer()
        }.frame(height: 56)
    }
    
    private func getFileListView() -> some View {
        FileListView(appModel: mainAppModel,
                     rootFile: mainAppModel.vaultManager.root,
                     fileType: [.audio],
                     title: LocalizableRecorder.audioRecordingsAppBar.localized,
                     fileListType: .recordList)
    }
    
    func showRenameFileSheet() {
        sheetManager.showBottomSheet( modalHeight: 165, content: {
            
            TextFieldBottomSheetView(titleText: LocalizableRecorder.renameRecordingSheetTitle.localized,
                                     validateButtonText: LocalizableRecorder.renameRecordingSaveSheetAction.localized,
                                     cancelButtonText: LocalizableRecorder.renameRecordingCancelSheetAction.localized,
                                     fieldContent: $fileName,
                                     fileName: viewModel.fileName,
                                     didConfirmAction: {
                viewModel.fileName =  fileName
            })
        })
    }
    
    func showSaveAudioConfirmationView() {
        
        sheetManager.showBottomSheet( modalHeight: 180.0,
                                      shouldHideOnTap: false,
                                      content: {
            SaveAudioConfirmationView(viewModel: viewModel, showingSaveSuccessView: $showingSaveSuccessView)
        })
    }
    
    @ViewBuilder
    private var saveSuccessView : some View {
        if showingSaveSuccessView {
            VStack {
                Spacer()
                
                Text(LocalizableRecorder.audioRecordingSavedToast.localized)
                    .font(.custom(Styles.Fonts.regularFontName, size: 14))
                    .foregroundColor(.black)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(4)
            }
            
        }
    }
    
}

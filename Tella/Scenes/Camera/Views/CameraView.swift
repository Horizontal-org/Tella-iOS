//
//  Copyrighét © 2022 HORIZONTAL. All rights reserved.
//

import SwiftUI
import Combine
import AVFoundation


struct CameraView: View {
    
    // MARK: - Public properties
    //    var sourceView : SourceView
    var showingCameraView : Binding<Bool>
    
    // MARK: - Private properties
    
    private var subscriptions = Set<AnyCancellable>()
    
    @State private var showingPermissionAlert : Bool = false
    @StateObject private var cameraViewModel :  CameraViewModel
    @StateObject private var model = CameraModel()
    @EnvironmentObject private var mainAppModel : MainAppModel
    @EnvironmentObject private var sheetManager: SheetManager
    
    
    init(sourceView: SourceView,
         showingCameraView: Binding<Bool>,
         resultFile: Binding<[VaultFileDB]?>? = nil,
         mainAppModel: MainAppModel,
         rootFile:VaultFileDB? = nil,
         shouldReloadVaultFiles: Binding<Bool>? = nil) {
        
        self.showingCameraView = showingCameraView
        
        _cameraViewModel = StateObject(wrappedValue: CameraViewModel(mainAppModel: mainAppModel,
                                                                     rootFile: rootFile,
                                                                     resultFile: resultFile,
                                                                     sourceView: sourceView,
                                                                     shouldReloadVaultFiles: shouldReloadVaultFiles))
        
    }
    
    var body: some View {
        
        NavigationContainerView(backgroundColor: Color.black) {
            
            CameraPreview(session: model.session)
                .edgesIgnoringSafeArea(.all)
            
            getCameraControlsView()
            
        }.background(Color.black)
            .accentColor(.white)
            .environmentObject(cameraViewModel)
            .onAppear {
                model.shouldPreserveMetadata = mainAppModel.settings.preserveMetadata
                model.configure()
            }
            .onDisappear {
                model.stopRunningCaptureSession()
            }
        
            .onReceive(model.$isRecording) { value in
                cameraViewModel.isRecording = value
            }
        
            .onReceive(model.$shouldShowPermission) { value in
                showingPermissionAlert = value
            }
        
            .onReceive(model.service.$shouldShowProgressView) { value in
                if value, cameraViewModel.shouldShowProgressView {
                    showProgressView()
                }
            }
        
            .onReceive(model.$shouldCloseCamera) { value in
                if value {
                    if cameraViewModel.sourceView == .tab {
                        mainAppModel.selectedTab = .home
                    } else {
                        showingCameraView.wrappedValue = false
                    }
                    mainAppModel.vaultManager.clearTmpDirectory()
                }
            }
        
            .onReceive(model.service.$imageCompletion) { imageCompletion in
                guard let imageCompletion else { return }
                cameraViewModel.capturePhoto = imageCompletion.capturePhoto
                cameraViewModel.saveImage()
            }
        
            .onReceive(model.$videoURLCompletion) { videoURL in
                guard let videoURL = videoURL else { return }
                cameraViewModel.videoURL = videoURL
                cameraViewModel.saveVideo()
            }
            .onReceive(cameraViewModel.$shouldShowToast) { shouldShowToast in
                if shouldShowToast {
                    Toast.displayToast(message: cameraViewModel.errorMessage)
                }
            }

            .alert(isPresented:$showingPermissionAlert) {
                getSettingsAlertView()
            }
            .edgesIgnoringSafeArea(.all)
    }
    
    private func getCameraControlsView() -> some View {
        
        CameraControlsView(showingCameraView: showingCameraView,
                           sourceView: cameraViewModel.sourceView,
                           captureButtonAction: {
            model.capturePhoto()
        }, recordVideoAction: {
            model.startCaptureVideo()
        }, toggleCamera: {
            model.toggleCameraType()
        }, updateCameraTypeAction: { cameraType in
            model.cameraType = cameraType
        }, toggleFlash: {
            model.toggleFlash()
        }, close: {
            model.stopRunningCaptureSession()
        })
        .edgesIgnoringSafeArea(.all)
        .environmentObject(cameraViewModel)
        
    }
    
    private func getSettingsAlertView() -> Alert {
        Alert(title: Text(""),
              message: Text(LocalizableCamera.deniedCameraPermissionExpl.localized),
              primaryButton: .default(Text(LocalizableCamera.deniedCameraPermissionActionCancel.localized), action: {
            mainAppModel.selectedTab = .home
        }), secondaryButton: .default(Text(LocalizableCamera.deniedCameraPermissionActionSettings.localized), action: {
            UIApplication.shared.openSettings()
            mainAppModel.selectedTab = .home
        }))
    }
    
    func showProgressView() {
        sheetManager.showBottomSheet(modalHeight: 190,
                                     shouldHideOnTap: false,
                                     content: {
            ImportFilesProgressView(progress: cameraViewModel.progressFile,
                                    importFilesProgressProtocol: ImportFilesFromCameraProgress())
        })
    }
}


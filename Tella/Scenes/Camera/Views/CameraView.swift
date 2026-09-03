//
//  Copyright © 2022 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
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
    @State private var gridIsOn: Bool = false
    @StateObject private var cameraViewModel :  CameraViewModel
    @StateObject private var model = CameraModel()
    @EnvironmentObject private var sheetManager: SheetManager
    
    
    init(sourceView: SourceView,
         showingCameraView: Binding<Bool>,
         resultFile: Binding<[VaultFileDB]?>? = nil,
         mainAppModel: MainAppModel,
         rootFile:VaultFileDB? = nil) {
        
        self.showingCameraView = showingCameraView
        
        _cameraViewModel = StateObject(wrappedValue: CameraViewModel(mainAppModel: mainAppModel,
                                                                     rootFile: rootFile,
                                                                     resultFile: resultFile,
                                                                     sourceView: sourceView))
        
    }
    
    var body: some View {
        
        NavigationContainerView(backgroundColor: Color.black) {
            
            CameraPreview(session: model.session,
                          gridIsOn: gridIsOn,
                          onZoomBegan: {
                model.startZoom()
            }, onZoomChanged: { pinchScale in
                model.zoom(by: pinchScale)
            })
            .edgesIgnoringSafeArea(.all)
            
            getCameraControlsView()
            
        }.background(Color.black)
            .accentColor(.white)
            .navigationBarHidden(true)
            .onAppear {
                UIApplication.shared.topNavigationController()?.setNavigationBarHidden(true, animated: false)
                model.shouldPreserveMetadata = cameraViewModel.mainAppModel.settings.preserveMetadata
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
                        cameraViewModel.mainAppModel.selectedTab = .home
                    } else {
                        showingCameraView.wrappedValue = false
                    }
                    cameraViewModel.mainAppModel.vaultManager.clearTmpDirectory()
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
        
        CameraControlsView(cameraViewModel: cameraViewModel,
                           showingCameraView: showingCameraView,
                           sourceView: cameraViewModel.sourceView,
                           gridIsOn: $gridIsOn,
                           captureButtonAction: {
            model.capturePhoto()
        }, recordVideoAction: {
            model.startCaptureVideo()
        }, toggleCamera: {
            model.toggleCameraType()
        }, updateCameraTypeAction: { cameraType in
            model.cameraType = cameraType
        }, updateFlashMode: { mode in
            model.setFlashMode(mode)
        }, close: {
            model.stopRunningCaptureSession()
        }, zoomFactor: model.currentZoomFactor,
                           flashMode: model.flashMode,
                           isFlashAvailable: model.isFlashAvailable)
        .edgesIgnoringSafeArea(.all)
    }
    
    private func getSettingsAlertView() -> Alert {
        Alert(title: Text(""),
              message: Text(LocalizableCamera.deniedCameraPermissionExpl1.localized.addTwolines
                            + LocalizableCamera.deniedCameraPermissionExpl2.localized.addline
                            + LocalizableCamera.deniedCameraPermissionExpl3.localized.numbered(1).addline
                            + LocalizableCamera.deniedCameraPermissionExpl4.localized.numbered(2).addline
                            + LocalizableCamera.deniedCameraPermissionExpl5.localized.numbered(3)),
              primaryButton: .default(Text(LocalizableCamera.deniedCameraPermissionActionCancel.localized), action: {
            cameraViewModel.mainAppModel.selectedTab = .home
        }), secondaryButton: .default(Text(LocalizableCamera.deniedCameraPermissionActionSettings.localized), action: {
            UIApplication.shared.openSettings()
            cameraViewModel.mainAppModel.selectedTab = .home
        }))
    }
    
    func showProgressView() {
        cameraViewModel.progressFile = ProgressFile()
        
        let content = ImportFilesProgressView(mainAppModel: cameraViewModel.mainAppModel,
                                              progress: cameraViewModel.progressFile,
                                              importFilesProgressProtocol: ImportFilesFromCameraProgress(),
                                              onImportFinished: { self.dismiss() })
        
        showBottomSheetView(content: content,
                            tapToDismiss: false)
        
    }
}

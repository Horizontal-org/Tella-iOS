//
//  Copyright © 2022 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI


struct CameraView: View {
    
    // MARK: - Public properties
    @Binding var showingCameraView: Bool
    
    // MARK: - Private properties
    
    @State private var showingPermissionAlert : Bool = false
    @State private var gridIsOn: Bool = false
    @State private var cameraState: CameraState = .readyTakingImage
    @StateObject private var cameraViewModel :  CameraViewModel
    @StateObject private var model = CameraModel()
    @EnvironmentObject private var sheetManager: SheetManager
    
    
    init(sourceView: SourceView,
         showingCameraView: Binding<Bool>,
         resultFile: Binding<[VaultFileDB]?>? = nil,
         mainAppModel: MainAppModel,
         rootFile:VaultFileDB? = nil) {
        
        _showingCameraView = showingCameraView
        
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
            }, onSwipe: { direction in
                selectCameraType(swipedTo: direction)
            })
            .ignoresSafeArea()
            
            cameraControls
            
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
                    cameraViewModel.dismissCamera(showingCameraView: $showingCameraView)
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
    }
    
    private var cameraControls: some View {
        CameraControlsView(cameraViewModel: cameraViewModel,
                           model: model,
                           showingCameraView: $showingCameraView,
                           gridIsOn: $gridIsOn,
                           cameraState: $cameraState)
    }
    
    private func selectCameraType(swipedTo direction: CameraSwipeDirection) {
        selectCameraType(direction == .left ? .image : .video)
    }
    
    private func selectCameraType(_ cameraType: CameraType) {
        guard !cameraState.isRecording,
              cameraState.cameraType != cameraType else { return }
        
        withAnimation(.easeInOut(duration: CameraStyle.Animations.modeChange)) {
            cameraState = CameraState(cameraType: cameraType)
        }
        
        model.cameraType = cameraType
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

//
//  Copyrighét © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI
import Combine


struct CameraView: View {
    
    // MARK: - Public properties
    var sourceView : SourceView
    var subscriptions = Set<AnyCancellable>()
    
    @State var showingPermissionAlert : Bool = false
    @Binding var showingCameraView : Bool
    @ObservedObject var cameraViewModel :  CameraViewModel
    @StateObject var model = CameraModel()
    
    @EnvironmentObject var mainAppModel : MainAppModel
    @EnvironmentObject var sheetManager: SheetManager
    
    
    var body: some View {
        
        NavigationContainerView(backgroundColor: Color.black) {
            
            CameraPreview(session: model.session)
                .edgesIgnoringSafeArea(.all)
            
            getCameraControlsView()
            
        }.background(Color.black)
            .accentColor(.white)
            .environmentObject(cameraViewModel)
            .onAppear {
                model.configure()
            }
            .onDisappear {
                model.stopRunningCaptureSession()
            }
            .navigationBarHidden(mainAppModel.selectedTab == .home ? false : true)
        
            .onReceive(model.$isRecording) { value in
                cameraViewModel.isRecording = value
            }
        
            .onReceive(model.$shouldShowPermission) { value in
                showingPermissionAlert = value
            }
        
            .onReceive(model.$shouldCloseCamera) { value in
                if value {
                    if sourceView == .tab {
                        mainAppModel.selectedTab = .home
                    } else {
                        showingCameraView = false
                    }
                    mainAppModel.clearTmpDirectory()
                }
            }
        
            .onReceive(model.$imageCompletion) { value in
                guard let value = value else { return }
                
                cameraViewModel.image = value.0
                cameraViewModel.imageData = value.1
                showProgressView()
                cameraViewModel.saveImage()
            }
        
            .onReceive(model.$videoURLCompletion) { videoURL in
                guard let videoURL = videoURL else { return }
                
                cameraViewModel.videoURL = videoURL
                showProgressView()
                cameraViewModel.saveVideo()
            }
        
            .alert(isPresented:$showingPermissionAlert) {
                getSettingsAlertView()
            }
            .edgesIgnoringSafeArea(.all)
    }
    
    private func getCameraControlsView() -> some View {
        
        CameraControlsView(showingCameraView: $showingCameraView,
                           sourceView: sourceView,
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
        sheetManager.showBottomSheet( modalHeight: 190,
                                      shouldHideOnTap: false,
                                      content: {
            ImportFilesProgressView(importFilesProgressProtocol: ImportFilesFromCameraProgress())
            
        })
    }
}


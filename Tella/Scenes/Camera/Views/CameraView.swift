//
//  Copyrighét © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI
import Combine


struct CameraView: View {
    
    // MARK: - Public properties
    var sourceView : SourceView

    @State var showingProgressView : Bool = false
    @State var showingPermissionAlert : Bool = false
    
    @Binding var showingCameraView : Bool

    @ObservedObject var cameraViewModel :  CameraViewModel
    
     var customCameraRepresentable = CustomCameraRepresentable(
        cameraFrame: .zero,
        imageCompletion: {_,_   in }, videoURLCompletion: { _  in }
    )
    
    // MARK: - Private properties
    
    @State private var image: UIImage?
    
    @EnvironmentObject private var mainAppModel : MainAppModel
    
    
    var body: some View {
        
        NavigationContainerView {

            let frame = CGRect(x: 0, y: 0, width: UIScreen.screenWidth, height: UIScreen.screenHeight)
            
            cameraView(frame: frame)
                .edgesIgnoringSafeArea(.all)
            
            getCameraControlsView()

            ImportFilesProgressView(showingProgressView: $showingProgressView,
                                    importFilesProgressProtocol: ImportFilesFromCameraProgress())
            
        }.background(Color.black)
            .accentColor(.white)
            .environmentObject(cameraViewModel)
            .onAppear {
                DispatchQueue.main.async {
                    customCameraRepresentable.checkCameraPermission()
                }
            }
            .onDisappear {
                customCameraRepresentable.stopRunningCaptureSession()
            }
            .navigationBarHidden(mainAppModel.selectedTab == .home ? false : true)
        
            .onReceive(customCameraRepresentable.$isRecording) { value in
                cameraViewModel.isRecording = value ?? false
                
                
            }
            .onReceive(customCameraRepresentable.$shouldShowPermission) { value in
                showingPermissionAlert = value
            }
            .onReceive(customCameraRepresentable.$shouldCloseCamera) { value in
                if value {
                    if sourceView == .tab {
                        mainAppModel.selectedTab = .home
                    } else {
                        showingCameraView = false
                    }
                    mainAppModel.clearTmpDirectory()
                }
            }
            .alert(isPresented:$showingPermissionAlert) {
                getSettingsAlertView()
            }
            .edgesIgnoringSafeArea(.all)

    }
    
    private func cameraView(frame: CGRect) -> CustomCameraRepresentable {
        
        customCameraRepresentable.cameraFrame = frame
        
        customCameraRepresentable.imageCompletion = {image , data in

            cameraViewModel.imageData = data

            showingProgressView = true
            cameraViewModel.saveImage()
        }
        
        customCameraRepresentable.videoURLCompletion = {videoURL in
            cameraViewModel.videoURL = videoURL
            showingProgressView = true
            
            cameraViewModel.saveVideo()
        }
        return customCameraRepresentable
    }
    
    
    private func getCameraControlsView() -> some View {
        
        CameraControlsView(showingCameraView: $showingCameraView,
                           sourceView: sourceView,
                           captureButtonAction: {
            customCameraRepresentable.takePhoto()
        }, recordVideoAction: {
            customCameraRepresentable.startCaptureVideo()
        }, toggleCamera: {
            customCameraRepresentable.toggleCameraType()
        }, updateCameraTypeAction: { cameraType in
            customCameraRepresentable.cameraType = cameraType
        }, toggleFlash: {
            customCameraRepresentable.toggleFlash()
        }, close: {
            customCameraRepresentable.stopRunningCaptureSession()
        })
            .edgesIgnoringSafeArea(.all)
        
    }
    
    private func getSettingsAlertView() -> Alert {
        Alert(title: Text(""),
              message: Text(Localizable.Camera.deniedPermissionMessage),
              primaryButton: .default(Text(Localizable.Common.cancel), action: {
            mainAppModel.selectedTab = .home
        }), secondaryButton: .default(Text(Localizable.Camera.deniedPermissionButtonTitle), action: {
            UIApplication.shared.openSettings()
            mainAppModel.selectedTab = .home
        }))
    }
    
}


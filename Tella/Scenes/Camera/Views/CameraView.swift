//
//  Copyrighét © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI
import Combine


struct CameraView: View {
    
    // MARK: - Public properties
    var sourceView : SourceView
    
    @State var showingPermissionAlert : Bool = false
    
    @Binding var showingCameraView : Bool
    
    @ObservedObject var cameraViewModel :  CameraViewModel
    
    @EnvironmentObject var sheetManager: SheetManager
    
    var customCameraRepresentable = CustomCameraRepresentable(
        cameraFrame: .zero,
        imageCompletion: {_,_   in }, videoURLCompletion: { _  in }
    )
    
    // MARK: - Private properties
    
    @State private var image: UIImage?
    
    @EnvironmentObject private var mainAppModel : MainAppModel
    
    
    var body: some View {
        
        NavigationContainerView(backgroundColor: Color.black) {
            
            let frame = CGRect(x: 0, y: 0, width: UIScreen.screenWidth, height: UIScreen.screenHeight)
            
            cameraView(frame: frame)
                .edgesIgnoringSafeArea(.all)
            
            getCameraControlsView()
            
        }.background(Color.black)
            .accentColor(.white)
            .environmentObject(cameraViewModel)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                    customCameraRepresentable.checkCameraPermission()
                })
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
            showProgressView()
            cameraViewModel.saveImage()
        }
        
        customCameraRepresentable.videoURLCompletion = {videoURL in
            cameraViewModel.videoURL = videoURL
            showProgressView()
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
              message: Text(Localizable.Camera.deniedCameraPermissionExpl),
              primaryButton: .default(Text(Localizable.Camera.deniedCameraPermissionActionCancel), action: {
            mainAppModel.selectedTab = .home
        }), secondaryButton: .default(Text(Localizable.Camera.deniedCameraPermissionActionSettings), action: {
            UIApplication.shared.openSettings()
            mainAppModel.selectedTab = .home
        }))
    }
    
    func showProgressView() {
        sheetManager.showBottomSheet( modalHeight: 165,
                                      shouldHideOnTap: false,
                                      content: {
            ImportFilesProgressView(importFilesProgressProtocol: ImportFilesFromCameraProgress())
            
        }) 
    }
}


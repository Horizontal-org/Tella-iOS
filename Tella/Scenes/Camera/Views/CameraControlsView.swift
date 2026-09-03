//
//  Copyright © 2022 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//



import SwiftUI

struct CameraControlsView: View {
    // MARK: - Public properties
    @ObservedObject var cameraViewModel: CameraViewModel
    @Binding var showingCameraView : Bool
    var sourceView : SourceView
    @Binding var gridIsOn: Bool
    
    var captureButtonAction: (() -> Void)
    var recordVideoAction: (() -> Void)
    var toggleCamera: (() -> Void)
    var updateCameraTypeAction: ((CameraType) -> Void)
    var toggleFlash: (() -> Void)
    var close: (() -> Void)
    
    // MARK: - Private properties
    
    @State private var selectedOption: CameraType = .image
    @State private var state : CameraState = .readyTakingImage
    @State private var flashIsOn: Bool = false
    @State private var shouldHideCloseButton: Bool = false
    
    
    @State private var  deviceOrientation : UIDeviceOrientation = UIDevice.current.orientation
    @State private var shouldAnimate: Bool = false
    
    var body: some View {
        
        VStack {
            
            cameraHeaderView()
            
            Spacer()
            
            switch state {
                
            case .readyTakingImage:
                capturePhotoControllers
                
            case .readyRecordingVideo:
                recordVideoControllers
                
            case .recordingVideo:
                recordingVideoControllers
            }
        }
        .onDisappear {
            flashIsOn = false
        }
        .onReceive(cameraViewModel.mainAppModel.$shouldSaveCurrentData) { value in
            if(value && state == .recordingVideo) {
                stopRecordingVideo()
            }
        }
    }
    
    private func cameraHeaderView() -> some View {
        HStack() {
            closeButton
            Spacer()
            gridButton
            flashButton
        }
        .padding(.top, .smallMedium)
        .frame(height: 90)
        .background(Color.black.opacity(0.8))
        .edgesIgnoringSafeArea(.all)
    }
    
    @ViewBuilder
    var closeButton: some View {
        if !shouldHideCloseButton {
            Button {
                
                if sourceView == .tab {
                    cameraViewModel.mainAppModel.selectedTab = .home
                } else {
                    showingCameraView = false
                }
                
                close()
                
            } label: {
                Image(.close)
                    .padding(.normal)
            }
            .rotate(deviceOrientation: self.deviceOrientation,
                    shouldAnimate: self.shouldAnimate)
        }
    }
    
    var flashButton: some View {
        Button {
            toggleFlash()
            flashIsOn.toggle()
        } label: {
            flashIsOn ? Image(.cameraFlashOn) .padding(.normal) : Image(.cameraFlashOff) .padding(.normal)
        }
        .rotate(deviceOrientation: self.deviceOrientation,
                shouldAnimate: self.shouldAnimate)
        
    }
    
    var gridButton: some View {
        Button {
            gridIsOn.toggle()
        } label: {
            Image(gridIsOn ? .cameraGridOn : .cameraGridOff)
                .padding(.normal)
        }
        
        .rotate(deviceOrientation: self.deviceOrientation,
                shouldAnimate: self.shouldAnimate)
        .accessibilityLabel(gridIsOn
                            ? LocalizableCamera.hideGrid.localized
                            : LocalizableCamera.showGrid.localized)
    }
    
    var capturePhotoControllers : some View {
        VStack {
            
            VStack {
                
                HStack(spacing: 50) {
                    
                    Spacer()
                    
                    flipCamera
                    
                    Button {
                        captureButtonAction()
                    } label: {
                        Image(.cameraCapture)
                    }.frame(width: 57, height: 57)
                    
                    previewImageAndVideodFile
                    
                    Spacer()
                }
                
                .padding(EdgeInsets(top: 13, leading: 0, bottom: 7, trailing: 0))
                
                bottomMenu
            }
            .background(Color.black.opacity(0.8))
        }
        
        .onAppear(perform: {
            DeviceOrientationHelper().startDeviceOrientationNotifier { deviceOrientation in
                self.deviceOrientation = deviceOrientation
                shouldAnimate = true
            }
        })
        
    }
    
    
    var recordVideoControllers : some View {
        
        VStack {
            
            VStack {
                
                HStack(spacing: 50) {
                    
                    Spacer()
                    
                    flipCamera
                    
                    Button {
                        shouldHideCloseButton = true
                        state = .recordingVideo
                        recordVideoAction()
                        cameraViewModel.initialiseTimerRunning()
                    } label: {
                        Image(.cameraStartRecordVideo)
                    }.frame(width: 57, height: 57)
                    
                    
                    previewImageAndVideodFile
                    
                    Spacer()
                }
                
                .padding(EdgeInsets(top: 13, leading: 0, bottom: 7, trailing: 0))
                
                bottomMenu
            }
            .background(Color.black.opacity(0.8))
        }
    }
    
    var recordingVideoControllers : some View {
        
        VStack {
            
            CustomText(cameraViewModel.formattedCurrentTime, style: .body1Style)
            
            VStack {
                
                HStack(spacing: 50) {
                    
                    Spacer()
                    
                    Button {
                        stopRecordingVideo()
                    } label: {
                        Image( .cameraStopRecordVideo)
                            .frame(width: 57, height: 57)
                    }.frame(width: 57, height: 57)
                    
                    Spacer()
                }
                .padding(EdgeInsets(top: 13, leading: 0, bottom: 7, trailing: 0))
                
                Spacer()
            }
            .frame(height: 120)
        }
    }
    
    @ViewBuilder
    var previewImageAndVideodFile : some View {
        VStack {
            if let file = $cameraViewModel.lastImageOrVideoVaultFile.wrappedValue,
               let data = file.thumbnail {
                
                Button {
                    navigateTo(destination: getFileListView())
                } label: {
                    UIImage.image(fromData:data)
                        .rounded()
                }
            } else {
                Spacer()
                    .frame(width: 40, height: 40)
            }
        }.rotate(deviceOrientation: self.deviceOrientation,
                 shouldAnimate: self.shouldAnimate)
    }
    
    var flipCamera: some View {
        Button {
            toggleCamera()
        } label: {
            Image(.cameraFlipCamera)
        }.frame(width: 40, height: 40)
            .rotate(deviceOrientation: self.deviceOrientation,
                    shouldAnimate: self.shouldAnimate)
    }
    
    func getFileListView() -> FileListView {
        FileListView(mainAppModel: cameraViewModel.mainAppModel,
                     filterType: .photoVideo,
                     title: LocalizableCamera.appBar.localized,
                     fileListType: .cameraGallery)
    }
    
    var bottomMenu : some View {
        
        HStack(spacing: 15) {
            Button(action: {
                
                if self.selectedOption != .image {
                    withAnimation(.interactiveSpring()){
                        self.selectedOption = .image
                    }
                    
                    updateCameraTypeAction(.image)
                    state = .readyTakingImage
                }
            }, label: {
                CameraTypeItemView(title: LocalizableCamera.tabTitlePhoto.localized, width: 140, page: .image, selectedOption: $selectedOption)
            })
            
            Button(action: {
                if self.selectedOption != .video {
                    withAnimation(.interactiveSpring()) {
                        self.selectedOption = .video
                    }
                    
                    updateCameraTypeAction(.video)
                    state = .readyRecordingVideo
                    
                }
            }, label: {
                CameraTypeItemView(title: LocalizableCamera.tabTitleVideo.localized,
                                   width: 140,
                                   page: .video,
                                   selectedOption: $selectedOption)
            })
        }
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
        
    }
    
    private func stopRecordingVideo() {
        shouldHideCloseButton = false
        state = .readyRecordingVideo
        recordVideoAction()
        cameraViewModel.invalidateTimerRunning()
    }
}

struct CameraControlsView_Previews: PreviewProvider {
    static var previews: some View {
        CameraControlsView(cameraViewModel: CameraViewModel.stub(),
                           showingCameraView:.constant(false),
                           sourceView: .tab,
                           gridIsOn: .constant(false)) {
            
        } recordVideoAction: {
            
        } toggleCamera: {
            
        } updateCameraTypeAction: { value in
            
        } toggleFlash: {
        } close: {}
    }
}

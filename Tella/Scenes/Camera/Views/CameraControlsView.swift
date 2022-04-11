//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//


import SwiftUI

struct CameraControlsView: View {
    // MARK: - Public properties
    
    @Binding var showingCameraView : Bool
    var sourceView : SourceView
    
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

    @EnvironmentObject var cameraViewModel: CameraViewModel
    @EnvironmentObject var mainAppModel: MainAppModel
    @EnvironmentObject var appViewState: AppViewState
    
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
    }
    
    private func cameraHeaderView() -> some View {
        VStack {
            
            HStack() {
                
                // Close button
                if !shouldHideCloseButton {
                    Button {
                        mainAppModel.vaultManager.clearTmpDirectory()
                        
                        if sourceView == .tab {
                            mainAppModel.selectedTab = .home
                        } else {
                            showingCameraView = false
                        }
                        
                        close()

                    } label: {
                        Image("close")
                    }
                    .frame(width: 30, height: 30)
                    .padding(EdgeInsets(top: 15, leading: 16, bottom: 0, trailing: 12))
                }
                Spacer()
                
                // Flash button
                Button {
                    toggleFlash()
                    flashIsOn.toggle()
                } label: {
                    flashIsOn ? Image("camera.flash-on") : Image("camera.flash-off")
                }
                .frame(width: 30, height: 30)
                .padding(EdgeInsets(top: 15, leading: 16, bottom: 0, trailing: 12))
            }
            .frame(height: 90)
            .background(Color.black.opacity(0.8))
            .edgesIgnoringSafeArea(.all)
            
            Spacer()
        }
        
    }
    
    var capturePhotoControllers : some View {
        VStack {
            
            VStack {
                
                HStack(spacing: 50) {
                    
                    Spacer()
                    
                    Button {
                        toggleCamera()
                    } label: {
                        Image("camera.flip-camera")
                    }.frame(width: 40, height: 40)
                    
                    Button {
                        captureButtonAction()
                    } label: {
                        Image("camera.capture")
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
    
    
    var recordVideoControllers : some View {
        
        VStack {
            
            Text(cameraViewModel.formattedCurrentTime)
                .font(.custom(Styles.Fonts.regularFontName, size: 14) )
                .foregroundColor(.white)
            
            VStack {
                
                HStack(spacing: 50) {
                    
                    Spacer()
                    
                    Button {
                        toggleCamera()
                    } label: {
                        Image("camera.flip-camera")
                    }.frame(width: 40, height: 40)
                    
                    Button {
                        shouldHideCloseButton = true
                        state = .recordingVideo
                        recordVideoAction()
                        cameraViewModel.initialiseTimerRunning()
                    } label: {
                        Image("camera.start-record-video")
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
            
            Text(cameraViewModel.formattedCurrentTime)
                .font(.custom(Styles.Fonts.regularFontName, size: 14) )
                .foregroundColor(.white)
            
            
            VStack {
                
                HStack(spacing: 50) {
                    
                    Spacer()
                    
                    Button {
                        shouldHideCloseButton = false
                        state = .readyRecordingVideo
                        recordVideoAction()
                        cameraViewModel.invalidateTimerRunning()
                    } label: {
                        Image( "camera.stop-record-video")
                            .frame(width: 57, height: 57)
                    }.frame(width: 57, height: 57)
                    
                    Spacer()
                }
                .padding(EdgeInsets(top: 13, leading: 0, bottom: 7, trailing: 0))
                
                Spacer()
            }
            .frame(height: 130)
        }
    }
    
    @ViewBuilder
    var previewImageAndVideodFile : some View {
        
        if let file = cameraViewModel.lastImageOrVideoVaultFile,
           let data = file.thumbnail {
            
            Button {

            } label: {
                UIImage.image(fromData:data).rounded()
                    .navigateTo(destination:getFileListView())
            }
            .navigateTo(destination:getFileListView())
        } else {
            Spacer()
        }
        
    }
    
    func getFileListView() -> some View {
        FileListView(appModel: mainAppModel,
                     rootFile: mainAppModel.vaultManager.root,
                     fileType: [.image, .video],
                     title: "Images and Videos")
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
                CameraTypeItemView(title: "Photo", width: 140, page: .image, selectedOption: $selectedOption)
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
                CameraTypeItemView(title: "Video", width: 140, page: .video, selectedOption: $selectedOption)
            })
        }
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
        
    }
}


struct CameraControlsView_Previews: PreviewProvider {
    static var previews: some View {
        CameraControlsView (showingCameraView:.constant(false),
                            sourceView: .tab) {
             
        } recordVideoAction: {
             
        } toggleCamera: {
             
        } updateCameraTypeAction: { value in
             
        } toggleFlash: { 
        } close: {}
    }
}


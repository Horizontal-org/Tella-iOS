//
//  Copyright © 2022 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct CameraView: View {
    
    @StateObject private var viewModel: CameraViewModel
    
    init(sourceView: SourceView,
         showingCameraView: Binding<Bool>,
         resultFile: Binding<[VaultFileDB]?>? = nil,
         mainAppModel: MainAppModel,
         rootFile: VaultFileDB? = nil) {
        
        _viewModel = StateObject(wrappedValue: CameraViewModel(mainAppModel: mainAppModel,
                                                               rootFile: rootFile,
                                                               resultFile: resultFile,
                                                               sourceView: sourceView,
                                                               showingCameraView: showingCameraView))
    }
    
    var body: some View {
        
        NavigationContainerView(backgroundColor: Styles.Colors.backgroundGrey1) {
            
            CameraControlsView(viewModel: viewModel)
            
        }.background(Styles.Colors.backgroundGrey1)
            .accentColor(.white)
            .navigationBarHidden(true)
            .onAppear {
                UIApplication.shared.topNavigationController()?.setNavigationBarHidden(true, animated: false)
                viewModel.configure()
            }
            .onDisappear {
                viewModel.stopRunningCaptureSession()
            }
            .onReceive(viewModel.$shouldShowToast) { shouldShowToast in
                if shouldShowToast {
                    Toast.displayToast(message: viewModel.errorMessage)
                    viewModel.shouldShowToast = false
                }
            }
            .overlay {
                if viewModel.shouldPresentProgressView {
                    progressView
                }
            }
            .alert(isPresented: $viewModel.shouldShowPermission) {
                getSettingsAlertView()
            }
    }
    
    private func getSettingsAlertView() -> Alert {
        Alert(title: Text(""),
              message: Text(LocalizableCamera.deniedCameraPermissionExpl1.localized.addTwolines
                            + LocalizableCamera.deniedCameraPermissionExpl2.localized.addline
                            + LocalizableCamera.deniedCameraPermissionExpl3.localized.numbered(1).addline
                            + LocalizableCamera.deniedCameraPermissionExpl4.localized.numbered(2).addline
                            + LocalizableCamera.deniedCameraPermissionExpl5.localized.numbered(3)),
              primaryButton: .default(Text(LocalizableCamera.deniedCameraPermissionActionCancel.localized), action: {
            viewModel.dismissCamera()
        }), secondaryButton: .default(Text(LocalizableCamera.deniedCameraPermissionActionSettings.localized), action: {
            UIApplication.shared.openSettings()
            viewModel.dismissCamera()
        }))
    }
    
    private var progressView: some View {
        DragView(isPresented: $viewModel.shouldPresentProgressView,
                 presentationType: .show,
                 backgroundColor: Styles.Colors.backgroundTab,
                 tapToDismiss: false) {
            ImportFilesProgressView(mainAppModel: viewModel.mainAppModel,
                                    progress: viewModel.progressFile,
                                    importFilesProgressProtocol: ImportFilesFromCameraProgress(),
                                    onImportFinished: {
                viewModel.shouldPresentProgressView = false
            })
        }
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView(sourceView: .tab,
                   showingCameraView: .constant(true),
                   mainAppModel: MainAppModel.stub())
    }
}

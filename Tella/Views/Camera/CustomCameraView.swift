//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI
import AVFoundation
 
struct CustomCameraPhotoView: View {
    @State private var image: Image?
    @State private var showingCustomCamera = false
    @State private var inputImage: UIImage?
    
    var body: some View {
        
        NavigationView {
            VStack {
                ZStack {
                    Rectangle().fill(Color.secondary)
                    
                    if image != nil
                    {
                        image?
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                    else
                    {
                        Text("Take Photo").foregroundColor(.white).font(.headline)
                    }
                }
                .onTapGesture {
                    self.showingCustomCamera = true
                }
            }
            .sheet(isPresented: $showingCustomCamera, onDismiss: loadImage) {
                CustomCameraView(image: self.$inputImage)
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
    }
}

struct CustomCameraView: View {
    
    @Binding var image: UIImage?
    @State var didTapCapture: Bool = false
    var body: some View {
        ZStack(alignment: .bottom) {
            Styles.Colors.backgroundMain.edgesIgnoringSafeArea(.all)
            CustomCameraRepresentable(image: self.$image, didTapCapture: $didTapCapture)
            CaptureButtonView().onTapGesture {
                self.didTapCapture = true
            }.padding(.bottom, 100)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct CustomCameraRepresentable: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    @Binding var didTapCapture: Bool
    
    func makeUIViewController(context: Context) -> CustomCameraController {
        let controller = CustomCameraController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ cameraViewController: CustomCameraController, context: Context) {
        
        if(self.didTapCapture) {
            cameraViewController.didTapRecord()
        }
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, AVCapturePhotoCaptureDelegate {
        let parent: CustomCameraRepresentable
        
        init(_ parent: CustomCameraRepresentable) {
            self.parent = parent
        }
        
        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            
            parent.didTapCapture = false
            
            if let imageData = photo.fileDataRepresentation() {
                parent.image = UIImage(data: imageData)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

class CustomCameraController: UIViewController {
    
    var image: UIImage?
    
    var captureSession = AVCaptureSession()
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var delegate: AVCapturePhotoCaptureDelegate?
    
    func didTapRecord() {
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: delegate!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        startRunningCaptureSession()
    }
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    func setupDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera],
          mediaType: AVMediaType.video,
          position: AVCaptureDevice.Position.unspecified)
        
        for device in deviceDiscoverySession.devices {
            switch device.position {
            case AVCaptureDevice.Position.front:
                self.frontCamera = device
            case AVCaptureDevice.Position.back:
                self.backCamera = device
            default:
                break
            }
        }
        self.currentCamera = self.backCamera
    }
    
    func setupInputOutput() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession.addInput(captureDeviceInput)
            photoOutput = AVCapturePhotoOutput()
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutput!)
            
        } catch {
            print(error)
        }
    }
    
    func setupPreviewLayer() {
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        self.cameraPreviewLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
        
    }
    func startRunningCaptureSession(){
        captureSession.startRunning()
    }
}


struct CaptureButtonView: View {
    @State private var animationAmount: CGFloat = 1
    var body: some View {
        Image(systemName: "video").font(.largeTitle)
            .padding(30)
            .background(Color.red)
            .foregroundColor(.white)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.red)
                    .scaleEffect(animationAmount)
                    .opacity(Double(2 - animationAmount))
                    .animation(Animation.easeOut(duration: 1)
                        .repeatForever(autoreverses: false))
        )
        .onAppear {
            self.animationAmount = 2
        }
    }
}

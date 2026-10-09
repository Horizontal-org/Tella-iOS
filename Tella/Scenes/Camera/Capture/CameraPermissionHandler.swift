//
//  CameraPermissionHandler.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 8/10/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import AVFoundation

enum CameraPermissionOutcome {
    case authorized
    case showSettings
    case close
}

enum CameraPermissionHandler {
    
    static func check(completion: @escaping (CameraPermissionOutcome) -> Void) {
        DispatchQueue.main.async {
            checkPermission(for: .video) { outcome in
                guard outcome == .authorized else {
                    completion(outcome)
                    return
                }
                checkPermission(for: .audio, completion: completion)
            }
        }
    }
    
    private static func checkPermission(
        for mediaType: AVMediaType,
        completion: @escaping (CameraPermissionOutcome) -> Void
    ) {
        switch AVCaptureDevice.authorizationStatus(for: mediaType) {
        case .denied, .restricted:
            completion(.showSettings)
            
        case .authorized:
            completion(.authorized)
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: mediaType) { granted in
                DispatchQueue.main.async {
                    completion(granted ? .authorized : .close)
                }
            }
            
        @unknown default:
            completion(.close)
        }
    }
}

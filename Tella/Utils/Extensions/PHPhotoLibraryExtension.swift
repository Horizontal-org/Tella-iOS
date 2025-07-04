//
//  PHPhotoLibraryExtension.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 19/6/2024.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Photos

extension PHPhotoLibrary {

    static func checkPhotoLibraryAuthorization() async -> PHAuthorizationStatus {
        let currentStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        if currentStatus == .notDetermined {
            // Request authorization
            let newStatus = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            return newStatus
        } else {
            return currentStatus
        }
    }
}

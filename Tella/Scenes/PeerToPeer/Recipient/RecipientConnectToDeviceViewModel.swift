//
//  RecipientConnectToDeviceViewModel.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 13/2/2025.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import Foundation

class RecipientConnectToDeviceViewModel: NSObject, ObservableObject {
    
    @Published var qrCodeInfos : QRCodeInfos

    override init() {
        self.qrCodeInfos = QRCodeInfos(ipAddress: "1.1.1.1", pin: "1234", hash: "1234")
    }
}


//
//  ConnectToDeviceManuallyViewModel.swift
//  Tella
//
//  Created by RIMA on 05.02.25.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import Foundation

class ConnectToDeviceManuallyViewModel: ObservableObject {
    
    @Published var ipAddress : String = ""
    @Published var pin: String = ""
    @Published var port: String = ""
    @Published var publicKey: String = ""
    @Published var valid : Bool = false
    @Published var validFields: Bool = false
}
